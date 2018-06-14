//
//  DetailViewController.swift
//  WayMovies
//
//  Created by Aaron Lichtman on 6/7/18.
//  Copyright © 2018 Aaron Lichtman. All rights reserved.
//

import UIKit
import Cosmos

struct Person: Decodable {
    let biography: String
}

class DetailViewController: InteractiveViewController {
    
    var detailObject: DetailsObject
    
    var personText: String?
    
    init(movieDetail: DetailsObject) {
        self.detailObject = movieDetail
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
        movieImage.image = detailObject.image
        movieImage.clipsToBounds = true
        movieDetailView.addSubview(movieImage)
        
        let type: String = detailObject.data.media_type
        
        let categoryTag = UILabel()
        categoryTag.translatesAutoresizingMaskIntoConstraints = false
        categoryTag.font = UIFont(name: "AvenirNext-Bold", size: 16)
        categoryTag.numberOfLines = 0
        categoryTag.textAlignment = .left
        categoryTag.textColor = .white
        
        if type == "movie" {
            categoryTag.backgroundColor = categoryTagColor.movieColor
            categoryTag.text = categoryTagText.movieTag
        } else if type == "tv" {
            categoryTag.backgroundColor = categoryTagColor.tvColor
            categoryTag.text = categoryTagText.tvTag
        } else {
            categoryTag.backgroundColor = categoryTagColor.personColor
            categoryTag.text = categoryTagText.personTag
        }
        movieDetailView.addSubview(categoryTag)
        
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.numberOfLines = 0
        title.textAlignment = .left
        title.textColor = .white
        title.font = UIFont(name: "AvenirNext-Bold", size: 24)
        
        if type == "movie" {
            title.text = detailObject.data.title
        } else if type == "tv" || type == "person" {
            title.text = detailObject.data.name
        }
        
        movieDetailView.addSubview(title)
        
        let cosmosView = CosmosView()
        // THIS LINE IS IMPORTANT FOR PROGRAMATIC UI CONSTRUCTION
        cosmosView.translatesAutoresizingMaskIntoConstraints = false
        
        if detailObject.data.media_type != "person" {
            cosmosView.settings.updateOnTouch = false
            cosmosView.settings.fillMode = .half
            cosmosView.settings.starSize = 25
            cosmosView.settings.starMargin = 5
            cosmosView.rating = detailObject.data.vote_average!
        } else {
            cosmosView.settings.filledColor = .clear
            cosmosView.settings.emptyBorderColor = .clear
            cosmosView.settings.emptyColor = .clear
            cosmosView.settings.filledBorderColor = .clear
        }
        
        movieDetailView.addSubview(cosmosView)
        
        let summary = UILabel()
        summary.translatesAutoresizingMaskIntoConstraints = false
        
        // Set Person text = known_for[0].mediaType -> known_for[0].overview
        if type == "person" {
            // API REQUEST TO https://api.themoviedb.org/3/person/{IDHERE}\?api_key\=71ab1b19293efe581c569c1c79d0f004
            let searchURL = URL(string: "https://api.themoviedb.org/3/person/\(detailObject.data.id)?api_key=\(TMDB_apiKey)")
            URLSession.shared.dataTask(with: searchURL!) { [weak self] (data, response, error) in
                if error == nil {
                    do {
                        print("API Request for Person Data")
                        print(try JSONSerialization.jsonObject(with: data!))
                        let personData = try JSONDecoder().decode(Person.self, from: data!)
                        self?.personText = personData.biography
                        
                        DispatchQueue.main.async {
                            summary.text = self?.personText
                        }
                    } catch {
                        print(error)
                    }
                }
                }.resume()
        } else {
            summary.text = detailObject.data.overview!
        }
        
        summary.numberOfLines = 0
        summary.textAlignment = .left
        summary.font = UIFont(name: "AvenirNext-Light", size: 14)
        movieDetailView.addSubview(summary)
        
        let xxSmallSpacing: CGFloat = 2
        let xSmallSpacing: CGFloat = 4
        let smallSpacing: CGFloat = 8
        let largeSpacing: CGFloat = 16
        
        if type == "person" {
            NSLayoutConstraint.activate([
                movieDetailView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                movieDetailView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: largeSpacing),
                movieDetailView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -largeSpacing),
                movieDetailView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
                movieDetailView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.8),
                
                movieImage.topAnchor.constraint(equalTo: movieDetailView.topAnchor),
                movieImage.leadingAnchor.constraint(equalTo: movieDetailView.leadingAnchor),
                movieImage.trailingAnchor.constraint(equalTo: movieDetailView.trailingAnchor),
                movieImage.heightAnchor.constraint(lessThanOrEqualToConstant: 250),
                
                // Stick category on top of title
                categoryTag.bottomAnchor.constraint(equalTo: title.topAnchor, constant: -xxSmallSpacing),
                categoryTag.leadingAnchor.constraint(equalTo: movieDetailView.leadingAnchor, constant: smallSpacing),
                
                // Stick title above the bottom of the image
                title.bottomAnchor.constraint(equalTo: movieImage.bottomAnchor, constant: -smallSpacing),
                title.leadingAnchor.constraint(equalTo: movieDetailView.leadingAnchor, constant: smallSpacing),
                title.trailingAnchor.constraint(equalTo: movieDetailView.trailingAnchor),
                
                // Stick summary below image
                summary.topAnchor.constraint(equalTo: movieImage.bottomAnchor, constant: smallSpacing),
                summary.leadingAnchor.constraint(equalTo: movieDetailView.leadingAnchor, constant: largeSpacing),
                summary.trailingAnchor.constraint(equalTo: movieDetailView.trailingAnchor, constant: -smallSpacing),
                summary.bottomAnchor.constraint(lessThanOrEqualTo: movieDetailView.bottomAnchor, constant: smallSpacing)
                ])
        } else {
            NSLayoutConstraint.activate([
                movieDetailView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                movieDetailView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: largeSpacing),
                movieDetailView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -largeSpacing),
                movieDetailView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
                movieDetailView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.65),
                
                movieImage.topAnchor.constraint(equalTo: movieDetailView.topAnchor),
                movieImage.leadingAnchor.constraint(equalTo: movieDetailView.leadingAnchor),
                movieImage.trailingAnchor.constraint(equalTo: movieDetailView.trailingAnchor),
                movieImage.heightAnchor.constraint(lessThanOrEqualToConstant: 250),
                
                // Stick category on top of title
                categoryTag.bottomAnchor.constraint(equalTo: title.topAnchor, constant: -xxSmallSpacing),
                categoryTag.leadingAnchor.constraint(equalTo: movieDetailView.leadingAnchor, constant: smallSpacing),
                
                // Stick title on top of stars
                title.bottomAnchor.constraint(equalTo: cosmosView.topAnchor, constant: xxSmallSpacing),
                title.leadingAnchor.constraint(equalTo: movieDetailView.leadingAnchor, constant: smallSpacing),
                title.trailingAnchor.constraint(equalTo: movieDetailView.trailingAnchor),
                
                // Put stars above the bottom of the image
                cosmosView.bottomAnchor.constraint(equalTo: movieImage.bottomAnchor, constant: -smallSpacing),
                cosmosView.leadingAnchor.constraint(equalTo: movieDetailView.leadingAnchor, constant: xSmallSpacing),
                cosmosView.trailingAnchor.constraint(equalTo: movieDetailView.trailingAnchor),
                
                // Stick summary below image
                summary.topAnchor.constraint(equalTo: movieImage.bottomAnchor, constant: smallSpacing),
                summary.leadingAnchor.constraint(equalTo: movieDetailView.leadingAnchor, constant: largeSpacing),
                summary.trailingAnchor.constraint(equalTo: movieDetailView.trailingAnchor, constant: -smallSpacing),
                summary.bottomAnchor.constraint(lessThanOrEqualTo: movieDetailView.bottomAnchor, constant: smallSpacing)
                ])
        }
    }
}
