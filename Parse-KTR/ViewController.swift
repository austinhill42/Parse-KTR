//
//  ViewController.swift
//  Parse-KTR
//
//  Created by Austin Hill on 12/22/17.
//  Copyright © 2017 Austin Hill. All rights reserved.
//

import UIKit
import TesseractOCR

class ViewController: UIViewController, UITextViewDelegate, UINavigationBarDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, G8TesseractDelegate {
    
    private var userDefaults = UserDefaults.standard
    
    var settingsViewController: SettingsViewController!
    var tableViewController: TableViewController!
    var tableView: UITableView!
    var keyboardViewController: KeyboardViewController!
    var documentsViewController: DocumentsViewController!
    
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var keyboardContainerView: UIView!
    
    @IBOutlet weak var navbar: UINavigationBar!
    
    var outstring: String = ""
    var keyboardShowing = true
    var containerViewOrigin: CGFloat!
    
    // do stuff when the view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add nice looking rounded corners to the container view
        containerView.layer.cornerRadius = 6.0
        
        if userDefaults.string(forKey: "code") == nil {
            
            userDefaults.set("PLT", forKey: "code")
        }
        
        if userDefaults.string(forKey: "output") == nil {
            
            userDefaults.set("Evaluator", forKey: "output")
        }
        
        // set user dark mode color defaults
        userDefaults.set(color: UIColor(red: 10/255, green: 10/255, blue: 10/255, alpha: 1), forKey: "viewDark")
        userDefaults.set(color: UIColor(red: 30/255, green: 30/255, blue: 60/255, alpha: 1), forKey: "tableCellDark")
        userDefaults.set(color: UIColor.clear, forKey: "labelDark")
        userDefaults.set(color: UIColor.white, forKey: "labelTextDark")
        userDefaults.set(color: UIColor(red: 92/255, green: 94/255, blue: 102/255, alpha: 1), forKey: "textViewDark")
        userDefaults.set(color: UIColor.white, forKey: "textViewTextDark")
        userDefaults.set(color: UIColor(red: 92/255, green: 94/255, blue: 102/255, alpha: 1), forKey: "pickerDark")
        userDefaults.set(color: UIColor.black, forKey: "navigationBarDark")
        userDefaults.set(color: UIColor.white, forKey: "navigationBarTextDark")
        userDefaults.set(color: UIColor.clear, forKey: "switchDark")
        userDefaults.set(color: UIColor.clear, forKey: "segmentedControlDark")
        userDefaults.set(color: UIColor.black, forKey: "tableViewCellSeperatorDark")
        userDefaults.set(color: UIColor(red: 30/255, green: 30/255, blue: 60/255, alpha: 1), forKey: "buttonDark")
        userDefaults.set(color: UIColor.blue, forKey: "buttonTextDark")
        
        // set user light mode color defaults
        userDefaults.set(color: UIColor.white, forKey: "viewLight")
        userDefaults.set(color: UIColor.groupTableViewBackground, forKey: "tableCellLight")
        userDefaults.set(color: UIColor.clear, forKey: "labelLight")
        userDefaults.set(color: UIColor.black, forKey: "labelTextLight")
        userDefaults.set(color: UIColor.white, forKey: "textViewLight")
        userDefaults.set(color: UIColor.black, forKey: "textViewTextLight")
        userDefaults.set(color: UIColor.white, forKey: "pickerLight")
        userDefaults.set(color: UIColor.lightGray, forKey: "navigationBarLight")
        userDefaults.set(color: UIColor.black, forKey: "navigationBarTextLight")
        userDefaults.set(color: UIColor.clear, forKey: "switchLight")
        userDefaults.set(color: UIColor.clear, forKey: "segmentedControlLight")
        userDefaults.set(color: UIColor.white, forKey: "tableViewCellSeperatorLight")
        userDefaults.set(color: UIColor.groupTableViewBackground, forKey: "buttonLight")
        userDefaults.set(color: UIColor.black, forKey: "buttonTextLight")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // set the initial container view origin
        containerViewOrigin = self.containerView.frame.origin.y
        
        // move the keyboard out of the way
        if keyboardShowing {
            
            hideKeyboard(0)
        }
        
