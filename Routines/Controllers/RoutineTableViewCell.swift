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
    
    @IBOutlet weak var circleView: UIView!{
        didSet{
            self.circleView.layer.cornerRadius = 25
            self.circleView.layer.masksToBounds = true
            //self.circleView.backgroundColor = UIColor.white
            //self.circleView.alpha = CGFloat(0.4)
        }
    }

    @IBOutlet weak var routineImage: UIImageView!
    
    @IBOutlet weak var routineName: UILabel!
    
    @IBOutlet weak var cellBackground: UIImageView!{
        didSet{
            blurImage()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //        self.layer.cornerRadius = 25
        //        self.layer.masksToBounds = true
        //        self.layer.shadowColor = UIColor(named: "Orange")?.cgColor
        //        self.layer.backgroundColor = UIColor(named: "Orange")?.cgColor
        //        self.layer.shadowOpacity = 1
        //        self.layer.shadowRadius = 2
        
        
        
        
        
        
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func blurImage(){
        
        cellBackground.image = UIImage(named: "cellBackground5")

        let darkBlur = UIBlurEffect(style: .dark)
        // 2
        let blurView = UIVisualEffectView(effect: darkBlur)
        
        blurView.frame = cellBackground!.bounds
        // 3
        cellBackground?.addSubview(blurView)
        cellBackground.alpha = CGFloat(0.7)
        
    }

    
    

}
