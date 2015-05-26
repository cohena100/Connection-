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
    
    public init() {
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    public var managedObjectModel: NSManagedObjectModel = {
        var modelPath = NSBundle.mainBundle().pathForResource("Model", ofType: "momd")
        var modelURL = NSURL.fileURLWithPath(modelPath!)
        var model = NSManagedObjectModel(contentsOfURL: modelURL!)!
        return model
        }()
    
    lazy var applicationDocumentsDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count - 1] as! NSURL
        }()
    
    public lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("Connection.sqlite")
        var options = [NSInferMappingModelAutomaticallyOption: true, NSMigratePersistentStoresAutomaticallyOption: true]
        var psc = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        var error: NSError? = nil
        if let ps = psc.addPersistentStoreWithType(NSSQLiteStoreType, configuration:nil, URL: url, options: options, error: &error) {
            return psc
        } else {
            abort()
        }
        }()
    
    public lazy var rootContext: NSManagedObjectContext? = {
        var context: NSManagedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        context.persistentStoreCoordinator = self.persistentStoreCoordinator
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
        }()
    
    public lazy var mainContext: NSManagedObjectContext? = {
        var mainContext: NSManagedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        mainContext.parentContext = self.rootContext
        mainContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "mainContextDidSave:", name: NSManagedObjectContextDidSaveNotification, object: mainContext)
        return mainContext
        }()
    
    public func newDerivedContext() -> NSManagedObjectContext {
        var context: NSManagedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        context.parentContext = self.mainContext
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }
    
    public func saveContext(context: NSManagedObjectContext) {
        if context.parentContext === self.mainContext {
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
        context.performBlock() { [weak self] in
            var error: NSError? = nil
            if !(context.obtainPermanentIDsForObjects(Array(context.insertedObjects), error: &error)) {
                Log.fail(functionName: __FUNCTION__, message: "Error obtaining permanent IDs for \(context.insertedObjects), \(error)")
            }
            if !(context.save(&error)) {
                Log.fail(functionName: __FUNCTION__, message: "Unresolved core data error: \(error)")
                abort()
            }
            self!.saveContext(self!.mainContext!)
        }
    }
    
    public func save() {
        saveContext(mainContext!)
    }
    
    func deleteObject(object: NSManagedObject) {
        mainContext!.deleteObject(object)
        save()
    }
    
    func fetch(entity: String, predicate: NSPredicate? = nil, inout error: NSError?) -> [AnyObject]? {
        let request = NSFetchRequest(entityName:entity)
        request.predicate =  predicate
        return mainContext!.executeFetchRequest(request, error: &error)
    }
    
    func fetchOne(entity: String, predicate: NSPredicate? = nil, inout error: NSError?) -> AnyObject? {
        let request = NSFetchRequest(entityName:entity)
        request.predicate =  predicate
        request.fetchLimit = 1
        let elements = mainContext!.executeFetchRequest(request, error: &error)
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
        let objects = mainContext!.executeFetchRequest(request, error: &error)
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
        saveContext(self.rootContext!)
    }
    
}