        darkMode(userDefaults.bool(forKey: "dark"))

    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        // hide the keyboard on transition if the user sets it
        if userDefaults.bool(forKey: "hidekeyboard") && keyboardShowing {
           
            hideKeyboard(0)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // change the name of the view to "Done" so it shows "Done" as the back button
        self.navigationItem.title = "Done"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        // initialize the table view controller and table view when they load
        if let vc = segue.destination as? TableViewController, segue.identifier == "segue" {
            
            self.tableViewController = vc
            self.tableView = tableViewController.tableView
            self.tableViewController.viewController = self
        }
        
        // initialize the settings view controller when it loads
        if let vc = segue.destination as? SettingsViewController, segue.identifier == "settings" {
            
            self.settingsViewController = vc
            self.settingsViewController.viewController = self
        }
        
        // initialize the keyboard view controller when it shows
        if let vc = segue.destination as? KeyboardViewController, segue.identifier == "keyboard" {
            
            self.keyboardViewController = vc
            self.keyboardViewController.viewController = self
            
        }
        
        // initialize the documents view when it loads
        if let vc = segue.destination as? DocumentsViewController, segue.identifier == "documents" {
            
            self.documentsViewController = vc
            self.documentsViewController.viewController = self
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        // hide the keyboard if it isn't the one being touched
        if touches.first?.view != self.keyboardViewController.view && keyboardShowing {
            
            hideKeyboard()
        }
        
    }
    
    // function to show the keyboard
    func showKeyboard() {
        
        // move both the keyboard and container view up with animation
        UIView.animate(withDuration: 0.75,
                       animations: {
                        self.keyboardContainerView.frame.origin.y = self.view.frame.height - (self.keyboardContainerView.frame.height)
                        
                        self.containerView.frame.origin.y -= self.keyboardContainerView.frame.height / 2})
        
        // set the keyboard as showing
        keyboardShowing = true
    }
    
    // function to hide the keyboard
    func hideKeyboard(_ duration: TimeInterval...) {
        
        let time: TimeInterval!
        
        // some places hide the keyboard immediately, others hide with animation
        // this allows for both
        if duration.isEmpty {
            time = 0.75
        } else {
            time = duration.first
        }
        
        // move both the keyboard view and the container view back down with animation
        UIView.animate(withDuration: time,
                       animations: {
                        self.keyboardContainerView.frame.origin.y = self.view.frame.height
                        
                        self.containerView.frame.origin.y = self.containerViewOrigin })
        
        // set the keyboard as not showing
        keyboardShowing = false
        
        // clears the keyboard when hidden
        self.keyboardViewController.clear()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func actionButton(_ sender: Any) {
    
        // create the popover for the available actions
        let actionPopover = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // set the print button properties
        let printButton = UIAlertAction(title: "Print",
                                       style: .default,
                                       handler: { (alert) in self.printOutput() })
        
        // set the share button properties
        let shareButton = UIAlertAction(title: "Share",
                                         style: .default,
                                         handler: { (alert) in self.shareOutput() })
       
        // set the save button properties
        let saveButton = UIAlertAction(title: "Save",
                                       style: .default,
                                       handler: { (alert) in self.saveData() })
        
        let loadButton = UIAlertAction(title: "Load",
                                       style: .default,
                                       handler: { (alert) in self.load() })
        
        // add the buttons to the popover
        actionPopover.addAction(printButton)
        actionPopover.addAction(shareButton)
        //actionPopover.addAction(saveButton)
        //actionPopover.addAction(loadButton)
        
        // required for the ipad, tell the app where the image picker should appear on screen
        if let popoverController = actionPopover.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
            
        }
        
        // show the image picker
        self.present(actionPopover, animated: true, completion: nil)
    
    }
    
    @IBAction func cameraButton(_ sender: Any) {
        
        presentImagePicker()
    }

    @IBAction func clearButton(_ sender: Any) {
        
        // create the popover for the available actions
        let actionPopover = UIAlertController(title: "Are you sure?", message: "This action will clear all fields. It is irreversible.", preferredStyle: .actionSheet)
    
        // set the save button properties
        let clear = UIAlertAction(title: "Clear",
                                       style: .default,
                                       handler: { (alert) in self.clear()})
        
        // set the share button properties
        let cancel = UIAlertAction(title: "Cancel",
                                        style: .cancel,
                                        handler: nil)
        
        if userDefaults.bool(forKey: "dark") {
            
            clear.setValue(userDefaults.color(forKey: "labelTextDark"), forKey: "titleTextColor")
            cancel.setValue(userDefaults.color(forKey: "labelTextDark"), forKey: "titleTextColor")
            actionPopover.view.backgroundColor = UIColor.clear
            actionPopover.view.subviews.first?.backgroundColor = userDefaults.color(forKey: "viewDark")

        } else {
            
            clear.setValue(userDefaults.color(forKey: "labelTextLight"), forKey: "titleTextColor")
            cancel.setValue(userDefaults.color(forKey: "labelTextLight"), forKey: "titleTextColor")
            actionPopover.view.backgroundColor = userDefaults.color(forKey: "viewLight")
            actionPopover.view.subviews.first?.backgroundColor = userDefaults.color(forKey: "viewLight")
            
        }

        // add the buttons to the popover
        actionPopover.addAction(clear)
        actionPopover.addAction(cancel)
        
        // required for the ipad, tell the app where the image picker should appear on screen
        if let popoverController = actionPopover.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        // show the actionsheet
        self.present(actionPopover, animated: true, completion: nil)
    }
    
    // function to clear all editable fields
    func clear() {
        
        for section in 0 ..< tableView.numberOfSections {
            
            for item in 0 ..< tableView.numberOfRows(inSection: section) {
                
                // get the cell corresponding to the given index path
                // then get the text view from the cell's content view
                let textview = (tableView.cellForRow(at: IndexPath(item: item, section: section))?.contentView.viewWithTag(1) as? UITextView)
                
                // set the text view text to an empty string
                textview?.text = ""
                
                // stop editing
                textview?.resignFirstResponder()
            }
        }
    }
    
    // print the output
    func printOutput() {
        
        // format the output for printing
        formatOutput(&outstring)
        
        // set the print controller and print info (using defaults)
        let printcontroller = UIPrintInteractionController.shared
        let printinfo = UIPrintInfo(dictionary: nil)
        
        // set the output type
        printinfo.outputType = UIPrintInfoOutputType.general
        
        // set the job name
        printinfo.jobName = "Parse-KTR Print Job"
        
        // give the print controller the print info
        printcontroller.printInfo = printinfo
        
        // set the formatter
        let formatter = UISimpleTextPrintFormatter(text: outstring)
        
        // set the margins
        formatter.perPageContentInsets = UIEdgeInsets(top: 72, left: 72, bottom: 72, right: 72)
        
        // give the print controller the format
        printcontroller.printFormatter = formatter
        
        // show the print controller
        printcontroller.present(animated: true, completionHandler: nil)
    }
    
    // save the output to a file
    func saveData() {
        
        // get the name, FTN, testype, path to the current directory, and format the outfile name
        let name: String = tableViewController.name.text!.split(separator: ",").joined().split(separator: " ").joined() as String
        let ftn: String = tableViewController.ftn.text!
        let testtype: String = tableViewController.testType.text!
        let path: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let outfile: String = name + "--" + (ftn != "" ? (ftn + "--") : "") + testtype + ".ktr"
        let outstring = name + ";" + ftn + ";" + testtype + ";" + tableViewController.KTRCodes.text
        
        do {
            
            // attempt to write the formatted output to a file
            try outstring.write(toFile: path + "/" + outfile, atomically: false, encoding: String.Encoding.utf8)
            
            // Let the user know saving succeeded
            
            // create the alert controller
            let alert = UIAlertController(title: "", message: "File Saved", preferredStyle: UIAlertControllerStyle.alert)
            
            // required for the ipad, tell the app where the alert view should appear on screen
            if let popoverController = alert.popoverPresentationController {
                popoverController.sourceView = self.view
                popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
                
            }
            
            // show the slert
            self.present(alert, animated:true, completion: nil)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                
                alert.dismiss(animated: true, completion: nil)
            }
            
            // let the user know that saving failed
        } catch{
            
            // show an error saying that the save failed and include the error description for error reporting
            showErrorAlert(title: "Save Failed", message: "Failed to save file: \(outfile)\n\n" +
                "Error: \(error.localizedDescription)")
            
        }
        
    }
    
