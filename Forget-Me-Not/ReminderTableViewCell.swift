//
//  ReminderTableViewCell.swift
//  Forget-Me-Not
//
//  Created by Lukas Carvajal on 10/18/15.
//  Copyright © 2015 Lukas Carvajal. All rights reserved.
//

import UIKit

class ReminderTableViewCell: UITableViewCell {

    @IBOutlet weak var reminderImageView: UIImageView!
    @IBOutlet weak var reminderLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
