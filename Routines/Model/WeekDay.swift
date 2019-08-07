//
//  Day.swift
//  Routines
//
//  Created by Adriany Cocom on 8/6/19.
//  Copyright © 2019 aic. All rights reserved.
//

import Foundation
import RealmSwift

class WeekDay: Object{
    @objc dynamic var name: String = ""
    @objc dynamic var checked = false
    @objc dynamic var number = -1
    @objc dynamic var notificationPath: String?
    
    //let subRoutines = List<SubRoutine>()
    var parentRoutine = LinkingObjects(fromType: Routine.self, property: "weekDayNotifications")
    
    
}