    // share the output file
    func shareOutput() {
        
        // get the name, FTN, testype, path to the current directory, and format the outfile name
        let name: String = tableViewController.name.text!.split(separator: ",").joined().split(separator: " ").joined() as String
        let ftn: String = tableViewController.ftn.text!
        let testtype: String = tableViewController.testType.text!
        let path: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let outfile: String = name + "--" + (ftn != "" ? (ftn + "--") : "") + testtype + ".txt"
        let outstring = name + ";" + ftn + ";" + testtype + ";" + tableViewController.KTRCodes.text
        
        // format the output to share
        formatOutput(&self.outstring)
        
        do {
       
            // attempt to write the formatted output to a file
            try outstring.write(toFile: path + "/" + outfile, atomically: false, encoding: String.Encoding.utf8)
        
        } catch {
            // show an error saying that the save failed and include the error description for error reporting
            showErrorAlert(title: "File Write Failed", message: "Failed to write to file: \(outfile)\n\n" +
                "Error: \(error.localizedDescription)")
        }
        
        let file = URL(fileURLWithPath: outfile, isDirectory: false, relativeTo: URL(fileURLWithPath: path, isDirectory: true))
        
        // create the activity view controller
        let shareViewController = UIActivityViewController(activityItems: ["Share", file], applicationActivities: nil)

        // exclude activity items thar aren't relevent to this app
        shareViewController.excludedActivityTypes = [UIActivityType.addToReadingList, UIActivityType.assignToContact, UIActivityType.postToFacebook, UIActivityType.postToFlickr, UIActivityType.postToTencentWeibo, UIActivityType.postToTwitter, UIActivityType.postToVimeo, UIActivityType.postToWeibo, UIActivityType.saveToCameraRoll]
        
        // required for the ipad, tell the app where the share view should appear on screen
        if let popoverController = shareViewController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
            
        }
        
