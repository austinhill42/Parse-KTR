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
 
    var userDefaults = UserDefaults.standard
    var tableViewController: SettingsTableViewController!
    var tableView: UITableView!
    var viewController: ViewController!
    
    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // add nice looking rounded corners to the container view
        self.containerView.layer.cornerRadius = 6.0
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        darkMode(userDefaults.bool(forKey: "dark"))
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
            self.tableViewController.settingsViewController = self
        }
    }
    
    func darkMode(_ value: Bool) {
        
        if value {
            
            self.view.backgroundColor = userDefaults.color(forKey: "viewDark")
            self.navigationController?.navigationBar.barTintColor = userDefaults.color(forKey: "navigationBarDark")
        } else {
            
            self.view.backgroundColor = userDefaults.color(forKey: "viewLight")
            self.navigationController?.navigationBar.barTintColor = userDefaults.color(forKey: "navigationBarLight")
        }
    }
}
