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
            
        }
        tableView.reloadData()
    }
    
    func loadRoutines(){
        routines = realm.objects(Routine.self)
        tableView.reloadData()
        
    }
    
    
}
