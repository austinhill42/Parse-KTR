//
//  KeyboardViewController.swift
//  Parse-KTR
//
//  Created by Austin Hill on 6/21/18.
//  Copyright © 2018 Austin Hill. All rights reserved.
//

import UIKit

class KeyboardViewController: UIViewController {

    private var userDefaults = UserDefaults.standard
    
    var viewController: ViewController!
    var tap: UITapGestureRecognizer!
    var codes = [String]()
    
    @IBOutlet weak var ktr1: UITextField!
    @IBOutlet weak var ktr2: UITextField!
    @IBOutlet weak var ktr3: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        darkmode(userDefaults.bool(forKey: "dark"))
        
    }
    
    // do stuff when the KTR keyboard keypad buttons are pressed
    @IBAction func btn_keypad(_ sender: UIButton) {
        
        // determine where the keypad text should go
        if (ktr1.text?.isEmpty)! {
            
            ktr1.text = sender.currentTitle
            
        } else if (ktr2.text?.isEmpty)! {
            
            ktr2.text = sender.currentTitle
            
        } else {
            
            ktr3.text = sender.currentTitle
            
            // delay for a sixteenth of a second for the text to appear in the text field
            // this code only for aesthetic purposes
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.0625) {
                
                // if all three numbers have been entered, enter the PLT code automatically
                self.btn_enter(sender)
            }
            
        }
    }
    
    // clear the currently entered code
    @IBAction func btn_clear(_ sender: UIButton) {
        
        ktr1.text = ""
        ktr2.text = ""
        ktr3.text = ""
    }
    
    // delete the last number entered
    @IBAction func btn_delete(_ sender: UIButton) {
        
        // determine which text field had the last number entered and delete it
        if !(ktr3.text?.isEmpty)! {
            ktr3.text = ""
        } else if !(ktr2.text?.isEmpty)! {
            ktr2.text = ""
        } else if !(ktr1.text?.isEmpty)! {
            ktr1.text = ""
        }
    }
    
    // add the PLT code entered by the user to the list of PLT codes
    @IBAction func btn_enter(_ sender: UIButton) {
        
        // at least one number has been entered
        if !(ktr1.text?.isEmpty)! {
            
            var code = ""
            
            // set the index path to the last item in the PLT codes array
           // let indexPath = IndexPath(item: PLTCodes.count, section: 0)
            
            // if only one number has been entered
            if (ktr2.text?.isEmpty)! {
                
                // set the KTR code in the correct format
                code = userDefaults.string(forKey: "code")! + "00" + ktr1.text! + " "
                
                // if two numbers have been entered
            } else if (ktr3.text?.isEmpty)! {
                
                // set the KTR code in the correct format
                code = userDefaults.string(forKey: "code")! + "0" + ktr1.text! + ktr2.text! + " "
                
                // if three numbers have been entered
            } else {
                
                // set the KTR code in the correct format
                code = userDefaults.string(forKey: "code")! + ktr1.text! + ktr2.text! + ktr3.text! + " "
            }
            
            var maxCode: Int
            
            switch userDefaults.string(forKey: "code") {
                
            case "PLT":
                maxCode = 537
            case "RIG":
                maxCode = 44
            case "IAR":
                maxCode = 32
            case "AMG":
                maxCode = 116
            case "AMA":
                maxCode = 102
            case "AMP":
                maxCode = 073
            default:
                maxCode = 999
            }
            
            // don't let the user enter an incorrect code
            if Int(String(String(code.dropLast()).suffix(3)))! > maxCode {

                viewController.showErrorAlert(title: "Oops", message: "\(code)is not a valid \(userDefaults.string(forKey: "code")!) code")
            
            } else {
                
                // append the code to the codes text view
                self.viewController.tableViewController.KTRCodes.text.append(code)
                
                // sort the KTR codes before putting them in the code list
                codes = self.viewController.tableViewController.KTRCodes.text.components(separatedBy: " ")
                codes.removeLast()
                codes.sort()
                
                // empty the cose list
                self.viewController.tableViewController.KTRCodes.text.removeAll()
                
                // add the codes seperated by a space (spaces werent added using the joined function for some reason)
                for code in codes {
                    self.viewController.tableViewController.KTRCodes.text.append(code + " ")
                }
                
                // make the text view scroll to the end when text goes beyond the visible length
                let string = self.viewController.tableViewController.KTRCodes.text
                let range = NSMakeRange((string?.endIndex.encodedOffset)!, 0)
                self.viewController.tableViewController.KTRCodes.scrollRangeToVisible(range)
                
            }
            
            // clear the text fields for new input
            btn_clear(sender)
            
        }
    }
    
    // when done, reload the initial view controller
    @IBAction func btn_done(_ sender: UIButton) {
        
        // clear the text fields so an old code isn't still there if they need to add more
        btn_clear(sender)
        
        // hide the KTR keyboard again
        viewController.hideKeyboard()
        
    }
    
   @IBAction func unhighlight(_ button: UIButton) {
        
        button.isHighlighted = false
    }
    
    func darkmode(_ value: Bool) {
        
        if value {
            
            self.view.backgroundColor = userDefaults.color(forKey: "viewDark")
            
            for view in self.view.subviews {
                
                if view is UIButton {
                    
                    view.backgroundColor = userDefaults.color(forKey: "buttonDark")
                    (view as? UIButton)?.titleLabel?.textColor = userDefaults.color(forKey: "buttonTextDark")
                } else if view is UITextField {
                    
                    view.backgroundColor = userDefaults.color(forKey: "textViewDark")
                    (view as? UITextField)?.textColor = userDefaults.color(forKey: "textViewTextDark")
                }
            }
        } else {
            
            self.view.backgroundColor = userDefaults.color(forKey: "viewLight")
            
            for view in self.view.subviews {
                
                if view is UIButton {
                    
                    view.backgroundColor = userDefaults.color(forKey: "buttonLight")
                    (view as? UIButton)?.titleLabel?.textColor = userDefaults.color(forKey: "buttonTextLight")
                } else if view is UITextField {
                    
                    view.backgroundColor = userDefaults.color(forKey: "textViewLight")
                    (view as? UITextField)?.textColor = userDefaults.color(forKey: "textViewTextLight")
                }
            }
        }
        
    }
}
