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

class RoutinesTableViewController: UITableViewController {
    
    //MARK: - My Variables
    
    let realm = try! Realm()
    var routines: Results<Routine>?
    // let cellSpacingHeight: CGFloat = 100
    //MARK: - IBoutlets
    
    
    @IBOutlet weak var addTxtField: UITextField!
    

    
    
    //MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        tableView.rowHeight = 105
        tableView.sectionHeaderHeight = CGFloat(200)
        
        //load text field
        initializeAddTxtFieldUI()
        
    
        
        //load items
        loadRoutines()
        testerItem()
    
        
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
        
        let backgroundImage = UIImage(named: "cellBackground3")
        let imageView = UIImageView(image: backgroundImage)
        imageView.contentMode = .scaleAspectFill
        self.tableView.backgroundView = imageView
        
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
            
            if let indexPath = tableView.indexPathForSelectedRow{
                destinationVC.selectedRoutine = routines?[indexPath.row]
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
        else if segue.identifier == "goToRoutineDetails"{
            let destinationVC = segue.destination as! DetailedRoutineViewController
            //print(tableView.indexPath(for: sender as! RoutineTableViewCell)!)
            if let indexPath = sender as? IndexPath{
                destinationVC.selectedRoutine = routines?[indexPath.row]
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }
    
    
    
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        performSegue(withIdentifier: "goToRoutineDetails", sender: indexPath)
        
    }
    

    
    func loadRoutines(){
        routines = realm.objects(Routine.self)
        tableView.reloadData()
        
    }
    
    func deleteRoutine(with indexPath: IndexPath) -> Bool {
        
        if let itemToBeDeleted = routines?[indexPath.row]{
            do{
                try realm.write {
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
                        realm.add(newRoutine)
                        //self.selectedRoutine?.numberOfTotalSubRoutines += 1
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
    
    func testerItem(){
        do{
            try self.realm.write {
                let newRoutine = Routine()
                newRoutine.name = "Tester"
                realm.add(newRoutine)
                //self.selectedRoutine?.numberOfTotalSubRoutines += 1
            }
        }
        catch{
            print("There was an error adding \(error)")
        }
        
        self.tableView.reloadData()
    }
}

