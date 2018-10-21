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
        var success = true
        if let image = avatar {
            if success {
                success = saveDataToFile(image: image, file: avatarFile)
            }
        }
        if let info = username {
            if success {
                success = saveInfoToUserDefaults(info: info, key: usernameKey)
            }
        }
        if let info = about {
            if success {
                success = saveInfoToUserDefaults(info: info, key: aboutKey)
            }
        }
        if success {
            delegate?.savingDataFinished()
        } else {
            delegate?.savingDataFailed()
        }
    }
    
    func loadData() {
        username = loadInfoFromUserDefaults(key: usernameKey)
        about = loadInfoFromUserDefaults(key: aboutKey)
        avatar = loadDataFromFile(file: avatarFile)
        delegate?.loadingDataFinished()
    }
    
    
    private func saveDataToFile(image: UIImage, file: String) -> Bool {
        if let data = image.pngData() {
            guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else { return false }
            do {
                try data.write(to: directory.appendingPathComponent(file)!)
                return true
            } catch {
                print(error.localizedDescription)
                return false
            }
        } else {
            return false
        }
    }
    
    private func saveInfoToUserDefaults(info: String, key: String) -> Bool {
        do {
            try UserDefaults.standard.setValue(NSKeyedArchiver.archivedData(withRootObject: info, requiringSecureCoding: false), forKey: key)
            UserDefaults.standard.synchronize()
            return true
        } catch {
            print("Cannot save info = \"\(info)\" for key = \"\(key)\" to UserDefaults")
            return false
        }
    }
    
    private func loadDataFromFile(file: String) -> UIImage? {
        if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            return UIImage(contentsOfFile: URL(fileURLWithPath: dir.absoluteString).appendingPathComponent(file).path)
        }
        return nil
    }
    
    private func loadInfoFromUserDefaults(key: String) -> String? {
        if let data = UserDefaults.standard.data(forKey: key) {
            do {
                let info = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? String
                return info
            } catch {
                print("Cannot unarchive loaded info for key = \"\(key)\" from UserDefaults")
            }
        } else {
            print("Cannot load info for key = \"\(key)\" from UserDefaults")
        }
        return nil
    }
    
}
