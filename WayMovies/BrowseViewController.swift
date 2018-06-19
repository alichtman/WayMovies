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
    static let popularMovies: String = " All-time Popular Movies"
    static let bestThisYear: String = " Best This Year!"
}

enum URLs {
    static let discover = URL(string: "https://api.themoviedb.org/3/discover/movie?api_key=\(TMDB_apiKey)")
    static let inTheaters = URL(string: "https://api.themoviedb.org/3/discover/movie?primary_release_date.gte=\(Date().subtractMonth().stringRepresentation())&primary_release_date.lte=\(Date().stringRepresentation())&api_key=\(TMDB_apiKey)")
    static let popularAllTime = URL(string: "https://api.themoviedb.org/3/discover/movie?sort_by=popularity.desc&api_key=\(TMDB_apiKey)")
    static let bestThisYear = URL(string: "https://api.themoviedb.org/3/discover/movie?primary_release_year=\(Date().stringRepresentation().prefix(4))&sort_by=vote_average.desc&api_key=\(TMDB_apiKey)")
}

class BrowseViewController: UIViewController {
    
    var inTheatersItems = [TVShowOrMovieOrPerson]()
    var popularAllTimeItems = [TVShowOrMovieOrPerson]()
    var bestThisYearItems = [TVShowOrMovieOrPerson]()
    
    let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    
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
        URLSession.shared.dataTask(with: URLs.inTheaters!) { (data, response, error) in
            if error == nil {
                do {
                    print("API Request for Coming Soon Data")
                    print(try JSONSerialization.jsonObject(with: data!))
                    let responseObj = try JSONDecoder().decode(JSONResponse.self, from: data!)
                    print(responseObj)
                    self.inTheatersItems = self.filterInvalidResponses(responseObj)

                    // TODO: Rescale all vote averages
                    print(self.inTheatersItems)
                } catch {
                    print(error)
                }
                DispatchQueue.main.async {
                    // self.collectionView?.reloadData()
                }
            }
            }.resume()
        
        // Popular All Time
        URLSession.shared.dataTask(with: URLs.popularAllTime!) { (data, response, error) in
            if error == nil {
                do {
                    print("API Request for Popular All Time")
                    print(try JSONSerialization.jsonObject(with: data!))
                    let responseObj = try JSONDecoder().decode(JSONResponse.self, from: data!)
                    
                    self.popularAllTimeItems = self.filterInvalidResponses(responseObj)
                    // TODO: Rescale all vote averages
                    print(self.popularAllTimeItems)
                } catch {
                    print(error)
                }
                DispatchQueue.main.async {
                    // self.collectionView?.reloadData()
                }
            }
            }.resume()
        
