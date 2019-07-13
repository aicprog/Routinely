//
//  RoutinesTableViewController.swift
//  Routines
//
//  Created by Adriany Cocom on 7/11/19.
//  Copyright © 2019 aic. All rights reserved.
//

import UIKit
import RealmSwift

class RoutinesTableViewController: UITableViewController {
    
    //MARK: - My Variables
    
    let realm = try! Realm()
    var routines: Results<Routine>?
    // let cellSpacingHeight: CGFloat = 100
    //MARK: - IBoutlets
    
    
    
    
    //MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        tableView.rowHeight = 100
        tableView.sectionHeaderHeight = CGFloat(200)
        loadRoutines()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
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
        
        
        
        if let routine = routines?[indexPath.row]{
            cell.routineName.text = routine.name
        }
        
        
        //test
        cell.contentView.backgroundColor = UIColor.clear
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "goToSubRoutine", sender: self)
    }
    
    //MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! SubRoutineTableViewController
        
        if let indexPath = tableView.indexPathForSelectedRow{
            destinationVC.selectedRoutine = routines?[indexPath.row]
            
        }
        
    }
    
    //MARK: - IBActions
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var txtField: UITextField?
        //add New Alert Controller
        let alertController = UIAlertController(title: "Add New Routine", message: "", preferredStyle: .alert)
        //add New Alert Action
        let alertAction = UIAlertAction(title: "Add", style: .default) { (alert) in
            //create new Item
            
            if let name = txtField?.text{
                if !name.trimmingCharacters(in: .whitespaces).isEmpty{
                    let newRoutine = Routine()
                    newRoutine.name = txtField?.text ?? "New Routine"
                    self.save(add: newRoutine)
                    
                    
                }
            }
            
            
        }
        //add textField
        alertController.addTextField { (alertTextField) in
            alertTextField.placeholder = "Enter New Routine"
            txtField = alertTextField
        }
        //show alert Controller
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
        
        
    }
    
    //MARK: - Realm Manipulation Methods
    func save(add routine: Routine){
        do{
            try realm.write {
                realm.add(routine)
            }
        }
        catch{
            print("There was an error adding \(error)")
        }
        tableView.reloadData()
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
            let alertController = UIAlertController(title: "Delete Routine", message: "Are you sure you want to delete this routine: \(routine.name)?", preferredStyle: .alert)
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
    
    
}
