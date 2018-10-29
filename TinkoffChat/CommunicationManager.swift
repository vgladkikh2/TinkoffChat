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
    
    func didFoundUser(userId: String, userName: String?) {
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
        if toUser == UIDevice.current.name {
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
