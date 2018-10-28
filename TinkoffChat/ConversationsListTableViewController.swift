//
//  ConversationsListTableViewController.swift
//  TinkoffChatProductTwo
//
//  Created by me on 14/10/2018.
//  Copyright © 2018 gladkikh. All rights reserved.
//

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
    var online: Bool { get set }
    var hasUnreadMessages: Bool { get set }
    
}

class ConversationsListCell: UITableViewCell, ConversationCellConfiguration {
    
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelMessage: UILabel!
    @IBOutlet weak var labelDate: UILabel!
    
    private func getRightFont(message: String?, hasUnreadMessages: Bool) -> UIFont {
        if message != nil {
            if hasUnreadMessages {
                return UIFont.boldSystemFont(ofSize: labelMessage.font.pointSize)
            } else {
                return UIFont.systemFont(ofSize: self.labelMessage.font.pointSize)
            }
        } else {
            if let font = UIFont(name: "HelveticaNeue-Italic", size: labelMessage.font.pointSize) {
                return font
            } else {
                return UIFont.italicSystemFont(ofSize: labelMessage.font.pointSize)
            }
        }
    }
    
    var name: String? {
        didSet {
            labelName.text = name ?? "Unnamed"
        }
    }
    var message: String? {
        didSet {
            labelMessage.font = getRightFont(message: message, hasUnreadMessages: hasUnreadMessages)
            if message != nil {
                labelMessage.text = message
            } else {
                labelMessage.text = "No messages yet"
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
                labelDate.text = dateFormatter.string(from: date!)
            } else {
                labelDate.text = ""
            }
        }
    }
    var online: Bool = false {
        didSet {
            if online {
                backgroundColor = UIColor(red: 255.0/255, green: 250.0/255, blue: 245.0/255, alpha: 1.0)
            } else {
                backgroundColor = UIColor.white
            }
        }
    }
    var hasUnreadMessages: Bool = false {
        didSet {
            labelMessage.font = getRightFont(message: message, hasUnreadMessages: hasUnreadMessages)
        }
    }
    
    func setParameters(name: String?, message: String?, date: Date?, online: Bool, hasUnreadMessages: Bool) {
        self.name = name
        self.message = message
        self.date = date
        self.online = online
        self.hasUnreadMessages = hasUnreadMessages
    }
    
}

// test data type:
class ConversationData: ConversationCellConfiguration {
    
    var name: String?
    var message: String?
    var date: Date?
    var online: Bool
    var hasUnreadMessages: Bool
    
    init(name: String?, message: String?, date: Date?, online: Bool, hasUnreadMessages: Bool) {
        self.name = name
        self.message = message
        self.date = date
        self.online = online
        self.hasUnreadMessages = hasUnreadMessages
    }
    
}

class ConversationsListViewController: UITableViewController {
    
    func updateConversationsListTable() {
        self.tableView.reloadData()
    }
    
    // test data:
    var onlineConversationsData = [ConversationData]()
    var offlineConversationsData = [ConversationData]()
    
    func logThemeChanging(selectedTheme: UIColor) {
        print("(swift version) \(selectedTheme)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 60
        // done 4 lines below in storyboard:
        //        self.title = "Tinkoff Chat"
        //        let backItem = UIBarButtonItem()
        //        backItem.title = ""
        //        self.navigationItem.backBarButtonItem = backItem
        // fill test data:
        for i in 1...15 {
            let hasMessages = (i % 2 == 0 ? true : false)
            let hasUnreadMessages = (hasMessages ? (i % 4 == 0 ? true : false) : false)
            let message = (hasMessages ? "Message\(i)" : nil)
            let dateInSeconds = -(3600.0*2 + 60.0*3 + 2.0) * Double(i)
            let date: Date? = (hasMessages ? Date(timeIntervalSinceNow: dateInSeconds) : nil)
            onlineConversationsData.append(ConversationData(name: "NameOnline\(i)", message: message, date: date, online: true, hasUnreadMessages: hasUnreadMessages))
        }
        for i in 1...20 {
            let hasMessages = (i % 2 == 0 ? true : false)
            let hasUnreadMessages = (hasMessages ? (i % 4 == 0 ? true : false) : false)
            let message = (hasMessages ? "Message\(i)" : nil)
            let dateInSeconds = -(3600.0*3 + 60.0*2 + 1.0) * Double(i)
            let date: Date? = (hasMessages ? Date(timeIntervalSinceNow: dateInSeconds) : nil)
            offlineConversationsData.append(ConversationData(name: "NameOffline\(i)", message: message, date: date, online: false, hasUnreadMessages: hasUnreadMessages))
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
            cell.setParameters(name: onlineConversationsData[indexPath.row].name, message: onlineConversationsData[indexPath.row].message, date: onlineConversationsData[indexPath.row].date, online: onlineConversationsData[indexPath.row].online, hasUnreadMessages: onlineConversationsData[indexPath.row].hasUnreadMessages)
        case 1:
            cell.setParameters(name: offlineConversationsData[indexPath.row].name, message: offlineConversationsData[indexPath.row].message, date: offlineConversationsData[indexPath.row].date, online:  offlineConversationsData[indexPath.row].online, hasUnreadMessages: offlineConversationsData[indexPath.row].hasUnreadMessages)
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
        if segue.identifier == "openThemes" {
            print("(swift version) open themes")
            ((segue.destination as! UINavigationController).topViewController as! ThemesViewController).themeChanged = { (newColor:UIColor?) -> Void in if let color = newColor {self.logThemeChanging(selectedTheme: color)} }
        }
    }
    
}
