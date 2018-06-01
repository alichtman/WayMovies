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

let TMDB_apiKey: String = "0de424715a984f077e1ad542e6cfb656"

class ViewController: UIViewController {
    
    var movies = [Movie]()
    
    fileprivate func getMovieData() -> [Movie] {
        let url = URL(string: "https://api.themoviedb.org/3/discover/movie?api_key=\(TMDB_apiKey)")
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error == nil {
                print("No ERR")
                do {
                    print("Fetch")
                    var movies: [Movie] = try JSONDecoder().decode(MovieListResponse.self, from: data!).results
                    print(movies)
                    return movies
                } catch {
                    print("Err")
                }
            }
            }.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Get JSON data and drop it in the movies array
        print("Getting data...")
        getMovieData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
