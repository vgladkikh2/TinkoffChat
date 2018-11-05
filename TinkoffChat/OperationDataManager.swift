//
//  OperationDataManager.swift
//  TinkoffChat
//
//  Created by me on 21/10/2018.
//  Copyright © 2018 gladkikh. All rights reserved.
//

import Foundation

class OperationDataManager: ProfileDataManager {
    
    class SaveProfileDataOperation: Operation {
        var username: String?
        var about: String?
        var avatar: UIImage?
        var isSuccess: Bool = true
        init(username: String?, about: String?, avatar: UIImage?) {
            self.username = username
            self.about = about
            self.avatar = avatar
        }
        override func main() {
//            sleep(2)
            if let image = avatar {
                if isSuccess {
                    isSuccess = FileManagerAndDefaultsHelper.SaveDataToFile(image: image, file: FileManagerAndDefaultsHelper.avatarFile)
                }
            }
            if let info = username {
                if isSuccess {
                    isSuccess = FileManagerAndDefaultsHelper.SaveInfoToUserDefaults(info: info, key: FileManagerAndDefaultsHelper.usernameKey)
                }
            }
            if let info = about {
                if isSuccess {
                    isSuccess = FileManagerAndDefaultsHelper.SaveInfoToUserDefaults(info: info, key: FileManagerAndDefaultsHelper.aboutKey)
                }
            }
        }
    }
    
    class LoadProfileDataOperation: Operation {
        var username: String?
        var about: String?
        var avatar: UIImage?
        
        override func main() {
//            sleep(2)
            username = FileManagerAndDefaultsHelper.LoadInfoFromUserDefaults(key: FileManagerAndDefaultsHelper.usernameKey)
            about = FileManagerAndDefaultsHelper.LoadInfoFromUserDefaults(key: FileManagerAndDefaultsHelper.aboutKey)
            avatar = FileManagerAndDefaultsHelper.LoadDataFromFile(file: FileManagerAndDefaultsHelper.avatarFile)
        }
    }
    
    var profileUsername: String?
    var profileAbout: String?
    var profileAvatar: UIImage?
    private var isLastSaveSuccess: Bool = true
    
    weak var profileDataDelegate: ProfileDataManagerDelegate?
    
    func saveProfileData(username: String?, about: String?, avatar: UIImage?) {
        let saveProfileDataOperation = SaveProfileDataOperation(username: username, about: about, avatar: avatar)
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
        let loadProfileDataOperation = LoadProfileDataOperation()
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
