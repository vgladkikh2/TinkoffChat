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
//        if peersIdsNamesSessionsStates[userId] != nil {
//            if peersIdsNamesSessionsStates[userId]!.state == MCSessionState.connected {
                let message = ["eventType": "TextMessage", "messageId": generateMessageID(), "text": string]
                do {
                    let data = try JSONSerialization.data(withJSONObject: message, options: [])
                    let session = peersIdsNamesSessionsStates[userId]!.session
                    let peers = [peersIdsNamesSessionsStates[userId]!.id]
                    try session.send(data, toPeers: peers, with: .reliable)
                    completionHandler?(true, nil)
                    delegate?.didReceiveMessage(text: string, fromUser: myPeerId.displayName, toUser: userId)
                    print("  Sended message to \(userId)")
                } catch {
                    completionHandler?(false, error)
                    print("  Fail to send message to \(userId)")
                }
//            } else {
//                completionHandler?(false, "\(userId) doesn't connected")
//            }
//        } else {
//            completionHandler?(false, "\(userId) doesn't connected")
//        }
    }
    weak var delegate: CommunicatorDelegate?
    var online: Bool?
    
    private let myPeerId: MCPeerID
    private let serviceAdvertiser : MCNearbyServiceAdvertiser
    private let serviceBrowser : MCNearbyServiceBrowser
    private var peersIdsNamesSessionsStates: [String: (id: MCPeerID, name: String?, session: MCSession, state: MCSessionState?)]
    
    override init() {
        self.myPeerId = MCPeerID(displayName: UIDevice.current.name)
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: ["userName": "v.gladkikhXXXX"], serviceType: "tinkoff-chat")
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
        for peer in peersIdsNamesSessionsStates.keys {
            if peer == peerID.displayName && peersIdsNamesSessionsStates[peer]?.state != MCSessionState.notConnected {
                //(peersIdsNamesSessionsStates[peer]?.state == MCSessionState.connected || peersIdsNamesSessionsStates[peer]?.state == MCSessionState.connecting) {
                peerAlreadyInSession = true
                print("Doesn't accepted invite from \(peerID.displayName) at didReceiveInvitation, as already")
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
            print("Accepted invite from \(peerID.displayName) at didReceiveInvitation")
        }
    }
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        delegate?.failedToStartAdvertising(error: error)
    }
}

extension MultipeerCommunicator: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("\(peerID.displayName) is found")
        var peerAlreadyInSession = false
        for peer in peersIdsNamesSessionsStates.keys {
            if peer == peerID.displayName && peersIdsNamesSessionsStates[peer]?.state != MCSessionState.notConnected {
                //(peersIdsNamesSessionsStates[peer]?.state == MCSessionState.connected || peersIdsNamesSessionsStates[peer]?.state == MCSessionState.connecting) {
                peerAlreadyInSession = true
                print("\(peerID.displayName) isn't invited at foundPeer, as already")
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
            print("\(peerID.displayName) is invited at foundPeer")
            browser.invitePeer(peerID, to: session, withContext: context, timeout: 10)
        }
    }
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("\(peerID.displayName) is lost")
        if peersIdsNamesSessionsStates[peerID.displayName] != nil {
            delegate?.didLostUser(userId: peerID.displayName)
            peersIdsNamesSessionsStates[peerID.displayName]?.session.disconnect()
            peersIdsNamesSessionsStates[peerID.displayName] = nil
            print(" \(peerID.displayName) is removed from peersIdsNamesSessionsStates at lostPeer")
        }
    }
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        delegate?.failedToStartBrowsingForUsers(error: error)
    }
}

extension MultipeerCommunicator: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
//        assert(peersIdsNamesSessionsStates[peerID.displayName] != nil, "peerID:\(peerID.displayName) doesn't exist in peersIdsNamesSessionsStates, but it must exist there!")
        peersIdsNamesSessionsStates[peerID.displayName] = (peerID, peersIdsNamesSessionsStates[peerID.displayName]?.name, session, state)
        print(" \(peerID.displayName) is change state and is changed in peersIdsNamesSessionsStates")
        if state == MCSessionState.connected {
            delegate?.didFoundUser(userId: peerID.displayName, userName: peersIdsNamesSessionsStates[peerID.displayName]?.name)
            print(" \(peerID.displayName) is connected")
            sendMessage(string: "Helllloooo!", to: peerID.displayName, completionHandler: nil)
        }
        if state == MCSessionState.notConnected {
            print(" \(peerID.displayName) is notConnected")
            if peersIdsNamesSessionsStates[peerID.displayName] != nil {
                print(" \(peerID.displayName) is removed from peersIdsNamesSessionsStates")
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
            print("  Received \(text) from \(peerID.displayName)")
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
