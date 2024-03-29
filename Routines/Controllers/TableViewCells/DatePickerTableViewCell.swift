//
//  DatePickerTableViewCell.swift
//  Routines
//
//  Created by Adriany Cocom on 7/16/19.
//  Copyright © 2019 aic. All rights reserved.
//

import UIKit

class DatePickerTableViewCell: UITableViewCell {

    //MARK: IB Outlets
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!

    
    //MARK: My variables
    var doneInputting: (() -> Void)? = nil

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.isHidden = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: DatePicker
    
    @IBAction func datePickerChanged(_ sender: UIDatePicker) {
        if let changeDate = self.doneInputting{
            changeDate()
        }
    }
    
 
    

}
