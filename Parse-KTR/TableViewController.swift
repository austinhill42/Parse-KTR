//
//  CollectionViewCell.swift
//  Parse-KTR
//
//  Created by Austin Hill on 6/14/18.
//  Copyright © 2018 Austin Hill. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {

    override func viewDidLoad() {
        super .viewDidLoad()
    
        self.tableView.estimatedRowHeight = 0
        
        self.preferredContentSize.height = 560

    }
 
}
