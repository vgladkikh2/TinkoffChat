//
//  GCDDataManager.swift
//  TinkoffChat
//
//  Created by me on 21/10/2018.
//  Copyright © 2018 gladkikh. All rights reserved.
//

import Foundation

class GCDDataManager: ProfileDataManager {
    var profileUsername: String?
    var profileAbout: String?
    var profileAvatar: UIImage?
    private var isLastSaveSuccess: Bool = true
    
    weak var profileDataDelegate: ProfileDataManagerDelegate?
    
    func saveProfileData(username: String?, about: String?, avatar: UIImage?) {
        isLastSaveSuccess = true
        let queue = DispatchQueue(label:"writeSerialQueue")
        queue.async{
//            sleep(2)
            if let image = avatar {
                if self.isLastSaveSuccess {
                    self.isLastSaveSuccess = FileManagerAndDefaultsHelper.SaveDataToFile(image: image, file: FileManagerAndDefaultsHelper.avatarFile)
                }
            }
            if let info = username {
                if self.isLastSaveSuccess {
                    self.isLastSaveSuccess = FileManagerAndDefaultsHelper.SaveInfoToUserDefaults(info: info, key: FileManagerAndDefaultsHelper.usernameKey)
                }
            }
            if let info = about {
                if self.isLastSaveSuccess {
                    self.isLastSaveSuccess = FileManagerAndDefaultsHelper.SaveInfoToUserDefaults(info: info, key: FileManagerAndDefaultsHelper.aboutKey)
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
            self.profileAvatar = FileManagerAndDefaultsHelper.LoadDataFromFile(file: FileManagerAndDefaultsHelper.avatarFile)
            self.profileUsername = FileManagerAndDefaultsHelper.LoadInfoFromUserDefaults(key: FileManagerAndDefaultsHelper.usernameKey)
            self.profileAbout = FileManagerAndDefaultsHelper.LoadInfoFromUserDefaults(key: FileManagerAndDefaultsHelper.aboutKey)
            DispatchQueue.main.async {
                self.profileDataDelegate?.loadingProfileDataFinished()
            }
        }
    }

}
