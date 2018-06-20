//
//  SettingsTableViewController.swift
//  Parse-KTR
//
//  Created by Austin Hill on 6/19/18.
//  Copyright © 2018 Austin Hill. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var userDefaults = UserDefaults.standard
    var settingsViewController: SettingsViewController!
    
    @IBOutlet weak var outputSwitch: UISegmentedControl!
    @IBOutlet weak var codePicker: UIPickerView!
    @IBOutlet weak var darkModeSwitch: UISwitch!
    
    var codeTypes = [String]()
    var outputTypes = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.estimatedRowHeight = 0
        
        // show the picker selection
        self.codePicker.showsSelectionIndicator = true
        
        // make the output switch larger
        self.outputSwitch.transform = CGAffineTransform(scaleX: 1.13, y: 1.25)
        
        // make the dark mode switch larger
        self.darkModeSwitch.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
        
        // set the view oontroller as the delegate and data source for the picker
        self.codePicker.dataSource = self
        self.codePicker.delegate = self
        
        // initialize the picker data
        codeTypes = ["PLT"]
        
        // initialize the output data
        outputTypes = ["Evaluator", "Instructor"]
        
        // set user dark mode color defaults
        userDefaults.set(color: UIColor(red: 33/255, green: 33/255, blue: 33/255, alpha: 1), forKey: "viewDark")
        userDefaults.set(color: UIColor.darkGray, forKey: "tableCellDark")
        userDefaults.set(color: UIColor.clear, forKey: "labelDark")
        userDefaults.set(color: UIColor(red: 92/255, green: 94/255, blue: 102/255, alpha: 1), forKey: "textViewDark")
        userDefaults.set(color: UIColor(red: 92/255, green: 94/255, blue: 102/255, alpha: 1), forKey: "pickerDark")
        userDefaults.set(color: UIColor.black, forKey: "navigationBarDark")
        userDefaults.set(color: UIColor.darkGray, forKey: "switchDark")
        // set user light mode color defaults
        userDefaults.set(color: UIColor.white, forKey: "viewLight")
        userDefaults.set(color: UIColor.groupTableViewBackground, forKey: "tableCellLight")
        userDefaults.set(color: UIColor.clear, forKey: "labelLight")
        userDefaults.set(color: UIColor.white, forKey: "textViewLight")
        userDefaults.set(color: UIColor.white, forKey: "pickerLight")
        userDefaults.set(color: UIColor.clear, forKey: "navigationBarLight")
        userDefaults.set(color: UIColor.clear, forKey: "switchLight")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        darkMode(userDefaults.bool(forKey: "dark"))
        
        // show the correct segmented control setting
        if userDefaults.string(forKey: "output") == outputTypes[0] {
            outputSwitch.selectedSegmentIndex = 0
        } else {
            outputSwitch.selectedSegmentIndex = 1
        }
        
        // show the correct picker setting
        for index in 0 ..< codeTypes.count {
            
            if codeTypes[index] == userDefaults.string(forKey: "code") {
                
                self.codePicker.selectRow(index, inComponent: 0, animated: true)
                break
            }
        }
        
        // show the correct switch setting
        darkModeSwitch.isOn = userDefaults.bool(forKey: "dark")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // get the selected index from the picker and add code type to the database
        let codePickerIndex = self.codePicker.selectedRow(inComponent: 0)
        self.userDefaults.set(self.codeTypes[codePickerIndex], forKey: "code")
        
        // get the selected index from the switch and add it to the database
        let outputSwitchIndex = self.outputSwitch.selectedSegmentIndex
        self.userDefaults.set(self.outputTypes[outputSwitchIndex], forKey: "output")
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let vc = segue.source as? SettingsViewController, segue.identifier == "segue" {
            
            self.settingsViewController = vc
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return codeTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return codeTypes[row]
    }
    
    // switch to dark mode when the switch is toggled
    @IBAction func switchToggled(_ sender: UISwitch) {
        
        if sender.isOn {
            userDefaults.set(true, forKey: "dark")
        } else {
            userDefaults.set(false, forKey: "dark")
        }
        
        darkMode(userDefaults.bool(forKey: "dark"))
    }
    
    func darkMode(_ value: Bool) {
        
        if value {
            
            for cell in self.tableView.visibleCells {
                
                cell.backgroundColor = userDefaults.color(forKey: "tableCellDark")
                
                for view in cell.contentView.subviews {
                    
                    if view is UILabel {
                        
                        view.backgroundColor = userDefaults.color(forKey: "labelDark")
                    } else if view is UITextView {
                        
                        view.backgroundColor = userDefaults.color(forKey: "textViewDark")
                    } else if view is UIPickerView {
                        
                        view.backgroundColor = userDefaults.color(forKey: "pickerDark")
                    } else if view is UISwitch {
                        
                        view.backgroundColor = userDefaults.color(forKey: "switchDark")
                    }
                }
            }
            
        } else {
            
            for cell in self.tableView.visibleCells {
                
                cell.backgroundColor = userDefaults.color(forKey: "tableCellLight")
                
                for view in cell.contentView.subviews {
                    
                    if view is UILabel {
                        
                        view.backgroundColor = userDefaults.color(forKey: "labelLight")
                    } else if view is UITextView {
                        
                        view.backgroundColor = userDefaults.color(forKey: "textViewLight")
                    } else if view is UIPickerView {
                        
                        view.backgroundColor = userDefaults.color(forKey: "pickerLight")
                    } else if view is UISwitch {
                        
                        view.backgroundColor = userDefaults.color(forKey: "switchLight")
                    }
                }
            }
            
        }
    }
}
































