//
//  IntroViewController.swift
//  WayMovies
//
//  Created by Aaron Lichtman on 6/6/18.
//  Copyright © 2018 Aaron Lichtman. All rights reserved.
//

import UIKit

class IntroViewController: UIViewController {
    
    var gradientLayer: CAGradientLayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        createGradientLayer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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
    
    @IBAction func goToBrowse(_ sender: UIButton) {
        
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
