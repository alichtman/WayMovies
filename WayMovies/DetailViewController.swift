//
//  DetailViewController.swift
//  WayMovies
//
//  Created by Aaron Lichtman on 6/7/18.
//  Copyright © 2018 Aaron Lichtman. All rights reserved.
//

import UIKit
import Cosmos

class DetailViewController: InteractiveViewController {
    
    // TODO: Swipe to dismiss detail.
    // https://gist.githubusercontent.com/gyubokbaik/d2ec06fed597759c56aa62c5ff71e9a0/raw/2c9fde04404914cb6e1f5b07db1f9f66e82fe558/panGestureRecognizerHandler.txt
    
    var movieDetail: MovieDetails
    
    init(movieDetail: MovieDetails) {
        self.movieDetail = movieDetail
        super.init(nibName: nil, bundle: nil)
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cornerRadiusConstant : CGFloat = CGFloat(15)
        
        let movieDetailView = UIView()
        movieDetailView.translatesAutoresizingMaskIntoConstraints = false
        movieDetailView.backgroundColor = .white
        movieDetailView.layer.cornerRadius = cornerRadiusConstant
        movieDetailView.clipsToBounds = true
        self.view.addSubview(movieDetailView)
        
        let movieImage = UIImageView()
        movieImage.contentMode = .scaleAspectFill
        movieImage.translatesAutoresizingMaskIntoConstraints = false
        movieImage.image = movieDetail.image
        movieImage.clipsToBounds = true
        movieDetailView.addSubview(movieImage)
        
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = movieDetail.movie.title
        title.numberOfLines = 0
        title.textAlignment = .left
        title.font = UIFont(name: "AvenirNext-Bold", size: 24)
        movieDetailView.addSubview(title)
        
        let cosmosView = CosmosView()
        // THIS LINE IS IMPORTANT FOR PROGRAMATIC UI CONSTRUCTION
        cosmosView.translatesAutoresizingMaskIntoConstraints = false
        cosmosView.settings.updateOnTouch = false
        cosmosView.settings.fillMode = .half
        cosmosView.settings.starSize = 25
        cosmosView.settings.starMargin = 5
        cosmosView.rating = movieDetail.movie.vote_average
        movieDetailView.addSubview(cosmosView)
        
        let summary = UILabel()
        summary.translatesAutoresizingMaskIntoConstraints = false
        summary.text = movieDetail.movie.overview
        summary.numberOfLines = 0
        summary.textAlignment = .left
        summary.font = UIFont(name: "AvenirNext-Light", size: 14)
        movieDetailView.addSubview(summary)
        
        let xSmallSpacing: CGFloat = 4
        let smallSpacing: CGFloat = 8
        let largeSpacing: CGFloat = 16
        
        NSLayoutConstraint.activate([
            movieDetailView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            movieDetailView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: largeSpacing),
            movieDetailView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -largeSpacing),
            movieDetailView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            
            movieImage.topAnchor.constraint(equalTo: movieDetailView.topAnchor),
            movieImage.leadingAnchor.constraint(equalTo: movieDetailView.leadingAnchor),
            movieImage.trailingAnchor.constraint(equalTo: movieDetailView.trailingAnchor),
            
            title.topAnchor.constraint(equalTo: movieImage.bottomAnchor, constant: smallSpacing),
            title.leadingAnchor.constraint(equalTo: movieDetailView.leadingAnchor, constant: smallSpacing),
            title.trailingAnchor.constraint(equalTo: movieDetailView.trailingAnchor),
            
            cosmosView.topAnchor.constraint(equalTo: title.bottomAnchor),
            cosmosView.leadingAnchor.constraint(equalTo: movieDetailView.leadingAnchor, constant: xSmallSpacing),
            cosmosView.trailingAnchor.constraint(equalTo: movieDetailView.trailingAnchor),
            
            summary.topAnchor.constraint(equalTo: cosmosView.bottomAnchor, constant: smallSpacing),
            summary.leadingAnchor.constraint(equalTo: movieDetailView.leadingAnchor, constant: largeSpacing),
            summary.trailingAnchor.constraint(equalTo: movieDetailView.trailingAnchor, constant: -smallSpacing),
            summary.bottomAnchor.constraint(lessThanOrEqualTo: movieDetailView.bottomAnchor, constant: -smallSpacing)
            ])
    }
}
