//
//  BrowseViewController.swift
//  WayMovies
//
//  Created by Aaron Lichtman on 6/13/18.
//  Copyright © 2018 Aaron Lichtman. All rights reserved.
//

import UIKit
import Cosmos

enum sectionHeaders {
    static let browse: String = " Browse"
    static let discover: String = " Discover"
    static let inTheaters: String = " In Theaters"
    static let popularAllTime: String = " All-Time Popular Movies"
    static let bestThisYear: String = " Best This Year"
}

enum URLs {
    static let discover = URL(string: "https://api.themoviedb.org/3/discover/movie?api_key=\(TMDB_apiKey)")
    static let inTheaters = URL(string: "https://api.themoviedb.org/3/discover/movie?primary_release_date.gte=\(Date().subtractMonth().stringRepresentation())&primary_release_date.lte=\(Date().stringRepresentation())&api_key=\(TMDB_apiKey)")
    static let popularAllTime = URL(string: "https://api.themoviedb.org/3/discover/movie?sort_by=popularity.desc&api_key=\(TMDB_apiKey)")
    static let bestThisYear = URL(string: "https://api.themoviedb.org/3/discover/movie?primary_release_year=\(Date().stringRepresentation().prefix(4))&sort_by=vote_average.desc&api_key=\(TMDB_apiKey)")
}

class BrowseViewController: UIViewController {
    
    var imgCache : NSCache<NSURL, UIImage> = NSCache()
    
    var collectionView0: UICollectionView?
    var collectionView1: UICollectionView?
    var collectionView2: UICollectionView?
    
    var inTheatersItems = [TVShowOrMovieOrPerson]()
    var popularAllTimeItems = [TVShowOrMovieOrPerson]()
    var bestThisYearItems = [TVShowOrMovieOrPerson]()
    
    public init() {
        print("INIT")
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Remove all results without any image path OR without a vote average.
    fileprivate func filterInvalidResponses(_ responseObj: JSONResponse) -> [TVShowOrMovieOrPerson] {
        let items = responseObj.results.filter {
            ($0.backdrop_path != nil || $0.poster_path != nil) // && $0.vote_average != 0
        }
        return items
    }
    
    func getBrowseData() {

        // Coming Soon Data
        URLSession.shared.dataTask(with: URLs.inTheaters!) { [weak self] (data, response, error) in
            if error == nil {
                do {
                    print("API Request for Coming Soon Data")
                    print(try JSONSerialization.jsonObject(with: data!))
                    let responseObj = try JSONDecoder().decode(JSONResponse.self, from: data!)
                    print(responseObj)
                    self?.inTheatersItems = (self?.filterInvalidResponses(responseObj))!

                    // TODO: Rescale all vote averages
                    print(self?.inTheatersItems as Any)
                } catch {
                    print(error)
                }
                DispatchQueue.main.async {
                    self?.collectionView0?.reloadData()
                }
            }
            }.resume()
        
        // Popular All Time
        URLSession.shared.dataTask(with: URLs.popularAllTime!) { [weak self] (data, response, error) in
            if error == nil {
                do {
                    print("API Request for Popular All Time")
                    print(try JSONSerialization.jsonObject(with: data!))
                    let responseObj = try JSONDecoder().decode(JSONResponse.self, from: data!)
                    
                    self?.popularAllTimeItems = (self?.filterInvalidResponses(responseObj))!
                    // TODO: Rescale all vote averages
                    print(self?.popularAllTimeItems as Any)
                } catch {
                    print(error)
                }
                DispatchQueue.main.async {
                    self?.collectionView1?.reloadData()
                }
            }
            }.resume()
        
        // Best This Year
        URLSession.shared.dataTask(with: URLs.bestThisYear!) { [weak self] (data, response, error) in
            if error == nil {
                do {
                    print("API Request for Best This Year")
                    print(try JSONSerialization.jsonObject(with: data!))
                    let responseObj = try JSONDecoder().decode(JSONResponse.self, from: data!)
                    
                    self?.bestThisYearItems = (self?.filterInvalidResponses(responseObj))!
                    // TODO: Rescale all vote averages
                    print(self?.bestThisYearItems as Any)
                } catch {
                    print(error)
                }
                DispatchQueue.main.async {
                    self?.collectionView2?.reloadData()
                }
            }
            }.resume()
    }
    
    func createCollectionView(tag: Int) -> UICollectionView {
        let inset: CGFloat = 8
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 142, height: 195)
        layout.sectionInset = UIEdgeInsetsMake(inset, inset, inset, inset);
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .white
        collectionView.tag = tag
        return collectionView
    }
    
