//
//  CoreDataStackMock.swift
//  Connection!
//
//  Created by Avi Cohen on 5/12/15.
//  Copyright (c) 2015 Avi Cohen. All rights reserved.
//

import Foundation
import Connection_
import CoreData

class CoreDataStackMock: CoreDataStack {
    
    init() {
        super.init(testing: true)
        var modelPath = NSBundle.mainBundle().pathForResource("Model", ofType: "momd")
        var modelURL = NSURL.fileURLWithPath(modelPath!)
        let model = NSManagedObjectModel(contentsOfURL: modelURL!)!
        var psc = NSPersistentStoreCoordinator(managedObjectModel: model)
        var error: NSError? = nil
        if let ps = psc.addPersistentStoreWithType(NSInMemoryStoreType, configuration:nil, URL: nil, options: nil, error: &error) {
        } else {
            abort()
        }
        mainContext = NSManagedObjectContext()
        mainContext.persistentStoreCoordinator = psc
    }
    
    override func save() {
        var error: NSError?
        let saved = mainContext.save(&error)
        if (!saved) {
            Log.fail(functionName: __FUNCTION__, message: "Unresolved core data error: \(error)")
            abort()
        }
    }
}
