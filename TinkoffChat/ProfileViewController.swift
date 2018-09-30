//
//  ProfileViewController.swift
//  TinkoffChat
//
//  Created by me on 30/09/2018.
//  Copyright © 2018 gladkikh. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var cameraIcon: UIImageView!
    @IBOutlet weak var userPlaceholder: UIImageView!
    @IBOutlet weak var editButton: UIButton!
    
    @IBAction func cameraIconTapped(_ sender: Any) {
        print("Выбери изображение профиля")
    }
    /*
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        print("\(#function) -> \(editButton.frame)")
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    init() {
        super.init(nibName: nil, bundle: nil)
        print("\(#function) -> \(editButton.frame)")
    }
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        userPlaceholder.layer.cornerRadius = 25
        userPlaceholder.layer.masksToBounds = true
        cameraIcon.layer.cornerRadius = 25
        cameraIcon.layer.masksToBounds = true
        editButton.layer.cornerRadius = 10
        editButton.layer.borderWidth = 2
        editButton.layer.borderColor = UIColor.black.cgColor
        print("\(#function) -> \(editButton.frame)")
    }
    
    override func viewWillAppear(_ animated:Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated:Bool) {
        super.viewDidAppear(animated)
        print("\(#function) -> \(editButton.frame)")
        // Так как в storyboard мы выбрали iphone SE, вью создавалось под его размеры, а после этого и перед его выводом оно перерисовалось под размеры того устройства, на котором сейчас запустилось.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewWillDisappear(_ animated:Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated:Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

