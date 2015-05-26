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
    
    override init() {
        super.init()
        self.persistentStoreCoordinator = {
            var psc = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
            var error: NSError? = nil
            if let ps = psc.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil, error: &error) {
                return psc
            } else {
                abort()
            }
            }()
        self.mainContext = {
            var mainContext: NSManagedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
            mainContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            mainContext.persistentStoreCoordinator = self.persistentStoreCoordinator
            return mainContext
            }()
    }
    
    override func save() {
        
    }
}
