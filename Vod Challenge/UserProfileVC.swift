//
//  ViewController.swift
//  Vod Challenge
//
//  Created by DongMing on 2019-06-17.
//  Copyright © 2019 littlebiteverything. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SVProgressHUD
import ChameleonFramework

class UserProfileVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - GLOBAL VARS
    
    let sectionTitles = ["BASIC INFO", "PASSWORD"]
    let s1Labels = ["Username", "First Name", "Last Name"]
    let s2Labels = ["New Password", "Re-enter Pin"]
    let s1Placeholders = ["Your username", "Your first name", "Your last name"]
    let s2Placeholders = ["New password", "Please type again"]
    var s1Textfields: [String] = []
    var s2Textfields: [String] = []
    lazy var sectionLabels: [[String]] = [s1Labels, s2Labels]
    lazy var sectionPlaceholders: [[String]] = [s1Placeholders, s2Placeholders]
    lazy var sectionTextfields: [[String]] = [s1Textfields, s2Textfields]
    // urls
//    let urlLocal = "http://localhost:3000/"
    let urlRemote = "https://whispering-coast-70375.herokuapp.com/"
    lazy var urlGetUser = urlRemote + "api.foo.com/profiles/"
    lazy var urlUpdateProfile = urlRemote + "api.foo.com/profiles/update"
    lazy var urlUpdatePin = urlRemote + "api.foo.com/password/change"
    lazy var urlNewUser = urlRemote + "api.foo.com/new-user"

    // MARK: - APP LIFE CYCLE METHODS
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = FlatRed()
        
        // Register MyTableSectionFooter
        tableView.register(MyTableSectionFooter.self, forHeaderFooterViewReuseIdentifier: "sectionHeader")
    }
    
    // MARK: - UI CONTROL METHODS (saveBtn)
    
    @IBAction func btnGetUserPressed(_ sender: UIBarButtonItem) {
        let usernameCell = tableView.cellForRow(at: IndexPath.init(row: 0, section: 0)) as! MyCell
        if usernameCell.textfield.text?.count == 0 {
            showAlert(title: "Empty Username", message: "Please enter your username first and try again.", buttonMessage: "OK")
            return
        }
        
        view.endEditing(true)  // dismiss keyboard
        getUserByUsername(usernameCell.textfield.text!)
    }
    

    // MARK: - CONVENIENT METHODS (HttpRequest)
    
    // send GET request to API to get user info in JSON format
    func getUserByUsername(_ username: String){
        // replace white space in url with '%20'
        let url = (urlGetUser + username).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        SVProgressHUD.show()  // show spinner before run aysnc method

        // use Alamofire to call API asynchronously
        AF.request(url, method: .get).responseJSON { response in
//            SVProgressHUD.dismiss(withDelay: 1)  // dismiss spinner

            switch response.result {
            case let .success(value):
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                    SVProgressHUD.dismiss()
                    SVProgressHUD.showSuccess(withStatus: "User Info Retrieved.")
                }
                let userJSON = JSON(value)
                self.updateUserInfo(json: userJSON)
                
            case let .failure(error):
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            }
        }
        
        
    }
    
    // Parse JSON and update TableView
    func updateUserInfo(json: JSON) {
        print(json)
        s1Textfields = []
        s1Textfields.append(json["data"]["username"].stringValue)
        s1Textfields.append(json["data"]["firstName"].stringValue)
        s1Textfields.append(json["data"]["lastName"].stringValue)
        tableView.reloadData()
    }
    
    // Save btn clicked, send POST request
    @objc func saveBtnPressed(_ sender: UIButton) {
        sender.flash()
        guard s1Textfields.count >= 3 else {
            showAlert(title: "Get a User First", message: "Please use username to fetch a user profile first, then make changes.", buttonMessage: "OK")
            return
        }
        switch sender.tag {
        case 0:  // profile saveBtn
            print("sending modify profile POST request...")
            let cellFirst = tableView.cellForRow(at: IndexPath.init(row: 1, section: sender.tag)) as! MyCell
            let cellLast = tableView.cellForRow(at: IndexPath.init(row: 2, section: sender.tag)) as! MyCell
            let username = s1Textfields[0]
            let firstName = cellFirst.textfield.text!
            let lastName = cellLast.textfield.text!
            if [username, firstName, lastName] == s1Textfields {  // check if there are changes made
                showAlert(title: "No Change Made", message: "Did not detect any change since last time.", buttonMessage: "OK")
            } else {
                updateUserProfile(username, firstName, lastName)
            }
            
        case 1:  // password saveBtn
            print("sending change pin POST request...")
            let username = s1Textfields[0]
            let cellPin = tableView.cellForRow(at: IndexPath.init(row: 0, section: 1)) as! MyCell
            let cellConfirm = tableView.cellForRow(at: IndexPath.init(row: 1, section: 1)) as! MyCell
            let newPin = cellPin.textfield.text!
            let pinConfirm = cellConfirm.textfield.text!
            if newPin != pinConfirm {
                showAlert(title: "Pins Not Identical", message: "Please double check you password and confirm to make sure they are identical.", buttonMessage: "OK")
            } else {
                updateUserPassword(username, newPin)
            }
            

        default:
            break
        }
    }
    
    // Update user profile
    func updateUserProfile(_ username: String, _ firstName: String, _ lastName: String) {
        let params: Parameters = [
            "username": username,
            "firstName": firstName,
            "lastName": lastName
        ]
        
        SVProgressHUD.show()  // show spinner before run aysnc method
        AF.request(urlUpdateProfile, method: .post, parameters: params).responseData { response in
            SVProgressHUD.dismiss(withDelay: 1)  // dismiss spinner
            switch response.result {
            case  .success:
                SVProgressHUD.showSuccess(withStatus: "Your Profile Updated!")
            case let .failure(error):
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            }
        }
    }
    
    // Update user password (assume identity is already confirmed by JWT)
    func updateUserPassword(_ username: String, _ newPin: String) {
        let username = s1Textfields[0]
        let cellPin = tableView.cellForRow(at: IndexPath.init(row: 0, section: 1)) as! MyCell
        let cellConfirm = tableView.cellForRow(at: IndexPath.init(row: 1, section: 1)) as! MyCell
        let newPin = cellPin.textfield.text!
        let pinConfirm = cellConfirm.textfield.text!
        // do some validation before update
        if newPin != pinConfirm {
            showAlert(title: "Pins Not Identical", message: "Please double check you password and confirm to make sure they are identical.", buttonMessage: "OK")
        } else if newPin.count <= 6 {
            showAlert(title: "Pin Too Short", message: "Please use a stronger password with numbers and letters combined.", buttonMessage: "OK")
        } else {
            let params: Parameters = [
                "username": username,
                "newPin": newPin
            ]
            
            SVProgressHUD.show()  // show spinner
            AF.request(urlUpdatePin, method: .post, parameters: params).responseData { response in
                SVProgressHUD.dismiss(withDelay: 1)  // dismiss spinner
                switch response.result {
                case  .success:
                    SVProgressHUD.showSuccess(withStatus: "You Password Updated!")
                    cellPin.textfield.text = ""
                    cellConfirm.textfield.text = ""
                case let .failure(error):
                    SVProgressHUD.showError(withStatus: error.localizedDescription)
                }
            }
        }
    }
    
    
    // Show alert
    func showAlert(title ti: String, message msg: String, buttonMessage btnMsg: String) {
        let alert = UIAlertController(title: ti, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: btnMsg, style: .cancel, handler: nil)
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - TableView DataSource Method
    
    // sections, row numbers
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionLabels[section].count
    }
    
    // header
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        let label = UILabel()
        
        label.frame = CGRect(x: 10, y: 3, width: 180, height: 35)
        label.textColor = FlatNavyBlueDark()
        label.text = sectionTitles[section]  // 0 -> BASIC INFO, 1 -> PASSWORD
        view.addSubview(label)
        view.backgroundColor = FlatWhite()
        
        return view
    }
    
    // footer
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier:
            "sectionHeader") as! MyTableSectionFooter
        view.saveBtn.tag = section  // assign section no. to saveBtn, 0 -> profile, 1 -> password
        view.saveBtn.addTarget(self, action: #selector(saveBtnPressed), for: .touchUpInside)
        
        return view
    }
    

    // customize cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! MyCell
        
        cell.label.text = sectionLabels[indexPath.section][indexPath.row]
        cell.textfield.placeholder = sectionPlaceholders[indexPath.section][indexPath.row]
        
        if indexPath.section == 1 {  // password section, change text to •••••••
            cell.textfield.textContentType = .password
            cell.textfield.isSecureTextEntry = true
        }
        if s1Textfields.count > 0 && indexPath.section == 0 {  // if profile section && data source loaded, display
            cell.textfield.text = s1Textfields[indexPath.row]
        }
        
        return cell
    }
}

