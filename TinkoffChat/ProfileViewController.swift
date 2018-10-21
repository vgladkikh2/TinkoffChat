//
//  ProfileViewController.swift
//  TinkoffChat
//
//  Created by me on 30/09/2018.
//  Copyright © 2018 gladkikh. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var cameraIcon: RoundedView!
    @IBOutlet weak var userPlaceholder: RoundedImage!
    @IBOutlet var editButton: RoundedButton!
    @IBOutlet var gcdButton: RoundedButton!
    @IBOutlet var operationButton: RoundedButton!
    
    @IBAction func editButtonTapped(_ sender: Any) {
        editButton.isHidden = true
        gcdButton.isHidden = false
        operationButton.isHidden = false
        cameraIcon.isHidden = false
    }
    @IBAction func gcdButtonTapped(_ sender: Any) {
        editButton.isHidden = false
        gcdButton.isHidden = true
        operationButton.isHidden = true
        cameraIcon.isHidden = true
    }
    @IBAction func operationButtonTapped(_ sender: Any) {
        editButton.isHidden = false
        gcdButton.isHidden = true
        operationButton.isHidden = true
        cameraIcon.isHidden = true
    }
    @IBAction func cameraIconTapped(_ sender: Any) {
        print("Вызов выбора изображения профиля")
        showActionSheet()
    }
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func showActionSheet() {
        let actionSheet = UIAlertController(title: "Выберите источник", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            actionSheet.addAction(UIAlertAction(title: "Камера", style: .default, handler: { (alert:UIAlertAction!) -> Void in
                self.runCamera()
            }))
        }
        actionSheet.addAction(UIAlertAction(title: "Галерея", style: .default, handler: { (alert:UIAlertAction!) -> Void in
            self.photoLibrary()
        }))
        actionSheet.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func runCamera()
    {
        let myPickerController = UIImagePickerController()
        myPickerController.delegate = self
        myPickerController.sourceType = .camera
        self.present(myPickerController, animated: true, completion: nil)
    }
    
    func photoLibrary()
    {
        let myPickerController = UIImagePickerController()
        myPickerController.delegate = self
        myPickerController.sourceType = .photoLibrary
        self.present(myPickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            userPlaceholder.image = pickedImage
        }
        self.dismiss(animated: true, completion: nil)
    }
    
//    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) { // is used when you create the view programmatically
//        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
//        print("\(#function) -> \(editButton.frame)")
//    }
    required init?(coder aDecoder: NSCoder) { // is used when the view is created from storyboard/xib
        super.init(coder: aDecoder)
//        print("\(#function) -> \(editButton.frame)") // editButton здесь nil, так как кнопка еще не успела создаться (и не присвоился адрес в переменную editButton). Поэтому, естественно, падает с ошибкой в рантайме
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func viewWillAppear(_ animated:Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated:Bool) {
        super.viewDidAppear(animated)
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

