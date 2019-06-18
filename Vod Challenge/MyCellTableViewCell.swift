//
//  MyCellTableViewCell.swift
//  Vod Challenge
//
//  Created by DongMing on 2019-06-18.
//  Copyright © 2019 littlebiteverything. All rights reserved.
//

import UIKit

class MyCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textfield: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
