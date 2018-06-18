//
//  ViewController.swift
//  Parse-KTR
//
//  Created by Austin Hill on 12/22/17.
//  Copyright © 2017 Austin Hill. All rights reserved.
//

import UIKit
import TesseractOCR

class ViewController: UIViewController, UITextViewDelegate, UINavigationBarDelegate, UITableViewDelegate, UITableViewDataSource, G8TesseractDelegate {
    
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var PLTView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navbar: UINavigationBar!
    
    var outstring: String = ""
    var cellsize = CGSize(width: 75, height: 50)
    var PLTCodes = [String]()
    var tableViewLabels = ["Applicant's Name", "FTN", "Test Type", "PLT Codes"]
    
    
    // do stuff when the view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set the view controller as the delegate for the table view and navigation bar
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.navbar.delegate = self
        
        // setup the table view
        self.tableView.register(TableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        // number of rows in the table view
        return tableViewLabels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        // get the table view cell
        let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell") as! TableViewCell
        
        // set the cell's background color and size
        cell.backgroundColor = UIColor.groupTableViewBackground
        cell.sizeThatFits(CGSize(width: 600, height: 100))
        
        // set the cell's content data
        cell.label.text = tableViewLabels[indexPath.item]
        cell.textview.delegate = self
        
        return cell
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
    
    // start the OCR process when the OCR button is pressed
    @IBAction func btn_ocr(_ sender: Any) {
        
            // show the image picker to select the image for OCR
            presentImagePicker()
    }
    
    // share the output file
    @IBAction func btn_share(_ sender: UIButton) {
        
        // format the output to share
        formatOutput()
        
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
    
    // save the output to a file
    @IBAction func btn_save(_ sender: Any) {
       
        // get the formatted output for saving
        formatOutput()
        
        // get the name, FTN, testype, path to the current directory, and format the outfile name
        let name: String = tf_name.text!.split(separator: ",").joined().split(separator: " ").joined() as String
        let ftn: String = tf_ftn.text!
        let testtype: String = tf_testtype.text!
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
    
    // print the output
    @IBAction func btn_print(_ sender: Any) {
        
        // format the output for printing
        formatOutput()
        
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
    
    // do stuff when the PLT keyboard keypad buttons are pressed
    @IBAction func btn_keypad(_ sender: UIButton) {
        
        // determine where the keypad text should go
        if (plt1.text?.isEmpty)! {
            
            plt1.text = sender.currentTitle
        } else if (plt2.text?.isEmpty)! {
            
            plt2.text = sender.currentTitle
        } else {
            
            plt3.text = sender.currentTitle
            
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
        
        plt1.text = ""
        plt2.text = ""
        plt3.text = ""
    }
    
    // delete the last number entered
    @IBAction func btn_delete(_ sender: UIButton) {
        
        // determine which text field had the last number entered and delete it
        if !(plt3.text?.isEmpty)! {
            plt3.text = ""
        } else if !(plt2.text?.isEmpty)! {
            plt2.text = ""
        } else if !(plt1.text?.isEmpty)! {
            plt1.text = ""
        }
    }
    
    // add the PLT code entered by the user to the list of PLT codes
    @IBAction func btn_enter(_ sender: UIButton) {
        
        // at least one number has been entered
        if !(plt1.text?.isEmpty)! {
            
            var code = ""
            
            // set the index path to the last item in the PLT codes array
            let indexPath = IndexPath(item: PLTCodes.count, section: 0)
        
            // if only one number has been entered
            if (plt2.text?.isEmpty)! {
            
                // set the PLT code in the correct format
                code = "PLT00" + plt1.text!
                
            // if two numbers have been entered
            } else if (plt3.text?.isEmpty)! {
                
                // set the PLT code in the correct format
                code = "PLT0" + plt1.text! + plt2.text!
            
            // if three numbers have been entered
            } else {
                
                // set the PLT code in the correct format
                code = "PLT" + plt1.text! + plt2.text! + plt3.text!
            }
            
            // don't let the user enter an incorrect code
            if Int(String(code.suffix(3)))! > 535 {
                
                showErrorAlert(title: "Oops", message: "\(code) is not a valid PLT code")
                
            } else {
                
                // add the new PLT code label to the PLT codes array
                PLTCodes.append(code)
                
                // add a new cell to the collectionview for the new PLT code
                collectionView.insertItems(at: [indexPath])
            }
            
            // clear the text fields for new input
            btn_clear(sender)
            
        }
    }
    
    // when done, reload the initial view controller
    @IBAction func btn_done(_ sender: UIButton) {
        
        // clear the text fields so an old code isn't still there if they need to add more
        btn_clear(sender)
        
        // sort the PLT codes before putting them in the cpode list
        PLTCodes.sort()
        
        // set the codelist text view to the entered codes
        tv_codelist.text = PLTCodes.joined(separator: " ")
        
        // hide the PLT keyboard again
        PLTView.isHidden = true
        
        // show the save, print, share, and OCR options again
        btn_ocr.isHidden = false
        btn_save.isHidden = false
        btn_print.isHidden = false
        btn_share.isHidden = false
    }

    // format the output for DPE
    func formatDPE(codes: [String], outstring: inout String) {
        
        do {
            
            // get the current app directory to save the file
            let pltpath: String = Bundle.main.path(forResource: "ALL_PLTS", ofType: "txt")!
            
            // get the code list from the codes file for camparing to the user entered codes
            let pltcodes: [String] = try String(contentsOfFile: pltpath, encoding: String.Encoding.utf8).components(separatedBy: "\n")
            
            // find the code in the file that matches the code entered by the user and add it to the output
            for code in codes {
                for pltcode in pltcodes {
                    let plt = pltcode.prefix(6)
                    
                    if plt == code {
                        outstring += "______  " + pltcode + "\n\n\n"
                    }
                    
                }
            }
        } catch {
            
        }
    }
    
    // format the output for CFI/Flight School
    func formatCFI(codes: [String], outstring: inout String) {
        
        do {
            
            // get the current app directory to save the file
            let pltpath: String = Bundle.main.path(forResource: "ALL_PLTS", ofType: "txt")!
            
            // get the code list from the codes file for camparing to the user entered codes
            let pltcodes: [String] = try String(contentsOfFile: pltpath, encoding: String.Encoding.utf8).components(separatedBy: "\n")
            
            // add the file header
            outstring +=
                "Re-Train" + "     Validate" + "      Tested" + "\n" +
                "Date By" + "      Date By" + "      Date By" + "\n\n"
            
            
            // find the code in the file that matches the code entered by the user and add it to the output
            for code in codes {
                for pltcode in pltcodes {
                    let plt = pltcode.prefix(6)
                    
                    if plt == code {
                        outstring += "____ ____  ____ ____  ____ ____  " + pltcode + "\n\n\n"
                    }
                    
                }
            }
        } catch {
            
        }
    }
    
    // function to format the output
    func formatOutput() {
        
        // add the initial header to the outfile
        outstring = "Name: " + tf_name.text! + "  FTN: " + tf_ftn.text! + "\n\n"
        
        // format the outfile for DPE or CFI/Flight School
        if sc_switch.selectedSegmentIndex == 0 {
            formatDPE(codes: PLTCodes, outstring: &outstring)
        }
        else if sc_switch.selectedSegmentIndex == 1 {
            formatCFI(codes: PLTCodes, outstring: &outstring)
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
                    self.tv_codelist.text = self.parseOCR(tesseract.recognizedText).joined(separator: " ")
                    
                    
                }
            }
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


// not sure
extension ViewController: UINavigationControllerDelegate {
    
}

extension ViewController: UIImagePickerControllerDelegate {

    // present the image picker so the user can choose to take  a photo or use one from their photo library
    func presentImagePicker() {
        
        
        // create the image picker actionsheet with a descriptive title
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
    
    // image picker controller, called in the background I think
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        
        // use the image selected by the user from the image picker
        let scaledImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        // when the image picker goes away, call the image recognition function
        dismiss(animated: true, completion: { self.performImageRecognition(scaledImage!)})
    }
    
}

extension UIImage {
    
    // function to scale the image, not currently used
    func scaleImage(_ maxDimension: CGFloat) -> UIImage? {
        
        var scaledSize = CGSize(width: maxDimension, height: maxDimension)
        
        if size.width > size.height {
            let scaleFactor = size.height / size.width
            scaledSize.height = scaledSize.width * scaleFactor
        } else {
            let scaleFactor = size.width / size.height
            scaledSize.width = scaledSize.height * scaleFactor
        }
        
        UIGraphicsBeginImageContext(scaledSize)
        draw(in: CGRect(origin: .zero, size: scaledSize))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
}
*/


























