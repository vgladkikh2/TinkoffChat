//
//  ProfileViewController.swift
//  TinkoffChat
//
//  Created by me on 30/09/2018.
//  Copyright © 2018 gladkikh. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate, DataManagerDelegate {
    
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
        usernameChangeField.text = usernameLabel.text
        aboutChangeView.text = aboutLabel.text
        inEditingState = true
        saveButtonsEnabled = false
    }
    @IBAction func gcdButtonTapped(_ sender: Any) {
        if !(dataManager is GCDDataManager) {
            print("AAAASSSSSS")
            dataManager = GCDDataManager(usernameKey: "username", aboutKey: "about", avatarFile: "avatar")
            dataManager.delegate = self
        }
        tryToSaveChangedValuesToDataManager()
    }
    @IBAction func operationButtonTapped(_ sender: Any) {
        if !(dataManager is OperationDataManager) {
            print("BBBBSSSSSS")
            dataManager = OperationDataManager(usernameKey: "username", aboutKey: "about", avatarFile: "avatar")
            dataManager.delegate = self
        }
        tryToSaveChangedValuesToDataManager()
    }
    @IBAction func cameraIconTapped(_ sender: Any) {
        print("Вызов выбора изображения профиля")
        showActionSheet()
    }
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    var dataManager: DataManager
    private var activityIndicator = UIActivityIndicatorView(style: .gray)
    private var usernameKey: String
    private var aboutKey: String
    private var avatarFile: String
    private var shouldSaveNewName: Bool = false {
        didSet {
            if shouldSaveNewName || shouldSaveNewAbout || shouldSaveNewAvatar {
                saveButtonsEnabled = true
            } else {
                saveButtonsEnabled = false
            }
        }
    }
    private var shouldSaveNewAbout: Bool = false {
        didSet {
            if shouldSaveNewName || shouldSaveNewAbout || shouldSaveNewAvatar {
                saveButtonsEnabled = true
            } else {
                saveButtonsEnabled = false
            }
        }
    }
    private var shouldSaveNewAvatar: Bool = false {
        didSet {
            if shouldSaveNewName || shouldSaveNewAbout || shouldSaveNewAvatar {
                saveButtonsEnabled = true
            } else {
                saveButtonsEnabled = false
            }
        }
    }
    private var saveButtonsEnabled: Bool = false {
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
    private var inEditingState: Bool = false {
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
    
    func tryToSaveChangedValuesToDataManager() {
        activityIndicator.startAnimating()
        saveButtonsEnabled = false
        cameraIcon.isHidden = true
        var usernameToSave: String?
        var aboutToSave: String?
        var avatarToSave: UIImage?
        if shouldSaveNewName {
            usernameToSave = usernameChangeField.text
        }
        if shouldSaveNewAbout {
            aboutToSave = aboutChangeView.text
        }
        if shouldSaveNewAvatar {
            avatarToSave = userPlaceholder.image
        }
        dataManager.saveData(username: usernameToSave, about: aboutToSave, avatar: avatarToSave)
    }
    func savingDataFinished() {
        activityIndicator.stopAnimating()
//        saveButtonsEnabled = true
//        cameraIcon.isHidden = false
        let actionSheet = UIAlertController(title: "Данные сохранены", message: nil, preferredStyle: UIAlertController.Style.alert)
        actionSheet.addAction(UIAlertAction(title: "ОК", style: .cancel, handler: { (alert:UIAlertAction!) -> Void in
            self.saveButtonsEnabled = false
            self.inEditingState = false
            self.editButton.isEnabled = false
            self.editButton.alpha = 0.5
            self.activityIndicator.startAnimating()
            self.dataManager.loadData()
        }))
        self.present(actionSheet, animated: true, completion: nil)
    }
    func savingDataFailed() {
        activityIndicator.stopAnimating()
//        saveButtonsEnabled = true
//        cameraIcon.isHidden = false
        let actionSheet = UIAlertController(title: "Ошибка", message: "Не удалось сохранить данные", preferredStyle: UIAlertController.Style.alert)
        actionSheet.addAction(UIAlertAction(title: "Повторить", style: .default, handler: { (alert:UIAlertAction!) -> Void in
            self.tryToSaveChangedValuesToDataManager()
        }))
        actionSheet.addAction(UIAlertAction(title: "ОК", style: .cancel, handler: { (alert:UIAlertAction!) -> Void in
            self.saveButtonsEnabled = false
            self.inEditingState = false
            self.editButton.isEnabled = false
            self.editButton.alpha = 0.5
            self.activityIndicator.startAnimating()
            self.dataManager.loadData()
        }))
        self.present(actionSheet, animated: true, completion: nil)
    }
    func loadDataFromDataManager() {
        activityIndicator.startAnimating()
        dataManager.loadData()
    }
    func loadingDataFinished() {
        activityIndicator.stopAnimating()
        usernameLabel.text = dataManager.username
        aboutLabel.text = dataManager.about
        if dataManager.avatar != nil {
            userPlaceholder.image = dataManager.avatar
        }
        shouldSaveNewName = false
        shouldSaveNewAbout = false
        shouldSaveNewAvatar = false
        editButton.isEnabled = true
        editButton.alpha = 1.0
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == usernameChangeField {
            if let text = textField.text, let textRange = Range(range, in: text) {
                let updatedText = text.replacingCharacters(in: textRange, with: string)
                if updatedText != dataManager.username && updatedText != "" {
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
            if textView.text != dataManager.about {
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
            if areTwoEqualImages(dataManager.avatar, pickedImage) {
                shouldSaveNewAvatar = false
            } else {
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
        usernameKey = "username"
        aboutKey = "about"
        avatarFile = "avatar.png"
        dataManager = GCDDataManager(usernameKey: usernameKey, aboutKey: aboutKey, avatarFile: avatarFile)
        super.init(coder: aDecoder)
        dataManager.delegate = self
//        print("\(#function) -> \(editButton.frame)") // editButton здесь nil, так как кнопка еще не успела создаться (и не присвоился адрес в переменную editButton). Поэтому, естественно, падает с ошибкой в рантайме
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.addSubview(activityIndicator)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        let horizontalConstraint = NSLayoutConstraint(item: activityIndicator, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
        view.addConstraint(horizontalConstraint)
        let verticalConstraint = NSLayoutConstraint(item: activityIndicator, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: usernameChangeField, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0)
        view.addConstraint(verticalConstraint)
        saveButtonsEnabled = false
        inEditingState = false
        editButton.isEnabled = false
        editButton.alpha = 0.5
        loadDataFromDataManager()
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

