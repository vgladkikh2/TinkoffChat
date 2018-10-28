//
//  OperationDataManager.swift
//  TinkoffChat
//
//  Created by me on 21/10/2018.
//  Copyright © 2018 gladkikh. All rights reserved.
//

import Foundation

class OperationDataManager: DataManager {
    
    class SaveDataOperation: Operation {
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
    
    class LoadDataOperation: Operation {
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
    
    var username: String?
    var about: String?
    var avatar: UIImage?
    private var usernameKey: String
    private var aboutKey: String
    private var avatarFile: String
    private var isLastSaveSuccess: Bool = true
    
    required init(usernameKey: String, aboutKey: String, avatarFile: String) {
        self.usernameKey = usernameKey
        self.aboutKey = aboutKey
        self.avatarFile = avatarFile
    }
    
    weak var delegate: DataManagerDelegate?
    
    func saveData(username: String?, about: String?, avatar: UIImage?) {
        let saveDataOperation = SaveDataOperation(username: username, about: about, avatar: avatar, usernameKey: self.usernameKey, aboutKey: self.aboutKey, avatarFile: self.avatarFile)
        saveDataOperation.completionBlock = {
            OperationQueue.main.addOperation {
                if saveDataOperation.isSuccess {
                    self.delegate?.savingDataFinished()
                } else {
                    self.delegate?.savingDataFailed()
                }
            }
        }
        let saveQueue = OperationQueue()
        saveQueue.maxConcurrentOperationCount = 1
        saveQueue.addOperation(saveDataOperation)
    }
    
    func loadData() {
        let loadDataOperation = LoadDataOperation(usernameKey: self.usernameKey, aboutKey: self.aboutKey, avatarFile: self.avatarFile)
        loadDataOperation.completionBlock = {
            OperationQueue.main.addOperation {
                self.username = loadDataOperation.username
                self.about = loadDataOperation.about
                self.avatar = loadDataOperation.avatar
                self.delegate?.loadingDataFinished()
            }
        }
        let loadQueue = OperationQueue()
        loadQueue.maxConcurrentOperationCount = 1
        loadQueue.addOperation(loadDataOperation)
    }
    
}
