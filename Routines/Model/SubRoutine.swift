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
    @objc dynamic var completed: Bool = false
    @objc dynamic var dateCreated = Date()
    @objc dynamic var order = 0

    var parentRoutine = LinkingObjects(fromType: Routine.self, property: "subRoutines")
    

    
    
}

