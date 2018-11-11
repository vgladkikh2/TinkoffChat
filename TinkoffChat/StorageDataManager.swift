//
//  StorageManager.swift
//  TinkoffChat
//
//  Created by me on 05/11/2018.
//  Copyright © 2018 gladkikh. All rights reserved.
//

import Foundation
import CoreData

class StorageDataManager: ProfileDataManager {
    var profileUsername: String? {
        return appUser?.currentUser?.name
    }
    var profileAbout: String? {
        return appUser?.currentUser?.about
    }
    var profileAvatar: UIImage? {
        if let data = appUser?.currentUser?.avatar {
            return UIImage(data: data)
        } else {
            return nil
        }
    }
    weak var profileDataDelegate: ProfileDataManagerDelegate?
    var coreDataStack: CoreDataStack
    var appUser: AppUser?
    var users: [User]
    var usersOnlineFRC: NSFetchedResultsController<User>
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    init() {
        coreDataStack = CoreDataStack()
        guard let appUser = coreDataStack.findOrInsertAppUser(in: coreDataStack.dataContext) else { assert (false, "cannot retrieve AppUser") }
        self.appUser = appUser
        users = coreDataStack.findUsers(in: coreDataStack.dataContext, for: appUser)
        print("UUUUUUUUUUsers:")
        for user in users {
            print(user.name ?? "Unnamed" + " \(user.isOnline)")
            user.isOnline = false
        }
        coreDataStack.performSave(with: coreDataStack.dataContext, completionToDoOnMain: nil, failureToDoOnMain: nil)
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "isOnline == %@ AND appUser == %@", argumentArray: [true, appUser])
        let sortDescriptor = NSSortDescriptor(key:"name", ascending:true)
        request.sortDescriptors = [sortDescriptor]
        usersOnlineFRC = NSFetchedResultsController(fetchRequest: request,
                                             managedObjectContext: coreDataStack.mainContext,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)
        try! usersOnlineFRC.performFetch()
    }
    
    func saveUserStateChange(userId: String, userName: String? = nil, isOnline: Bool) {
        let user = coreDataStack.findOrInsertUser(userId: userId, in: coreDataStack.dataContext, for: appUser!)
        user?.isOnline = isOnline
        if isOnline {
            user?.name = userName
        }
        coreDataStack.performSave(with: coreDataStack.dataContext, completionToDoOnMain: nil, failureToDoOnMain: nil)
    }
    
    func saveProfileData(username: String?, about: String?, avatar: UIImage?) {
        var isUserNameChanged = false
        if username != nil {
            isUserNameChanged = true
            appUser?.currentUser?.name = username
        }
        if about != nil {
            appUser?.currentUser?.about = about
        }
        if avatar != nil {
            appUser?.currentUser?.avatar = avatar?.pngData()
        }
        coreDataStack.performSave(with: coreDataStack.dataContext,
                                  completionToDoOnMain: isUserNameChanged ?
                                    { [unowned self] in self.profileDataDelegate?.savingProfileDataFinished()
//                                        let conversationList = self.appDelegate.communicationManager.conversationsList
//                                        self.appDelegate.communicationManager = nil
//                                        self.appDelegate.multipeerCommunicator = nil
//                                        self.appDelegate.communicationManager = CommunicationManager()
//                                        self.appDelegate.multipeerCommunicator = MultipeerCommunicator()
//                                        self.appDelegate.multipeerCommunicator.delegate = self.appDelegate.communicationManager
//                                        conversationList!.sortedOnlineData = conversationList!.getSortedOnlineData()
//                                        self.appDelegate.communicationManager.conversationsList = conversationList
                                    } :
                                    { [unowned self] in self.profileDataDelegate?.savingProfileDataFinished()
                                    },
                                  failureToDoOnMain: { [unowned self] in self.profileDataDelegate?.savingProfileDataFailed() })
    }
    func loadProfileData() {
        appUser = coreDataStack.findOrInsertAppUser(in: coreDataStack.dataContext)
        profileDataDelegate?.loadingProfileDataFinished()
    }
    
}
