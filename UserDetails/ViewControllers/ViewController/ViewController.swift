//
//  ViewController.swift
//  UserDetails
//
//  Created by Chandra Rao on 06/12/17.
//  Copyright © 2017 Chandra Rao. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tblListUser: UITableView!
    @IBOutlet weak var btnAdd: UIBarButtonItem!
    @IBOutlet weak var lblNoRecords: UILabel!
    var ctrVariable : Int = 0

    var userList: [NSManagedObject] = []


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tblListUser.estimatedRowHeight = 116
        tblListUser.rowHeight = UITableViewAutomaticDimension

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getDataFromDB()
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - UITableView Delegate / DataSource Methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let userTableViewCell : UserCell = tblListUser.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
        let user = userList[indexPath.row]

        userTableViewCell.imgViewUser.layer.cornerRadius = userTableViewCell.imgViewUser.frame.size.width / 2
        
        userTableViewCell.lblName.text = user.value(forKey: "name") as? String
        
        userTableViewCell.lblEmail.text = user.value(forKey: "email") as? String
        
        if let imageData = user.value(forKey: "image") as? NSData {
            if let image = UIImage(data:imageData as Data) {
                userTableViewCell.imgViewUser.image = image
            }
        }
        
        return userTableViewCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        let singleUser: [NSManagedObject] = [userList[indexPath.row] as NSManagedObject]
        let addUpdateVCLR : AddUpdateViewController = self.storyboard?.instantiateViewController(withIdentifier: "AddUpdateViewController") as! AddUpdateViewController
        addUpdateVCLR.user = singleUser
        addUpdateVCLR.isUpdate = true
        self.navigationController?.pushViewController(addUpdateVCLR, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete
        {
            //1
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            let managedContext = appDelegate.persistentContainer.viewContext
            managedContext.delete(userList[indexPath.row] as NSManagedObject)
            do {
                try managedContext.save()
                getDataFromDB()
                tblListUser.reloadData()
            } catch _ {
                
            }
        }
    }
    
    func getDataFromDB() {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "User")
        
        
        do {
            userList = try managedContext.fetch(fetchRequest)
            if userList.count > 0 {
                lblNoRecords.isHidden = true
                tblListUser.isHidden = false
                tblListUser.reloadData()
            } else {
                lblNoRecords.isHidden = false
                tblListUser.isHidden = true
            }
            ctrVariable = userList.count
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
    }
    
    @IBAction func btnAddClicked(_ sender: Any) {
        let addUpdateVCLR : AddUpdateViewController = self.storyboard?.instantiateViewController(withIdentifier: "AddUpdateViewController") as! AddUpdateViewController
        addUpdateVCLR.isUpdate = false
        addUpdateVCLR.ctrVariable = ctrVariable
        self.navigationController?.pushViewController(addUpdateVCLR, animated: true)
    }
    
}

