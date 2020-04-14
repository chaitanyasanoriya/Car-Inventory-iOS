//
//  CardViewController.swift
//  iOSFinalProjectDev2
//
//  Created by Chaitanya Sanoriya on 26/03/20.
//  Copyright © 2020 Chaitanya Sanoriya. All rights reserved.
//

import UIKit

class CardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //Member Variables (Always starting with small m to denote member variables of a class)
    private var mCellIdentifier = "data_cell"
    private var mTitles: [String] = ["Name","Model","Year","Price","Color","Vin"]
    var mDetails: [String]?
    
    //Outlet of the UI Elements
    @IBOutlet weak var mWholeView: UIView!
    @IBOutlet weak var mTableView: UITableView!
    @IBOutlet weak var mHandleAreaView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    //Function with the UITableViewDataSource, returns the number of cells
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mTitles.count
    }
    
    //Function with the UITableViewDataSource, returns the cell at a particular indexPath
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Getting the reusable cell
        var cell = tableView.dequeueReusableCell(withIdentifier: self.mCellIdentifier)
        
        //If condition to check cell
        if cell == nil
        {
            //Creating a new cell with sub-title style cell
            cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: self.mCellIdentifier)
        }
        
        //Setting title and and subtitle
        cell?.textLabel?.text = self.mTitles[indexPath.row]
        cell?.detailTextLabel?.text = self.mDetails?[indexPath.row]
        
        //Returning cell
        return cell!
    }

    //Function with UITableViewDelegate, returns if cell at a particular index path is highlightatble
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
}
