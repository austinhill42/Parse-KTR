//
//  CollectionViewCell.swift
//  Parse-KTR
//
//  Created by Austin Hill on 6/14/18.
//  Copyright © 2018 Austin Hill. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController, UITextViewDelegate {

    @IBOutlet weak var name: UITextView!
    @IBOutlet weak var ftn: UITextView!
    @IBOutlet weak var testType: UITextView!
    @IBOutlet weak var KTRCodes: UITextView!
    
    var textViews: Dictionary<String, UITextView?>!
    
    override func viewDidLoad() {
        super .viewDidLoad()
    
        self.tableView.estimatedRowHeight = 0
        
    }
    
    // when enter is pressed, ignore it and go to the next text view
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n" {
            textView.resignFirstResponder()
            
            switch textView {
            
            case name:
                ftn.becomeFirstResponder()
                break
            case ftn:
                testType.becomeFirstResponder()
                break
            case testType:
                KTRCodes.becomeFirstResponder()
                break
            default:
                break
            }
            
            return false
        }
        
        return true
    }
 
    
}
