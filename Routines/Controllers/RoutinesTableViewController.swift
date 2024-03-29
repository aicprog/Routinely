//
//  RoutinesTableViewController.swift
//  Routines
//
//  Created by Adriany Cocom on 7/11/19.
//  Copyright © 2019 aic. All rights reserved.
//

import UIKit
import RealmSwift
import EventKit
import UserNotifications

//MARK: - My protocols
protocol WallpaperDelegate {
    func passBackBackgroundImage(image: UIImage) -> ()
}

class RoutinesTableViewController: UITableViewController, WallpaperDelegate {
    
    //MARK: - My Variables
    
    let realm = try! Realm()
    var routines: Results<Routine>?
    var activityIndicator = UIActivityIndicatorView()
    let defaultImageName = "icon0"
    let defaultBackgroundImage = UIImage(named: "background3")
    
    //MARK: - IBoutlets
    
    
    @IBOutlet weak var addTxtField: UITextField!
    
    @IBOutlet weak var wallpaperButton: UIBarButtonItem!
    
    //MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        tableView.rowHeight = 105
        tableView.sectionHeaderHeight = CGFloat(200)
        
        
        //For background image of cell
        if let image = defaultBackgroundImage{
            setBackgroundImage(image: image)
        }
        
     
        
        
        //load text field
        initializeAddTxtFieldUI()
        
        
        
        //load items
        loadRoutines()
        // testerItem()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
        
