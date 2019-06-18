//
//  ViewController.swift
//  Vod Challenge
//
//  Created by DongMing on 2019-06-17.
//  Copyright © 2019 littlebiteverything. All rights reserved.
//

import UIKit

class UserProfileVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - GLOBAL VARS
    
    let sectionTitles = ["BASIC INFO", "PASSWORD"]
    let s1Labels = ["Username", "First Name", "Last Name"]
    let s2Labels = ["New Password", "Re-enter Password"]
    let s1Placeholders = ["Your username", "Your first name", "Your last name"]
    let s2Placeholders = ["New strong password", "Please type again"]
    var sectionLabels: [[String]] = []
    var sectionPlaceholders: [[String]] = []
    
    // MARK: - APP LIFE CYCLE METHODS
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sectionLabels = [s1Labels, s2Labels]
        sectionPlaceholders = [s1Placeholders, s2Placeholders]
        
        // Register MyTableSectionFooter
        tableView.register(MyTableSectionFooter.self, forHeaderFooterViewReuseIdentifier: "sectionHeader")
    }

    
    // MARK: - TableView DataSource Method
    
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
        
        label.frame = CGRect(x: 5, y: 5, width: 180, height: 35)
        label.text = sectionTitles[section]
        view.addSubview(label)
        view.backgroundColor = UIColor.lightGray
        
        return view
    }
    
    // section footer
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier:
            "sectionHeader") as! MyTableSectionFooter
        view.saveBtn.setTitle(sectionTitles[section], for: .reserved)
        
        return view
    }
    

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! MyCell
        
        cell.label.text = sectionLabels[indexPath.section][indexPath.row]
        cell.textfield.placeholder = sectionPlaceholders[indexPath.section][indexPath.row]
        
        return cell
    }
}

