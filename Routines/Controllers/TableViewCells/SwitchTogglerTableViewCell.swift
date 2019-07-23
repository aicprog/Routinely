//
//  SwitchTogglerTableViewCell.swift
//  Routines
//
//  Created by Adriany Cocom on 7/17/19.
//  Copyright © 2019 aic. All rights reserved.
//

import UIKit



class SwitchTogglerTableViewCell: UITableViewCell {
    
    //MARK: - My Variables
    var switchToggled: (() -> Void)? = nil
    
    //MARK: - My Outlets
    @IBOutlet weak var remindMeSwitch: UISwitch!
    
    @IBOutlet weak var routineName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        remindMeSwitch.isOn = false 
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func switchToggled(_ sender: UISwitch) {
        if let switchChanged = self.switchToggled{
            switchChanged()
        }
    }
    
}
