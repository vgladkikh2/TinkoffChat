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
            if(context == self.mainContext) {
                //Here to add FRCDelegate's funcs calls
            }
            do {
//                sleep(2)
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
//        guard let model = context.persistentStoreCoordinator?.managedObjectModel else {
//            assert(false, "Model is not available in context!")
//            return nil
//        }
//        guard let fetchRequest = AppUser.fetchRequestAppUser(model: model) else {
//            return nil
//        }
        let fetchRequest: NSFetchRequest<AppUser> = AppUser.fetchRequest() // this one line replaces 2 commented guards above and fetchRequestAppUser() in extension of AppUser
        var appUser: AppUser?
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
    
    func findOrInsertUser(userId: String, in context: NSManagedObjectContext, for appUser: AppUser) -> User? {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userId == %@ AND appUser == %@", argumentArray: [userId, appUser])
        var user: User?
        do {
            let results = try context.fetch(fetchRequest)
            assert(results.count < 2, "Multiple Users with one userId found!")
            if let foundUser = results.first {
                user = foundUser
            }
        } catch {
            print("failed to fetch user with userId=\(userId): \(error)")
        }
        if user == nil {
            user = User.insertUser(in: context)
            user?.userId = userId
            user?.appUser = appUser
        }
        return user
    }
    func findUsers(in context: NSManagedObjectContext, for AppUser: AppUser) -> [User] {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "appUser == %@", AppUser)
        var users = [User]()
        do {
            users = try context.fetch(fetchRequest)
        } catch {
            print("failed to fetch Users: \(error)")
        }
        return users
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
        currentUser?.userId = UIDevice.current.identifierForVendor!.uuidString //UIDevice.current.name
        currentUser?.name = "User \(Int.random(in: 1...1000))"
        appUser.currentUser = currentUser
        return appUser
    }
//    static func fetchRequestAppUser(model: NSManagedObjectModel) -> NSFetchRequest<AppUser>? {
//        let templateName = "AppUserRequest"
//        guard let fetchRequest = model.fetchRequestTemplate(forName: templateName) as? NSFetchRequest<AppUser> else {
//            assert(false, "No template with name: \(templateName)")
//            return nil
//        }
//        return fetchRequest
//    }
}
