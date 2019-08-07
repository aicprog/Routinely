//
//  RepeatTableViewCell.swift
//  Routines
//
//  Created by Adriany Cocom on 8/5/19.
//  Copyright © 2019 aic. All rights reserved.
//

import UIKit

class RepeatTableViewCell: UITableViewCell {
    
    //MARK: - IB Outlets

    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var repeatButton: UIButton!
    
    @IBOutlet weak var reminderSetLabel: UILabel!
    
    var checked = false
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.isHidden = true
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: - IB Actions
    
    @IBAction func repeatButtonTapped(_ sender: UIButton) {
    }
    
}
