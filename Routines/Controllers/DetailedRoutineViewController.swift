//
//  DetailedRoutineViewController.swift
//  Routines
//
//  Created by Adriany Cocom on 7/22/19.
//  Copyright © 2019 aic. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class DetailedRoutineViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    //MARK: - Variables for Table View Controller
    var startPickerVisible = false
    var endPickerVisible = false
    let realm = try! Realm()
    let data = [["Remind Me: ","Start Time", "End Time"]]
    var selectedRoutine: Routine?
    
    
    //MARK: Variables for datePicker
    var startTime = Date()
    var endTime = Date()
    var reminderOn = false
    var userChoosingDate = false
    
    //MARK: Variables for setting up icons
    var pickerController = UIImagePickerController()
    var selectedImage: UIImage?
 //   var selectedIndex: Int?
    var icons: [UIImage] = [
        UIImage(named: "icon1")!,
        UIImage(named: "icon2")!,
        UIImage(named: "icon3")!,
        UIImage(named: "icon4")!,
        UIImage(named: "icon5")!,
        UIImage(named: "icon6")!,
        UIImage(named: "icon7")!,
        UIImage(named: "icon8")!,
        UIImage(named: "icon9")!,
        UIImage(named: "icon10")!,
        UIImage(named: "icon11")!,
        UIImage(named: "icon12")!,
        UIImage(named: "icon13")!,
        UIImage(named: "icon14")!,
        UIImage(named: "icon15")!,
        UIImage(named: "icon16")!,
        UIImage(named: "icon17")!,
        UIImage(named: "icon18")!,
        UIImage(named: "icon19")!,
        UIImage(named: "icon20")!,
        UIImage(named: "icon21")!,
        UIImage(named: "icon23")!,
        UIImage(named: "icon24")!,
        UIImage(named: "icon25")!
    ]
    
    //MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var routineName: UITextField!
    @IBOutlet weak var needPermissionView: UIView!

    @IBOutlet weak var selectedImageView: UIImageView!
    
    @IBOutlet weak var libraryImageButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 40
        
        if let routine = selectedRoutine{
            routineName?.text = routine.name
            reminderOn = routine.reminderSet
   
        }
        
        //For tableView
        tableView.delegate = self
        tableView.dataSource = self
        UNUserNotificationCenter.current().delegate = self
        
        //initialize UI TextField
        initializeRoutineNameTxtField()
        
        
        //set pickerController delegate
         pickerController.delegate = self
        
        //initialize roundness property for library image Button
        libraryImageButton.layer.cornerRadius = libraryImageButton.frame.size.width / 3;
        libraryImageButton.clipsToBounds = true
        libraryImageButton.alpha = 0.9
        
          //initialize roundness property for selected image view
        selectedImageView.layer.cornerRadius = selectedImageView.frame.size.width / 4;
        selectedImageView.clipsToBounds = true
        selectedImageView.alpha = 0.9
        
        
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //For Calendar
        askUserForPermission()
        print("I work")
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
            return 125
            
        } else if endPickerVisible && indexPath.row == 2{
            return 125
            
        } else{
            return 44
        }
        
    }
    
    //MARK: - IB Actions
    
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        
        guard let routine = selectedRoutine else {fatalError()}
        
        //var succcesful = false
        
        do{
            try realm.write {
                //updates for reminders and notifications
                if reminderOn{
                    routine.startTime = startTime
                    print("Start Time: \(startTime)")
                    
                    routine.endTime = endTime
                    print("End Time: \(endTime)")
                    routine.reminderSet = true
                    routine.notificationIdentifier = createNotification(with: startTime)
    
                }
                else{
                    routine.startTime = nil
                    routine.endTime = nil
                    routine.reminderSet = false
                    
                }
                //updates for selectedImage
                if let image = selectedImage {
                    routine.partialImagePath = saveImage(previousPartialPath:routine.partialImagePath, image: image)
                    print(routine.partialImagePath!)
                }
            }
           
            
        }
        catch{
            print("There was an error adding \(error)")
        }
         self.dismiss(animated: true)
        
    }
    
    @IBAction func cancelBtnPressed(_ sender: UIButton) {
        self.dismiss(animated: true) {
            print("I am dismissed")
        }
    }
    
    @IBAction func goToSettingsBtnTapped(_ sender: UIButton) {
        
        self.dismiss(animated: true)
        
        if let url = URL(string:UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    
        
        
    }
    
    @IBAction func cameraButtonTapped(_ sender: UIButton) {
        pickerController.sourceType = .photoLibrary
        present(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func photoButtonTapped(_ sender: UIButton) {
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
    
    func initializeRoutineNameTxtField(){
        
        routineName.delegate = self
        routineName.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        setLeftPaddingPoints(10)
        
        
        
        //custom placeholder for txt field
        var placeHolder = NSMutableAttributedString()
        let name  = "  + Enter Routine Name"
        
        // Set the Font
        placeHolder = NSMutableAttributedString(string: name, attributes: [NSAttributedString.Key.font:UIFont(name: "Helvetica", size: 15.0)!])
        
        // Set the color
        placeHolder.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.darkGray, range:NSRange(location:0,length:name.count))
        
        // Add attribute
        routineName.attributedPlaceholder = placeHolder
    }
    
    

    
    //MARK: - For Notifications
    func askUserForPermission(){
        
        let center = UNUserNotificationCenter.current()
        
        
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted && error == nil{
                print("Authorization Granted")
            }
            else{
                DispatchQueue.main.async {
                    self.needPermissionView.fadeIn()
                }
            }
        }
    }
    
    func createNotification(with startDate: Date) -> String {
        
        guard let routine = selectedRoutine else {fatalError()}
        
        let content = UNMutableNotificationContent()
        content.title = routine.name
        content.body = "Every Tuesday at \(startDate)"
        content.sound = UNNotificationSound.default
        
        
        let unitFlags: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]
        let startComponents = NSCalendar.current.dateComponents(unitFlags, from: startDate.addingTimeInterval(20))
        print(startComponents)
        
        
        // Create the trigger as a repeating event.
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: startComponents, repeats: false)
        
        
        // Create the request
        var uniqueIdentifier = ""
        if let identifierString = routine.notificationIdentifier{
            uniqueIdentifier = identifierString
        }
        else{
            uniqueIdentifier = UUID().uuidString
        }
        let request = UNNotificationRequest(identifier: uniqueIdentifier,
                                            content: content, trigger: trigger)
        
        // Schedule the request with the system.
        let notificationCenter = UNUserNotificationCenter.current()
        
        notificationCenter.add(request) { (error) in
            if error != nil {
                print("There was an error adding the notification")
            }else{
                print("Notification Added")
            }
        }
        print(uniqueIdentifier)
        return uniqueIdentifier
    }
    //MARK: - Functions for saving images
    
    func saveImage(previousPartialPath: String?, image: UIImage) -> String? {
        
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil}
        
        if let oldPartialPath = previousPartialPath {
            
            //for old image path
            let oldFileURL: URL = documentsDirectory.appendingPathComponent(oldPartialPath)
            print("Previous \(oldFileURL.absoluteString)")
            
            //Checks if file exists, removes it if so.
            if FileManager.default.fileExists(atPath: oldFileURL.path) {
                do {
                    try FileManager.default.removeItem(atPath: oldFileURL.path)
                    print("Removed old image")
                } catch let removeError {
                    print("couldn't remove file at path", removeError)
                }
                
            }
        }

        //for new image Path
        let uniqueIdentifier = UUID().uuidString
        let partialPath = "RoutinelyImages/icon\(uniqueIdentifier)"
        let newFileURL = documentsDirectory.appendingPathComponent(partialPath)
        guard let data = image.pngData() else {return nil}
        //    .jpegData(compressionQuality: 1) else { return nil}
        
        print("New: \(newFileURL.absoluteString)")
        
        do {
            try data.write(to: newFileURL)
        } catch let error {
            print("error saving file with error", error)
        }
        
