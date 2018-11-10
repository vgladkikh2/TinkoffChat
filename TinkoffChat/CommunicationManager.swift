//
//  CommunicationManager.swift
//  TinkoffChat
//
//  Created by me on 28/10/2018.
//  Copyright © 2018 gladkikh. All rights reserved.
//

import Foundation

class CommunicationManager: CommunicatorDelegate {
    
    weak var conversationsList: ConversationsListViewController?
    weak var conversation: ConversationViewController?
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func didFoundUser(userId: String, userName: String?) {
        appDelegate.storageDataManager?.saveUserStateChange(userId: userId, userName: userName, isOnline: true)
        usersOnline[userId] = userName
        if usersChatMessages[userId] == nil {
           usersChatMessages[userId] = []
        }
        DispatchQueue.main.async {
            self.conversationsList?.updateConversationsListTable()
            self.conversation?.updateConversation()
        }
    }
    func didLostUser(userId: String) {
        appDelegate.storageDataManager?.saveUserStateChange(userId: userId, isOnline: false)
        usersOnline[userId] = nil
        DispatchQueue.main.async {
            self.conversationsList?.updateConversationsListTable()
            self.conversation?.updateConversation()
        }
    }
    func failedToStartBrowsingForUsers(error: Error) {
        print("failedToStartBrowsingForUsers")
    }
    func failedToStartAdvertising(error: Error) {
        print("failedToStartAdvertising")
    }
    func didReceiveMessage(text: String, fromUser: String, toUser: String) {
        guard let myUserId = appDelegate.storageDataManager?.appUser?.currentUser?.userId else {
            assert(false, "cannot retrieve userId")
        }
        if toUser == myUserId {
            if usersChatMessages[fromUser] != nil {
                usersChatMessages[fromUser]!.append((side: 1, message: text, date: Date.init(timeIntervalSinceNow: 0.0), unreaded: true))
            } else {
                usersChatMessages[fromUser] = [(side: 1, message: text, date: Date.init(timeIntervalSinceNow: 0.0), unreaded: true)]
            }
        } else {
            if usersChatMessages[toUser] != nil {
                usersChatMessages[toUser]!.append((side: 0, message: text, date: Date.init(timeIntervalSinceNow: 0.0), unreaded: false))
            } else {
                usersChatMessages[toUser] = [(side: 0, message: text, date: Date.init(timeIntervalSinceNow: 0.0), unreaded: false)]
            }
        }
        DispatchQueue.main.async {
            self.conversationsList?.updateConversationsListTable()
            self.conversation?.updateConversation()
        }
    }
    var usersOnline: [String: String?] = [:]
    var usersChatMessages: [String: [(side: Int, message: String, date: Date, unreaded: Bool)]] = [:]
}
