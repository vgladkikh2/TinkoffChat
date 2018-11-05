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
    func saveData(username: String?, about: String?, avatar: UIImage?)
    func loadData()
}
