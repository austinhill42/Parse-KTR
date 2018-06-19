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
        
        var frame = self.tableView.frame
        
        if self.view.frame.height > self.view.frame.width {
            
            frame.size.height = 560
            
        } else {
            
            frame.size.height = 450
        }
        
        self.tableView.frame = frame
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super .viewWillTransition(to: size, with: coordinator)
        
        var frame = self.tableView.frame
        
        if self.view.frame.height > self.view.frame.width {
            
            frame.size.height = 560
            
        } else {
            
            frame.size.height = 450
        }
        
        self.tableView.frame = frame
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if self.tableView.frame.height > self.tableView.frame.width {
            
            return 100
        } else {
            
            return 75
        }
    }
}
