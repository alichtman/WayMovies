//
//  ViewController.swift
//  WayMovies
//
//  Created by Aaron Lichtman on 6/1/18.
//  Copyright © 2018 Aaron Lichtman. All rights reserved.
//

import UIKit
import Cosmos

struct TVShowOrMovieOrPerson: Decodable {
    let media_type: String
    let name: String?
    let title: String?
    let overview: String?
    let popularity: Double
    let backdrop_path: String?
    let poster_path: String?
    let profile_path: String?
    let first_air_date: String?
    let release_date: String?
    var vote_average: Double?
    var imageURL : URL {
        let baseURL = "http://image.tmdb.org/t/p/"
        let width = "w500"
        
        let endPath: String
        // Person image
        if let backdrop = profile_path {
            endPath = backdrop
        }
        // Preferred movie image
        else if let backdrop = backdrop_path {
            endPath = backdrop
        }
        // Fall-back image
        else {
            endPath = poster_path!
        }
        
        return URL(string: baseURL + width + endPath)!
    }
    var known_for: [TVShowOrMovieOrPerson]?
}

struct JSONResponse: Decodable {
    let results: [TVShowOrMovieOrPerson]
}

struct DetailsObject {
    let movie: TVShowOrMovieOrPerson
    let image: UIImage
}

class SearchResultsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var imgCache : NSCache<NSURL, UIImage> = NSCache()
    var searchTerm : String = ""

    @IBOutlet weak var collectionView: UICollectionView!
    var displayedResults = [TVShowOrMovieOrPerson]()

    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }

    fileprivate func getDataFromAPI() {
        let TMDB_apiKey: String = "0de424715a984f077e1ad542e6cfb656"
        // let discoverUrl = URL(string: "https://api.themoviedb.org/3/discover/movie?api_key=\(TMDB_apiKey)")
        //TODO: ASCII MAGIC
        searchTerm = searchTerm.replacingOccurrences(of: " ", with: "%20")
        let searchURL = URL(string: "https://api.themoviedb.org/3/search/multi?api_key=\(TMDB_apiKey)&query=\(searchTerm)")
        URLSession.shared.dataTask(with: searchURL!) { (data, response, error) in
            if error == nil {
                do {
                    print("API Request for Search Data")
                    print(try JSONSerialization.jsonObject(with: data!))
                    let responseObj = try JSONDecoder().decode(JSONResponse.self, from: data!)
                    
                    // Remove all results missing all three of the possible image paths.
                    self.displayedResults = responseObj.results.filter {
                        $0.backdrop_path != nil || $0.poster_path != nil || $0.profile_path != nil
                    }
                    
                    // Rescale all vote averages
                    self.displayedResults = self.displayedResults.map { (result: TVShowOrMovieOrPerson) -> TVShowOrMovieOrPerson in
                        // Checks if vote average exists or not.
                        if result.media_type != "person" {
                            var mutableResult = result
                            mutableResult.vote_average = self.rescaleRating(rating:  result.vote_average!)
                            return mutableResult
                        } else {
                            return result
                        }
                    }
                    print(self.displayedResults)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "SearchResultCell", bundle: nil), forCellWithReuseIdentifier: "searchResultCell")
        
        print(searchTerm + " RECEIVED -> VC2")

        getDataFromAPI()
    }

    
    /// Rescale scores from a scale of 0 -> 10 to 0 -> 5
    func rescaleRating(rating: Double) -> Double {
        let rescale: Double = round(rating) / 2
        print("RESCALED: \(rescale) from \(rating)")
        return rescale
    }
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(self.displayedResults.count)
        return self.displayedResults.count
    }
    
    // TODO: Animation for cell about to come in.
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) { }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("TAPPED ITEM: \(indexPath.item)")
        
        // Create a new view controller
        let movieJSON = displayedResults[indexPath.item]
        let movieImage = imgCache.object(forKey: movieJSON.imageURL as NSURL)
        let detailViewController = DetailViewController(movieDetail: DetailsObject(movie: movieJSON, image: movieImage!))
        detailViewController.providesPresentationContextTransitionStyle = true
        detailViewController.definesPresentationContext = true
        detailViewController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        detailViewController.showInteractive()
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "searchResultCell", for: indexPath) as! SearchResultCell

        let displayItem = self.displayedResults[indexPath.item]
        
        // Set movie title and category tag
        cell.categoryTag?.text = String(displayItem.popularity)
        cell.titleLabel?.text = displayItem.title
        
        // Set stars in cosmosView with scaled rating
        guard let cosmosView = cell.cosmosView else {
            return SearchResultCell()
        }
        
        // Don't show stars for people search results
        if displayItem.media_type != "person" {
            cosmosView.settings.updateOnTouch = false
            cosmosView.settings.fillMode = .half
            cosmosView.rating = displayItem.vote_average!
        } else {
            cosmosView.settings.emptyBorderColor = .clear
            cosmosView.settings.filledColor = .clear
        }
        
        // Get image
        // EXAMPLE URL: http://image.tmdb.org/t/p/w185//nBNZadXqJSdt05SHLqgT0HuC5Gm.jpg
        let displayImage = cell.movieImage
        displayImage?.contentMode = .scaleAspectFill
        displayImage?.layer.cornerRadius = 30
        displayImage?.clipsToBounds = true
        
        // If movie image in cache, use it
        if let poster = imgCache.object(forKey: displayItem.imageURL as NSURL) {
            displayImage?.image = poster
        } else { // Else, make API request for movie image and update cache
            getDataFromUrl(url: displayItem.imageURL) { data, response, error in
                guard let data = data, error == nil else { return }
                print("Download Finished: " + (response?.suggestedFilename)!)
                DispatchQueue.main.async() {
                    let fetchedImg = UIImage(data: data)
                    displayImage?.image = fetchedImg
                    self.imgCache.setObject(fetchedImg!, forKey: displayItem.imageURL as NSURL)
                }
            }
        }
    
        print(displayItem.title as Any)
        print(displayItem.popularity)
        return cell
    }
}
