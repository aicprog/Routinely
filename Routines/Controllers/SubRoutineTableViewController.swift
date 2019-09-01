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
    
    override func viewWillAppear(_ animated: Bool) {
        updateSubRoutineCheckedList()
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        

    
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        addTxtField.resignFirstResponder()
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
                cell.nameTxtField.isHidden = true
                cell.nameLabel.isHidden = false
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
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        if let subRoutines = subRoutines{
            try! realm.write {
                let sourceObject = subRoutines[sourceIndexPath.row]
                let destinationObject = subRoutines[destinationIndexPath.row]
                
                let destinationObjectOrder = destinationObject.order
                
                if sourceIndexPath.row < destinationIndexPath.row {
                    
                    for index in sourceIndexPath.row...destinationIndexPath.row {
                        let object = subRoutines[index]
                        object.order -= 1
                    }
                } else {
                    
                    for index in (destinationIndexPath.row..<sourceIndexPath.row).reversed() {
                        let object = subRoutines[index]
                        object.order += 1
                    }
                }
                sourceObject.order = destinationObjectOrder
            }
        }
    }
    
    
    //MARK: - Data Manipulation
    
    func loadSubRoutines(){
        subRoutines = selectedRoutine?.subRoutines.sorted(byKeyPath: "order", ascending: true)
  
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
    
    //hides nameTxtField when keyboard resigns
    @objc func keyboardWillHide(_ notification: NSNotification){
        if let indexPath = tableView.indexPathForSelectedRow{
            let cell = tableView.cellForRow(at: indexPath) as! SubRoutineTableViewCell
            cell.nameTxtField.isHidden = true
            cell.nameLabel.isHidden = false
        }
        
    }
    //update checked list
    func updateSubRoutineCheckedList(){
        if let routine = selectedRoutine{
            if let baseDate = routine.baseDate{
                updateBaseDate(baseDate: baseDate, routine: routine)
            }
                // initialize baseDate
            else{
                do{
                    try self.realm.write {
                        routine.baseDate = getDate(from: Date())
                    }
                }
                catch{
                    print("There was an error updating routines \(error)")
                }
            }
        }
    }
    
    func getDate(from originalDate: Date) -> Date {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: originalDate)
        let date = Calendar.current.date(from: components)
        return date!
    }
    
    func updateBaseDate(baseDate: Date, routine: Routine){
        if baseDate != getDate(from: Date()){
            do{
                try self.realm.write {
                    for subRoutine in routine.subRoutines{
                        if subRoutine.completed{
                            subRoutine.completed = false
                            routine.numberOfCompletedSubRoutines -= 1
                        
                        }
                    }
                    
                }
            }
            catch{
                print("There was an error updating the subRoutines \(error)")
            }
        }
    }
    
    
    
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


