//
//  CustomCollectionViewCell.swift
//  WayMovies
//
//  Created by Aaron Lichtman on 6/1/18.
//  Copyright © 2018 Aaron Lichtman. All rights reserved.
//

import UIKit
import Cosmos

class SearchResultCell: UICollectionViewCell {

    @IBOutlet weak var movieImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var categoryTag: UILabel!
    @IBOutlet weak var cosmosView: CosmosView!
}
