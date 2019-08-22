//
//  BackgroundImageViewController.swift
//  Routines
//
//  Created by Adriany Cocom on 8/16/19.
//  Copyright © 2019 aic. All rights reserved.
//

import UIKit


class BackgroundImageViewController: UIViewController  {
    
    var delegate: WallpaperDelegate?
    var selectedImage: UIImage?
    
    
    var backgrounds: [UIImage] = [
        UIImage(named: "background1")!,
        UIImage(named: "background2")!,
        UIImage(named: "background3")!,
        UIImage(named: "background4")!,
        UIImage(named: "background5")!,
        UIImage(named: "background6")!,
        UIImage(named: "background7")!,
        UIImage(named: "background8")!,
        UIImage(named: "background9")!,
        UIImage(named: "background10")!,
        UIImage(named: "background11")!,
        UIImage(named: "background12")!,
        UIImage(named: "background13")!,
        UIImage(named: "background14")!,
        UIImage(named: "background15")!
        //UIImage(named: "background16")!
//        UIImage(named: "background17")!,
//        UIImage(named: "background18")!,
//        UIImage(named: "background19")!,
//        UIImage(named: "background20")!,
//        UIImage(named: "background21")!,
//        UIImage(named: "background22")!,
//        UIImage(named: "background23")!,
//        UIImage(named: "background24")!,
        ]

    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Do any additional setup after loading the view.
    }

    
    //MARK: - IB Actions
    @IBAction func doneButtonPressed(_ sender: Any) {
        if let image = selectedImage{
            delegate?.passBackBackgroundImage(image: image)
        }
        
        self.dismiss(animated: true, completion: nil)
        
        
        
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}


//MARK: - UICollectionView Extension
extension BackgroundImageViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return backgrounds.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "backgroundImageCell", for: indexPath) as! BackgroundImageCollectionViewCell
        
        cell.layer.cornerRadius = cell.layer.frame.size.width / 4.5;
        
        cell.backgroundImage.image = backgrounds[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! BackgroundImageCollectionViewCell
        cell.layer.borderWidth = 5.0
        cell.layer.borderColor = UIColor.orange.cgColor
        //cell?.backgroundIm
        
        
        let image = backgrounds[indexPath.item]
        selectedImage = image

    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! BackgroundImageCollectionViewCell
        cell.layer.borderWidth = 0
        //cell.backgroundImage.layer.backgroundColor = UIColor.white.cgColor
        
    }
}
