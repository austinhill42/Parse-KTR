//
//  PLTInputViewController.swift
//  Parse-KTR
//
//  Created by Austin Hill on 6/10/18.
//  Copyright © 2018 Austin Hill. All rights reserved.
//

import UIKit

class PLTInputViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // when done, reload the initial view controller
    @IBAction func click(_ sender: Any) {
        
        // get the main storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // get the initial view controller
        let controller = storyboard.instantiateInitialViewController()
        
        // load the initial view controller
        self.present(controller!, animated: true, completion: nil)
    }
    
    
}
