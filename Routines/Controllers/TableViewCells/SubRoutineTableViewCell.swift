//
//  SubRoutineTableViewCell.swift
//  Routines
//
//  Created by Adriany Cocom on 7/14/19.
//  Copyright © 2019 aic. All rights reserved.
//

import UIKit

class SubRoutineTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    //MarK: - My variables
    var chkButton : (() -> Void)? = nil
    var doneInputting: (() -> Void)? = nil
    
    
    //MARK: - IBOutlets
    

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameTxtField: UITextField!

    @IBOutlet weak var checkImage: UIImageView!
    @IBOutlet weak var checkButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.nameTxtField.delegate = self
        self.nameTxtField.isHidden = true
        self.nameLabel.isUserInteractionEnabled = true
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    //MARK: - IB Actions
    @IBAction func checkButtonPressed(_ sender: UIButton) {
        if let btnAction = self.chkButton
        {
            btnAction()
            //  user!("pass string")
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let doneInputting = self.doneInputting
        {
            
            doneInputting()
        }
        return true 
    }
    
    
    
}