//        if let routine = selectedRoutine{
//            do{
//                try realm.write {
//                    routine.partialImagePath = partialPath
//                }
//            }
//            catch{
//
//            }
//        }
        
        return partialPath
        
    }

    
}
// MARK: - UNUserNotificationCenter Extension Methods
extension DetailedRoutineViewController: UNUserNotificationCenterDelegate{
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if let identifier = selectedRoutine?.notificationIdentifier{
            if response.notification.request.identifier == identifier{
                
            }
        }
    }
    
    
}
//MARK: - TextField Extension Methods
extension DetailedRoutineViewController : UITextFieldDelegate{
    

    
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: routineName.frame.size.height))
        routineName.leftView = paddingView
        routineName.leftViewMode = .always
    }
    
}

//MARK: - UICollectionView Extension
extension DetailedRoutineViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return icons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "iconCell", for: indexPath) as! IconCollectionViewCell
        
        cell.iconImage.image = icons[indexPath.item]
        

        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
        print(indexPath.item)
        let image = icons[indexPath.item]
        //update selected image
        selectedImageView.image = image
        selectedImage = image
        
       // collectionView.reloadData()
        
        //libraryImageButton.setImage(icons[indexPath.item], for: .normal)
    }
    
    
}

//MARK: - Extension for UIImagePickerControllerDelegate
extension DetailedRoutineViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.originalImage] as? UIImage {
            //libraryImageButton.setImage(image, for: .normal)
            selectedImageView.image = image
            selectedImage = image
        
