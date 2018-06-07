//
//  DetailViewController.swift
//  WayMovies
//
//  Created by Aaron Lichtman on 6/7/18.
//  Copyright © 2018 Aaron Lichtman. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    // TODO: Swipe to dismiss detail.
    // https://gist.githubusercontent.com/gyubokbaik/d2ec06fed597759c56aa62c5ff71e9a0/raw/2c9fde04404914cb6e1f5b07db1f9f66e82fe558/panGestureRecognizerHandler.txt
    
    var movieDetail: MovieDetails
    var initialTouchPoint: CGPoint = CGPoint(x: 0,y: 0)
    
    
    init(movieDetail: MovieDetails) {
        self.movieDetail = movieDetail
        super.init(nibName: nil, bundle: nil)
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @IBAction func panGestureRecognizerHandler(_ sender: UIPanGestureRecognizer) {
        let touchPoint = sender.location(in: self.view?.window)
        
        if sender.state == UIGestureRecognizerState.began {
            initialTouchPoint = touchPoint
        } else if sender.state == UIGestureRecognizerState.changed {
            if touchPoint.y - initialTouchPoint.y > 0 {
                self.view.frame = CGRect(x: 0, y: touchPoint.y - initialTouchPoint.y, width: self.view.frame.size.width, height: self.view.frame.size.height)
            }
        } else if sender.state == UIGestureRecognizerState.ended || sender.state == UIGestureRecognizerState.cancelled {
            if touchPoint.y - initialTouchPoint.y > 100 {
                self.dismiss(animated: true, completion: nil)
            } else {
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
                })
            }
        }
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