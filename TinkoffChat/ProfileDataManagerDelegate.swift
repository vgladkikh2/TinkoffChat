//
//  DataManagerDelegate.swift
//  TinkoffChat
//
//  Created by me on 21/10/2018.
//  Copyright © 2018 gladkikh. All rights reserved.
//

import Foundation

protocol ProfileDataManagerDelegate: class {
    func loadingProfileDataFinished()
    func savingProfileDataFinished()
    func savingProfileDataFailed()
}
