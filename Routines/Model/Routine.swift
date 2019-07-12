//
//  Routine.swift
//  Routines
//
//  Created by Adriany Cocom on 7/11/19.
//  Copyright © 2019 aic. All rights reserved.
//

import Foundation
import RealmSwift

class Routine: Object{
    
    @objc dynamic var name: String = ""
    @objc dynamic var completed: Bool = false
    let subRoutines = List<SubRoutine>()
    
    //@objc dynamic var color: String = UIColor.randomFlat.hexValue()
    //@objc dynamic var information?
    //@objc dynamic var timeAllotted?
    //@objc dynamic  var numOfTaks?
    
    
}


