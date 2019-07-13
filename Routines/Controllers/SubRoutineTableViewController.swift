//
//  SubRoutineTableViewController.swift
//  
//
//  Created by Adriany Cocom on 7/12/19.
//

import UIKit
import RealmSwift

class SubRoutineTableViewController: UITableViewController {
    
    var selectedRoutine: Routine?
    var subRoutines: Results<SubRoutine>?

    override func viewDidLoad() {
        super.viewDidLoad()

 
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return subRoutines?.count ?? 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "subRoutineCell", for: indexPath)

        // Configure the cell...

        return cell
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

    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
