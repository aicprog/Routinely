//
//  RepeatTableViewController.swift
//
//
//  Created by Adriany Cocom on 8/5/19.
//
import UIKit
import RealmSwift

class RepeatTableViewController: UITableViewController {
    
    let realm = try! Realm()
    var weekDays: List<WeekDay>?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeWeekDays()

    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        
        return weekDays?.count ?? 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dayCell", for: indexPath)
        
        if let weekDays = weekDays{
            let weekDay = weekDays[indexPath.row]
            
            cell.textLabel?.textColor = weekDay.checked ? UIColor.black: UIColor.gray
            cell.textLabel?.text = weekDay.name
            cell.accessoryType = weekDay.checked ? .checkmark : .none
        }
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if let weekDays = weekDays{
            let weekDay = weekDays[indexPath.row]
            print(indexPath.row)
            
            do{
                try realm.write{
                    
                    weekDay.checked = !weekDay.checked
                }
            }catch{
                print("Error saving done status, \(error)")
            }
            
            tableView.reloadData()
        }
    }
    
    //MARK: - My Functions
    func createWeekDay(name: String, number: Int) -> WeekDay {
        let weekDay = WeekDay()
        weekDay.name = name
        weekDay.number = number
        return weekDay
        
    }
    
    func initializeWeekDays(){
        if let weekDays = weekDays{
            if weekDays.isEmpty{
                print("I am empty")
                do{
                    try realm.write {
                        weekDays.append(createWeekDay(name: "Monday", number: 2))
                        weekDays.append(createWeekDay(name: "Tuesday", number: 3))
                        weekDays.append(createWeekDay(name: "Wednesday", number: 4))
                        weekDays.append(createWeekDay(name: "Thursday", number: 5))
                        weekDays.append(createWeekDay(name: "Friday", number: 6))
                        weekDays.append(createWeekDay(name: "Saturday", number: 7))
                        weekDays.append(createWeekDay(name: "Sunday", number: 1))
                    }
                }
                catch{
                    print("There was a problem adding the days of the week")
                }
            }
        }
    }

    
}
