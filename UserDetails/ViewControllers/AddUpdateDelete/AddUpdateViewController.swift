//
//  AddUpdateViewController.swift
//  UserDetails
//
//  Created by Chandra Rao on 06/12/17.
//  Copyright © 2017 Chandra Rao. All rights reserved.
//

import UIKit
import CoreData

class AddUpdateViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate {

    @IBOutlet weak var imgUserImg: UIImageView!
    @IBOutlet weak var txtFieldName: UITextField!
    @IBOutlet weak var txtFieldEmail: UITextField!
    @IBOutlet weak var txtFieldOtherDetails: UITextField!
    @IBOutlet weak var btnSaveUpdate: UIButton!
    
    let imagePicker = UIImagePickerController()
    var tapGesture = UITapGestureRecognizer()
    var user: [NSManagedObject] = []
    var isUpdate : Bool = false
    var ctrVariable : Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        imagePicker.delegate = self
        
        if isUpdate {
            txtFieldName.text = user[0].value(forKey: "name") as? String
            txtFieldEmail.text = user[0].value(forKey: "email") as? String
            txtFieldOtherDetails.text = user[0].value(forKey: "others") as? String
            
            if let imageData = user[0].value(forKey: "image") as? NSData {
                if let image = UIImage(data:imageData as Data) {
                    imgUserImg.image = image
                }
            }
            
            btnSaveUpdate.setTitle("Update", for: UIControlState.normal)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        configureImageView()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnSaveUpdateClicked(_ sender: Any) {
        
        if check(forBlanks: txtFieldName) {
            showAlert(withTitleMessageAndAction: "Alert!", message: "Please enter valid text." ,action: false)
        } else if check(forBlanks: txtFieldEmail) {
            showAlert(withTitleMessageAndAction: "Alert!", message: "Please enter valid text.", action: false)
        } else if !check(forValidEmail: txtFieldEmail) {
            showAlert(withTitleMessageAndAction: "Alert!", message: "Please enter valid Email id.", action: false)
        } else if check(forBlanks: txtFieldOtherDetails) {
            showAlert(withTitleMessageAndAction: "Alert!", message: "Please enter valid Text.", action: false)
        } else {
            if isUpdate {
                updateRecord()
            } else {
                save(name: txtFieldName.text!, email: txtFieldEmail.text!, others: txtFieldOtherDetails.text!)
            }
        }
    }
    
    func save(name: String , email: String, others: String) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        ctrVariable = ctrVariable + 1
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "User", in: managedContext)!
        
        let userObj = NSManagedObject(entity: entity, insertInto: managedContext)
        
        userObj.setValue(ctrVariable, forKeyPath: "id")
        userObj.setValue(name, forKeyPath: "name")
        userObj.setValue(email, forKeyPath: "email")
        userObj.setValue(others, forKeyPath: "others")
        userObj.setValue(UIImageJPEGRepresentation(imgUserImg.image!, 1), forKey: "image")
        
        do {
            try managedContext.save()
            user.append(userObj)
            showAlert(withTitleMessageAndAction: "Sucess!!", message: "Your record has been saved sucessfully!!", action: true)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }

    func updateRecord() {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        // 1
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "User")
        let predicate = NSPredicate(format: "id == '\(user[0].value(forKey: "id") as! Int)'")
        fetchRequest.predicate = predicate
        do
        {
            let test = try managedContext.fetch(fetchRequest)
            if test.count == 1
            {
                let objectUpdate = test[0] as! NSManagedObject
                objectUpdate.setValue((user[0].value(forKey: "id") as! Int), forKeyPath: "id")
                objectUpdate.setValue(txtFieldName.text!, forKey: "name")
                objectUpdate.setValue(txtFieldEmail.text!, forKey: "email")
                objectUpdate.setValue(txtFieldOtherDetails.text!, forKeyPath: "others")
                objectUpdate.setValue(UIImageJPEGRepresentation(imgUserImg.image!, 1), forKey: "image")

                do {
                    try managedContext.save()
                    showAlert(withTitleMessageAndAction: "Sucess!!", message: "Your record has been updated sucessfully!!", action: true)
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                    
                }
            }
        }
        catch
        {
            print(error)
        }
    }
    
    func configureImageView() {
        
        imgUserImg.layer.cornerRadius = imgUserImg.frame.size.width / 2
        imgUserImg.layer.borderWidth = 3.0
        imgUserImg.layer.borderColor = UIColor.lightGray.cgColor
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(AddUpdateViewController.handleTap(_:)))
        tapGesture.delegate = self
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        
        imgUserImg.addGestureRecognizer(tapGesture)
    }

    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        
        let alertController = UIAlertController(title: "Alert!", message: "PLease choose source.", preferredStyle:UIAlertControllerStyle.actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Camera", style: UIAlertActionStyle.default)
        { action -> Void in
            // Put your code here
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = .camera;
                self.imagePicker.allowsEditing = false
                self.present(self.imagePicker, animated: true, completion: nil)
            } else {
                self.showAlert(withTitleMessageAndAction: "Alert!", message: "Camera not available.", action: false)
            }
        })
        
        alertController.addAction(UIAlertAction(title: "Photo Library", style: UIAlertActionStyle.default)
        { action -> Void in
            self.imagePicker.allowsEditing = true
            self.imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            self.present(self.imagePicker, animated: true) {
                
            }
        })
        
        self.present(alertController, animated: true) {
            
        }
    }

    func check(forBlanks textfield: UITextField) -> Bool {
        let rawString: String? = textfield.text
        let whitespace = CharacterSet.whitespacesAndNewlines
        let trimmed: String? = rawString?.trimmingCharacters(in: whitespace)
        if (trimmed?.count ?? 0) == 0 {
            return true
        }
        else {
            return false
        }
    }
    
    func check(forValidEmail textfield: UITextField) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        print(emailTest.evaluate(with: textfield.text!))
        return emailTest.evaluate(with: textfield.text!)
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    private func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject])
    {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage //2
        imgUserImg.contentMode = .scaleAspectFit
        imgUserImg.image = chosenImage
        
        dismiss(animated:true, completion: nil)

    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imgUserImg.image = image
            dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
    }
    
    func showAlert(withTitleMessageAndAction title:String, message:String , action: Bool) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        if action {
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action : UIAlertAction!) in
                self.navigationController?.popViewController(animated: true)
            }))
        } else{
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
}
