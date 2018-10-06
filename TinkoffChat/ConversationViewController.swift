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

class ConversationCell: UITableViewCell {
    
    @IBOutlet weak var messageLabel: UILabel!
    
    var message: String? {
        didSet {
            self.messageLabel?.text = message
        }
    }
    
    func setParameters(message: String?) {
        self.message = message
    }
    
}

class ConversationViewController: UITableViewController {
    
    var conversationData: ConversationData!
    
    // test data:
    var messages = [(side: Int, message: String)]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 44
        self.title = conversationData.name
        // fill test data:
        for i in 0...40 {
            var side = 0
            if i % 2 == 0 {
                side = 1
            }
            var message = "ASD\(i) ASD\(conversationData.name ?? "no name")"
            if i % 3 == 0 {
                message = "ASssssdddssdddsssssssD\(i) ASddddddddddddfffffffddD\(conversationData.name ?? "no name")"
            }
            messages.append((side, message))
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cellIdentifier = "ConversationCellUser"
        if messages[indexPath.row].side == 1 {
            cellIdentifier = "ConversationCellCompanion"
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ConversationCell
        cell.setParameters(message: messages[indexPath.row].message)
        return cell
    }

}