    fileprivate func createLabel(_ text: String, _ font: String, _ fontSize: CGFloat) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textAlignment = .left
        label.textColor = .black
        label.font = UIFont(name: font, size: fontSize)
        label.numberOfLines = 1;
        label.adjustsFontSizeToFitWidth = true;
        return label
    }
    
    override func viewDidLoad() {
        print("VIEWDIDLOAD")
        super.viewDidLoad()
        
        self.navigationItem.title = "Browse";
        
        let myScrollView = UIScrollView()
        myScrollView.translatesAutoresizingMaskIntoConstraints = false
        myScrollView.backgroundColor = .white
        myScrollView.showsVerticalScrollIndicator = false
        self.view.addSubview(myScrollView)
        
        let myStackView = UIStackView()
        myStackView.translatesAutoresizingMaskIntoConstraints = false
        myStackView.axis = .vertical
        myScrollView.addSubview(myStackView)
        
//        let searchBar = UISearchBar()
//        searchBar.autocorrectionType = .yes
//        searchBar.autocapitalizationType = .words
//        searchBar.barStyle = .default
//        searchBar.searchBarStyle = .minimal
//        view.addSubview(searchBar)
        
        self.collectionView0 = createCollectionView(tag: 0)
        self.collectionView1 = createCollectionView(tag: 1)
        self.collectionView2 = createCollectionView(tag: 2)
        
        
        let nib = UINib(nibName: "BrowseCollectionViewCell", bundle: nil)
        collectionView0?.register(nib, forCellWithReuseIdentifier: "BrowseCollectionViewCell")
        collectionView1?.register(nib, forCellWithReuseIdentifier: "BrowseCollectionViewCell")
        collectionView2?.register(nib, forCellWithReuseIdentifier: "BrowseCollectionViewCell")
        
        getBrowseData()
        
        let inTheatersLabel = createLabel(sectionHeaders.inTheaters, "AvenirNext-Bold", 25)
        let popularAllTimeLabel = createLabel(sectionHeaders.popularAllTime, "AvenirNext-Bold", 25)
        let bestThisYearLabel = createLabel(sectionHeaders.bestThisYear, "AvenirNext-Bold", 25)
        
        myStackView.addArrangedSubview(inTheatersLabel)
        myStackView.addArrangedSubview(collectionView0!)
        myStackView.addArrangedSubview(popularAllTimeLabel)
        myStackView.addArrangedSubview(collectionView1!)
        myStackView.addArrangedSubview(bestThisYearLabel)
        myStackView.addArrangedSubview(collectionView2!)
        
        let navBarHeight: CGFloat = (self.navigationController?.navigationBar.frame.height)!
        let heightConstant: CGFloat = 200
        let topPadding: CGFloat = 15
        let titleHeight: CGFloat = 25
        
        NSLayoutConstraint.activate([
            myScrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: navBarHeight),
            myScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            myScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            myScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            myStackView.widthAnchor.constraint(equalToConstant: view.frame.width),
            myStackView.topAnchor.constraint(equalTo: myScrollView.topAnchor, constant: topPadding),
            myStackView.leadingAnchor.constraint(equalTo: myScrollView.leadingAnchor),
            myStackView.trailingAnchor.constraint(equalTo: myScrollView.trailingAnchor),
            myStackView.bottomAnchor.constraint(equalTo: myScrollView.bottomAnchor),
            
            inTheatersLabel.heightAnchor.constraint(equalToConstant: titleHeight),
            popularAllTimeLabel.heightAnchor.constraint(equalToConstant: titleHeight),
            bestThisYearLabel.heightAnchor.constraint(equalToConstant: titleHeight),
            
            (collectionView0?.heightAnchor.constraint(equalToConstant: heightConstant))!,
            (collectionView1?.heightAnchor.constraint(equalToConstant: heightConstant))!,
            (collectionView2?.heightAnchor.constraint(equalToConstant: heightConstant))!
            ])
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
}
    
extension BrowseViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView.tag {
        case 0:
            let count = inTheatersItems.count
            print(count)
            return count
        case 1:
            return popularAllTimeItems.count
        case 2:
            return bestThisYearItems.count
        default:
            print("COLLECTION VIEW TAG -- OUT OF BOUNDS ERROR")
            return 0
        }
    }
    
    fileprivate func configureCollectionViewCell(collectionView: UICollectionView, indexPath: IndexPath, itemForDisplay: TVShowOrMovieOrPerson) -> BrowseCollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BrowseCollectionViewCell", for: indexPath as IndexPath) as! BrowseCollectionViewCell
        
        // Title
        cell.title!.text = itemForDisplay.title
        
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
        
        // Rescale rating and set cosmos view
        guard let cosmosView = cell.stars else {
            return BrowseCollectionViewCell()
        }
        
        cosmosView.settings.updateOnTouch = false
        cosmosView.settings.fillMode = .half
        cosmosView.settings.emptyBorderColor = .clear
        cosmosView.settings.filledColor = .orange
        cosmosView.settings.starSize = 18
        cosmosView.settings.starMargin = 2
        cosmosView.rating = rescaleRating(rating: itemForDisplay.vote_average!)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch collectionView.tag {
        case 0:
            return configureCollectionViewCell(collectionView: collectionView, indexPath: indexPath, itemForDisplay: inTheatersItems[indexPath.row])
        case 1:
            return configureCollectionViewCell(collectionView: collectionView, indexPath: indexPath, itemForDisplay: popularAllTimeItems[indexPath.row])
        case 2:
            return configureCollectionViewCell(collectionView: collectionView, indexPath: indexPath, itemForDisplay: bestThisYearItems[indexPath.row])
        default:
            print("COLLECTION VIEW TAG -- OUT OF BOUNDS ERROR")
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        print("Num: \(collectionView[indexPath.row])")
//        print("Value: \(myArray[indexPath.row])")
    }
    
}

extension Date {
    
    static let formatter = DateFormatter()
    
    /// Returns current date
    func stringRepresentation() -> String {
        Date.formatter.dateFormat = "yyyy-MM-dd"
        let result = Date.formatter.string(from: self)
        return result
    }
    
    /// Returns current date - 1 month
    func subtractMonth() -> Date {
        return Calendar.current.date(byAdding: .month, value: -1, to: self)!
    }
}
