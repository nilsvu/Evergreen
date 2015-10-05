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
    
    @IBAction func refreshButtonPressed(sender: AnyObject) {
        self.tableView.reloadData()
    }
    
    @IBAction func addButtonPressed(sender: AnyObject) {
        log(__FUNCTION__, forLevel: .Info)
        self.tableView.reloadData()
    }
    
    // MARK: Table View Datasource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stenographyHandler.records.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let record = stenographyHandler.records.reverse()[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("recordCell", forIndexPath: indexPath) 
        cell.textLabel?.text = record.description
        return cell
    }
    
}

