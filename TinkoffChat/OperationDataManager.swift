//
//  OperationDataManager.swift
//  TinkoffChat
//
//  Created by me on 21/10/2018.
//  Copyright © 2018 gladkikh. All rights reserved.
//

import Foundation

class OperationDataManager: FileManagerAndDefaultsHelper, ProfileDataManager {
    
    class SaveProfileDataOperation: Operation {
        var username: String?
        var about: String?
        var avatar: UIImage?
        var usernameKey: String
        var aboutKey: String
        var avatarFile: String
        var isSuccess: Bool = true
        init(username: String?, about: String?, avatar: UIImage?, usernameKey: String, aboutKey: String, avatarFile: String) {
            self.username = username
            self.about = about
            self.avatar = avatar
            self.usernameKey = usernameKey
            self.aboutKey = aboutKey
            self.avatarFile = avatarFile
        }
        override func main() {
//            sleep(2)
            if let image = avatar {
                if isSuccess {
                    isSuccess = OperationDataManager.SaveDataToFile(image: image, file: avatarFile)
                }
            }
            if let info = username {
                if isSuccess {
                    isSuccess = OperationDataManager.SaveInfoToUserDefaults(info: info, key: usernameKey)
                }
            }
            if let info = about {
                if isSuccess {
                    isSuccess = OperationDataManager.SaveInfoToUserDefaults(info: info, key: aboutKey)
                }
            }
        }
    }
    
    class LoadProfileDataOperation: Operation {
        var usernameKey: String
        var aboutKey: String
        var avatarFile: String
        var username: String?
        var about: String?
        var avatar: UIImage?
        init(usernameKey: String, aboutKey: String, avatarFile: String) {
            self.usernameKey = usernameKey
            self.aboutKey = aboutKey
            self.avatarFile = avatarFile
        }
        override func main() {
//            sleep(2)
            username = OperationDataManager.LoadInfoFromUserDefaults(key: usernameKey)
            about = OperationDataManager.LoadInfoFromUserDefaults(key: aboutKey)
            avatar = OperationDataManager.LoadDataFromFile(file: avatarFile)
        }
    }
    
    var profileUsername: String?
    var profileAbout: String?
    var profileAvatar: UIImage?
    private var usernameKey: String = "username"
    private var aboutKey: String = "about"
    private var avatarFile: String = "avatar.png"
    private var isLastSaveSuccess: Bool = true
    
    weak var profileDataDelegate: ProfileDataManagerDelegate?
    
    func saveProfileData(username: String?, about: String?, avatar: UIImage?) {
        let saveProfileDataOperation = SaveProfileDataOperation(username: username, about: about, avatar: avatar, usernameKey: self.usernameKey, aboutKey: self.aboutKey, avatarFile: self.avatarFile)
        saveProfileDataOperation.completionBlock = {
            OperationQueue.main.addOperation {
                if saveProfileDataOperation.isSuccess {
                    self.profileDataDelegate?.savingProfileDataFinished()
                } else {
                    self.profileDataDelegate?.savingProfileDataFailed()
                }
            }
        }
        let saveQueue = OperationQueue()
        saveQueue.maxConcurrentOperationCount = 1
        saveQueue.addOperation(saveProfileDataOperation)
    }
    
    func loadProfileData() {
        let loadProfileDataOperation = LoadProfileDataOperation(usernameKey: self.usernameKey, aboutKey: self.aboutKey, avatarFile: self.avatarFile)
        loadProfileDataOperation.completionBlock = {
            OperationQueue.main.addOperation {
                self.profileUsername = loadProfileDataOperation.username
                self.profileAbout = loadProfileDataOperation.about
                self.profileAvatar = loadProfileDataOperation.avatar
                self.profileDataDelegate?.loadingProfileDataFinished()
            }
        }
        let loadQueue = OperationQueue()
        loadQueue.maxConcurrentOperationCount = 1
        loadQueue.addOperation(loadProfileDataOperation)
    }
    
}
