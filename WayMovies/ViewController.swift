//
//  ViewController.swift
//  WayMovies
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

// TODO: Add image caching
// TODO: Refactor API requests into well-organized methods
// TODO: Figure out why images aren't populating
// TODO: Figure out constraints for customCell

class ViewController: UIViewController, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    var movies = [Movie]()

    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }

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

        // Set movie title and rating
        cell.titleLabel?.text = self.movies[indexPath.item].title
        cell.ratingLabel?.text = String(self.movies[indexPath.item].popularity)

        // Get movie image
        let baseURL = "http://image.tmdb.org/t/p/"
        let width = "w100"
        let posterPath = String(self.movies[indexPath.item].poster_path)
        let downloadURL = URL(string: baseURL + width + posterPath)

        cell.movieImage?.contentMode = .scaleAspectFill

        getDataFromUrl(url: downloadURL!) { data, response, error in
            guard let data = data, error == nil else { return }
            print("Download Finished: " + (response?.suggestedFilename)!)
            DispatchQueue.main.async() {
                cell.movieImage.image = UIImage(data: data)
            }
        }

        // EXAMPLE URL: http://image.tmdb.org/t/p/w185//nBNZadXqJSdt05SHLqgT0HuC5Gm.jpg


        print(self.movies[indexPath.item].title)
        print(self.movies[indexPath.item].popularity)
        return cell
    }

}
