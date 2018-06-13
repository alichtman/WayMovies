//
//  IntroViewController.swift
//  WayMovies
//
//  Created by Aaron Lichtman on 6/6/18.
//  Copyright © 2018 Aaron Lichtman. All rights reserved.
//

import UIKit

class IntroViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    var gradientLayer: CAGradientLayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        createGradientLayer()
    }

    /// Create gradient for homescreen and push it to the back
    func createGradientLayer() {
        let gradientView = UIView()
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        let lightGreen = UIColor(red: 102.0/255, green: 220.0/255, blue: 157.0/255, alpha: 1.0)
        let darkGreen = UIColor(red: 95.0/255, green: 206.0/255, blue: 128.0/255, alpha: 1.0)
        gradientLayer.colors = [lightGreen.cgColor, darkGreen.cgColor]
        gradientView.layer.addSublayer(gradientLayer)
        self.view.addSubview(gradientView)
        self.view.sendSubview(toBack: gradientView)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        // Return if there's no content in the text
        guard searchBar.text != "" else { return }
        print(searchBar.text! + "VC1")
        self.performSegue(withIdentifier: "search", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            let searchVC: SearchResultsViewController = segue.destination as! SearchResultsViewController
            searchVC.searchTerm = searchBar.text!
    }
    
    // "I just want to browse" button clicked.
    @IBAction func goToBrowse(_ sender: UIButton) {
        
    }
}
