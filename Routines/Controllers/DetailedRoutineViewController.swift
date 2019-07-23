//
//  DetailedRoutineViewController.swift
//  Routines
//
//  Created by Adriany Cocom on 7/22/19.
//  Copyright © 2019 aic. All rights reserved.
//

import UIKit
import RealmSwift
import EventKit

class DetailedRoutineViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - My variables
    var startPickerVisible = false
    var endPickerVisible = false
    let realm = try! Realm()
    let data = [["Remind Me: ","Start Time", "End Time"]]
    var eventStore: EKEventStore?
    var event: EKEvent?
    //  var selectedRoutineName = "New Routine"
    //   var selectedRoutineSubRoutines = 0
    
    var selectedRoutine: Routine? {
        didSet{
            self.title = "Edit Routine"
            
        }
        
    }
    //variables for datePicker
    var startTime = Date()
    var endTime = Date()
    var reminderOn = false
    var userChoosingDate = false
    //MARK: - IB Outlet
    
    //MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var routineName: UITextField!
    @IBOutlet weak var needPermissionView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let routine = selectedRoutine{
            routineName?.text = routine.name
            reminderOn = routine.reminderSet
            
        }
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        //For Calendar
        addRoutinelyCalendar()
        
        // Do any additional setup after loading the view.
    }
    
    //MARK: - TableView Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //tableView cell is of type SwitchToggle
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchToggleCell", for: indexPath) as! SwitchTogglerTableViewCell
            
            //if previous settings
            
            if reminderOn{
                cell.remindMeSwitch.isOn = reminderOn
            }
            
            cell.routineName.text = data[indexPath.section][indexPath.row]
            
            //action if switch is toggled
            cell.switchToggled = {
                self.reminderOn = !self.reminderOn
                tableView.reloadData()
            }
            return cell
        }
            //tableView is of type DatePickerTableViewCell
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "DatePickerCell", for: indexPath) as! DatePickerTableViewCell
            
            
            //Only show cells if switch is on
            if reminderOn{
                cell.isHidden = false
                
                //update subtitle based on datePicker or previous reminder
                if let routine = selectedRoutine {
                    //if cell is startDate
                    if indexPath.row == 1{
                        startTime = cell.datePicker.date
                        startTime = userChoosingDate ? cell.datePicker.date: routine.startTime ?? Date()
                        updateStartCell(with: cell)
                        //if cell is endDate
                    }else if indexPath.row == 2{
                        endTime = cell.datePicker.date
                        endTime = userChoosingDate ? cell.datePicker.date: routine.endTime ?? Date()
                        updateEndCell(with: cell)
                    }
                }
                //else hide cells if user chooses not to have a reminder
            } else{
                cell.isHidden = true
            }
            
            //action for datepicker
            cell.doneInputting = {
                let strDate = self.dateFormatter(with: cell.datePicker.date)
                self.userChoosingDate = true
                cell.subtitle.text = strDate
                tableView.reloadData()
                
                
            }
            cell.title.text = data[indexPath.section][indexPath.row]
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            toggleStartDatePicker()
            //print(startPickerVisible)
        }
        else if indexPath.row == 2 {
            toggleEndDatePicker()
            //print(endPickerVisible)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if startPickerVisible && indexPath.row == 1{
            return 180
            
        } else if endPickerVisible && indexPath.row == 2{
            return 180
            
        } else{
            return 44
        }
        
    }
    
    //MARK: - IB Actions
    
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        
        guard let routine = selectedRoutine else {fatalError()}
        
        var succcesful = false
        
        do{
            try realm.write {
                if reminderOn{
                    routine.startTime = startTime
                    print("Start Time: \(startTime)")
                    
                    routine.endTime = endTime
                    print("End Time: \(endTime)")
                    routine.reminderSet = true
                    succcesful = true
                }
                else{
                    routine.startTime = nil
                    routine.endTime = nil
                    routine.reminderSet = false
                    
                }
            }
            
        }
        catch{
            print("There was an error adding \(error)")
        }
        
        
        if succcesful{
            createCalendarEvent(with: startTime, with: endTime, routineName: routine.name, routineSubRoutineCount: routine.numberOfTotalSubRoutines)
            
            do{
                try realm.write {
                    routine.calendarEventOn = true
                }
            }
            catch{
                print("There was an error updating calendarEventOn")
            }
        }
        else{
            do{
                try eventStore!.remove(event!, span: .futureEvents)
            }catch{
                print("There was an error removing the event")
            }
        }
        navigationController?.popViewController(animated: true)
        //tableView.reloadData()
    }
    
    @IBAction func cancelBtnPressed(_ sender: UIButton) {
        self.dismiss(animated: true) {
            print("I am dismissed")
        }
    }
    
    
    
    //MARK: - Calendar Methods
    func addRoutinelyCalendar() {
        
        let status = EKEventStore.authorizationStatus(for: EKEntityType.event)
        
        switch (status) {
        case EKAuthorizationStatus.notDetermined:
            EKEventStore().requestAccess(to: .event, completion: { (granted, error) in
                if (error != nil) {
                    print("There was an error asking for your request")
                }
                else if granted {
                    let _ = self.createCalendarWithICloud()
                }
                else{
                    
                    self.addRoutinelyCalendar()
                }
            })
        case EKAuthorizationStatus.authorized:
            let _ = createCalendarWithICloud()
            
        case EKAuthorizationStatus.restricted, EKAuthorizationStatus.denied:
            // We need to help them give us permission
            DispatchQueue.main.async {
                self.needPermissionView.fadeIn()
            }
        //print("Ask for permission")
        @unknown default:
            print("There was an error.")
        }
        
        
    }
    
    //Clean code later so that you don't have teh first if
    func createCalendarWithICloud(){
        
        let eventStore = EKEventStore()
        let uniqueIdentifier = UserDefaults.standard.string(forKey: "RoutinelyEventTrackerCalendar")
        
        if eventStore.calendars(for: .event).first(where: { $0.calendarIdentifier == uniqueIdentifier }) != nil{
            
            print("Calendar already made")
            
        } else{
            
            //var routinelyCalendar: EKCalendar?
            let routinelyCalendar = EKCalendar(for: .event, eventStore: eventStore)
            
            routinelyCalendar.title = "Routinely Calendar"
            let sourcesInEventStore = eventStore.defaultCalendarForNewEvents
            
            if let src = sourcesInEventStore?.source{
                routinelyCalendar.source = src
                
                // Save the calendar using the Event Store instance
                do {
                    
                    try eventStore.saveCalendar(routinelyCalendar, commit: true)
                    UserDefaults.standard.set(routinelyCalendar.calendarIdentifier, forKey: "RoutinelyEventTrackerCalendar")
                    print("Calendar Made")
                } catch {
                    let alert = UIAlertController(title: "Calendar could not save", message: (error as NSError).localizedDescription, preferredStyle: .alert)
                    let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(OKAction)
                    
                    self.present(alert, animated: true, completion: nil)
                    
                }
                
                
            }
            
        }
        
    }
    
    @IBAction func goToSettingsBtnTapped(_ sender: UIButton) {
        
        if let url = URL(string:UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        
        
    }
    
    
    //MARK: - My Functions
    
    func toggleStartDatePicker () {
        startPickerVisible = !startPickerVisible
        tableView.reloadData()
    }
    
    func toggleEndDatePicker () {
        endPickerVisible = !endPickerVisible
        tableView.reloadData()
    }
    
    func dateFormatter(with date: Date) -> String{
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = DateFormatter.Style.short
        dateFormatter.timeStyle = DateFormatter.Style.short
        
        return dateFormatter.string(from: date)
    }
    
    func updateStartCell(with cell: DatePickerTableViewCell) {
        cell.datePicker.date = startTime
        cell.subtitle.text = dateFormatter(with: startTime)
    }
    func updateEndCell(with cell: DatePickerTableViewCell) {
        cell.datePicker.date = endTime
        cell.subtitle.text = dateFormatter(with: endTime)
    }
    
    
    //MARK: - Calendar Event
    //Create Calendar Event from data of DatePicker
    func createCalendarEvent(with startDate: Date, with endDate: Date, routineName: String, routineSubRoutineCount: Int) {
        //if let routine = selectedRoutine{
        eventStore = EKEventStore()
        
        eventStore!.requestAccess(to: .event, completion: { (granted, error) in
            if error == nil{
                
                self.event = EKEvent(eventStore: self.eventStore!)
                self.event!.title = routineName
                self.event!.startDate = startDate
                self.event!.endDate = endDate
                self.event!.notes = "This routine has \(routineSubRoutineCount) items"
                self.event!.calendar = self.eventStore?.defaultCalendarForNewEvents
                
                //try to add Calendar event
                do{
                    try self.eventStore!.save(self.event!, span: .thisEvent)
                }catch let error as NSError{
                    print("There was an error saving the event: \(error)")
                }
                
                print("saved Event")
            }
            else{
                print("There was an error creating this event ")
            }
        })
        
        // }
        
    }
    
    
    
    
}
