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
        
        let categoryTag = UILabel()
        categoryTag.translatesAutoresizingMaskIntoConstraints = false
        categoryTag.font = UIFont(name: "AvenirNext-Bold", size: 16)
        categoryTag.numberOfLines = 0
        categoryTag.textAlignment = .left
        categoryTag.textColor = .white
        
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.numberOfLines = 0
        title.textAlignment = .left
        title.textColor = .white
        title.font = UIFont(name: "AvenirNext-Bold", size: 24)
        
        let cosmosView = CosmosView()
        // THIS LINE IS IMPORTANT FOR PROGRAMATIC UI CONSTRUCTION
        cosmosView.translatesAutoresizingMaskIntoConstraints = false
        cosmosView.settings.updateOnTouch = false
        cosmosView.settings.fillMode = .half
        cosmosView.settings.starMargin = 5
        cosmosView.settings.starSize = 30
        
        let summary = UILabel()
        summary.translatesAutoresizingMaskIntoConstraints = false
        summary.numberOfLines = 0
        summary.textAlignment = .left
        summary.font = UIFont(name: "AvenirNext-Light", size: 14)
        
        switch detailObject.data.media_type {
        case objType.movie:
            categoryTag.backgroundColor = categoryTagColor.movieColor
            categoryTag.text = categoryTagText.movieTag
            title.text = detailObject.data.title
            cosmosView.rating = detailObject.data.vote_average!
            summary.text = detailObject.data.overview!
            
        case objType.tv:
            categoryTag.backgroundColor = categoryTagColor.tvColor
            categoryTag.text = categoryTagText.tvTag
            title.text = detailObject.data.name
            cosmosView.rating = detailObject.data.vote_average!
            summary.text = detailObject.data.overview!
            
        case objType.person:
            categoryTag.backgroundColor = categoryTagColor.personColor
            categoryTag.text = categoryTagText.personTag
            title.text = detailObject.data.name
            cosmosView.settings.starSize = 0
            
            // Get person summary data
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
            
            
        default:
            print("IMPOSSIBLE ERROR")
        }
        
        movieDetailView.addSubview(categoryTag)
        movieDetailView.addSubview(title)
        movieDetailView.addSubview(cosmosView)
        movieDetailView.addSubview(summary)
        
        let xxSmallSpacing: CGFloat = 2
        let xSmallSpacing: CGFloat = 4
        let smallSpacing: CGFloat = 8
        let largeSpacing: CGFloat = 16
        
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
