//
//  CollectionViewCell.swift
//  Swift-Kingfisher
//
//  Created by Alan Yen on 2017/6/4.
//  Copyright © 2017年 Alan-App. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var cellImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.layer.borderColor = UIColor.gray.cgColor
        self.contentView.layer.borderWidth = (1.0 / UIScreen.main.scale)
    }
}
