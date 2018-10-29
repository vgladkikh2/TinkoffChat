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
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func getSortedOnlineDataForIndex(index: Int) -> (name: String?, message: String?, date: Date?, online: Bool, hasUnreadMessages: Bool) {
        var data: [(name: String?, message: String?, date: Date?, online: Bool, hasUnreadMessages: Bool)] = []
        for key in appDelegate.communicationManager.usersOnline.keys {
            let cntMessages = appDelegate.communicationManager.usersChatMessages[key]!.count - 1
            if cntMessages >= 0 {
                data.append((name: appDelegate.communicationManager.usersOnline[key] ?? nil,
                             message: appDelegate.communicationManager.usersChatMessages[key]?[cntMessages].message,
                             date: appDelegate.communicationManager.usersChatMessages[key]?[cntMessages].date,
                             online: true,
                             hasUnreadMessages: appDelegate.communicationManager.usersChatMessages[key]?[cntMessages].unreaded ?? false
                         ))
            } else {
                data.append((name: appDelegate.communicationManager.usersOnline[key] ?? nil,
                             message: nil,
                             date: nil,
                             online: true,
                             hasUnreadMessages: false))
            }
        }
        var swapped = false
        repeat {
            swapped = false
            for i in 1..<data.count {
                if data[i-1].date == nil {
                    if data[i].date != nil {
                        swapped = true
                    } else {
                        if data[i-1].name == nil {
                            if data[i].name != nil {
                                swapped = true
                            } else {
                                swapped = false
                            }
                        } else {
                            if data[i].name != nil && data[i-1].name! > data[i].name! {
                                swapped = true
                            } else {
                                swapped = false
                            }
                        }
                    }
                } else {
                    if data[i].date != nil {
                        if data[i-1].date! < data[i].date! {
                            swapped = true
                        }
                    } else {
                        swapped = false
                    }
                }
                if swapped {
                    let tmp = data[i]
                    data[i] = data[i-1]
                    data[i-1] = tmp
                }
            }
        } while swapped
        return data[index]
    }
    
    func updateConversationsListTable() {
        self.tableView.reloadData()
    }
    
    func logThemeChanging(selectedTheme: UIColor) {
        print("(swift version) \(selectedTheme)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate.communicationManager.conversationsList = self
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 60
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
            rowsCount = appDelegate.communicationManager.usersOnline.keys.count
        case 1:
            rowsCount = 0
        default:
            assertionFailure("Not online/offline conversation")
        }
        return rowsCount
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationsListCell", for: indexPath) as! ConversationsListCell
        switch indexPath.section {
        case 0:
            let data = getSortedOnlineDataForIndex(index: indexPath.row)
            cell.setParameters(name: data.name, message: data.message, date: data.date, online: data.online, hasUnreadMessages: data.hasUnreadMessages)
        case 1:
            assertionFailure("Cannot Be at homework 6")
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
            appDelegate.communicationManager.conversation = (segue.destination as! ConversationViewController)
            switch tableView.indexPathForSelectedRow!.section {
            case 0:
                (segue.destination as! ConversationViewController).userIdInConversation = appDelegate.communicationManager.usersOnline.keys.sorted()[tableView.indexPathForSelectedRow!.row]
            case 1:
                assertionFailure("Cannot Be at homework 6")
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
