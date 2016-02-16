//
//  StoredTimers.swift
//  Timers
//
//  Created by Asad Khaliq on 5/31/15.
//  Copyright (c) 2015 Asad Khaliq. All rights reserved.
//

import Foundation
import CoreData

class StoredTimers: NSManagedObject {

    @NSManaged var color: AnyObject
    @NSManaged var duration: NSNumber
    @NSManaged var name: String
    @NSManaged var target: NSNumber
    @NSManaged var time: String
    @NSManaged var sortID: NSDate

}
