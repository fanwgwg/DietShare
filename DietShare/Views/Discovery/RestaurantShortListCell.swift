//
//  RestaurantShortListCell.swift
//  DietShare
//
//  Created by Shuang Yang on 3/4/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import Foundation
import UIKit

class RestaurantShortListCell: UICollectionViewCell {
    
    @IBOutlet weak var imageHolder: UIView!
    @IBOutlet weak private var restaurantImage: UIImageView!
    @IBOutlet weak private var restaurantName: UILabel!

    func setImage(_ image: UIImage) {
        let croppedImage = cropToBounds(image, Double(restaurantImage.frame.width), Double(restaurantImage.frame.height))
        restaurantImage.image = croppedImage
        restaurantImage.alpha = CGFloat(Constants.DiscoveryPage.shortListCellAlpha)
        addRoundedRectBackground(restaurantImage, Constants.defaultCornerRadius, 0, UIColor.clear.cgColor, UIColor.clear)
        addShadowToView(view: self.imageHolder, offset: 2, radius: 2)
    }
    
    func setName(_ name: String) {
        restaurantName.text = name
    }
}
