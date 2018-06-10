//
//  ViewController.swift
//  Parse-KTR
//
//  Created by Austin Hill on 12/22/17.
//  Copyright © 2017 Austin Hill. All rights reserved.
//

import UIKit
import TesseractOCR

class ViewController: UIViewController, G8TesseractDelegate {
    
    @IBOutlet weak var tf_name: UITextField!
    @IBOutlet weak var tf_ftn: UITextField!
    @IBOutlet weak var tf_testtype: UITextField!
    @IBOutlet weak var tf_codelist: UITextField!
    @IBOutlet weak var l_outfile: UITextView!
    @IBOutlet weak var sc_switch: UISegmentedControl!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var outstring: String = ""
    
    @IBAction func btn_ocr(_ sender: Any) {
        
            presentImagePicker()
    }
    
    @IBAction func btn_save(_ sender: Any) {
        
        let name: String = tf_name.text!.split(separator: ",").joined().split(separator: " ").joined() as String
        let ftn: String = tf_ftn.text!
        let testtype: String = tf_testtype.text!
        let codes: [String] = tf_codelist.text!.replacingOccurrences(of: ",", with: " ").replacingOccurrences(of: "  ", with: " ").components(separatedBy: " ")
        let path: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let outfile: String = path + "/" + name + "--" + (ftn != "" ? (ftn + "--") : "") + testtype + ".txt"
        l_outfile.text! = outfile
        
        outstring = "Name: " + tf_name.text! + "  FTN: " + tf_ftn.text! + "\n\n"
        
        if sc_switch.selectedSegmentIndex == 0 {
            formatDPE(codes: codes, outstring: &outstring)
        }
        else if sc_switch.selectedSegmentIndex == 1 {
            formatCFI(codes: codes, outstring: &outstring)
        }
        
        do {
            try outstring.write(toFile: outfile, atomically: false, encoding: String.Encoding.utf8)
            
        } catch{
            print("FAILED")
        }
    }
    
    @IBAction func btn_print(_ sender: Any) {
        btn_save((Any).self)
        
        let printcontroller = UIPrintInteractionController.shared
        let printinfo = UIPrintInfo(dictionary: nil)
        
        printinfo.outputType = UIPrintInfoOutputType.general
        printinfo.jobName = "PLT Print Job"
        printcontroller.printInfo = printinfo
        
        let formatter = UISimpleTextPrintFormatter(text: outstring)
        formatter.perPageContentInsets = UIEdgeInsets(top: 72, left: 72, bottom: 72, right: 72)
        printcontroller.printFormatter = formatter
        
        printcontroller.present(animated: true, completionHandler: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // the activity indicator was covered in testing, bring it to the front
        self.view.bringSubview(toFront: self.activityIndicator)

        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

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
                    
                    if (plt == code || plt == "PLT" + code || plt == "PLT0" + code || plt == "PLT00" + code) {
                        outstring += "______  " + pltcode + "\n\n\n"
                    }
                    
                }
            }
        } catch {
            
        }
    }
    
    // format the output for CFI
    func formatCFI(codes: [String], outstring: inout String) {
        
        do {
            
            // get the current app directory to save the file
            let pltpath: String = Bundle.main.path(forResource: "ALL_PLTS", ofType: "txt")!
            
            // get the code list from the codes file for camparing to the user entered codes
            let pltcodes: [String] = try String(contentsOfFile: pltpath, encoding: String.Encoding.utf8).components(separatedBy: "\n")
            
            // add the file header
            outstring += "Re-Train".padding(toLength: 11, withPad: " ", startingAt: 0) + "Validate".padding(toLength: 11, withPad: " ", startingAt: 0) + "Tested".padding(toLength: 11, withPad: " ", startingAt: 0) + "\n" + "Date By".padding(toLength: 11, withPad: " ", startingAt: 0) + "Date By".padding(toLength: 11, withPad: " ", startingAt: 0) + "Date By".padding(toLength: 11, withPad: " ", startingAt: 0) + "\n\n"
            
            
            // find the code in the file that matches the code entered by the user and add it to the output
            for code in codes {
                for pltcode in pltcodes {
                    let plt = pltcode.prefix(6)
                    
                    if (plt == code || plt == "PLT" + code || plt == "PLT0" + code || plt == "PLT00" + code)  {
                        outstring += "____ ____  ____ ____  ____ ____  " + plt + "\n\n\n"
                    }
                    
                }
            }
        } catch {
            
        }
    }
    
    func parse(_ string: String) -> [String] {
        
        var originalString = string
        var codes = [String]()
        
        // remove errant date before the PLT codes
        while originalString.isEmpty == false && originalString.hasPrefix("PLT") == false {
            originalString.removeFirst()
        }
        
        while originalString.isEmpty == false {
           
            var parsedString = ""
            
            // grab the first element
            var first = originalString.removeFirst()
            
            // chech that the first element starts a possible PLT code
            while (first == "P" || first == "L" || first == "T" ||
                (first >= "0" && first <= "9")) {
                
                    // add the character to the parsed string
                    parsedString.append(first)
                    first = originalString.removeFirst()
            }
            
            // append the parsed PLT code to the code array
            codes.append(parsedString)
        }
        
        return codes
    }
    
    func performImageRecognition(_ image: UIImage) {
        
        // this operation takes a while, show the user something's working
        self.activityIndicator.startAnimating()
        l_outfile.text = ""
        
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
                    
                    // parse the tesseract text data and add them to the PLT codes textview
                    self.l_outfile.text = self.parse(tesseract.recognizedText).joined(separator: " ")
                    
                    // stop the activity indicator when done
                    self.activityIndicator.stopAnimating() }
            }
        }

    }

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

        // set the cancel button properties and add it as an option
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel)
        imagePickerActionSheet.addAction(cancelButton)
        
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


























