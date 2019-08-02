//
//  SubRoutineTableViewController.swift
//  
//
//  Created by Adriany Cocom on 7/12/19.
//

import UIKit
import RealmSwift

class SubRoutineTableViewController: UITableViewController {
    
    
    let realm = try! Realm()
    var selectedRoutine: Routine?{
        didSet{
            //print("SelectedRoutine Passed")
            self.title = self.selectedRoutine!.name
            loadSubRoutines()
        }
    }
    var subRoutines: Results<SubRoutine>?{
        didSet{
            //updateSectionData()
        }
    }
    
    //MARK: IB Outlets
    @IBOutlet weak var addTxtField: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Use the edit button item provided by the table view controller.
        navigationItem.rightBarButtonItem = editButtonItem
        initializeAddTxtFieldUI()
        
        
    }
    
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // #warning Incomplete implementation, return the number of rows
        
        
        return subRoutines?.count ?? 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "subRoutineCell", for: indexPath) as! SubRoutineTableViewCell
        
        if let subRoutine = subRoutines?[indexPath.row], let routine = selectedRoutine{
            
            let attributedString = NSMutableAttributedString(string: subRoutine.name)
            attributedString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributedString.length))
            
            cell.nameLabel.attributedText = subRoutine.completed ? attributedString: NSMutableAttributedString(string: subRoutine.name)
            cell.nameLabel.textColor = subRoutine.completed ? UIColor.gray: UIColor.black
            cell.checkImage.image = subRoutine.completed ? UIImage(named: "checked"): UIImage(named: "unchecked")
            
            
            //update completed tasks
            cell.chkButton = {
                do{
                    try self.realm.write{
                        subRoutine.completed = !subRoutine.completed
                        
                        //update # of completed tasks
                        guard let allSubRoutines = self.subRoutines else {fatalError()}
                        routine.numberOfCompletedSubRoutines = allSubRoutines.filter("completed == %@", true).count
                    }
                }catch{
                    print("Error saving done status, \(error)")
                }
                
                tableView.reloadData()
            }
            
            //update nameTxtLabel when user wants to change name
            cell.doneInputting = {
                cell.nameTxtField.resignFirstResponder()
                cell.nameTxtField.isHidden = true
                cell.nameLabel.isHidden = false
                let name = cell.nameTxtField.text ?? "New Item"
                
                let attributedString = NSMutableAttributedString(string: name)
                attributedString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributedString.length))
                
                cell.nameLabel.text = cell.nameTxtField.text
                cell.nameLabel.attributedText = subRoutine.completed ? attributedString: NSMutableAttributedString(string: name)
                
                do{
                    try self.realm.write {
                        subRoutine.name = name
                       // tableView.reloadData()
                    }
                }catch{
                    print("There was an error deleting \(error)")
                    
                }
            }
        }
        
        return cell
    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //deselect
        //tableView.deselectRow(at: indexPath, animated: false)
        let cell = tableView.cellForRow(at: indexPath) as! SubRoutineTableViewCell
        cell.nameLabel.isHidden = true
        cell.nameTxtField.isHidden = false
        cell.nameTxtField.isUserInteractionEnabled = true
        cell.nameTxtField.text = cell.nameLabel.text
        
        //cell.nameTxtField.end
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let _ = deleteSubRoutine(with: indexPath)
        
        
    }
    
    
    //MARK: - Data Manipulation
    
    func loadSubRoutines(){
        subRoutines = selectedRoutine?.subRoutines.sorted(byKeyPath: "name", ascending: true)
        tableView.reloadData()
        
    }
    
    func deleteSubRoutine(with indexPath: IndexPath) -> Bool {
        
        if let itemToBeDeleted = subRoutines?[indexPath.row]{
            do{
                try realm.write {
                    selectedRoutine?.numberOfTotalSubRoutines -= 1
                    if itemToBeDeleted.completed{
                        selectedRoutine?.numberOfCompletedSubRoutines -= 1
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

    //MARK: - IBActions
    @IBAction func checkButtonPressed(_ sender: UIButton) {
        
        if let indexPath = tableView.indexPathForSelectedRow{
            guard let subRoutine = subRoutines?[indexPath.row] else {fatalError()}
            guard let routine = selectedRoutine else {fatalError()}
            do{
                try realm.write{
                    print("I work")
                    subRoutine.completed = !subRoutine.completed
                    
                    //update # of completed tasks
                    guard let allSubRoutines = subRoutines else {fatalError()}
                    routine.numberOfCompletedSubRoutines = allSubRoutines.filter("completed == %@", true).count
                    tableView.reloadData()
                }
            }catch{
                print("Error saving done status, \(error)")
            }
            
        }
        
        
        
    }
    
    //MARK: - My Functions
    func initializeAddTxtFieldUI(){
        
        addTxtField.delegate = self
        addTxtField.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
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
    
    
    //    func textFieldDidEndEditing(_ textField: UITextField) {
    //        resignFirstResponder()
    //
    //        if let indexPath = tableView.indexPathForSelectedRow{
    //            let cell = tableView.cellForRow(at: indexPath) as! SubRoutineTableViewCell
    //            cell.nameTxtField.isHidden = true
    //            cell.nameLabel.isHidden = false
    //
    //
    //            let name = cell.nameTxtField.text ?? "New Item"
    //
    //            let attributedString = NSMutableAttributedString(string: name)
    //            attributedString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributedString.length))
    //
    //            cell.nameLabel.text = cell.nameTxtField.text
    //            // cell.nameLabel.attributedText = subRoutine.completed ? attributedString: NSMutableAttributedString(string: name)
    //    }
    
}

//MARK: - UITextField Extension
extension SubRoutineTableViewController: UITextFieldDelegate{
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
                        let newSubRoutine = SubRoutine()
                        newSubRoutine.name = name
                        self.selectedRoutine?.subRoutines.append(newSubRoutine)
                        self.selectedRoutine?.numberOfTotalSubRoutines += 1
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

////MARK: - Search Bar Methods
//extension SubRoutineTableViewController: UISearchBarDelegate{
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//
//
//
//        //add predicate
//        if let searchedText = searchBar.text {
//            //let filteredPredicate = NSPredicate(format: "name CONTAINS[cd] %@", searchedText)
//            //add formatting
//            //toDoItems = toDoItems?.filter(filteredPredicate).sorted(byKeyPath: "name", ascending: true)
//
//            subRoutines = subRoutines?.filter("name CONTAINS[cd] %@", searchedText).sorted(byKeyPath: "name", ascending: true)
//            tableView.reloadData()
//
//        }
//
//        //try fetch
//
//    }
//
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        if searchBar.text?.count == 0{
//            //Since it has no predicate, then loadData()'s predicate will only have categoryPredicate
//            loadSubRoutines()
//
//            //Since it is the userInterface, make sure it is a prioirity while loadData() happens in the background
//            DispatchQueue.main.async {
//                searchBar.resignFirstResponder()
//            }
//
//        }
//
//
//    }
//
//}

