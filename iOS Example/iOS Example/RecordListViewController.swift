//
//  ViewController.swift
//  iOS Example
//
//  Created by Nils Fischer on 26.04.15.
//  Copyright (c) 2015 viWiD Webdesign & iOS Development. All rights reserved.
//

import UIKit
import Evergreen

class RecordListViewController: UITableViewController {
    
    var stenographyHandler: StenographyHandler!

    // MARK: User Interaction
    
    @IBAction func refreshButtonPressed(_ sender: AnyObject) {
        self.tableView.reloadData()
    }
    
    @IBAction func addButtonPressed(_ sender: AnyObject) {
        Evergreen.info(#function)
        self.tableView.reloadData()
    }
    
    // MARK: Table View Datasource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stenographyHandler.records.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let record = stenographyHandler.records.reversed()[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "recordCell", for: indexPath) 
        cell.textLabel?.text = record.description
        return cell
    }
    
}