        // show the share view controller
        self.present(shareViewController, animated:true, completion: nil)
    }
    
    
    
    func load() {
        
        performSegue(withIdentifier: "documents", sender: self)
        
        //let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
        do {
           
            let files = try FileManager.default.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            
            for file in files  {
            
                if file.relativeString.hasSuffix(".ktr") {
                
                    label.text = file.relativeString.components(separatedBy: "/").last
                    label.textColor = (userDefaults.bool(forKey: "dark") ? userDefaults.color(forKey: "labelTextDark") : userDefaults.color(forKey: "labelTextLight"))
                    label.sizeToFit()
                
                    documentsViewController.labels.append(label)
                }
        }
            
        } catch {
            
        }
        
    }
    
    // present the image picker so the user can choose to take a photo or use one from their photo library
    func presentImagePicker() {
        
        
        // create the image picker
        let imagePickerActionSheet = UIAlertController(title: "Take/Upload Image", message: nil, preferredStyle: .actionSheet)
        
        // make sure the camera is available before adding it as an option
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            
            // set the camera button properties
            let cameraButton = UIAlertAction(title: "Take Photo",
                                             style: .default,
                                             handler: { (alert) ->Void in
                                                let imagePicker = UIImagePickerController()
                                                imagePicker.delegate = self
                                                imagePicker.sourceType = .camera
                                                self.present(imagePicker, animated: true)
            })
            
            // add the camera as an option for the image picker
            imagePickerActionSheet.addAction(cameraButton)
        }
        
        // set the library button properties
        let libraryButton = UIAlertAction(title: "Choose Existing",
                                          style: .default,
                                          handler: { (alert) -> Void in
                                            let imagePicker = UIImagePickerController()
                                            imagePicker.delegate = self
                                            imagePicker.sourceType = .photoLibrary
                                            self.present(imagePicker, animated: true)
        })
        
        // add the liobrary button as an option
        imagePickerActionSheet.addAction(libraryButton)
        
        // required for the ipad, tell the app where the image picker should appear on screen
        if let popoverController = imagePickerActionSheet.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []

        }
        
        // show the image picker
        self.present(imagePickerActionSheet, animated: true, completion: nil)
        
    }
    
    // image picker controller
   @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        
        // use the image selected by the user from the image picker
        let scaledImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        // when the image picker goes away, call the image recognition function
        dismiss(animated: true, completion: { self.performImageRecognition(scaledImage!)})
                
                
    }
    
    // perform the image recognition with Tesseract
    func performImageRecognition(_ image: UIImage) {
        
        var cancel = false
        
        // this operation takes a while, show the user something's working
        // create the alert controller
        let alert = UIAlertController(title: "Performing OCR", message: "This will take a moment, please be patient", preferredStyle: UIAlertControllerStyle.alert)
       
        // create a cancel button to cancel OCR
        let cancelButton = UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: { (action: UIAlertAction!) in
                cancel = true
        })
        
        // add the button to the alert controller
        alert.addAction(cancelButton)
        
        // required for the ipad, tell the app where the alert view should appear on screen
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
            
        }
        
        // show the slert
        self.present(alert, animated:true, completion: nil)
        
        // put the OCR in a background thread
        DispatchQueue.global(qos: .background).async {
            
            // select english as the detected language
            if let tesseract = G8Tesseract(language: "eng") {
                
                // not entirely sure
                tesseract.delegate = self
                
                // set engine mode to the most accurate one
                tesseract.engineMode = .tesseractCubeCombined
                
                // let tesseract know that there are paragraph breaks
                tesseract.pageSegmentationMode = .auto
                
                // convert the image to black and white to help improve recognition
                tesseract.image = image.g8_blackAndWhite()
                
                // perform the OCR
                tesseract.recognize()
                
                 if !cancel {
                    // UI updates must go in the main thread
                    DispatchQueue.main.async {
                    
                        // parse the tesseract text data and add them to the PLT codes textview
                        self.parseOCR(tesseract.recognizedText)
                        
                        // dismiss the alert when done
                        alert.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    // function to parse the PLT codes returned by OCR
    func parseOCR(_ string: String) {
        
        var originalString = string
        var codes = [String]()
        var name = ""
        var testType = ""
        var lookingForName = true
        var lookingForTestType = true
        
        originalString.removeFirst(100)
        // loop while the string isn't empty and is large enough to contain a code
        while !originalString.isEmpty && originalString.count > 6 {
            
            var parsedString = ""
            
            if lookingForName && originalString.hasPrefix("NAME:") {
                
                // remove NAME:
                originalString.removeFirst(5)
                
                while !originalString.hasPrefix("APPLICANT") {
                    
                    // append each character
                    name.append(originalString.first!)
                    
                    // remove the now appended character
                    originalString.removeFirst()
                }
                
                // not looking for name anymore
                lookingForName = false
                
                // UI updates must go in the main thread
                DispatchQueue.main.async {
                    
                    // set the name text view
                    self.tableViewController.name.text = name
                }
            }
            
            if lookingForTestType && originalString.hasPrefix("EXAM:") {
                
                // remove EXAM:
                originalString.removeFirst(5)
                
                // go until you get to EXAM ID
                while !originalString.hasPrefix("EXAM ID") {
                    
                    // append each character
                    testType.append(originalString.first!)
                    
                    // remove the now appended character
                    originalString.removeFirst()
                }
                
                // found test type
                lookingForTestType = false

                // get the test type as string array to initialize the string
                var test = testType.components(separatedBy: " ")
                
                // remove the empty string if needed
                if test.last == "" {
                    
                    test.removeLast()
                }
                
                // remove the empty string if needed
                if test.first == "" {
                    
                    test.removeFirst()
                }
                
                // set test type to empty string
                testType = ""
                
                for string in test {
                    
                    // make sure it's not in parentheses
                    if string.first != "(" {
                        
                        // append the first letter of each string in the test type
                        testType.append(string.first!)
                    }
                }
                // UI updates must go in the main thread
                DispatchQueue.main.async {
                    
                    // set the test type as the initialization of teh test type
                    self.tableViewController.testType.text = testType
                }
            }
            
            // if it starts with PLT then it's likely a proper code, grab it and remove it from the original string
            if originalString.hasPrefix(userDefaults.string(forKey: "code")!) {
                
                lookingForName = false
                lookingForTestType = false
                
                // create the character set for invalid characters
                let charset = CharacterSet(charactersIn: "0123456789Oo").inverted
                
                // get the 3 characters after PLT
                let code = String(String(originalString.prefix(6)).suffix(3))
                
                // check if the numerical part of the code contains invalid characters
                if code.rangeOfCharacter(from: charset) == nil {
                    
                    parsedString.append(String(originalString.prefix(6)))
                
                    originalString.removeSubrange(originalString.startIndex..<originalString.index(originalString.startIndex, offsetBy: 6))
                    
                    // Tesseract sometimes comfuses zero with the letter O, let's fix that
                    parsedString = parsedString.replacingOccurrences(of: "O", with: "0")
                    parsedString = parsedString.replacingOccurrences(of: "o", with: "0")
                    
                    // append the parsed PLT code to the code array
                    codes.append(parsedString)
                    
                } else {
                    // remove the first element and look for the code again
                    originalString.removeFirst()
                }
                
            } else {
                
                // remove the first element and look for the code again
                originalString.removeFirst()
            }
            
        }
        
        // UI updates must go in the main thread
        DispatchQueue.main.async {
        
            // add the found KTR codes to the code list
            self.tableViewController.KTRCodes.text = codes.joined(separator: " ")
        }
    }
    
    // function to format the output
    func formatOutput(_ outstring: inout String) {
        
        // get the list of codes
        var KTRCodes = tableViewController.KTRCodes.text.components(separatedBy: " ")
        
        // codes entered by the user have a space at the end, remove it
        if KTRCodes.last == "" {
            
            KTRCodes.removeLast()
        }
        
        // get the path to the KTR codes file
        let KTRPath = Bundle.main.path(forResource: "ALL_KTR_CODES", ofType: "txt")!
        
        var space: String!
        
        // add the initial header to the outfile
        outstring = "Name: " + tableViewController.name.text! + "  FTN: " + tableViewController.ftn.text! + "\n\n"
        
        do {
            
            // format the outfile for DPE or CFI/Flight School
            if userDefaults.string(forKey: "output") == "Evaluator" {
            
                // set the spacers
                space = "______  "
            }
            else if userDefaults.string(forKey: "output") == "Instructor" {
            
                // add the file header
                outstring +=
                    "Re-Train" + "     Validate" + "      Tested" + "\n" +
                    "Date By" + "      Date By" + "      Date By" + "\n\n"
            
                // set the spacers
                space = "____ ____  ____ ____  ____ ____  "
            }
            
            // get the code list from the codes file for camparing to the user entered codes
            let KTRCodesFromFile: [String] = try String(contentsOfFile: KTRPath, encoding: String.Encoding.utf8).components(separatedBy: "\n")
            
            // find the code in the file that matches the code entered by the user and add it to the output
            for code in KTRCodes {
                for ktrcode in KTRCodesFromFile {
                    let ktr = ktrcode.prefix(6)
                    
                    if ktr == code {
                        
                        print("\n\n**\(code)**   **\(ktr)\n\n")
                        outstring += space + ktrcode + "\n\n\n"
                    }
                    
                }
            }
        } catch {
            
            // show an error saying that the codes file failed to load
            // and include the error description for error reporting
            showErrorAlert(title: "Error", message: "Failed to read from file: \(KTRPath)\n\n" +
                "Error: \(error.localizedDescription)")
            
        }
 
    }
    
    // function to show a standard error alert window with a title, message, and close button
    func showErrorAlert(title: String, message: String) {
        
        // create the alert controller
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        // create the close button
        let close = UIAlertAction(title: "Close", style: .cancel, handler: nil)
        
        let report = UIAlertAction(title: "Report", style: .default, handler: { (alert) in self.report(error: message) })
        
        // add the close button to the alert controller
        alert.addAction(close)
        
        // required for the ipad, tell the app where the alert view should appear on screen
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
            
        }
        
        // show the slert
        self.present(alert, animated:true, completion: nil)
    }
    
    func report(error: String) {
        
        
    }
    
    func darkMode(_ value: Bool) {
        
        if value {
            
            navigationController?.navigationBar.barStyle = .black

            self.view.backgroundColor = userDefaults.color(forKey: "viewDark")
            self.navigationController?.navigationBar.barTintColor = userDefaults.color(forKey: "navigationBarDark")
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: userDefaults.color(forKey: "navigationBarTextDark")!]
            self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: userDefaults.color(forKey: "navigationBarTextDark")!]
            
        } else {
            
            navigationController?.navigationBar.barStyle = .default

            self.view.backgroundColor = userDefaults.color(forKey: "viewLight")
            self.navigationController?.navigationBar.barTintColor = userDefaults.color(forKey: "navigationBarLight")
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: userDefaults.color(forKey: "navigationBarTextLight")!]
            self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: userDefaults.color(forKey: "navigationBarTextLight")!]
            
        }
    }
    
}

extension UserDefaults {
    
    func set(color: UIColor?, forKey key: String) {
       
        var colorData: NSData?
        
        if let color = color {
            
            colorData = NSKeyedArchiver.archivedData(withRootObject: color) as NSData?
        }
        
        set(colorData, forKey: key)
    }
    
    func color(forKey key: String) -> UIColor? {
        
        var color: UIColor?
        
        if let colorData = data(forKey: key) {
            
            color = NSKeyedUnarchiver.unarchiveObject(with: colorData) as? UIColor
        }
        
        return color
    }
}

























