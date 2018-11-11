//
//  AppDelegate.swift
//  TinkoffChat
//
//  Created by me on 30/09/2018.
//  Copyright © 2018 gladkikh. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var multipeerCommunicator: MultipeerCommunicator!
    var communicationManager: CommunicationManager!
    var gcdDataManager: GCDDataManager?
    var operationDataManager: OperationDataManager?
    var storageDataManager: StorageDataManager?
    let isStorageDataManager = true
    
    override init() {
        super.init()
    }

    static func changeApplicationColor(color: UIColor) {
        let sharedApplication = UIApplication.shared
        sharedApplication.delegate?.window??.tintColor = color
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0
        var brightness: CGFloat = 0.0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        brightness = ((r * 299) + (g * 587) + (b * 114)) / 1000;
        if (brightness < 0.5) {
            UINavigationBar.appearance().barStyle = .default
        }
        else {
            UINavigationBar.appearance().barStyle = .black
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if isStorageDataManager {
            storageDataManager = StorageDataManager()
        } else {
            gcdDataManager = GCDDataManager()
            operationDataManager = OperationDataManager()
        }
        communicationManager = CommunicationManager()
        multipeerCommunicator = MultipeerCommunicator()
        multipeerCommunicator.delegate = communicationManager
        if let colorData = UserDefaults.standard.data(forKey: "ApplicationTheme") {
            do {
                let color = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(colorData) as? UIColor
                if color != nil {
                    AppDelegate.changeApplicationColor(color: color!)
                }
            } catch {
                print("Cannot load application theme from UserDefaults")
            }
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }

}

