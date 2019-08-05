//
//  Notification.swift
//  Routines
//
//  Created by Adriany Cocom on 8/4/19.
//  Copyright © 2019 aic. All rights reserved.
//

import Foundation
import RealmSwift
import EventKit


class Notification: Object{
    @objc dynamic var dayofTheWeek: Int = 0
    @objc dynamic var notificationPath: String = ""
    
    let subRoutines = List<SubRoutine>()
    var parentRoutine = LinkingObjects(fromType: Routine.self, property: "notifications")

}
