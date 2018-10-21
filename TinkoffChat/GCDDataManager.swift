//
//  GCDDataManager.swift
//  TinkoffChat
//
//  Created by me on 21/10/2018.
//  Copyright © 2018 gladkikh. All rights reserved.
//

import Foundation

class GCDDataManager: DataManager {

    var username: String?
    var about: String?
    var avatar: UIImage?
    private var usernameKey: String
    private var aboutKey: String
    private var avatarFile: String
    
    required init(usernameKey: String, aboutKey: String, avatarFile: String) {
        self.usernameKey = usernameKey
        self.aboutKey = aboutKey
        self.avatarFile = avatarFile
    }
    
    var delegate: DataManagerDelegate?
    
    func saveData(username: String?, about: String?, avatar: UIImage?) {
        if let info = username {
            saveInfoToUserDefaults(info: info, key: usernameKey)
        }
        if let info = about {
            saveInfoToUserDefaults(info: info, key: aboutKey)
        }
        if let image = avatar {
            saveDataToFile(image: image, file: avatarFile)
        }
        delegate?.savingDataFinished()
    }
    
    func loadData() {
        username = loadInfoFromUserDefaults(key: usernameKey)
        about = loadInfoFromUserDefaults(key: aboutKey)
        avatar = loadDataFromFile(file: avatarFile)
        delegate?.loadingDataFinished()
    }
    
    
    private func saveDataToFile(image: UIImage, file: String) {
        print("saveDataToFile \(file)")
//        delegate?.savingDataFailed()
    }
    
    private func saveInfoToUserDefaults(info: String, key: String) {
        do {
            try UserDefaults.standard.setValue(NSKeyedArchiver.archivedData(withRootObject: info, requiringSecureCoding: false), forKey: key)
            UserDefaults.standard.synchronize()
        } catch {
            print("Cannot save info = \"\(info)\" for key = \"\(key)\" to UserDefaults")
            delegate?.savingDataFailed()
        }
    }
    
    private func loadDataFromFile(file: String) -> UIImage? {
        print("loadDataFromFile \(file)")
        return UIImage()
    }
    
    private func loadInfoFromUserDefaults(key: String) -> String? {
        if let data = UserDefaults.standard.data(forKey: key) {
            do {
                let info = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? String
                return info
            } catch {
                print("Cannot load info for key = \"\(key)\" from UserDefaults")
            }
        }
        return nil
    }
    
}
