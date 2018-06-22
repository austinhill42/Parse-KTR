//
//  CollectionViewCell.swift
//  Parse-KTR
//
//  Created by Austin Hill on 6/14/18.
//  Copyright © 2018 Austin Hill. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController, UITextViewDelegate, UIGestureRecognizerDelegate {

    var userDefaults = UserDefaults.standard
    var viewController: ViewController!
    var tableViewCell: TableViewCell!
    
    @IBOutlet weak var name: UITextView!
    @IBOutlet weak var ftn: UITextView!
    @IBOutlet weak var testType: UITextView!
    @IBOutlet weak var KTRCodes: UITextView!
    @IBOutlet weak var outputType: UILabel!
    @IBOutlet weak var codeType: UILabel!
    @IBOutlet weak var darkmode: UILabel!
    @IBOutlet weak var hideKeyboard: UILabel!
    
    var textViews: Dictionary<String, UITextView?>!
    var visibleRows = [IndexPath]()
    
    override func viewDidLoad() {
        super .viewDidLoad()
    
        self.tableView.estimatedRowHeight = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.contentInsetAdjustmentBehavior = .always
        
        darkMode(userDefaults.bool(forKey: "dark"))
        
        // set the defaults if they don't exist yet
        if userDefaults.string(forKey: "output") == nil {
            userDefaults.set("Evaluator", forKey: "output")
        }
        
        if userDefaults.string(forKey: "code") == nil {
            userDefaults.set("PLT", forKey: "code")
        }
        
        // get and display the user default settings
        outputType.text = "Output: " + userDefaults.string(forKey: "output")!
        codeType.text = "KTR Code: " + userDefaults.string(forKey: "code")!
        darkmode.text = "Dark Mode: " + (userDefaults.bool(forKey: "dark") ? "On" : "Off")
        hideKeyboard.text = "Hide Keyboard on Device Rotation: " + (userDefaults.bool(forKey: "hidekeyboard") ? "On" : "Off")
    }
    
    @IBAction func handleTap(recognizer: UITapGestureRecognizer) {
        print("\n** tap works **\n")
        
        if !viewController.keyboardShowing {
            
            self.viewController.showKeyboard()
        }
    }
    
    
//    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
//        coordinator.animate(
//            alongsideTransition: {
//                context in
//
//                // Save the visible row position
//                self.visibleRows = self.tableView.indexPathsForVisibleRows!
//
//                context.viewController(forKey: UITransitionContextViewControllerKey.from)},
//
//            completion: { context in
//
//                // Scroll to the saved position prior to screen rotate
//                self.tableView.scrollToRow(at: self.visibleRows[0], at: .top, animated: false)
//        })
//    }
//
//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        super.viewWillTransition(to: size, with: coordinator)
//
//        //self.view.layoutIfNeeded()
//        self.tableView.selectRow(at: IndexPath(item: 0, section: 0), animated: true, scrollPosition: UITableViewScrollPosition.top)
//        self.tableView.layoutIfNeeded()
//    }
//    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        // hide the keyboard if it isn't the one being touched
        if touches.first?.view != self.viewController.keyboardViewController.view && viewController.keyboardShowing {
            
            self.viewController.hideKeyboard()
        }
        
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        if textView.restorationIdentifier == "keyboard" {
            return false
        }
    
        return true
    }
//
//    func textViewDidBeginEditing(_ textView: UITextView) {
//
//        if textView.restorationIdentifier == "keyboard" {
//
//            textView.endEditing(true)
//
//            if !viewController.keyboardShowing {
//
//                self.viewController.showKeyboard()
//            }
//        }
//    }
    
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
    
    func darkMode(_ value: Bool) {
        
        if value {
            
            tableView.separatorColor = userDefaults.color(forKey: "tableViewCellSeperatorDark")
            
            for cell in self.tableView.visibleCells {
                
                cell.backgroundColor = userDefaults.color(forKey: "tableCellDark")
                
                for view in cell.contentView.subviews {
                    
                    if view is UILabel {
                        
                        view.backgroundColor = userDefaults.color(forKey: "labelDark")
                        (view as? UILabel)?.textColor = userDefaults.color(forKey: "labelTextDark")
                    } else if view is UITextView {
                        
                        view.backgroundColor = userDefaults.color(forKey: "textViewDark")
                        (view as? UITextView)?.textColor = userDefaults.color(forKey: "textViewTextDark")
                    } else if view is UIPickerView {
                        
                        view.backgroundColor = userDefaults.color(forKey: "pickerDark")
                    }
                }
            }
            
        } else {
            
            tableView.separatorColor = userDefaults.color(forKey: "tableViewCellSeperatorLight")

            for cell in self.tableView.visibleCells {
                
                cell.backgroundColor = userDefaults.color(forKey: "tableCellLight")
                
                for view in cell.contentView.subviews {
                    
                    if view is UILabel {
                        
                        view.backgroundColor = userDefaults.color(forKey: "labelLight")
                        (view as? UILabel)?.textColor = userDefaults.color(forKey: "labelTextlight")
                    } else if view is UITextView {
                        
                        view.backgroundColor = userDefaults.color(forKey: "textViewLight")
                        (view as? UITextView)?.textColor = userDefaults.color(forKey: "textViewTextLight")
                    } else if view is UIPickerView {
                        
                        view.backgroundColor = userDefaults.color(forKey: "pickerLight")
                    }
                }
            }
            
        }
    }
 
    
}
