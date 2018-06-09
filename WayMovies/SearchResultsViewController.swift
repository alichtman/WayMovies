//
//  ViewController.swift
//  WayMovies
//
//  Created by Aaron Lichtman on 6/1/18.
//  Copyright © 2018 Aaron Lichtman. All rights reserved.
//

import UIKit
import Cosmos

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
    let title: String
    let overview: String
    let popularity: Double
    let backdrop_path: String?
    let release_date: String
    var vote_average: Double
    var imageURL : URL {
        let baseURL = "http://image.tmdb.org/t/p/"
        let width = "w500"
        return URL(string: baseURL + width + (backdrop_path)!)!
    }
}

struct MovieListResponse: Decodable {
    let results: [Movie]
}

struct MovieDetails {
    let movie: Movie
    let image: UIImage
}


class SearchResultsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var imgCache : NSCache<NSURL, UIImage> = NSCache()
    var searchTerm : String = ""

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
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "SearchResultCell", bundle: nil), forCellWithReuseIdentifier: "searchResultCell")
        
        print(searchTerm + "VC2")

        // Get JSON data and drop it in the movies array
        let TMDB_apiKey: String = "0de424715a984f077e1ad542e6cfb656"
        let url = URL(string: "https://api.themoviedb.org/3/discover/movie?api_key=\(TMDB_apiKey)")
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error == nil {
                do {
                    print("API Request for Movie Data")
                    print(try JSONSerialization.jsonObject(with: data!))
                    let json = try JSONDecoder().decode(MovieListResponse.self, from: data!)
                    
                    // Remove all movies with a nil backdrop path?? Still don't know what the TMDB people were thinking tbh...
                    self.movies = json.results.filter {
                        $0.backdrop_path != nil
                    }
                    
                    // Rescale all vote averages
                    self.movies = self.movies.map { (movie: Movie) -> Movie in
                        var mutableMovie = movie
                        mutableMovie.vote_average = self.rescaleRating(rating: movie.vote_average)
                        return mutableMovie
                    }
                    
                    print(self.movies)
                } catch {
                    print("Err")
                    print(error)
                }
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                }
            }
        }.resume()
    }

    
    /// Rescale scores from a scale of 0 -> 10 to 0 -> 5
    func rescaleRating(rating: Double) -> Double {
        let rescale: Double = round(rating) / 2
        print("RESCALED: \(rescale) from \(rating)")
        return rescale
    }
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(self.movies.count)
        return self.movies.count
    }
    
    // TODO: Animation for cell about to come in.
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) { }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("TAPPED ITEM: \(indexPath.item)")
        
        // Create a new view controller
        let movieJSON = movies[indexPath.item]
        let movieImage = imgCache.object(forKey: movieJSON.imageURL as NSURL)
        let detailViewController = DetailViewController(movieDetail: MovieDetails(movie: movieJSON, image: movieImage!))
        detailViewController.providesPresentationContextTransitionStyle = true
        detailViewController.definesPresentationContext = true
        detailViewController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        detailViewController.showInteractive()
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "searchResultCell", for: indexPath) as! SearchResultCell

        let movie = self.movies[indexPath.item]
        
        // Set movie title and category tag
        cell.categoryTag?.text = String(movie.popularity)
        cell.titleLabel?.text = movie.title
        
        // Set stars in cosmosView with scaled rating
        guard let cosmosView = cell.cosmosView else {
            return SearchResultCell()
        }
        cosmosView.settings.updateOnTouch = false
        cosmosView.settings.fillMode = .half
        cosmosView.rating = movie.vote_average
        
        // Get movie image
        // EXAMPLE URL: http://image.tmdb.org/t/p/w185//nBNZadXqJSdt05SHLqgT0HuC5Gm.jpg
        let movieImage = cell.movieImage
        movieImage?.contentMode = .scaleAspectFill
        movieImage?.layer.cornerRadius = 30
        movieImage?.clipsToBounds = true
        
        // If movie image in cache, use it
        if let poster = imgCache.object(forKey: movie.imageURL as NSURL) {
            movieImage?.image = poster
        } else { // Else, make API request for movie image and update cache
            getDataFromUrl(url: movie.imageURL) { data, response, error in
                guard let data = data, error == nil else { return }
                print("Download Finished: " + (response?.suggestedFilename)!)
                DispatchQueue.main.async() {
                    let fetchedImg = UIImage(data: data)
                    movieImage?.image = fetchedImg
                    self.imgCache.setObject(fetchedImg!, forKey: movie.imageURL as NSURL)
                }
            }
        }
    
        print(movie.title)
        print(movie.popularity)
        return cell
    }
}
