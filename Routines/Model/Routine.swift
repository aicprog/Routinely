//
//  Routine.swift
//  Routines
//
//  Created by Adriany Cocom on 7/11/19.
//  Copyright © 2019 aic. All rights reserved.
//

import Foundation
import RealmSwift
import EventKit


class Routine: Object{
    
    @objc dynamic var name: String = ""
    @objc dynamic var completed: Bool = false
    @objc dynamic var numberOfTotalSubRoutines: Int = 0
    @objc dynamic var numberOfCompletedSubRoutines: Int = 0
    @objc dynamic var dateCreated = Date()
    
    @objc dynamic var partialImagePath: String?
    @objc dynamic var timeForRoutine: Date?
    @objc dynamic var startTime: Date?
    //@objc dynamic var notificationIdentifiers: [Int: String]?
    @objc dynamic var reminderSet = false


    
    
    let subRoutines = List<SubRoutine>()
    let notifications = List<Notification>()
    
    //let reminders = List<Reminder>()
    
    //@objc dynamic var color: String = UIColor.randomFlat.hexValue()
    //@objc dynamic var information?
    //@objc dynamic var timeAllotted?
    //@objc dynamic  var numOfTaks?
    
    
}


