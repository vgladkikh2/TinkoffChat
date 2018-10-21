//
//  ProfileViewController.swift
//  TinkoffChat
//
//  Created by me on 30/09/2018.
//  Copyright © 2018 gladkikh. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate {
    
    var savedUsername: String?
    var savedAbout: String?
    var savedAvatar: UIImage?
    var shouldSaveNewName: Bool = false {
        didSet {
            if shouldSaveNewName || shouldSaveNewAbout || shouldSaveNewAvatar {
                saveButtonsEnabled = true
            } else {
                saveButtonsEnabled = false
            }
        }
    }
    var shouldSaveNewAbout: Bool = false {
        didSet {
            if shouldSaveNewName || shouldSaveNewAbout || shouldSaveNewAvatar {
                saveButtonsEnabled = true
            } else {
                saveButtonsEnabled = false
            }
        }
    }
    var shouldSaveNewAvatar: Bool = false {
        didSet {
            if shouldSaveNewName || shouldSaveNewAbout || shouldSaveNewAvatar {
                saveButtonsEnabled = true
            } else {
                saveButtonsEnabled = false
            }
        }
    }
    var saveButtonsEnabled: Bool = false {
        didSet {
            if saveButtonsEnabled {
                gcdButton.isEnabled = true
                operationButton.isEnabled = true
                gcdButton.alpha = 1.0
                operationButton.alpha = 1.0
            } else {
                gcdButton.isEnabled = false
                operationButton.isEnabled = false
                gcdButton.alpha = 0.5
                operationButton.alpha = 0.5
            }
        }
    }
    var inEditingState: Bool = false {
        didSet {
            if inEditingState {
                editButton.isHidden = true
                usernameLabel.isHidden = true
                aboutLabel.isHidden = true
                gcdButton.isHidden = false
                operationButton.isHidden = false
                cameraIcon.isHidden = false
                usernameChangeField.isHidden = false
                aboutChangeView.isHidden = false
            } else {
                savedUsername = usernameLabel.text
                savedAbout = aboutLabel.text
                savedAvatar = userPlaceholder.image
                editButton.isHidden = false
                usernameLabel.isHidden = false
                aboutLabel.isHidden = false
                gcdButton.isHidden = true
                operationButton.isHidden = true
                cameraIcon.isHidden = true
                usernameChangeField.isHidden = true
                aboutChangeView.isHidden = true
            }
        }
    }
    
    @IBOutlet weak var cameraIcon: RoundedView!
    @IBOutlet weak var userPlaceholder: RoundedImage!
    @IBOutlet var editButton: RoundedButton!
    @IBOutlet var gcdButton: RoundedButton!
    @IBOutlet var operationButton: RoundedButton!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var usernameChangeField: UITextField!
    @IBOutlet var aboutLabel: UILabel!
    @IBOutlet var aboutChangeView: UITextView!
    
    @IBAction func editButtonTapped(_ sender: Any) {
        usernameChangeField.text = savedUsername
        aboutChangeView.text = savedAbout
        inEditingState = true
        saveButtonsEnabled = false
    }
    @IBAction func gcdButtonTapped(_ sender: Any) {
        savedUsername = usernameChangeField.text
        savedAbout = aboutChangeView.text
        usernameLabel.text = savedUsername
        aboutLabel.text = savedAbout
        inEditingState = false
        saveButtonsEnabled = false
    }
    @IBAction func operationButtonTapped(_ sender: Any) {
        savedUsername = usernameChangeField.text
        savedAbout = aboutChangeView.text
        usernameLabel.text = savedUsername
        aboutLabel.text = savedAbout
        inEditingState = false
        saveButtonsEnabled = false
    }
    @IBAction func cameraIconTapped(_ sender: Any) {
        print("Вызов выбора изображения профиля")
        showActionSheet()
    }
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == usernameChangeField {
            if let text = textField.text, let textRange = Range(range, in: text) {
                let updatedText = text.replacingCharacters(in: textRange, with: string)
                if updatedText != savedUsername && updatedText != "" {
                    shouldSaveNewName = true
                } else {
                    shouldSaveNewName = false
                }
            }
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView == aboutChangeView {
            if textView.text != savedAbout {
                shouldSaveNewAbout = true
            } else {
                shouldSaveNewAbout = false
            }
        }
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
            if areTwoEqualImages(savedAvatar, pickedImage) {
                print("photo-false")
                shouldSaveNewAvatar = false
            } else {
                print("photo-true")
                shouldSaveNewAvatar = true
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func areTwoEqualImages(_ image1: UIImage?, _ image2: UIImage?) -> Bool {
        if let img1 = image1, let img2 = image2 {
            guard let data1 = img1.pngData() else { return false }
            guard let data2 = img2.pngData() else { return false }
            return data1.elementsEqual(data2)
        } else {
            return false
        }
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
        inEditingState = false
//        savedUsername = usernameLabel.text
//        savedAbout = aboutLabel.text
//        savedAvatar = userPlaceholder.image
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

