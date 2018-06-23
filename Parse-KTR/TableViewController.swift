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
    
    override func viewDidLoad() {
        super .viewDidLoad()
    
        self.tableView.estimatedRowHeight = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.contentInsetAdjustmentBehavior = .always
        
        darkMode(userDefaults.bool(forKey: "dark"))
        
        // get and display the user default settings
        outputType.text = "Output: " + userDefaults.string(forKey: "output")!
        codeType.text = "KTR Code: " + userDefaults.string(forKey: "code")!
        darkmode.text = "Dark Mode: " + (userDefaults.bool(forKey: "dark") ? "On" : "Off")
        hideKeyboard.text = "Hide Keyboard on Device Rotation: " + (userDefaults.bool(forKey: "hidekeyboard") ? "On" : "Off")
    }
    
    @IBAction func handleTap(recognizer: UITapGestureRecognizer) {
        
        if recognizer.view is UITextView {
            
            if !((recognizer.view as? UITextView)?.text.isEmpty)! {
             
                let point = self.KTRCodes.closestPosition(to: recognizer.location(in: recognizer.view))
                var startIndex = point
                var endIndex = point
                var text: String!
                
                while true {
                    
                    // if the first character in the text in the range from start index to end index doesn't equal "P"
                    if self.KTRCodes.text(in: self.KTRCodes.textRange(from: startIndex!, to: endIndex!)!)?.first != userDefaults.string(forKey: "code")?.first {
                        
                        // move the start index one character to the left
                        startIndex = self.KTRCodes.position(from: startIndex!, offset: -1)
                        
                        // make sure the start index isn't before the start of the string
                        if startIndex == nil {
                            
                            startIndex = self.KTRCodes.beginningOfDocument
                        }
                    }
                    
                    // if the last character in the text in the range from start index to end index doesn't equal " "
                    if self.KTRCodes.text(in: self.KTRCodes.textRange(from: startIndex!, to: endIndex!)!)?.last != " " {
                        
                        // move the end index one character to the right
                        endIndex = self.KTRCodes.position(from: endIndex!, offset: 1)
                        
                        // make sure the end index isn't after the end of the string
                        if endIndex == nil {
                            
                            endIndex = self.KTRCodes.endOfDocument
                        }
                    }
                    
                    // if the first character is "P" and the last character is " " in the text in the range from
                    // start index to end index, code is found, exit the loop
                    if self.KTRCodes.text(in: self.KTRCodes.textRange(from: startIndex!, to: endIndex!)!)?.first == userDefaults.string(forKey: "code")?.first &&
                        self.KTRCodes.text(in: self.KTRCodes.textRange(from: startIndex!, to: endIndex!)!)?.last == " " {
                            
                        break
                    }
                }
                
                // the code as a string, with PLT and the space removed
                text = String(String((self.KTRCodes.text(in: self.KTRCodes.textRange(from: startIndex!, to: endIndex!)!)?.dropFirst(3))!).dropLast())
                self.KTRCodes.replace(self.KTRCodes.textRange(from: startIndex!, to: endIndex!)!, withText: "")
                
                // put the code in the keyboard
                self.viewController.keyboardViewController.ktr1.text = String(text.removeFirst())
                self.viewController.keyboardViewController.ktr2.text = String(text.removeFirst())
                self.viewController.keyboardViewController.ktr3.text = String(text.removeFirst())
            }
        }
    }
    
    @IBAction func addButton(_ sender: UIButton) {
        
        if !viewController.keyboardShowing {
            
            self.viewController.showKeyboard()
        }
    }
    
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
                    } else if view is UIButton {
                        
                        view.backgroundColor = userDefaults.color(forKey: "buttonDark")
                        (view as? UIButton)?.titleLabel?.textColor = userDefaults.color(forKey: "buttonTextDark")
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
                    } else if view is UIButton {
                        
                        view.backgroundColor = userDefaults.color(forKey: "buttonLight")
                        (view as? UIButton)?.titleLabel?.textColor = userDefaults.color(forKey: "buttonTextLight")
                    }
                }
            }
            
        }
    }
 
    
}
