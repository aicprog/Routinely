//
//  Day.swift
//  Routines
//
//  Created by Adriany Cocom on 8/6/19.
//  Copyright © 2019 aic. All rights reserved.
//

import Foundation
import RealmSwift

class Day: Object{
    @objc dynamic var dayofTheWeek: Int = 0
    @objc dynamic var completed = false
    @objc dynamic var notificationPath: String = ""
    
    let subRoutines = List<SubRoutine>()
    var parentRoutine = LinkingObjects(fromType: Routine.self, property: "weekDayNotifications")
    
    
}
