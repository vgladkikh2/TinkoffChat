//
//  ThemesViewController.swift
//  TinkoffChatProductTwo
//
//  Created by me on 14/10/2018.
//  Copyright © 2018 gladkikh. All rights reserved.
//

import UIKit

class ThemesViewController: UIViewController {
    
    var model: Themes?
    var themeChanged: ((UIColor?) -> Void)?
    
    func applyColorChanges(theme: UIColor?) {
        if let color = theme {
            view.backgroundColor = color
            let queue = DispatchQueue.global(qos: .utility)
            queue.async{
                do {
                    try UserDefaults.standard.setValue(NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false), forKey: "ApplicationTheme")
                    UserDefaults.standard.synchronize()
                } catch {
                    print("Cannot save application theme to UserDefaults")
                }
            }
            AppDelegate.changeApplicationColor(color: color)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        model = Themes()
        model?.theme1 = UIColor(red: 255.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        model?.theme2 = UIColor(red: 0.0/255.0, green: 255.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        model?.theme3 = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    }
    @IBAction func buttonTheme1Touched(_ sender: Any) {
        applyColorChanges(theme: model?.theme1)
        themeChanged?(model?.theme1)
    }
    @IBAction func buttonTheme2Touched(_ sender: Any) {
        applyColorChanges(theme: model?.theme2)
        themeChanged?(model?.theme2)
    }
    @IBAction func buttonTheme3Touched(_ sender: Any) {
        applyColorChanges(theme: model?.theme3)
        themeChanged?(model?.theme3)
    }
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
