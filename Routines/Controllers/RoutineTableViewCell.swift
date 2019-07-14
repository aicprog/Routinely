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
    
    
//    @IBOutlet weak var cellBackground: UIImageView!{
//        didSet{
//            blurImage()
//        }
//    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
       customizeUIViewCell()

    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
//    func blurImage(){
//        
//        cellBackground.image = UIImage(named: "cellBackground5")
//
//        let darkBlur = UIBlurEffect(style: .dark)
//        // 2
//        let blurView = UIVisualEffectView(effect: darkBlur)
//        
//        blurView.frame = cellBackground!.bounds
//        // 3
//        cellBackground?.addSubview(blurView)
//        cellBackground.alpha = CGFloat(0.7)
//        
//    }

    //MARK: - Customization of UI of Cell
    func customizeUIViewCell(){
        //rounded Corners
        self.layer.cornerRadius = 20
        self.layer.masksToBounds = true
        //self.layer.borderWidth = 1
        
        cellBackground.layer.cornerRadius = 20
        cellBackground.layer.masksToBounds = true
        cellBackground.image = UIImage(named: "cellBackground5")
        
        let darkBlur = UIBlurEffect(style: .dark)
        // 2
        let blurView = UIVisualEffectView(effect: darkBlur)
        
        blurView.frame = self.cellBackground!.bounds
        // 3
        cellBackground?.addSubview(blurView)
        cellBackground.alpha = CGFloat(0.7)
        
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
    


}
