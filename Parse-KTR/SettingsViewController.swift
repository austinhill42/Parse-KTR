//
//  SettingsViewController.swift
//  Parse-KTR
//
//  Created by Austin Hill on 6/19/18.
//  Copyright © 2018 Austin Hill. All rights reserved.
//

import UIKit
import Foundation

class SettingsViewController: UIViewController {
 
    private var userDefaults = UserDefaults.standard
    private var tableViewController: SettingsTableViewController!
    private var tableView: UITableView!
    private var viewController: ViewController!
    
    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // add nice looking rounded corners to the container view
        self.containerView.layer.cornerRadius = 6.0
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // initialize the table view controller and table view when they load
        if let vc = segue.destination as? SettingsTableViewController, segue.identifier == "segue" {
            
            self.tableViewController = vc
            self.tableView = tableViewController.tableView
        }
        
        if let vc = segue.source as? ViewController, segue.identifier == "settings" {
            
            self.viewController = vc
        }
    }

}
