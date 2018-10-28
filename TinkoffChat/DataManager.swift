//
//  DataManager.swift
//  TinkoffChat
//
//  Created by me on 21/10/2018.
//  Copyright © 2018 gladkikh. All rights reserved.
//

import Foundation

protocol DataManager {
    var username: String? { get set }
    var about: String? { get set }
    var avatar: UIImage? { get set }
    var delegate: DataManagerDelegate? { get set }
    init(usernameKey: String, aboutKey: String, avatarFile: String)
    func saveData(username: String?, about: String?, avatar: UIImage?)
    func loadData()
}



extension DataManager {
    static func SaveDataToFile(image: UIImage, file: String) -> Bool {
        if let data = image.pngData() {
            let fileManager = FileManager.default
            let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(file)
            fileManager.createFile(atPath: path as String, contents: data, attributes: nil)
            return true
        } else {
            return false
        }
    }
    static func SaveInfoToUserDefaults(info: String, key: String) -> Bool {
        do {
            try UserDefaults.standard.setValue(NSKeyedArchiver.archivedData(withRootObject: info, requiringSecureCoding: false), forKey: key)
            UserDefaults.standard.synchronize()
            return true
        } catch {
            print("Cannot save info = \"\(info)\" for key = \"\(key)\" to UserDefaults")
            return false
        }
    }
    static func LoadDataFromFile(file: String) -> UIImage? {
        let fileManager = FileManager.default
        let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(file)
        if fileManager.fileExists(atPath: path) {
            return UIImage(contentsOfFile: path)
        } else {
            return nil
        }
    }
    static func LoadInfoFromUserDefaults(key: String) -> String? {
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