        pickerController.dismiss(animated: true, completion: nil)
    }
    
        //guard let fileUrl = info[UIImagePickerController.InfoKey.imageURL] as? URL else { return }
        // print(fileUrl.lastPathComponent) // get file Name
        //print(fileUrl.pathExtension)     // get file extension
        
        // selectedImageName = fileUrl.lastPathComponent
    
}






//create a new reminder set



//MARK: - Extra
//func createRoutinelyReminderSet(){
//
//
//
//    let eventStore = EKEventStore()
//
//    let uniqueIdentifier = UserDefaults.standard.string(forKey: keyForRoutinelyCalendar)
//
//    if let _ = eventStore.calendars(for: .reminder).first(where: { $0.calendarIdentifier == uniqueIdentifier }){
//        print("List already made")
//
//    } else{
//
//        //var routinelyCalendar: EKCalendar?
//        let routinelyCalendar = EKCalendar(for: .reminder, eventStore: eventStore)
//
//        routinelyCalendar.title = "Routinely"
//        let sourcesInEventStore = eventStore.defaultCalendarForNewReminders()
//
//        if let src = sourcesInEventStore?.source{
//            routinelyCalendar.source = src
//
//            // Save the calendar using the Event Store instance
//            do {
//
//                try eventStore.saveCalendar(routinelyCalendar, commit: true)
//                UserDefaults.standard.set(routinelyCalendar.calendarIdentifier, forKey: keyForRoutinelyCalendar)
//                print("Reminder List Just Made")
//            } catch {
//                let alert = UIAlertController(title: "Reminder List could not save", message: (error as NSError).localizedDescription, preferredStyle: .alert)
//                let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//                alert.addAction(OKAction)
//
//                self.present(alert, animated: true, completion: nil)
//
//            }
//
//
//        }
//
//    }
//
//}
//
////create a new reminder event
//
//func createReminderEvent(with startDate: Date, with endDate: Date, routineName: String, routineSubRoutineCount: Int){
//
//    let eventStore = EKEventStore()
//
//    let uniqueIdentifier = UserDefaults.standard.string(forKey: keyForRoutinelyCalendar)
//    //if cal.title == "Calendarname" { calUid = cal.calendarIdentifier }
//
//
//
//    if let routinelyCalendar = eventStore.calendars(for: .reminder).first(where:{ $0.calendarIdentifier == uniqueIdentifier }){
//
//
//
//        let reminder = EKReminder(eventStore: eventStore)
//        reminder.title = routineName
//        reminder.calendar = routinelyCalendar
//
//
//        let unitFlags: Set<Calendar.Component> = [.hour, .day, .month, .year]
//        let startComponents = NSCalendar.current.dateComponents(unitFlags, from: startDate)
//        reminder.startDateComponents = startComponents
//
//
//        reminder.addAlarm(EKAlarm(absoluteDate: startDate))
//        //reminder.addAlarm(EKAlarm(absoluteDate: endDate))
//
//        do {
//            try eventStore.save(reminder, commit: true)
//            print("Reminder Added")
//        } catch let error {
//            print("Reminder failed with error \(error.localizedDescription)")
//        }
//    }
//}
////fetch reminder
//
//func checkForReminder(reminderName: String, startDate: Date) -> Bool {
//    let eventStore = EKEventStore()
//
//
//    let uniqueIdentifier = UserDefaults.standard.string(forKey: keyForRoutinelyCalendar)
//    //if cal.title == "Calendarname" { calUid = cal.calendarIdentifier }
//
//
//
//    if let routinelyCalendar = eventStore.calendars(for: .reminder).first(where:{ $0.calendarIdentifier == uniqueIdentifier }){
//
//        var answer = false
//
//        //check if previous event
//        let predicate: NSPredicate? = eventStore.predicateForReminders(in: [routinelyCalendar])
//
//        if let aPredicate = predicate {
//            eventStore.fetchReminders(matching: aPredicate, completion: { (reminders) in
//                for reminder in reminders! {
//                    let unitFlags: Set<Calendar.Component> = [.hour, .day, .month, .year]
//                    let startComponents = NSCalendar.current.dateComponents(unitFlags, from: startDate)
//                    reminder.startDateComponents = startComponents
//                    if reminder.title == reminderName && reminder.startDateComponents == startComponents {
//                        answer = true
//                        print("Inside: \(answer)")
//                    }
//                }
//            })
//            print("Hello \(answer)")
//            return answer
//        }
//    }
//
//    return false
//
//}