        //make sure RoutinelyImages Folder is intact
        createFolder()
        
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return routines?.count ?? 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "routineCell", for: indexPath) as! RoutineTableViewCell
        
        //update each cell
        if let routine = routines?[indexPath.row]{
            cell.routineName.text = "\(routine.name)"
            cell.numberOfSubRoutines.text = "\(routine.numberOfCompletedSubRoutines)/\(routine.numberOfTotalSubRoutines)"
            
            //To get Path of image associated with routine
            let img = UIImage(named:defaultImageName)
            if let selectedImagePartialPath = routine.partialImagePath{
                
                //print("I have an image")
                guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return cell}
                let selectedFileURL: URL = documentsDirectory.appendingPathComponent(selectedImagePartialPath)
                print("Get pic: \(selectedFileURL.absoluteString)")
                cell.routineImage.image = UIImage(contentsOfFile: selectedFileURL.path)
                
            }else if img != nil {
                cell.routineImage.image = img
            }
            
            if let startTime = routine.startTime{
                let dateFormatter = DateFormatter()
                dateFormatter.timeStyle = DateFormatter.Style.short
                cell.timeDifference.text = dateFormatter.string(from: startTime)
            }
            else{
                cell.timeDifference.text = ""
            }
            
            cell.goToDetails = {
                 self.performSegue(withIdentifier: "goToRoutineDetails", sender: indexPath)
            }
            
            
        }
        
        //test
        cell.contentView.backgroundColor = UIColor.clear
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "goToSubRoutines", sender: self)
    }
    
    //MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToSubRoutines"{
            let destinationVC = segue.destination as! SubRoutineTableViewController
            
            self.navigationItem.backBarButtonItem?.title = "Back"
            if let indexPath = tableView.indexPathForSelectedRow{
                destinationVC.selectedRoutine = routines?[indexPath.row]
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
        else if segue.identifier == "goToRoutineDetails"{
            let destinationVC = segue.destination as! DetailedRoutineViewController
            self.navigationItem.backBarButtonItem?.title = "Cancel"
            //print(tableView.indexPath(for: sender as! RoutineTableViewCell)!)
            if let indexPath = sender as? IndexPath{
                destinationVC.selectedRoutine = routines?[indexPath.row]
                tableView.deselectRow(at: indexPath, animated: true)
                
            }
            let popVC = destinationVC.popoverPresentationController
            popVC?.delegate = self
        }
        else if segue.identifier == "goToWallpapers"{
            let destinationVC = segue.destination as! BackgroundImageViewController
            destinationVC.delegate = self
                
        }
        
    }
    

    
    
    
    func loadRoutines(){
        routines = realm.objects(Routine.self)
        tableView.reloadData()
        
    }
    
    func deleteRoutine(with indexPath: IndexPath) -> Bool {
        
        if let itemToBeDeleted = routines?[indexPath.row]{
            do{
                try realm.write {
                    //delete all notifications
                    for day in itemToBeDeleted.weekDayNotifications{
                        if let path = day.notificationPath{
                            deleteNotification(with: path )
                        }
                    }
                    realm.delete(itemToBeDeleted)
                    tableView.reloadData()
                }
            }catch{
                print("There was an error deleting \(error)")
                return false
            }
        }
        return true
    }
    
    func createBaseDate(date: Date){
        
    }
    
    
    
    //MARK: SwipeToDelete Methods
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        guard let routine = routines?[indexPath.row] else {fatalError()}
        
        //create delete action
        let delete = UIContextualAction(style: .destructive, title: "Delete") { (action, view, actionPerformed) in
            
            //create alert action
            let alertController = UIAlertController(title: "Delete Routine", message: "Are you sure you want to delete this \(routine.name) routine?", preferredStyle: .alert)
            //create action
            let alertCancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                actionPerformed(false)
            }
            let alertDeleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
                actionPerformed(self.deleteRoutine(with: indexPath))
            }
            
            alertController.addAction(alertCancelAction)
            alertController.addAction(alertDeleteAction)
            
            self.present(alertController, animated: true, completion: nil)
            
        }
        delete.image =  UIImage(named: "remove")
        
        return UISwipeActionsConfiguration(actions: [delete])
        
    }
    
    
    //MARK: - My functions
    
    func initializeAddTxtFieldUI(){
        
        //Make RoutineTableViewController our delegate
        addTxtField.delegate = self
        addTxtField.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        
        //set padding of TextField
        setLeftPaddingPoints(10)
        
        //custom placeholder for txt field
        var placeHolder = NSMutableAttributedString()
        let name  = "  + Add New Item"
        
        // Set the Font
        placeHolder = NSMutableAttributedString(string: name, attributes: [NSAttributedString.Key.font:UIFont(name: "Helvetica", size: 15.0)!])
        
        // Set the color
        placeHolder.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.darkGray, range:NSRange(location:0,length:name.count))
        
        // Add attribute
        addTxtField.attributedPlaceholder = placeHolder
    }
    
    //MARK: Functions for saving images
    func createFolder(){
        
        do{
            let folderName = "RoutinelyImages"
            let fileManager = FileManager.default
            let docsUrl = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let myFolder = docsUrl.appendingPathComponent(folderName)
            try fileManager.createDirectory(at: myFolder, withIntermediateDirectories: true)
            
            print(myFolder.absoluteString)
        }
        catch{
            print("Folder could not save")
        }
    }
    
    func setBackgroundImage(image: UIImage){
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        self.tableView.backgroundView = imageView
    }
    
    //MARK: - Conforming to backgroundImageProtocol
    func passBackBackgroundImage(image: UIImage) {
        setBackgroundImage(image: image)
    }
    
    func deleteNotification(with notificationIdentifier: String){
        print("Identifier to be deleted: \(notificationIdentifier)")
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationIdentifier])
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        
        
    }
    
    
}


//MARK: - UITextField Extension
extension RoutinesTableViewController: UITextFieldDelegate{
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        addItem()
        return true
    }
    
    func addItem(){
        if let name = addTxtField?.text{
            if !name.trimmingCharacters(in: .whitespaces).isEmpty{
                do{
                    try self.realm.write {
                        let newRoutine = Routine()
                        newRoutine.name = name
                        newRoutine.partialImagePath = nil
                        realm.add(newRoutine)
                
                        addTxtField.text = ""
                    }
                }
                catch{
                    print("There was an error adding \(error)")
                }
                
                self.tableView.reloadData()
                
            }
        }
    }
    
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: addTxtField.frame.size.height))
        addTxtField.leftView = paddingView
        addTxtField.leftViewMode = .always
    }
    
    
}

//MARK: - UIPopOver Extension
extension RoutinesTableViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.fullScreen
    }
    
    func presentationController(_ controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        return UINavigationController(rootViewController: controller.presentedViewController)
    }
}


