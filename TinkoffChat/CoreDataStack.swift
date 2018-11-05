//
//  CoreDataStack.swift
//  TinkoffChat
//
//  Created by me on 05/11/2018.
//  Copyright © 2018 gladkikh. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    var storeUrl: URL {
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsUrl.appendingPathComponent("TinkoffChat.sqlite")
    }
    let dataModelName = "TinkoffChat"
    let dataModelExtension = "momd"
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelUrl = Bundle.main.url(forResource: self.dataModelName, withExtension: self.dataModelExtension)!
        return NSManagedObjectModel(contentsOf: modelUrl)!
    }()
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                               configurationName: nil,
                                               at: self.storeUrl,
                                               options: nil)
        } catch {
            assert(false, "Error adding store: \(error)")
        }
        return coordinator
    }()
    lazy var masterContext: NSManagedObjectContext = {
        var masterContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        masterContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        masterContext.mergePolicy = NSOverwriteMergePolicy
        return masterContext
    }()
    lazy var mainContext: NSManagedObjectContext = {
        var mainContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        mainContext.parent = self.masterContext
        mainContext.mergePolicy = NSOverwriteMergePolicy
        return mainContext
    }()
    lazy var saveContext: NSManagedObjectContext = {
        var saveContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        saveContext.parent = self.mainContext
        saveContext.mergePolicy = NSOverwriteMergePolicy
        return saveContext
    }()
    
    func performSave(with context: NSManagedObjectContext, completion: (() -> Void)? = nil) {
        guard context.hasChanges else {
            completion?()
            return
        }
        context.perform {
            do {
                try context.save()
            } catch {
                print("Context save error: \(error)")
            }
            if let parentContext = context.parent {
                self.performSave(with: parentContext, completion: completion)
            } else {
                completion?()
            }
        }
    }
    
}

