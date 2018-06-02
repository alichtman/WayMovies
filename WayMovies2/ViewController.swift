//
//  ViewController.swift
//  WayMovies2
//
//  Created by Aaron Lichtman on 6/1/18.
//  Copyright © 2018 Aaron Lichtman. All rights reserved.
//

import UIKit

/**
 "results": [
 {
 "id": 383498,
 "vote_average": 7.9,
 "title": "Deadpool 2",
 "popularity": 321.086589,
 "poster_path": "/to0spRl1CMDvyUbOnbb4fTk3VAd.jpg",
 "original_title": "Deadpool 2",
 "backdrop_path": "/3P52oz9HPQWxcwHOwxtyrVV1LKi.jpg",
 "overview": "Wisecracking mercenary Deadpool battles the evil and powerful Cable and other bad guys to save a boy's life.",
 },
 **/

struct Movie: Decodable {
    let id: Int
    let title: String
    let overview: String
    let popularity: Double
    let poster_path: String
    let backdrop_path: String
}

struct MovieListResponse: Decodable {
    let results: [Movie]
}


class ViewController: UIViewController, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var movies = [Movie]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        
        // Get JSON data and drop it in the movies array
        let TMDB_apiKey: String = "0de424715a984f077e1ad542e6cfb656"
        let url = URL(string: "https://api.themoviedb.org/3/discover/movie?api_key=\(TMDB_apiKey)")
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error == nil {
                do {
                    print("Fetch")
                    self.movies = try JSONDecoder().decode(MovieListResponse.self, from: data!).results
                    print(self.movies)
                } catch {
                    print("Err")
                }
                
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                    
                }
            }
        }.resume()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(self.movies.count)
        return self.movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "customCell", for: indexPath) as!CustomCollectionViewCell
        
        cell.titleLabel?.text = self.movies[indexPath.item].title
        cell.ratingLabel?.text = String(self.movies[indexPath.item].popularity)
        
        print(self.movies[indexPath.item].title)
        print(self.movies[indexPath.item].popularity)
        return cell
    }
    
}
