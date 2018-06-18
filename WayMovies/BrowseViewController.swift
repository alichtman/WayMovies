//
//  BrowseViewController.swift
//  WayMovies
//
//  Created by Aaron Lichtman on 6/13/18.
//  Copyright © 2018 Aaron Lichtman. All rights reserved.
//

import UIKit

class BrowseViewController: UIViewController {
    
    private let myArray: NSArray = ["First","Second","Third"]
    private var myTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let barHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        
        myTableView = UITableView(frame: CGRect(x: 0, y: barHeight, width: displayWidth, height: displayHeight - barHeight))
        myTableView.dataSource = self
        myTableView.delegate = self
        let nib = UINib(nibName: "BrowseTableViewCell", bundle: nil)
        myTableView.register(nib, forCellReuseIdentifier: "BrowseTableViewCell")
        self.view.addSubview(myTableView)
    }
}
    
extension BrowseViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Num: \(indexPath.row)")
        print("Value: \(myArray[indexPath.row])")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BrowseTableViewCell", for: indexPath as IndexPath) as! BrowseTableViewCell
        cell.textLabel!.text = "\(myArray[indexPath.row])"
        return cell
    }
}
