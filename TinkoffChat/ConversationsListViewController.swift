//
//  ConversationsListViewController.swift
//  TinkoffChat
//
//  Created by me on 05/10/2018.
//  Copyright © 2018 gladkikh. All rights reserved.
//

import UIKit

protocol ConversationCellConfiguration: class {
    
    var name: String? { get set }
    var message: String? { get set }
    var date: Date? { get set }
    var online: Bool? { get set }
    var hasUnreadMessages: Bool? { get set }
    
}

class ConversationsListCell: UITableViewCell, ConversationCellConfiguration {
    
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelMessage: UILabel!
    @IBOutlet weak var labelDate: UILabel!
    
    var name: String? {
        didSet {
            self.labelName.text = name ?? "Unnamed"
        }
    }
    var message: String? {
        didSet {
            if message != nil {
                self.labelMessage.font = UIFont.systemFont(ofSize: self.labelMessage.font.pointSize)
                self.labelMessage.text = message
            } else {
                if let font = UIFont(name: "HelveticaNeue-Italic", size: self.labelMessage.font.pointSize) {
                    self.labelMessage.font = font
                } else {
                    self.labelMessage.font = UIFont.italicSystemFont(ofSize: self.labelMessage.font.pointSize)
                }
                self.labelMessage.text = "No messages yet"
            }
        }
    }
    var date: Date? {
        didSet {
            if date != nil {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM-dd-yyyy"
                let today = dateFormatter.date(from: (dateFormatter.string(from: Date(timeIntervalSinceNow: 0))))
                dateFormatter.locale = Locale(identifier: "ru_RU")
                if date! < today! {
                    dateFormatter.dateFormat = "dd MMM"
                } else {
                    dateFormatter.dateFormat = "HH:mm"
                }
                self.labelDate.text = dateFormatter.string(from: date!)
            } else {
                self.labelDate.text = ""
            }
        }
    }
    var online: Bool? {
        didSet {
            if online != nil {
                if online! {
                    self.backgroundColor = UIColor(red: 255.0/255, green: 250.0/255, blue: 245.0/255, alpha: 1.0)
                } else {
                    self.backgroundColor = UIColor.white
                }
            }
        }
    }
    var hasUnreadMessages: Bool? {
        didSet {
            if hasUnreadMessages != nil && self.message != nil {
                if hasUnreadMessages! {
                    self.labelMessage.font = UIFont.boldSystemFont(ofSize: self.labelMessage.font.pointSize)
                }
            }
        }
    }
    
    func setParameters(name: String?, message: String?, date: Date?, online: Bool?, hasUnreadMessages: Bool?) {
        self.name = name
        self.message = message
        self.date = date
        self.online = online
        self.hasUnreadMessages = hasUnreadMessages
    }
    
}

// test data type:
struct ConversationData {
    
    var name: String?
    var message: String?
    var date: Date?
    var hasUnreadMessages: Bool?
    
}

class ConversationsListViewController: UITableViewController {
    
    // test data:
    var onlineConversationsData = [ConversationData]()
    var offlineConversationsData = [ConversationData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 60
        self.title = "Tinkoff Chat"
        // fill test data:
        for i in 1...15 {
            let hasMessages = (i % 2 == 0 ? true : false)
            let hasUnreadMessages = (hasMessages ? (i % 4 == 0 ? true : false) : false)
            let message = (hasMessages ? "Message\(i)" : nil)
            let dateInSeconds = -(3600.0*2 + 60.0*3 + 2.0) * Double(i)
            let date: Date? = (hasMessages ? Date(timeIntervalSinceNow: dateInSeconds) : nil)
            onlineConversationsData.append(ConversationData(name: "NameOnline\(i)", message: message, date: date, hasUnreadMessages: hasUnreadMessages))
        }
        for i in 1...20 {
            let hasMessages = (i % 2 == 0 ? true : false)
            let hasUnreadMessages = (hasMessages ? (i % 4 == 0 ? true : false) : false)
            let message = (hasMessages ? "Message\(i)" : nil)
            let dateInSeconds = -(3600.0*3 + 60.0*2 + 1.0) * Double(i)
            let date: Date? = (hasMessages ? Date(timeIntervalSinceNow: dateInSeconds) : nil)
            offlineConversationsData.append(ConversationData(name: "NameOffline\(i)", message: message, date: date, hasUnreadMessages: hasUnreadMessages))
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var sectionHeader: String?
        switch section {
        case 0:
            sectionHeader = "Online"
        case 1:
            sectionHeader = "History"
        default:
            assertionFailure("Not online/offline conversation")
        }
        return sectionHeader
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowsCount = 0
        switch section {
        case 0:
            rowsCount = onlineConversationsData.count
        case 1:
            rowsCount = offlineConversationsData.count
        default:
            assertionFailure("Not online/offline conversation")
        }
        return rowsCount
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationsListCell", for: indexPath) as! ConversationsListCell
        switch indexPath.section {
        case 0:
            cell.setParameters(name: onlineConversationsData[indexPath.row].name, message: onlineConversationsData[indexPath.row].message, date: onlineConversationsData[indexPath.row].date, online: true, hasUnreadMessages: onlineConversationsData[indexPath.row].hasUnreadMessages)
        case 1:
            cell.setParameters(name: offlineConversationsData[indexPath.row].name, message: offlineConversationsData[indexPath.row].message, date: offlineConversationsData[indexPath.row].date, online: false, hasUnreadMessages: offlineConversationsData[indexPath.row].hasUnreadMessages)
        default:
            assertionFailure("Not online/offline conversation")
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "openConversation", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openConversation" {
            switch tableView.indexPathForSelectedRow!.section {
            case 0:
                (segue.destination as! ConversationViewController).conversationData = onlineConversationsData[tableView.indexPathForSelectedRow!.row]
            case 1:
                (segue.destination as! ConversationViewController).conversationData = offlineConversationsData[tableView.indexPathForSelectedRow!.row]
            default:
                assertionFailure("Not online/offline conversation")
            }
        }
    }

}
