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
    var profileAvatar: UIImage?
    var profileDataDelegate: ProfileDataManagerDelegate?
    var coreDataStack: CoreDataStack
    var appUser: AppUser?
    
    init() {
        coreDataStack = CoreDataStack()
        appUser = coreDataStack.findOrInsertAppUser(in: coreDataStack.dataContext)
    }
    
    func saveProfileData(username: String?, about: String?, avatar: UIImage?) {
        if username != nil {
            appUser?.currentUser?.name = username
        }
        if about != nil {
            appUser?.currentUser?.about = about
        }
        coreDataStack.performSave(with: coreDataStack.dataContext, completion: profileDataDelegate?.savingProfileDataFinished)
    }
    func loadProfileData() {
        appUser = coreDataStack.findOrInsertAppUser(in: coreDataStack.dataContext)
        profileDataDelegate?.loadingProfileDataFinished()
    }
    
}
