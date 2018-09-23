//
//  CustomEventCell.swift
//  Eventr
//
//  Created by Jerry on 19/9/18.
//  Copyright © 2018 Jerry. All rights reserved.
//

import UIKit

class CustomEventCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    
    @IBOutlet weak var eventLabel: UILabel!
    @IBOutlet weak var relativeTimeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = UIColor.clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
