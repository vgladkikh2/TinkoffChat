//
//  DataManager.swift
//  TinkoffChat
//
//  Created by me on 21/10/2018.
//  Copyright © 2018 gladkikh. All rights reserved.
//

import Foundation

protocol ProfileDataManager {
    var profileUsername: String? { get }
    var profileAbout: String? { get }
    var profileAvatar: UIImage? { get }
    var profileDataDelegate: ProfileDataManagerDelegate? { get set }
    func saveProfileData(username: String?, about: String?, avatar: UIImage?)
    func loadProfileData()
}
