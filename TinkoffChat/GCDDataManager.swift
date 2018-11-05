//
//  GCDDataManager.swift
//  TinkoffChat
//
//  Created by me on 21/10/2018.
//  Copyright © 2018 gladkikh. All rights reserved.
//

import Foundation

class GCDDataManager: FileManagerAndDefaultsHelper, ProfileDataManager {
    var profileUsername: String?
    var profileAbout: String?
    var profileAvatar: UIImage?
    private var usernameKey: String = "username"
    private var aboutKey: String = "about"
    private var avatarFile: String = "avatar.png"
    private var isLastSaveSuccess: Bool = true
    
    weak var profileDataDelegate: ProfileDataManagerDelegate?
    
    func saveProfileData(username: String?, about: String?, avatar: UIImage?) {
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
                    self.profileDataDelegate?.savingProfileDataFinished()
                } else {
                    self.profileDataDelegate?.savingProfileDataFailed()
                }
            }
        }
    }
    
    func loadProfileData() {
        let queue = DispatchQueue(label:"readSerialQueue")
        queue.async{
//            sleep(2)
            self.profileAvatar = GCDDataManager.LoadDataFromFile(file: self.avatarFile)
            self.profileUsername = GCDDataManager.LoadInfoFromUserDefaults(key: self.usernameKey)
            self.profileAbout = GCDDataManager.LoadInfoFromUserDefaults(key: self.aboutKey)
            DispatchQueue.main.async {
                self.profileDataDelegate?.loadingProfileDataFinished()
            }
        }
    }

}
