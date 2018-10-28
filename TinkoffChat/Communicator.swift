//
//  Communicator.swift
//  TinkoffChat
//
//  Created by me on 28/10/2018.
//  Copyright © 2018 gladkikh. All rights reserved.
//

import Foundation

protocol Communicator {
    func sendMessage(string: String, to userId: String, completionHandler: ((_ success: Bool, _ error: Error?) -> ())?)
    var delegate: CommunicatorDelegate? { get set }
    var online: Bool? { get set }
}
