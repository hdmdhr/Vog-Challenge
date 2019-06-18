//
//  MyTableSectionFooter.swift
//  Vod Challenge
//
//  Created by DongMing on 2019-06-18.
//  Copyright © 2019 littlebiteverything. All rights reserved.
//

import UIKit

class MyTableSectionFooter: UITableViewHeaderFooterView {

    let saveBtn = UIButton()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureContents()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureContents() {
        saveBtn.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(saveBtn)
        
        // set background to transparent
        contentView.backgroundColor = .red
        
        // center button in the middle
        saveBtn.setTitle("SAVE CHANGES", for: .normal)
        saveBtn.tintColor = .white
        
        NSLayoutConstraint.activate([
            saveBtn.widthAnchor.constraint(equalToConstant: 180),
            saveBtn.heightAnchor.constraint(equalToConstant: 50),
            saveBtn.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            saveBtn.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
