//
//  RoutineTableViewCell.swift
//  Routines
//
//  Created by Adriany Cocom on 7/12/19.
//  Copyright © 2019 aic. All rights reserved.
//

import UIKit


class RoutineTableViewCell: UITableViewCell {
    
    
    //MARK: - IBOutlets
    @IBOutlet weak var routineImage: UIImageView!
    
    @IBOutlet weak var cellBackground: UIImageView!
    
    @IBOutlet weak var routineName: UILabel!

    @IBOutlet weak var numberOfSubRoutines: UILabel!
    
    @IBOutlet weak var timeDifference: UILabel!
    //MARK: - My variables
    let defaultImageName = "icon0"

    var goToDetails: (() -> Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        //customize image
        initializeImageProperties()
        
        //customize UIView Cell
        customizeUIViewCell()
        
       

    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    


    //MARK: - Customization of UI of Cell
    func customizeUIViewCell(){
 
        cellBackground.image = UIImage(named: "cellBackground5")
        
        let darkBlur = UIBlurEffect(style: .dark)
        // 2
        let blurView = UIVisualEffectView(effect: darkBlur)
        
        blurView.frame = self.cellBackground!.bounds
        // 3
        cellBackground?.addSubview(blurView)
        cellBackground.alpha = CGFloat(0.7)
        
        //self.accessoryType = .detailButton
        
        
    //spacing inbetween cells
    }
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set (newFrame) {
            var frame =  newFrame
            frame.origin.y += 4
            frame.size.height -= 2 * 3
            super.frame = frame
        }
    }
    
    //MARK: My Functions
    func initializeImageProperties(){
        //rounded image
        routineImage.layer.cornerRadius = routineImage.frame.size.width / 6;
        routineImage.clipsToBounds = true
        routineImage.alpha = 0.9
        

        routineImage.image = UIImage(named: defaultImageName)
       
        //routineImage.image = UIImage(cgImage: routineImage.image!.cgImage!, scale: routineImage.image!.scale, orientation: .up)
        
       
        
    }
    
    
    
    @IBAction func detailButtonPressed(_ sender: UIButton) {
        if let goToDetails = self.goToDetails
        {
            goToDetails()
        }
    }
    


}
