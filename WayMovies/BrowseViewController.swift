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
    static let discover: String = " Discover"
    static let inTheaters: String = " In Theaters"
    static let popularAllTime: String = " All-time Popular Movies"
    static let bestThisYear: String = " Best This Year!"
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
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 139, height: 145)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .white
        collectionView.tag = tag
        return collectionView
    }
    
    fileprivate func createLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textAlignment = .left
        label.textColor = .white
        label.font = UIFont(name: "AvenirNext-Bold", size: 24)
        return label
    }
    
    override func viewDidLoad() {
        print("VIEWDIDLOAD")
        super.viewDidLoad()
        
//        let myScrollView = UIScrollView()
//        myScrollView.translatesAutoresizingMaskIntoConstraints = false
//        self.view.addSubview(myScrollView)
        
        let myStackView = UIStackView()
        myStackView.translatesAutoresizingMaskIntoConstraints = false
        myStackView.axis = .vertical
        myStackView.distribution = .fill
        myStackView.spacing = 2.0
        view.addSubview(myStackView)
        
        
        self.collectionView0 = createCollectionView(tag: 0)
        self.collectionView1 = createCollectionView(tag: 1)
        self.collectionView2 = createCollectionView(tag: 2)
        
        
        let nib = UINib(nibName: "BrowseCollectionViewCell", bundle: nil)
        collectionView0?.register(nib, forCellWithReuseIdentifier: "BrowseCollectionViewCell")
        collectionView1?.register(nib, forCellWithReuseIdentifier: "BrowseCollectionViewCell")
        collectionView2?.register(nib, forCellWithReuseIdentifier: "BrowseCollectionViewCell")
        
        getBrowseData()
        
        let inTheatersLabel = createLabel(sectionHeaders.inTheaters)
        let popularAllTimeLabel = createLabel(sectionHeaders.popularAllTime)
        let bestThisYearLabel = createLabel(sectionHeaders.bestThisYear)
        
        myStackView.addArrangedSubview(inTheatersLabel)
        myStackView.addArrangedSubview(collectionView0!)
        
        myStackView.addArrangedSubview(popularAllTimeLabel)
        myStackView.addArrangedSubview(collectionView1!)
        
        myStackView.addArrangedSubview(bestThisYearLabel)
        myStackView.addArrangedSubview(collectionView2!)
        
        let heightConstant: CGFloat = 172
        
        NSLayoutConstraint.activate([
//            myScrollView.topAnchor.constraint(equalTo: self.view.topAnchor),
//            myScrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
//            myScrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
//            myScrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            myStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            myStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            myStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            myStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
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
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch collectionView.tag {
        case 0:
            print("SET TITLE \(String(describing: inTheatersItems[indexPath.row].title))")
            return configureCollectionViewCell(collectionView: collectionView, indexPath: indexPath, itemForDisplay: inTheatersItems[indexPath.row])
        case 1:
            print("SET TITLE \(String(describing: popularAllTimeItems[indexPath.row].title))")
            return configureCollectionViewCell(collectionView: collectionView, indexPath: indexPath, itemForDisplay: popularAllTimeItems[indexPath.row])
        case 2:
            print("SET TITLE \(String(describing: bestThisYearItems[indexPath.row]))")
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
    
    func subtractMonth() -> Date {
        return Calendar.current.date(byAdding: .month, value: -1, to: self)!
    }
}
