//
//  GCDDataManager.swift
//  TinkoffChat
//
//  Created by me on 21/10/2018.
//  Copyright © 2018 gladkikh. All rights reserved.
//

import Foundation

class GCDDataManager: FileManagerAndDefaultsHelper, DataManager {

    var username: String?
    var about: String?
    var avatar: UIImage?
    private var usernameKey: String = "username"
    private var aboutKey: String = "about"
    private var avatarFile: String = "avatar.png"
    private var isLastSaveSuccess: Bool = true
    
    weak var delegate: DataManagerDelegate?
    
    func saveData(username: String?, about: String?, avatar: UIImage?) {
        isLastSaveSuccess = true
        let queue = DispatchQueue(label:"writeSerialQueue")
        queue.async{
//            sleep(2)
            if let image = avatar {
                if self.isLastSaveSuccess {
                    self.isLastSaveSuccess = GCDDataManager.SaveDataToFile(image: image, file: self.avatarFile)
                }
            }
            if let info = username {
                if self.isLastSaveSuccess {
                    self.isLastSaveSuccess = GCDDataManager.SaveInfoToUserDefaults(info: info, key: self.usernameKey)
                }
            }
            if let info = about {
                if self.isLastSaveSuccess {
                    self.isLastSaveSuccess = GCDDataManager.SaveInfoToUserDefaults(info: info, key: self.aboutKey)
                }
            }
            DispatchQueue.main.async {
                if self.isLastSaveSuccess {
                    self.delegate?.savingDataFinished()
                } else {
                    self.delegate?.savingDataFailed()
                }
            }
        }
    }
    
    func loadData() {
        let queue = DispatchQueue(label:"readSerialQueue")
        queue.async{
//            sleep(2)
            self.avatar = GCDDataManager.LoadDataFromFile(file: self.avatarFile)
            self.username = GCDDataManager.LoadInfoFromUserDefaults(key: self.usernameKey)
            self.about = GCDDataManager.LoadInfoFromUserDefaults(key: self.aboutKey)
            DispatchQueue.main.async {
                self.delegate?.loadingDataFinished()
            }
        }
    }

}
