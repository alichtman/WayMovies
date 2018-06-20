//
//  BrowseCollectionViewCell.swift
//  WayMovies
//
//  Created by Aaron Lichtman on 6/13/18.
//  Copyright © 2018 Aaron Lichtman. All rights reserved.
//

import UIKit
import Cosmos

class BrowseCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var movieImage: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var stars: CosmosView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
