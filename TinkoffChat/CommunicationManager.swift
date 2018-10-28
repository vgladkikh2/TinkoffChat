//
//  CommunicationManager.swift
//  TinkoffChat
//
//  Created by me on 28/10/2018.
//  Copyright © 2018 gladkikh. All rights reserved.
//

import Foundation

class CommunicationManager: CommunicatorDelegate {
    
//    weak var communicationManager: CommunicationManager?
    
    func didFoundUser(userId: String, userName: String?) {
        usersOnline[userId]! = userName
    }
    func didLostUser(userId: String) {
        usersOnline[userId]! = nil
    }
    func failedToStartBrowsingForUsers(error: Error) {
        print("failedToStartBrowsingForUsers")
    }
    func failedToStartAdvertising(error: Error) {
        print("failedToStartAdvertising")
    }
    func didReceiveMessage(text: String, fromUser: String, toUser: String) {
        if toUser == UIDevice.current.name {
            usersMessages[fromUser]!.append(text)
        } else {
            // Cannot be
        }
    }
    
    var usersOnline: [String: String?] = [:]
    var usersMessages: [String: [String]] = [:]
}
