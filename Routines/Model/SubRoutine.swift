//
//  SubRoutine.swift
//  Routines
//
//  Created by Adriany Cocom on 7/11/19.
//  Copyright © 2019 aic. All rights reserved.
//

import Foundation
import RealmSwift

class SubRoutine: Object{
    
    @objc dynamic var name: String = ""
    //@objc dynamic var color: String = UIColor.randomFlat.hexValue()
    let toDoItems = List<SubRoutine>()
    
    var parentRoutine = LinkingObjects(fromType: Routine.self, property: "subRoutines")
    
    //@objc dynamic var timeAllotted?
    
    
}

