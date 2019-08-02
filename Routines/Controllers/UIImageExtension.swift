//
//  UIImageExtension.swift
//  Routines
//
//  Created by Adriany Cocom on 8/1/19.
//  Copyright © 2019 aic. All rights reserved.
//

import UIKit

extension UIImage {
    
    //Extension created by AhmedZah of StackOverflow
    public class func PNGRepresentation(_ img: UIImage) -> Data? {
        // No-op if the orientation is already correct
        if (img.imageOrientation == UIImage.Orientation.up) {
            return img.pngData();
        }
        // We need to calculate the proper transformation to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
        var transform:CGAffineTransform = CGAffineTransform.identity
        
        if (img.imageOrientation == UIImage.Orientation.down
            || img.imageOrientation == UIImage.Orientation.downMirrored) {
            
            transform = transform.translatedBy(x: img.size.width, y: img.size.height)
            transform = transform.rotated(by: CGFloat(Double.pi))
        }
        
        if (img.imageOrientation == UIImage.Orientation.left
            || img.imageOrientation == UIImage.Orientation.leftMirrored) {
            
            transform = transform.translatedBy(x: img.size.width, y: 0)
            transform = transform.rotated(by: CGFloat(Double.pi/2))
        }
        
        if (img.imageOrientation == UIImage.Orientation.right
            || img.imageOrientation == UIImage.Orientation.rightMirrored) {
            
            transform = transform.translatedBy(x: 0, y: img.size.height);
            transform = transform.rotated(by: CGFloat(-Double.pi/2));
        }
        
        if (img.imageOrientation == UIImage.Orientation.upMirrored
            || img.imageOrientation == UIImage.Orientation.downMirrored) {
            
            transform = transform.translatedBy(x: img.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        }
        
        if (img.imageOrientation == UIImage.Orientation.leftMirrored
            || img.imageOrientation == UIImage.Orientation.rightMirrored) {
            
            transform = transform.translatedBy(x: img.size.height, y: 0);
            transform = transform.scaledBy(x: -1, y: 1);
        }
        
        
        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        let ctx:CGContext = CGContext(data: nil, width: Int(img.size.width), height: Int(img.size.height),
                                      bitsPerComponent: img.cgImage!.bitsPerComponent, bytesPerRow: 0,
                                      space: img.cgImage!.colorSpace!,
                                      bitmapInfo: img.cgImage!.bitmapInfo.rawValue)!
        
        ctx.concatenate(transform)
        
        
        if (img.imageOrientation == UIImage.Orientation.left
            || img.imageOrientation == UIImage.Orientation.leftMirrored
            || img.imageOrientation == UIImage.Orientation.right
            || img.imageOrientation == UIImage.Orientation.rightMirrored
            ) {
            
            
            ctx.draw(img.cgImage!, in: CGRect(x:0,y:0,width:img.size.height,height:img.size.width))
            
        } else {
            ctx.draw(img.cgImage!, in: CGRect(x:0,y:0,width:img.size.width,height:img.size.height))
        }
        
        
        // And now we just create a new UIImage from the drawing context
        let cgimg:CGImage = ctx.makeImage()!
        let imgEnd:UIImage = UIImage(cgImage: cgimg)
        
        return imgEnd.pngData()
    }
}
