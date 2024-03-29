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
    let data = [["Remind Me: ","Start Time", "How Long", "Repeat For"]]
    var selectedRoutine: Routine?
    
    
    //MARK: Variables for datePicker
    var startTime: Date?
    var timeInterval: Date?
    //var endTime: Date?
    var reminderOn = false
    var userChoosingDate = false
    // var validTimePeriod = false
    
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
    
    //MARK: Variables for Reminder
    var notificationDays:[Int] = []
    //MARK: Variables for Navigation Bar
    
    @IBOutlet weak var navBar: UINavigationItem!
    
    
    
    //MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var routineName: UITextField!
    @IBOutlet weak var needPermissionView: UIView!
    
    @IBOutlet weak var selectedImageView: UIImageView!
    
    @IBOutlet weak var libraryImageButton: UIButton!
    
    
    override func viewDidLoad() {
        self.removeSpinner()
        super.viewDidLoad()
        tableView.rowHeight = 40
        
        
        
        if let routine = selectedRoutine{
            routineName?.text = routine.name
            reminderOn = routine.reminderSet
            
            if let imagePath = routine.partialImagePath{
                guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {return}
                
                //for old image path
                let fileURL: URL = documentsDirectory.appendingPathComponent(imagePath)
                
                selectedImageView.image = UIImage(contentsOfFile: fileURL.path)
            }
            
            
            
        }
        
        //For tableView
        tableView.delegate = self
        tableView.dataSource = self
        UNUserNotificationCenter.current().delegate = self
        
        //initialize UI TextField
        initializeRoutineNameTxtField()
        self.setupHideKeyboardOnTap()
        
        
        //set pickerController delegate
        pickerController.delegate = self
        
        //initialize roundness property for library image Button
        libraryImageButton.layer.cornerRadius = libraryImageButton.frame.size.width / 3;
        libraryImageButton.clipsToBounds = true
        libraryImageButton.alpha = 0.9
        
        //initialize roundness property for selected image view
        selectedImageView.layer.cornerRadius = selectedImageView.frame.size.width / 6;
        selectedImageView.clipsToBounds = true
        selectedImageView.alpha = 0.9
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
        //For Calendar
        askUserForPermission()
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        //update notification if changes are made to the name of the Routine
        if let routine = selectedRoutine{
            if let startTime = routine.startTime, let intervalTime = routine.timeForRoutine{
                alertForRepeat()
                do{
                    try realm.write {
                        createNotificationDays(with: routine.weekDayNotifications, startTime: startTime, intervalTime: intervalTime)
                        print("Notification Updated")
                    }
                }
                catch{
                    print("Could not update Notifications")
                }
                
            }
        }
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
        else if indexPath.row == 1 || indexPath.row == 2{
            let cell = tableView.dequeueReusableCell(withIdentifier: "DatePickerCell", for: indexPath) as! DatePickerTableViewCell
            
            //Only show cells if switch is on
            if reminderOn{
                cell.isHidden = false
                
                //update subtitle based on datePicker or previous reminder
                if let routine = selectedRoutine {
                    //if cell is startDate
                    if indexPath.row == 1{
                        cell.datePicker.datePickerMode = .time
                        //startTime = cell.datePicker.date
                        startTime = userChoosingDate ? cell.datePicker.date: routine.startTime ?? Date()
                        updateStartTimeCell(with: cell)
                        
                    }else if indexPath.row == 2{
                        let units: Set<Calendar.Component> = [.hour, .minute]
                        var startComponents = NSCalendar.current.dateComponents(units, from: Date())
                        startComponents.hour = 0
                        startComponents.minute = 1
                        let date = Calendar.current.date(from: startComponents)
                        //print(startComponents.date!)
                        timeInterval = userChoosingDate ? cell.datePicker.date: routine.timeForRoutine ?? date
                        updateTimeIntervalCell(with: cell)
                    }
                    
                }     //else hide cells if user chooses not to have a reminder
            } else{
                cell.isHidden = true
            }
            
            
            //action for datepicker
            cell.doneInputting = {
                
                self.userChoosingDate = true
                
                tableView.reloadData()
                
                
            }
            cell.title.text = data[indexPath.section][indexPath.row]
            
            return cell
        }
            // if cell is repeatCell
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "repeatCell", for: indexPath) as! RepeatTableViewCell
            if reminderOn{
                cell.isHidden = false
                cell.title?.text = data[indexPath.section][indexPath.row]
                cell.reminderSetLabel = initializeReminderSetLabel(with: cell, label: cell.reminderSetLabel)
            }
            else{
                cell.isHidden = true
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            toggleStartDatePicker()
            
        }
        else if indexPath.row == 2 {
            toggleEndDatePicker()
            
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if startPickerVisible && indexPath.row == 1{
            return 150
            
        } else if endPickerVisible && indexPath.row == 2{
            return 150
            
        } else{
            return 44
        }
        
    }
    
    //MARK: - IB Actions
    
    
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        
        
        guard let routine = selectedRoutine else {fatalError()}
        
        do{
            try realm.write {
                
                
                //updates for reminders and notifications
                if reminderOn{
                    
                    routine.timeForRoutine = timeInterval
                    routine.startTime = startTime
                    routine.reminderSet = true
                    
                    //if user has not checked a day
                    alertForRepeat()
                    
                    //create Notifications
                    createNotificationDays(with: routine.weekDayNotifications, startTime: routine.startTime!, intervalTime: routine.timeForRoutine!)
                    
                }
                else{
                    routine.timeForRoutine = nil
                    routine.reminderSet = false
                    routine.startTime = nil
                    
                    for day in routine.weekDayNotifications{
                        if let path = day.notificationPath{
                            deleteNotification(with: path )
                        }
                        
                    }
                    
                    routine.weekDayNotifications.removeAll()
                    
                }
                //updates for selectedImage
                if let image = selectedImage {
                    routine.partialImagePath = saveImage(previousPartialPath:routine.partialImagePath, image: image)
                    //print(routine.partialImagePath!)
                }
                
                if let name = routineName?.text{
                    if !name.trimmingCharacters(in: .whitespaces).isEmpty{
                        routine.name = name
                    }
                }
                
                
                
            }
            
            
        }
        catch{
            print("There was an error adding \(error)")
        }
        
        
        
        
        self.navigationController?.popViewController(animated: true)
        
        
        
    }
    
    @IBAction func cancelBtnPressed(_ sender: UIButton) {
        self.dismiss(animated: true) {
            //print("I am dismissed")
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
    
    
    
    //MARK: - Segue Functions
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! RepeatTableViewController
        
        if let indexPath = tableView.indexPathForSelectedRow, let routine = selectedRoutine{
            destinationVC.weekDays = routine.weekDayNotifications
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
    }
    
    
    
    //MARK: - My Functions
    
    func addToNotificationArray(dayOfTheWeek: Int) -> Bool{
        
        var buttonPressed = false
        
        if notificationDays.contains(dayOfTheWeek){
            notificationDays.removeAll{$0 == dayOfTheWeek}
            buttonPressed = true
        }else{
            notificationDays.append(dayOfTheWeek)
        }
        
        
        return buttonPressed
    }
    
    
    func toggleStartDatePicker () {
        startPickerVisible = !startPickerVisible
        tableView.reloadData()
    }
    
    func toggleEndDatePicker () {
        endPickerVisible = !endPickerVisible
        tableView.reloadData()
    }
    
    func updateTimeIntervalCell(with cell: DatePickerTableViewCell) {
        if let interval = timeInterval{
            cell.datePicker.date = interval
            
            let units: Set<Calendar.Component> = [.hour, .minute,]
            let intervalComponents = NSCalendar.current.dateComponents(units, from: interval)
            
            
            cell.subtitle.text = "\(intervalComponents.hour!) hours, \(intervalComponents.minute!) minutes"
        }
    }
    func updateStartTimeCell(with cell: DatePickerTableViewCell) {
        if let start = startTime{
            cell.datePicker.date = start
            let dateFormatter = DateFormatter()
            // dateFormatter.dateStyle = DateFormatter.Style.short
            dateFormatter.timeStyle = DateFormatter.Style.short
            
            
            cell.subtitle.text = dateFormatter.string(from: start)
        }
    }
    
    func initializeRoutineNameTxtField(){
        
        routineName.delegate = self
        routineName.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        setLeftPaddingPoints(10)
        
        
        
        //custom placeholder for txt field
        var placeHolder = NSMutableAttributedString()
        let name  = "  Enter Routine Name"
        
        // Set the Font
        placeHolder = NSMutableAttributedString(string: name, attributes: [NSAttributedString.Key.font:UIFont(name: "Helvetica", size: 15.0)!])
        
        // Set the color
        placeHolder.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.darkGray, range:NSRange(location:0,length:name.count))
        
        // Add attribute
        routineName.attributedPlaceholder = placeHolder
    }
    
    
    func initializeReminderSetLabel(with cell: RepeatTableViewCell, label: UILabel) -> UILabel {
        
        
        var text = ""
        let noneChecked = checkIfNoneCheckedForWeekDayNotifications()
        
        if let routine = selectedRoutine{
            for day in routine.weekDayNotifications{
                if day.checked{
                    text.append("\(day.name.prefix(2)) ")
                }
            }
        }
        
        if noneChecked{
            label.font = label.font.withSize(17)
            label.text = "None Selected"
            label.textColor = UIColor.gray
            print("I work")
        }
        else{
            label.text = text
            label.textColor = UIColor.black
            label.font = label.font.withSize(14)
        }
        
        
        return label
    }
    
    func alertForRepeat(){
        let noneChecked = checkIfNoneCheckedForWeekDayNotifications()
        
        if noneChecked{
            let alert = UIAlertController(title: "Reminder", message: "For a remidner to be set, a day needs to be selected.", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(OKAction)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func checkIfNoneCheckedForWeekDayNotifications() -> Bool{
        var noneChecked = true
        
        if let routine = selectedRoutine{
            for day in routine.weekDayNotifications{
                if day.checked{
                    noneChecked = false
                }
            }
        }
        return noneChecked
    }
    
    //    func setupNavigationBar() {
    //        navigationItem.title = .none
    //
    //        if #available(iOS 11.0, *) {
    //            navigationController?.navigationBar.prefersLargeTitles = true
    //
    //            let titleLabel = UILabel()
    //            titleLabel.text = "Edit Routine"
    //
    //            titleLabel.font = UIFont.systemFont(ofSize: 25, weight: .medium)
    //            titleLabel.numberOfLines = 2
    //            titleLabel.textColor = .white
    //            titleLabel.sizeToFit()
    //            titleLabel.textAlignment = .center
    //
    //            titleLabel.translatesAutoresizingMaskIntoConstraints = false
    //
    //            let targetView = self.navigationController?.navigationBar
    //            targetView?.addSubview(titleLabel)
    //            titleLabel.anchor(top: nil, left: nil, bottom: targetView?.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 222, height: 50)
    //
    //            titleLabel.centerXAnchor.constraint(equalTo: (targetView?.centerXAnchor)!).isActive = true
    //
    //        } else {
    //            // Fallback on earlier versions
    //        }
    //
    //    }
    
    
    
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
    
    func createNotificationDays(with weekDays: List<WeekDay>,  startTime: Date, intervalTime: Date){
        
        for day in weekDays{
            if day.checked{
                if let path = day.notificationPath{
                    deleteNotification(with: path)
                }
                print("WeekdayNumber: \(day.number)")
                day.notificationPath = setNotification(weekday: day.number, startTime: startTime, intervalTime: intervalTime)
                print("WeekdayNotification made: \(day.name)")
            }
            else{
                if let path = day.notificationPath{
                    deleteNotification(with: path)
                    day.notificationPath = nil
                }
            }
        }
    }
    
    func setNotification(weekday: Int, startTime: Date, intervalTime: Date) -> String {
        
        guard let routine = selectedRoutine else {fatalError()}
        
        
        //for interval
        let units: Set<Calendar.Component> = [.weekday, .hour, .minute,]
        let intervalComponents = NSCalendar.current.dateComponents(units, from: intervalTime)
        
        
        
        
        // guard let weekday = intervalComponents.weekday else {fatalError()}
        guard let hours = intervalComponents.hour else {fatalError()}
        guard let minutes = intervalComponents.minute else {fatalError()}
        
        
        
        var timeIntervalString = ""
        
        if hours > 0{
            if hours == 1{
                timeIntervalString.append("\(hours) hour and ")
            }else{
                timeIntervalString.append("\(hours) hours and ")
            }
            
        }
        if minutes > 0{
            if minutes == 1{
                timeIntervalString.append("\(minutes) minute")
            }else{
                timeIntervalString.append("\(minutes) minutes")
            }
            
        }
        
        let content = UNMutableNotificationContent()
        content.title = routine.name
        content.body = "Your \(content.title) routine is starting! This routine lasts for \(timeIntervalString)."
        content.sound = UNNotificationSound.default
        
        
        
        var startComponents = NSCalendar.current.dateComponents(units, from: startTime)
        startComponents.weekday = weekday
        
        // Create the trigger as a repeating event.
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: startComponents, repeats: true)
        
        
        // Create the request
        var uniqueIdentifier: String?
        
        for day in routine.weekDayNotifications{
            if day.number == weekday{
                uniqueIdentifier = day.notificationPath
            }
        }
        
        if uniqueIdentifier == nil{
            uniqueIdentifier = UUID().uuidString
        }
        
        guard let identifier = uniqueIdentifier else{fatalError()}
        
        let request = UNNotificationRequest(identifier: identifier,
                                            content: content, trigger: trigger)
        
        
        // Schedule the request with the system.
        let notificationCenter = UNUserNotificationCenter.current()
        
        notificationCenter.add(request) { (error) in
            if error != nil {
                print("There was an error adding the notification")
            }else{
                print("Notification Added")
                print("Identifier: \(identifier)")
            }
        }
        return identifier
    }
    
    func deleteNotification(with notificationIdentifier: String){
        print("Identifier to be deleted: \(notificationIdentifier)")
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationIdentifier])
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        
        
    }
    
    
    //MARK: - Functions for saving images
    
    func saveImage(previousPartialPath: String?, image: UIImage) -> String? {
        
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil}
        
        if let oldPartialPath = previousPartialPath {
            
            //for old image path
            let oldFileURL: URL = documentsDirectory.appendingPathComponent(oldPartialPath)
            //print("Previous \(oldFileURL.absoluteString)")
            
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
        let partialPath = "RoutinelyImages/icon\(uniqueIdentifier).png"
        let newFileURL = documentsDirectory.appendingPathComponent(partialPath)
        guard let data = UIImage.PNGRepresentation(image) else {return nil}
        
        print(data)
        
        
        do {
            try data.write(to: newFileURL)
        } catch let error {
            print("error saving file with error", error)
        }
        
        return partialPath
        
    }
    
}
// MARK: - UNUserNotificationCenter Extension Methods
extension DetailedRoutineViewController: UNUserNotificationCenterDelegate{
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    }
    
    
}
//MARK: - TextField Extension Methods
extension DetailedRoutineViewController : UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
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
        
        
    }
    
}






