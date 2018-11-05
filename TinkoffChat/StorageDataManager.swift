//
//  StorageManager.swift
//  TinkoffChat
//
//  Created by me on 05/11/2018.
//  Copyright © 2018 gladkikh. All rights reserved.
//

import Foundation

class StorageDataManager: ProfileDataManager {
    var profileUsername: String? {
        return appUser?.currentUser?.name
    }
    var profileAbout: String? {
        return appUser?.currentUser?.about
    }
    var profileAvatar: UIImage? {
        return nil //...
    }
    weak var profileDataDelegate: ProfileDataManagerDelegate?
    var coreDataStack: CoreDataStack
    var appUser: AppUser?
    
    init() {
        coreDataStack = CoreDataStack()
    }
    
    func saveProfileData(username: String?, about: String?, avatar: UIImage?) {
        if username != nil {
            appUser?.currentUser?.name = username
        }
        if about != nil {
            appUser?.currentUser?.about = about
        }
        if avatar != nil {
//            appUser?.currentUser?.avatar = ...
        }
        coreDataStack.performSave(with: coreDataStack.dataContext, completionOnMain: profileDataDelegate?.savingProfileDataFinished)
    }
    func loadProfileData() {
//        print("loadProfileData start")
        appUser = coreDataStack.findOrInsertAppUser(in: coreDataStack.dataContext)
//        print("loadProfileData end")
        profileDataDelegate?.loadingProfileDataFinished()
    }
    
}