        // Best This Year
        URLSession.shared.dataTask(with: URLs.bestThisYear!) { (data, response, error) in
            if error == nil {
                do {
                    print("API Request for Best This Year")
                    print(try JSONSerialization.jsonObject(with: data!))
                    let responseObj = try JSONDecoder().decode(JSONResponse.self, from: data!)
                    
                   self.bestThisYearItems = self.filterInvalidResponses(responseObj)
                    // TODO: Rescale all vote averages
                    print(self.bestThisYearItems)
                } catch {
                    print(error)
                }
                DispatchQueue.main.async {
                    // self.collectionView?.reloadData()
                }
            }
            }.resume()
    }
    
    override func viewDidLoad() {
        print("VIEWDIDLOAD")
        super.viewDidLoad()
        
        getBrowseData()
        
//        let myScrollView = UIScrollView()
//        myScrollView.translatesAutoresizingMaskIntoConstraints = false
//        self.view.addSubview(myScrollView)
        
        let myStackView = UIStackView()
        myStackView.translatesAutoresizingMaskIntoConstraints = false
        myStackView.axis = .vertical
        myStackView.distribution = .equalSpacing
        myStackView.spacing = 5.0
        view.addSubview(myStackView)
        
        layout.scrollDirection = UICollectionViewScrollDirection.vertical
        
        let collectionView0 = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView0.translatesAutoresizingMaskIntoConstraints = false
        collectionView0.dataSource = self
        collectionView0.delegate = self
        collectionView0.backgroundColor = .red
        collectionView0.tag = 0
        
        let collectionView1 = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView1.translatesAutoresizingMaskIntoConstraints = false
        collectionView1.dataSource = self
        collectionView1.delegate = self
        collectionView1.backgroundColor = .white
        collectionView1.tag = 1
        
        let collectionView2 = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView2.translatesAutoresizingMaskIntoConstraints = false
        collectionView2.dataSource = self
        collectionView2.delegate = self
        collectionView2.backgroundColor = .blue
        collectionView2.tag = 2
        
        let collectionView3 = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView3.translatesAutoresizingMaskIntoConstraints = false
        collectionView3.dataSource = self
        collectionView3.delegate = self
        collectionView3.backgroundColor = .green
        
        let nib = UINib(nibName: "BrowseCollectionViewCell", bundle: nil)
        collectionView0.register(nib, forCellWithReuseIdentifier: "BrowseCollectionViewCell")
        collectionView1.register(nib, forCellWithReuseIdentifier: "BrowseCollectionViewCell")
        collectionView2.register(nib, forCellWithReuseIdentifier: "BrowseCollectionViewCell")
        collectionView3.register(nib, forCellWithReuseIdentifier: "BrowseCollectionViewCell")
        
        let inTheatresLabel = UILabel()
        inTheatresLabel.text = sectionHeaders.inTheaters
        inTheatresLabel.textAlignment = .left
        inTheatresLabel.textColor = .white
        
        let popularAllTimeLabel = UILabel()
        popularAllTimeLabel.text = sectionHeaders.popularMovies
        popularAllTimeLabel.textAlignment = .left
        popularAllTimeLabel.textColor = .white
        
        let bestDramaLabel = UILabel()
        bestDramaLabel.text = sectionHeaders.bestThisYear
        bestDramaLabel.textAlignment = .left
        bestDramaLabel.textColor = .white
        
        myStackView.addArrangedSubview(inTheatresLabel)
        myStackView.addArrangedSubview(collectionView0)
        
        myStackView.addArrangedSubview(popularAllTimeLabel)
        myStackView.addArrangedSubview(collectionView1)
        
        myStackView.addArrangedSubview(bestDramaLabel)
        myStackView.addArrangedSubview(collectionView2)
        
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
            
            collectionView0.heightAnchor.constraint(equalToConstant: heightConstant),
            collectionView1.heightAnchor.constraint(equalToConstant: heightConstant),
            collectionView2.heightAnchor.constraint(equalToConstant: heightConstant),
            collectionView3.heightAnchor.constraint(equalToConstant: heightConstant)
            ])
    }
}
    
extension BrowseViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView.tag {
        case 0:
            return inTheatersItems.count
        case 1:
            return popularAllTimeItems.count
        case 2:
            return bestThisYearItems.count
        default:
            print("COLLECTION VIEW TAG -- OUT OF BOUNDS ERROR")
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BrowseCollectionViewCell", for: indexPath as IndexPath) as! BrowseCollectionViewCell
        
        switch collectionView.tag {
        case 0:
            print("SET TITLE \(inTheatersItems[indexPath.row])")
            cell.title!.text = inTheatersItems[indexPath.row].title
        case 1:
            print("SET TITLE \(popularAllTimeItems[indexPath.row])")
            cell.title!.text = popularAllTimeItems[indexPath.row].title
        case 2:
            print("SET TITLE \(bestThisYearItems[indexPath.row])")
            cell.title!.text = bestThisYearItems[indexPath.row].title
        default:
            print("COLLECTION VIEW TAG -- OUT OF BOUNDS ERROR")
        }
        
        return cell
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
