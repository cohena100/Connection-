//
//  CoreDataStack.swift
//  Connection!
//
//  Created by Avi Cohen on 5/11/15.
//  Copyright (c) 2015 Avi Cohen. All rights reserved.
//

import Foundation
import CoreData

public class CoreDataStack {
    
    static let sharedInstance = CoreDataStack()
    
    let rootContext: NSManagedObjectContext!
    public var mainContext: NSManagedObjectContext!
    let derivedContext: NSManagedObjectContext!
    
    convenience init() {
        self.init(testing: false)
    }
    
    public init(testing: Bool) {
        if testing {
            rootContext = nil
            mainContext = nil
            derivedContext = nil
            return
        }
        var modelPath = NSBundle.mainBundle().pathForResource("Model", ofType: "momd")
        var modelURL = NSURL.fileURLWithPath(modelPath!)
        let model = NSManagedObjectModel(contentsOfURL: modelURL!)!
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let  url = (urls[urls.count - 1] as! NSURL).URLByAppendingPathComponent("Connection.sqlite")
        var options = [NSInferMappingModelAutomaticallyOption: true, NSMigratePersistentStoresAutomaticallyOption: true]
        var psc = NSPersistentStoreCoordinator(managedObjectModel: model)
        var error: NSError? = nil
        if let ps = psc.addPersistentStoreWithType(NSSQLiteStoreType, configuration:nil, URL: url, options: options, error: &error) {
        } else {
            abort()
        }
        rootContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        rootContext.persistentStoreCoordinator = psc
        rootContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        mainContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        mainContext.parentContext = self.rootContext
        mainContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        derivedContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        derivedContext.parentContext = self.mainContext
        derivedContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "mainContextDidSave:", name: NSManagedObjectContextDidSaveNotification, object: mainContext)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "mainContextDidSave:", object: mainContext)
    }
    
    public func saveContext(context: NSManagedObjectContext) {
        if context.parentContext === mainContext {
            saveDerivedContext(context)
            return
        }
        context.performBlock( {
            var error: NSError? = nil
            if !(context.obtainPermanentIDsForObjects(Array(context.insertedObjects), error: &error)) {
                Log.fail(functionName: __FUNCTION__, message: "Error obtaining permanent IDs for \(context.insertedObjects), \(error)")
            }
            if !(context.save(&error)) {
                Log.fail(functionName: __FUNCTION__, message: "Unresolved core data error: \(error)")
                abort()
            }
            }
        )
    }
    
    public func saveDerivedContext(context: NSManagedObjectContext) {
        context.performBlock() { [unowned self] in
            var error: NSError? = nil
            if !(context.obtainPermanentIDsForObjects(Array(context.insertedObjects), error: &error)) {
                Log.fail(functionName: __FUNCTION__, message: "Error obtaining permanent IDs for \(context.insertedObjects), \(error)")
            }
            if !(context.save(&error)) {
                Log.fail(functionName: __FUNCTION__, message: "Unresolved core data error: \(error)")
                abort()
            }
            self.saveContext(self.mainContext)
        }
    }
    
    public func save() {
        saveContext(mainContext)
    }
    
    func deleteObject(object: NSManagedObject) {
        mainContext.deleteObject(object)
        save()
    }
    
    func fetch(entity: String, predicate: NSPredicate? = nil, inout error: NSError?) -> [AnyObject]? {
        let request = NSFetchRequest(entityName:entity)
        request.predicate =  predicate
        return mainContext.executeFetchRequest(request, error: &error)
    }
    
    func fetchOne(entity: String, predicate: NSPredicate? = nil, inout error: NSError?) -> AnyObject? {
        let request = NSFetchRequest(entityName:entity)
        request.predicate =  predicate
        request.fetchLimit = 1
        let elements = mainContext.executeFetchRequest(request, error: &error)
        if let elements = elements {
            
        } else {
            return nil
        }
        if elements!.count == 0 {
            return nil
        }
        return elements![0]
    }
    
    func getLastObject(entity: String, inout error: NSError?) -> AnyObject? {
        let request = NSFetchRequest(entityName: entity)
        let sortDescriptor = NSSortDescriptor(key: "created", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        request.fetchLimit = 1
        let objects = mainContext.executeFetchRequest(request, error: &error)
        if let objects = objects {
        } else {
            return nil
        }
        if objects!.count > 0 {
        } else {
            Log.warn(functionName: __FUNCTION__, message: "it appears that there are no objects at all")
            return nil
        }
        return objects![0]
    }
    
    @objc func mainContextDidSave(notification: NSNotification) {
        saveContext(self.rootContext)
    }
    
}