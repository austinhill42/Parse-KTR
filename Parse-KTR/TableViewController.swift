//
//  CollectionViewCell.swift
//  Parse-KTR
//
//  Created by Austin Hill on 6/14/18.
//  Copyright © 2018 Austin Hill. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController, UITextViewDelegate {

    private var userDefaults = UserDefaults.standard
    
    @IBOutlet weak var name: UITextView!
    @IBOutlet weak var ftn: UITextView!
    @IBOutlet weak var testType: UITextView!
    @IBOutlet weak var KTRCodes: UITextView!
    @IBOutlet weak var outputType: UILabel!
    @IBOutlet weak var codeType: UILabel!
    
    var textViews: Dictionary<String, UITextView?>!
    
    override func viewDidLoad() {
        super .viewDidLoad()
    
        self.tableView.estimatedRowHeight = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // set the defaults if they don't exist yet
        if userDefaults.string(forKey: "output") == nil {
            userDefaults.set("Evaluator", forKey: "output")
            print("\n\n** HERE **\n\n")
        }
        
        if userDefaults.string(forKey: "code") == nil {
            userDefaults.set("PLT", forKey: "code")
        }
        
        // get and display the user default settings
        outputType.text = "Output: " + userDefaults.string(forKey: "output")!
        codeType.text = "KTR Code: " + userDefaults.string(forKey: "code")!
        
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
