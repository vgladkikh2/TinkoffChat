//
//  MultipeerCommunicator.swift
//  TinkoffChat
//
//  Created by me on 28/10/2018.
//  Copyright © 2018 gladkikh. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class MultipeerCommunicator: NSObject, Communicator {
    func sendMessage(string: String, to userId: String, completionHandler: ((Bool, Error?) -> ())?) {
        if peersIdsNamesSessionsStates[userId] != nil {
            if peersIdsNamesSessionsStates[userId]!.state == MCSessionState.connected {
                let message = ["eventType": "TextMessage", "messageId": generateMessageID(), "text": string]
                do {
                    let data = try JSONSerialization.data(withJSONObject: message, options: [])
                    let session = peersIdsNamesSessionsStates[userId]!.session
                    let peers = [peersIdsNamesSessionsStates[userId]!.id]
                    try session.send(data, toPeers: peers, with: .reliable)
                    completionHandler?(true, nil)
                    delegate?.didReceiveMessage(text: string, fromUser: myPeerId.displayName, toUser: userId)
                } catch {
                    completionHandler?(false, error)
                }
            } else {
                completionHandler?(false, nil)
            }
        } else {
            completionHandler?(false, nil)
        }
    }
    weak var delegate: CommunicatorDelegate?
    var online: Bool?
    
    private let myPeerId: MCPeerID
    private let serviceAdvertiser : MCNearbyServiceAdvertiser
    private let serviceBrowser : MCNearbyServiceBrowser
    private var peersIdsNamesSessionsStates: [String: (id: MCPeerID, name: String?, session: MCSession, state: MCSessionState?)]
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override init() {
        guard let myUserId = appDelegate.storageDataManager?.appUser?.currentUser?.userId else {
            assert(false, "cannot retrieve userId")
        }
        self.myPeerId = MCPeerID(displayName: myUserId)
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: ["userName": appDelegate.storageDataManager?.appUser?.currentUser?.name ?? ""], serviceType: "tinkoff-chat")
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: "tinkoff-chat")
        self.peersIdsNamesSessionsStates = [:]
        super.init()
        self.serviceAdvertiser.delegate = self
        self.serviceAdvertiser.startAdvertisingPeer()
        self.serviceBrowser.delegate = self
        self.serviceBrowser.startBrowsingForPeers()
    }
    deinit {
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
    }
    
    func generateMessageID() -> String {
        let string = "\(arc4random_uniform(UINT32_MAX))+\(Date.timeIntervalSinceReferenceDate)".data(using: .utf8)?.base64EncodedString()
        return string!
    }
}

extension MultipeerCommunicator: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        var peerAlreadyInSession = false
//        for peer in peersIdsNamesSessionsStates.keys {
//            if (peersIdsNamesSessionsStates[peer]?.state == MCSessionState.connected || peersIdsNamesSessionsStates[peer]?.state == MCSessionState.connecting) {
//                peerAlreadyInSession = true
//            }
//        }
        for peer in peersIdsNamesSessionsStates.keys {
            for connectedPeer in peersIdsNamesSessionsStates[peer]!.session.connectedPeers {
                if connectedPeer == peerID {
                    peerAlreadyInSession = true
                }
            }
        }
        if !peerAlreadyInSession {
            let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: .none)
            session.delegate = self
            var info: [String:String]?
            if let data = context {
                info = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String:String]
            }
            peersIdsNamesSessionsStates[peerID.displayName] = (peerID, info?["userName"], session, nil)
            invitationHandler(true, session)
        } else {
            invitationHandler(false, nil)
        }
    }
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        delegate?.failedToStartAdvertising(error: error)
    }
}

extension MultipeerCommunicator: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        var peerAlreadyInSession = false
//        for peer in peersIdsNamesSessionsStates.keys {
//            if (peersIdsNamesSessionsStates[peer]?.state == MCSessionState.connected || peersIdsNamesSessionsStates[peer]?.state == MCSessionState.connecting) {
//                peerAlreadyInSession = true
//            }
//        }
        for peer in peersIdsNamesSessionsStates.keys {
            for connectedPeer in peersIdsNamesSessionsStates[peer]!.session.connectedPeers {
                if connectedPeer == peerID {
                    peerAlreadyInSession = true
                }
            }
        }
        if !peerAlreadyInSession {
            let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: .none)
            session.delegate = self
            peersIdsNamesSessionsStates[peerID.displayName] = (peerID, info?["userName"], session, nil)
            var context: Data?
            if let discoveryInfo = self.serviceAdvertiser.discoveryInfo {
                context = try? JSONSerialization.data(withJSONObject: discoveryInfo, options: [])
            }
            browser.invitePeer(peerID, to: session, withContext: context, timeout: 10)
        }
    }
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        if peersIdsNamesSessionsStates[peerID.displayName] != nil {
            delegate?.didLostUser(userId: peerID.displayName)
            peersIdsNamesSessionsStates[peerID.displayName]?.session.disconnect()
            peersIdsNamesSessionsStates[peerID.displayName] = nil
        }
    }
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        delegate?.failedToStartBrowsingForUsers(error: error)
    }
}

extension MultipeerCommunicator: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        peersIdsNamesSessionsStates[peerID.displayName] = (peerID, peersIdsNamesSessionsStates[peerID.displayName]?.name, session, state)
        if state == MCSessionState.connected {
            delegate?.didFoundUser(userId: peerID.displayName, userName: peersIdsNamesSessionsStates[peerID.displayName]?.name)
        }
        if state == MCSessionState.notConnected {
            if peersIdsNamesSessionsStates[peerID.displayName] != nil {
                delegate?.didLostUser(userId: peerID.displayName)
                peersIdsNamesSessionsStates[peerID.displayName]?.session.disconnect()
                peersIdsNamesSessionsStates[peerID.displayName] = nil
            }
        }
    }
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        var json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String:String]
        if let text = json?["text"] {
            delegate?.didReceiveMessage(text: text, fromUser: peerID.displayName, toUser: myPeerId.displayName)
        }
    }
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print("-")
    }
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        print("--")
    }
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        print("---")
    }
}