//
//func askUserPermissionForReminders() {
//
//    let status = EKEventStore.authorizationStatus(for: EKEntityType.reminder)
//
//    switch (status) {
//    case EKAuthorizationStatus.notDetermined:
//        EKEventStore().requestAccess(to: .reminder, completion: { (granted, error) in
//            if (error != nil) || !granted {
//                self.askUserPermissionForReminders()
//                print("There was an error asking for your request")
//            }
//            else if granted && error == nil {
//                self.createRoutinelyReminderSet()
//            }
//        })
//    case EKAuthorizationStatus.authorized:
//        createRoutinelyReminderSet()
//        print("Authorized")
//    case EKAuthorizationStatus.restricted, EKAuthorizationStatus.denied:
//        // We need to help them give us permission
//        DispatchQueue.main.async {
//            self.needPermissionView.fadeIn()
//        }
//    //print("Ask for permission")
//    @unknown default:
//        print("There was an error.")
//    }
//
//
//}



























        
        //        func checkEvent(startTime: Date, endTime: Date) -> Bool{
        //
        //            let eventStore = EKEventStore()
        //
        //            let uniqueIdentifier = UserDefaults.standard.string(forKey: keyForRoutinelyCalendar)
        //
        //            guard let calendar = eventStore.calendars(for: .event).first(where: { $0.calendarIdentifier == uniqueIdentifier }) else {fatalError()}
        //
        //            //print(calendar)
        //            let predicate = eventStore.predicateForEvents(withStart: startTime.addingTimeInterval(-3600), end: endTime.addingTimeInterval(3600), calendars: [calendar])
        //            //print(predicate)
        //
        //            let existingEvents = eventStore.events(matching: predicate)
        //            //print(existingEvents)
        //            if let date = existingEvents.first?.startDate{
        //                print(date == startTime)
        //            }
        //            // print(existingEvents.first!.startDate)
        //            print(startTime)
        //            //print(endTime)
        //            let eventAlreadyExists = existingEvents.contains(where: {event in selectedRoutine!.name == event.title && event.startDate == startTime && event.endDate == endTime})
        //
        //            return eventAlreadyExists
        //        }
        //
        //
        
        
        //
        //    func createCalendarWithICloud(){
        //
        //        let eventStore = EKEventStore()
        //        let uniqueIdentifier = UserDefaults.standard.string(forKey: keyForRoutinelyCalendar)
        //
        //        if let _ = eventStore.calendars(for: .event).first(where: { $0.calendarIdentifier == uniqueIdentifier }){
        //            print("Calendar already made")
        //
        //        } else{
        //
        //            //var routinelyCalendar: EKCalendar?
        //            let routinelyCalendar = EKCalendar(for: .event, eventStore: eventStore)
        //
        //            routinelyCalendar.title = "Routinely Calendar"
        //            let sourcesInEventStore = eventStore.defaultCalendarForNewEvents
        //
        //            if let src = sourcesInEventStore?.source{
        //                routinelyCalendar.source = src
        //
        //                // Save the calendar using the Event Store instance
        //                do {
        //
        //                    try eventStore.saveCalendar(routinelyCalendar, commit: true)
        //                    UserDefaults.standard.set(routinelyCalendar.calendarIdentifier, forKey: keyForRoutinelyCalendar)
        //                    print("Calendar Just Made")
        //                } catch {
        //                    let alert = UIAlertController(title: "Calendar could not save", message: (error as NSError).localizedDescription, preferredStyle: .alert)
        //                    let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        //                    alert.addAction(OKAction)
        //
        //                    self.present(alert, animated: true, completion: nil)
        //
        //                }
        //
        //
        //            }
        //
        //        }
        //
        //    }
        //
        
        
        
        
        
        
        
        
        
        
        
        //
        //    func createCalendarEvent(with startDate: Date, with endDate: Date, routineName: String, routineSubRoutineCount: Int) {
        //
        //
        //        //access the database
        //        // if !checkEvent(startDate: startDate, endDate: endDate){
        //
        //
        //
        //        let eventStore = EKEventStore()
        //
        //        let uniqueIdentifier = UserDefaults.standard.string(forKey: keyForRoutinelyCalendar)
        //        //if cal.title == "Calendarname" { calUid = cal.calendarIdentifier }
        //        if let newCalender = eventStore.calendars(for: .event).first(where: { $0.calendarIdentifier == uniqueIdentifier }){
        //            let newEvent = EKEvent(eventStore: eventStore)
        //            //assigning calendar you just crated to new event
        //            newEvent.calendar = newCalender//eventStore.defaultCalendarForNewEvents
        //            newEvent.title =  routineName
        //            newEvent.startDate = startDate
        //            newEvent.endDate = endDate
        //            newEvent.notes = "This routine has \(routineSubRoutineCount) items"
        //
        //            //save the calendar using the event store instance
        //            do{
        //                //try to save teh event in the calendar associated with it
        //                try eventStore.save(newEvent, span: .thisEvent)
        //                //try eventStore.save(newEvent, span: .thisEvent, commit: true)
        //                print("Event Saved")
        //
        //            }catch{
        //                print("Event could not save")
        //            }
        //
        //
        //        }
        
        
        
        
        
        
        
        
        
        //    func createCalendarEvent(with startDate: Date, with endDate: Date, routineName: String, routineSubRoutineCount: Int) {
        //
        //
        //
        //
        //        //if let routine = selectedRoutine{
        //        eventStore = EKEventStore()
        //
        //        eventStore!.requestAccess(to: .event, completion: { (granted, error) in
        //            if error == nil{
        //
        //                self.event = EKEvent(eventStore: self.eventStore!)
        //                self.event!.title = routineName
        //                self.event!.startDate = startDate
        //                self.event!.endDate = endDate
        //                self.event!.notes = "This routine has \(routineSubRoutineCount) items"
        //                self.event!.calendar = self.eventStore?.defaultCalendarForNewEvents
        //
        //                //try to add Calendar event
        //                do{
        //                    try self.eventStore!.save(self.event!, span: .thisEvent)
        //                }catch let error as NSError{
        //                    print("There was an error saving the event: \(error)")
        //                }
        //
        //                print("saved Event")
        //            }
        //            else{
        //                print("There was an error creating this event ")
        //            }
        //        })
        //
        //        // }
        //
        //    }
        //
        
        
        

    

}
