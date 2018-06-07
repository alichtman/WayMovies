//
//  DetailViewController.swift
//  WayMovies
//
//  Created by Aaron Lichtman on 6/7/18.
//  Copyright © 2018 Aaron Lichtman. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
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
        self.view.addSubview(movieDetailView)
        
        let movieImage = UIImageView()
        movieImage.contentMode = .scaleAspectFill
        movieImage.translatesAutoresizingMaskIntoConstraints = false
        movieImage.image = movieDetail.image
        movieImage.layer.cornerRadius = cornerRadiusConstant
        movieImage.clipsToBounds = true
        movieDetailView.addSubview(movieImage)
        
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = movieDetail.movie.title
        title.numberOfLines = 0
        title.textAlignment = .left
        title.font = UIFont(name: "AvenirNext-Medium", size: 24)
        movieDetailView.addSubview(title)
        
        NSLayoutConstraint.activate([
            movieDetailView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            movieDetailView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            movieDetailView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            movieDetailView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            
            movieImage.topAnchor.constraint(equalTo: movieDetailView.topAnchor),
            movieImage.leadingAnchor.constraint(equalTo: movieDetailView.leadingAnchor),
            movieImage.trailingAnchor.constraint(equalTo: movieDetailView.trailingAnchor),
            
            title.topAnchor.constraint(equalTo: movieImage.bottomAnchor, constant: 8),
            title.leadingAnchor.constraint(equalTo: movieDetailView.leadingAnchor, constant: 8),
            title.trailingAnchor.constraint(equalTo: movieDetailView.trailingAnchor),
            title.bottomAnchor.constraint(lessThanOrEqualTo: movieDetailView.bottomAnchor)
            ])
        // Do any additional setup after loading the view.
    }
    
    
    
}
