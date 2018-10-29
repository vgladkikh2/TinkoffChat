//
//  ConversationViewController.swift
//  TinkoffChat
//
//  Created by me on 06/10/2018.
//  Copyright © 2018 gladkikh. All rights reserved.
//

import UIKit

protocol MessageCellConfiguration: class {
    
    var message: String? { get set }
    
}

class ConversationCell: UITableViewCell, MessageCellConfiguration {
    
    @IBOutlet weak var messageLabel: UILabel!
    
    var message: String? {
        didSet {
            messageLabel?.text = message
        }
    }
    
    func setParameters(message: String?) {
        self.message = message
    }
    
}

class ConversationViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var textInputField: UITextField!
    @IBAction func sendButtonPressed(_ sender: Any) {
        if let message = textInputField.text {
            appDelegate.multipeerCommunicator.sendMessage(string: message, to: userIdInConversation, completionHandler: nil)
        }
        textInputField.text = nil
        textInputField.resignFirstResponder()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var userIdInConversation: String = ""
    func updateConversation() {
        if appDelegate.communicationManager.usersOnline[userIdInConversation] == nil {
            sendButton.isEnabled = false
            sendButton.alpha = 0.5
        } else {
            sendButton.isEnabled = true
            sendButton.alpha = 1.0
        }
        self.tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 44
        self.title = appDelegate.communicationManager.usersOnline[userIdInConversation] ?? nil
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appDelegate.communicationManager.usersChatMessages[userIdInConversation]?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cellIdentifier: String = ""
        switch appDelegate.communicationManager.usersChatMessages[userIdInConversation]?[indexPath.row].side {
        case 0:
            cellIdentifier = "ConversationCellUser"
        case 1:
            cellIdentifier = "ConversationCellCompanion"
        default:
            assertionFailure("Not online/offline conversation")
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ConversationCell
        cell.setParameters(message: appDelegate.communicationManager.usersChatMessages[userIdInConversation]?[indexPath.row].message)
        return cell
    }

}
