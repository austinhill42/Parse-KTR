//
//  ViewController.swift
//  Parse-KTR
//
//  Created by Austin Hill on 12/22/17.
//  Copyright © 2017 Austin Hill. All rights reserved.
//

import UIKit
import TesseractOCR

class ViewController: UIViewController, UITextViewDelegate, UINavigationBarDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, G8TesseractDelegate {
    
    private var userDefaults = UserDefaults.standard
    
    var settingsViewController: SettingsViewController!
    var tableViewController: TableViewController!
    var tableView: UITableView!
    var keyboardViewController: KeyboardViewController!
    
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
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // change the nae of the view controller back to "Parse-KTR"
        self.navigationItem.title = "Parse-KTR"
        
        // set the initial container view origin
        containerViewOrigin = self.containerView.frame.origin.y
        
        // move the keyboard out of the way
        if keyboardShowing {
            
            hideKeyboard(0)
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
                                       handler: { (alert) in self.printOutput()})
        
        // set the save button properties
        let saveButton = UIAlertAction(title: "Save",
                                       style: .default,
                                       handler: { (alert) in self.saveOutput()})
        
        // set the share button properties
        let shareButton = UIAlertAction(title: "Share",
                                         style: .default,
                                         handler: { (alert) in self.shareOutput()})
        
        // add the buttons to the popover
        actionPopover.addAction(printButton)
        actionPopover.addAction(saveButton)
        actionPopover.addAction(shareButton)
        
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
        printinfo.jobName = "PLT Print Job"
        
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
    func saveOutput() {
        
        // get the formatted output for saving
        formatOutput(&outstring)
        
        // get the name, FTN, testype, path to the current directory, and format the outfile name
        let name: String = tableViewController.name.text!.split(separator: ",").joined().split(separator: " ").joined() as String
        let ftn: String = tableViewController.ftn.text!
        let testtype: String = tableViewController.testType.text!
        let path: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let outfile: String = name + "--" + (ftn != "" ? (ftn + "--") : "") + testtype + ".txt"
        
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
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                
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
        
        // format the output to share
        formatOutput(&outstring)
        
        // create the activity view controller
        let shareViewController = UIActivityViewController(activityItems: ["Share", outstring], applicationActivities: nil)
        
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
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        
        // use the image selected by the user from the image picker
        let scaledImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        // when the image picker goes away, call the image recognition function
        dismiss(animated: true, completion: { self.performImageRecognition(scaledImage!)})
    }
    
    // perform the image recognition with Tesseract
    func performImageRecognition(_ image: UIImage) {
        
        // this operation takes a while, show the user something's working
        // create the alert controller
        let alert = UIAlertController(title: "Performing OCR", message: "This will take a moment, please be patient", preferredStyle: UIAlertControllerStyle.alert)
        
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
                
                // UI updates must go in the main thread
                DispatchQueue.main.async {
                    
                    // dismiss the alert when done
                    alert.dismiss(animated: true, completion: nil)
                    
                    // parse the tesseract text data and add them to the PLT codes textview
                    self.tableViewController.KTRCodes.text = self.parseOCR(tesseract.recognizedText).joined(separator: " ")
                    
                    
                }
            }
        }
    }
    
    // function to parse the PLT codes returned by OCR
    func parseOCR(_ string: String) -> [String] {
        
        var originalString = string
        var codes = [String]()
        
        // loop while the string isn't empty and is large enough to contain a code
        while !originalString.isEmpty && originalString.count > 6{
            
            var parsedString = ""
            
            // if it starts with PLT then it's likely a proper code, grab it and remove it from the original string
            if originalString.hasPrefix("PLT") {
                
                // create the character set for invalid characters
                let charset = CharacterSet(charactersIn: "0123456789").inverted
                
                // get the 3 characters after PLT
                let code = String(String(originalString.prefix(6)).suffix(3))
                
                // check if the numerical part of the code contains invalid characters
                if code.rangeOfCharacter(from: charset) == nil {
                    
                    parsedString.append(String(originalString.prefix(6)))
                    
                    originalString.removeSubrange(originalString.startIndex..<originalString.index(originalString.startIndex, offsetBy: 6))
                    
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
        
        return codes
    }
    
    // function to format the output
    func formatOutput(_ outstring: inout String) {
        
        // get the list of codes
        let KTRCodes = tableViewController.KTRCodes.text.components(separatedBy: " ")
        
        // get the path to the KTR codes file
        let pltpath = Bundle.main.path(forResource: "ALL_PLTS", ofType: "txt")!
        
        var space: String!
        
        // add the initial header to the outfile
        outstring = "Name: " + tableViewController.name.text! + "  FTN: " + tableViewController.ftn.text! + "\n\n"
        
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
        
        do {
            
            // get the code list from the codes file for camparing to the user entered codes
            let pltcodes: [String] = try String(contentsOfFile: pltpath, encoding: String.Encoding.utf8).components(separatedBy: "\n")
            
            // find the code in the file that matches the code entered by the user and add it to the output
            for code in KTRCodes {
                for pltcode in pltcodes {
                    let plt = pltcode.prefix(6)
                    
                    if plt == code {
                        outstring += space + pltcode + "\n\n\n"
                    }
                    
                }
            }
        } catch {
            
            // show an error saying that the codes file failed to load
            // and include the error description for error reporting
            showErrorAlert(title: "Error", message: "Failed to read from file: \(pltpath)\n\n" +
                "Error: \(error.localizedDescription)")
            
        }
 
    }
    
    // function to show a standard error alert window with a title, message, and close button
    func showErrorAlert(title: String, message: String) {
        
        // create the alert controller
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        // create the close button
        let close = UIAlertAction(title: "Close", style: .cancel, handler: nil)
        
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
    
    /*
    // for typing in the plt codes, load the plt code "keyboard" view controller
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        // end editing so the user can't type anything
        textView.endEditing(true)
        
        // hide the save, print, share, and OCR options so the user doesnt click them
        // before they're done entering the PLT codes
        btn_ocr.isHidden = true
        btn_save.isHidden = true
        btn_print.isHidden = true
        btn_share.isHidden = true
        
        // clear the collection view so there are no duplicates
        while PLTCodes.count > 0 {
            
            let indexPath = IndexPath(item: 0, section: 0)
            
            // get the cell that was selected
            let cell = self.collectionView.cellForItem(at: indexPath) as! CollectionViewCell
            
            // remove the label from the array
            PLTCodes.remove(at: indexPath.item)
            
            // reset the cell's label to an empty string
            // note: this is because the cell isn't deleted, just removed from the collection view
            //       if the label isnt set to an empty string the cell could be reused and the old
            //       label will show up over the new one
            cell.label.text = ""
            
            // remove the cell from the collection view
            self.collectionView.deleteItems(at: [indexPath])
        }
        
        // add existing PLT codes to collection view
        if !tv_codelist.text.isEmpty {
            
            // get an array of plt codes
            let codes = tv_codelist.text.components(separatedBy: " ")
            
            // create index path to add collection view cells
            var indexPath = IndexPath(item: 0, section: 0)
            
            // add each code to the PLT codes array and create a cell for each code
            for code in codes {
                
                // add the PLT code to the array
                PLTCodes.append(code)
                
                // add a cell to teh collection view
                collectionView.insertItems(at: [indexPath])
                
                // incrememnt the index path
                indexPath.item += 1
            }
        }
        
        // show the PLT keyboard
        PLTView.isHidden = false
        
    }
 
    
*/

























