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
    var urlGetUser = "http://localhost:3000/api.foo.com/profiles/"
    let urlUpdateProfile = "http://localhost:3000/api.foo.com/profiles/update"
    let urlUpdatePin = "http://localhost:3000/api.foo.com/password/change"
    let urlNewUser = "http://localhost:3000/api.foo.com/new-user"

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
        AF.request(url, method: .get).responseJSON {
            response in
            SVProgressHUD.dismiss(withDelay: 1)  // dismiss spinner
            switch response.result {
            case let .success(value):
//                print("Success, got user data \(value).")
                let userJSON = JSON(value)
                self.updateUserInfo(json: userJSON)
                
            case let .failure(error):
                print("Following error occured: \(error)")
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
    
    
    
    
    // MARK: - TableView DataSource Method
    
    // section, row numbers
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionLabels[section].count
    }
    
    // section header
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        let label = UILabel()
        
        label.frame = CGRect(x: 10, y: 3, width: 180, height: 35)
        label.textColor = FlatNavyBlueDark()
        label.text = sectionTitles[section]
        view.addSubview(label)
        view.backgroundColor = FlatWhite()
        
        return view
    }
    
    // section footer
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier:
            "sectionHeader") as! MyTableSectionFooter
        view.saveBtn.setTitle(sectionTitles[section], for: .reserved)
        
        return view
    }
    

    // customize cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! MyCell
        
        cell.label.text = sectionLabels[indexPath.section][indexPath.row]
        cell.textfield.placeholder = sectionPlaceholders[indexPath.section][indexPath.row]
        if s1Textfields.count > 0 {
            cell.textfield.text = s1Textfields[indexPath.row]
        }
        
        return cell
    }
}

