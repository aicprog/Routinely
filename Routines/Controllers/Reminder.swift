//
//  Reminder.swift
//  Routines
//
//  Created by Adriany Cocom on 7/16/19.
//  Copyright © 2019 aic. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class Reminder: Object{
    @objc dynamic var name: String = ""
    @objc dynamic var time = NSDate()
    
    //var parentRoutine = LinkingObjects(fromType: Routine.self, property: "reminders")
}
