//
//  SettingsTableViewController.swift
//  Parse-KTR
//
//  Created by Austin Hill on 6/19/18.
//  Copyright © 2018 Austin Hill. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    private var userDefaults = UserDefaults.standard
    
    @IBOutlet weak var outputSwitch: UISegmentedControl!
    @IBOutlet weak var codePicker: UIPickerView!
    
    var codeTypes = [String]()
    var outputTypes = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.estimatedRowHeight = 0
        
        // show the picker selection
        self.codePicker.showsSelectionIndicator = true
        
        // make the output switch larger
        self.outputSwitch.transform = CGAffineTransform(scaleX: 1.13, y: 1.25)
        
        // set the view oontroller as the delegate and data source for the picker
        self.codePicker.dataSource = self
        self.codePicker.delegate = self
        
        // initialize the picker data
        codeTypes = ["PLT"]
        
        // initialize the output data
        outputTypes = ["Evaluator", "Instructor"]
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // show the correct switch setting
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
}
