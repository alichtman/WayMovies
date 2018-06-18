//
//  ViewController.swift
//  WayMovies
//
//  Created by Aaron Lichtman on 6/1/18.
//  Copyright © 2018 Aaron Lichtman. All rights reserved.
//

import UIKit
import Cosmos

let TMDB_apiKey: String = "0de424715a984f077e1ad542e6cfb656"

enum categoryTagText {
    static let movieTag = " MOVIE "
    static let tvTag = " TV SHOW "
    static let personTag = " ACTOR / ACTRESS "
}

enum categoryTagColor {
    static let movieColor = UIColor.green
    static let tvColor = UIColor.blue
    static let personColor = UIColor.red
}

enum objType {
    static let tv: String = "tv"
    static let movie: String = "movie"
    static let person: String = "person"
}

struct TVShowOrMovieOrPerson: Decodable {
    let id: Int
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
    let data: TVShowOrMovieOrPerson
    let image: UIImage
}

class SearchResultsViewController: UIViewController {
    
    var imgCache : NSCache<NSURL, UIImage> = NSCache()
    @IBOutlet weak var resultsSearchBar: UISearchBar!
    var searchTerm : String = ""
    
    @IBOutlet weak var collectionView: UICollectionView!
    var displayedResults = [TVShowOrMovieOrPerson]()
    
    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
    
    // TODO: Refactor this to take in a keyword and search for that category.
    func APISearchRequest() {
        // let discoverUrl = URL(string: "https://api.themoviedb.org/3/discover/movie?api_key=\(TMDB_apiKey)")
        
        // ASCII magic
        searchTerm = searchTerm.replacingOccurrences(of: " ", with: "%20")
        let searchURL = URL(string: "https://api.themoviedb.org/3/search/multi?api_key=\(TMDB_apiKey)&query=\(searchTerm)")
        URLSession.shared.dataTask(with: searchURL!) { (data, response, error) in
            if error == nil {
                do {
                    print("API Request for Search Data")
                    print(try JSONSerialization.jsonObject(with: data!))
                    let responseObj = try JSONDecoder().decode(JSONResponse.self, from: data!)
                    
                    // Remove all results without any image path AND without a vote average.
                    self.displayedResults = responseObj.results.filter {
                        ($0.backdrop_path != nil || $0.poster_path != nil || $0.profile_path != nil) && $0.vote_average != 0
                    }
                    
                    // Rescale all vote averages for non-people objects
                    self.displayedResults = self.displayedResults.map { (result: TVShowOrMovieOrPerson) -> TVShowOrMovieOrPerson in
                        if result.media_type != objType.person {
                            var mutableResult = result
                            mutableResult.vote_average = self.rescaleRating(rating:  result.vote_average!)
                            return mutableResult
                        } else {
                            return result
                        }
                    }
                    print(self.displayedResults)
                } catch {
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
        resultsSearchBar.delegate = self
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "SearchResultCell", bundle: nil), forCellWithReuseIdentifier: "searchResultCell")
        
        print(searchTerm + " RECEIVED -> VC2")
        APISearchRequest()
    }
    
    
    /// Rescale scores from a scale of 0 -> 10 to 0 -> 5
    func rescaleRating(rating: Double) -> Double {
        let rescale: Double = round(rating) / 2
        print("RESCALED: \(rescale) from \(rating)")
        return rescale
    }
}


extension SearchResultsViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Just return if there's no content in the text
        guard searchBar.text != "" else { return }
        searchTerm = searchText
        APISearchRequest()
    }
}


extension SearchResultsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(self.displayedResults.count)
        return self.displayedResults.count
    }
    
    // TODO: Animation for cell about to pop in.
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) { }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("TAPPED ITEM: \(indexPath.item)")
        
        // Create a new view controller
        let movieJSON = displayedResults[indexPath.item]
        let movieImage = imgCache.object(forKey: movieJSON.imageURL as NSURL)
        let detailViewController = DetailViewController(movieDetail: DetailsObject(data: movieJSON, image: movieImage!))
        detailViewController.providesPresentationContextTransitionStyle = true
        detailViewController.definesPresentationContext = true
        detailViewController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        detailViewController.showInteractive()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "searchResultCell", for: indexPath) as! SearchResultCell
        
        let itemForDisplay = self.displayedResults[indexPath.item]
        
        // Get image
        let displayImage = cell.movieImage
        displayImage?.contentMode = .scaleAspectFill
        displayImage?.layer.cornerRadius = 30
        displayImage?.clipsToBounds = true
        
        // If movie image in cache, use it
        if let poster = imgCache.object(forKey: itemForDisplay.imageURL as NSURL) {
            displayImage?.image = poster
        } else { // Else, make API request for movie image and update cache
            
            getDataFromUrl(url: itemForDisplay.imageURL) { data, response, error in
                guard let data = data, error == nil else { return }
                print("Download Finished: " + (response?.suggestedFilename)!)
                DispatchQueue.main.async() {
                    let fetchedImg = UIImage(data: data)
                    displayImage?.image = fetchedImg
                    self.imgCache.setObject(fetchedImg!, forKey: itemForDisplay.imageURL as NSURL)
                }
            }
        }
        
        guard let cosmosView = cell.cosmosView else {
            return SearchResultCell()
        }
        
        cosmosView.settings.updateOnTouch = false
        cosmosView.settings.fillMode = .half
        cosmosView.settings.emptyBorderColor = .clear
        cosmosView.settings.filledBorderColor = .gray
        cosmosView.settings.filledBorderWidth = 0.5
        cosmosView.settings.filledColor = .orange
        cosmosView.settings.starSize = 30
        
        cell.titleLabel.numberOfLines = 1;
        cell.titleLabel.adjustsFontSizeToFitWidth = true;
        
        switch itemForDisplay.media_type {
        case objType.movie:
            cell.categoryTag?.text = categoryTagText.movieTag
            cell.categoryTag?.backgroundColor = categoryTagColor.movieColor
            cell.titleLabel?.text = itemForDisplay.title
            cosmosView.rating = itemForDisplay.vote_average!
        case objType.tv:
            cell.categoryTag?.text = categoryTagText.tvTag
            cell.categoryTag?.backgroundColor = categoryTagColor.tvColor
            cell.titleLabel?.text = itemForDisplay.name
            cosmosView.rating = itemForDisplay.vote_average!
        case objType.person:
            // TODO: Detection of "she"/"her" in the overview with probabilistic decision for "Actor/Actress" tag
            cell.categoryTag?.text = categoryTagText.personTag
            cell.categoryTag?.backgroundColor = categoryTagColor.personColor
            cell.titleLabel?.text = itemForDisplay.name
            print(itemForDisplay.imageURL)
            
            // Don't show stars for people search results
            cosmosView.settings.starSize = 0
        default:
            print("Impossible error - if you're seeing this, that's an issue.")
        }
        
        return cell
    }
}
