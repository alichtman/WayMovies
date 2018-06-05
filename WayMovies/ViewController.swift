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
    let release_date: String
    let vote_average: Double
}

struct MovieListResponse: Decodable {
    let results: [Movie]
}

// TODO: Add image caching -> http://jamesonquave.com/blog/developing-ios-apps-using-swift-part-5-async-image-loading-and-caching/
// TODO: Refactor API requests into well-organized methods
// TODO: Figure out why images aren't populating
// TODO: Figure out constraints for customCell

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var yOffset: CGFloat = 0

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
    
    ///
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let collectionViewController = self.collectionView else { return }
        collectionViewController.preloadPagination(in: collectionView, withCell: cell, forIndexPath: indexPath)
    }
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//
//        let yCurr: CGFloat = self.collectionView.contentOffset.y
//
//        collectionView.transform = CGAffineTransform(translationX: 0, y: yCurr);
//
//        for view in collectionView.subviews {
//
//            if view is UICollectionViewCell {
//
//                let index: Int = 1
//                let delay: Double = Double(index) * 0.02;
//                let duration: Double = 1.0 - delay;
//
//                UIScrollView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: 0.1, initialSpringVelocity: 0.2, options: [UIViewAnimationOptions.curveEaseInOut, UIViewAnimationOptions.allowUserInteraction], animations: {
//                    view.transform =  view.transform.translatedBy(x: 0, y: -1 * (yCurr - self.yOffset))
//                }, completion: nil)
//            }
//        }
//
//        yOffset = yCurr
//    }


    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "customCell", for: indexPath) as!CustomCollectionViewCell

        // Set movie title and release date
        cell.titleLabel?.text = self.movies[indexPath.item].title
        cell.ratingLabel?.text = String(self.movies[indexPath.item].vote_average)
//        let releaseDateUnformatted = String(self.movies[indexPath.item].release_date)
//        // Convert Date to MM/DD/YYYY
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "MM-dd-yyyy"
//        guard let releaseDate = dateFormatter.date(from: releaseDateUnformatted) else {
//            return UICollectionViewCell()
//        }
//        cell.dateLabel?.text = dateFormatter.string(from: releaseDate)

        // Get movie image
        let baseURL = "http://image.tmdb.org/t/p/"
        let width = "w500"
        let posterPath = String(self.movies[indexPath.item].poster_path)
        let downloadURL = URL(string: baseURL + width + posterPath)

        cell.movieImage?.contentMode = .scaleAspectFill

        getDataFromUrl(url: downloadURL!) { data, response, error in
            guard let data = data, error == nil else { return }
            print("Download Finished: " + (response?.suggestedFilename)!)
            DispatchQueue.main.async() {
                cell.movieImage.image = UIImage(data: data)
                cell.movieImage.layer.borderWidth = 4
                cell.movieImage.layer.masksToBounds = false
                cell.movieImage.layer.borderColor = UIColor.white.cgColor
                cell.movieImage.layer.cornerRadius = cell.movieImage.frame.height / 2
                cell.movieImage.clipsToBounds = true
            }
        }

        // EXAMPLE URL: http://image.tmdb.org/t/p/w185//nBNZadXqJSdt05SHLqgT0HuC5Gm.jpg


        print(self.movies[indexPath.item].title)
        print(self.movies[indexPath.item].popularity)
        return cell
    }


}
