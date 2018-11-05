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
    lazy var dataContext: NSManagedObjectContext = {
        var dataContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        dataContext.parent = self.mainContext
        dataContext.mergePolicy = NSOverwriteMergePolicy
        return dataContext
    }()
    lazy var mainContext: NSManagedObjectContext = {
        var mainContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        mainContext.parent = self.storeContext
        mainContext.mergePolicy = NSOverwriteMergePolicy
        return mainContext
    }()
    lazy var storeContext: NSManagedObjectContext = {
        var storeContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        storeContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        storeContext.mergePolicy = NSOverwriteMergePolicy
        return storeContext
    }()
    private var lastSaveWasSuccessed = true
    func performSave(with context: NSManagedObjectContext, completionToDoOnMain: (() -> Void)? = nil, failureToDoOnMain: (() -> Void)? = nil) {
        guard context.hasChanges || !lastSaveWasSuccessed else {
            self.mainContext.perform {
                completionToDoOnMain?()
            }
            return
        }
        context.perform {
            sleep(3)
            do {
                try context.save()
                if let parentContext = context.parent {
                    self.performSave(with: parentContext, completionToDoOnMain: completionToDoOnMain)
                } else {
                    self.lastSaveWasSuccessed = true
                    self.mainContext.perform {
                        completionToDoOnMain?()
                    }
                }
            } catch {
                print("Context save error: \(error)")
                self.lastSaveWasSuccessed = false
                self.mainContext.perform {
                    failureToDoOnMain?()
                }
            }
        }
    }
    
    func findOrInsertAppUser(in context: NSManagedObjectContext) -> AppUser? {
        guard let model = context.persistentStoreCoordinator?.managedObjectModel else {
            assert(false, "Model is not available in context!")
            return nil
        }
        var appUser: AppUser?
        guard let fetchRequest = AppUser.fetchRequestAppUser(model: model) else {
            return nil
        }
        do {
            let results = try context.fetch(fetchRequest)
            assert(results.count < 2, "Multiple AppUsers found!")
            if let foundUser = results.first {
                appUser = foundUser
            }
        } catch {
            print("failed to fetch AppUser: \(error)")
        }
        if appUser == nil {
            appUser = AppUser.insertAppUser(in: context)
        }
        return appUser
    }
}

extension User {
    static func insertUser(in context: NSManagedObjectContext) -> User? {
        guard let user = NSEntityDescription.insertNewObject(forEntityName: "User", into: context) as? User else { return nil }
        return user
    }
}

extension AppUser {
    static func insertAppUser(in context: NSManagedObjectContext) -> AppUser? {
        guard let appUser = NSEntityDescription.insertNewObject(forEntityName: "AppUser", into: context) as? AppUser else { return nil }
        let currentUser = User.insertUser(in: context)
        currentUser?.userId = UIDevice.current.name
        appUser.currentUser = currentUser
        return appUser
    }
    static func fetchRequestAppUser(model: NSManagedObjectModel) -> NSFetchRequest<AppUser>? {
        let templateName = "AppUser"
        guard let fetchRequest = model.fetchRequestTemplate(forName: templateName) as? NSFetchRequest<AppUser> else {
            assert(false, "No template with name: \(templateName)")
            return nil
        }
        return fetchRequest
    }
}
