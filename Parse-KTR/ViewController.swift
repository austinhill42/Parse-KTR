//
//  ViewController.swift
//  Parse-KTR
//
//  Created by Austin Hill on 12/22/17.
//  Copyright © 2017 Austin Hill. All rights reserved.
//

import UIKit
import TesseractOCR

class ViewController: UIViewController, UITextViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, G8TesseractDelegate {
    
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var PLTView: UIView!
    @IBOutlet weak var tf_name: UITextField!
    @IBOutlet weak var tf_ftn: UITextField!
    @IBOutlet weak var tf_testtype: UITextField!
    @IBOutlet weak var tv_codelist: UITextView!
    @IBOutlet weak var l_outfile: UILabel!
    @IBOutlet weak var sc_switch: UISegmentedControl!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var plt1: UITextField!
    @IBOutlet weak var plt2: UITextField!
    @IBOutlet weak var plt3: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var outstring: String = ""
    var cellsize = CGSize(width: 75, height: 50)
    var labels = [UILabel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // the activity indicator was covered in testing, bring it to the front
        self.view.bringSubview(toFront: self.activityIndicator)
        
        self.view.sendSubview(toBack: self.PLTView)
        self.PLTView.isHidden = true
        
        // assign the view controller as the code lists delegate to do something when editing
        tv_codelist.delegate = self
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: "cell")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return labels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        
        cell.label = labels[indexPath.item]
        cell.contentView.addSubview(cell.label)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return cellsize
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 5.0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 2.0
    }
    
    // for typing in the plt codes, load the plt code "keyboard" view controller
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        textView.endEditing(true)
        self.view.bringSubview(toFront: PLTView)
        PLTView.isHidden = false
        
    }
    
    @IBAction func btn_ocr(_ sender: Any) {
        
            presentImagePicker()
    }
    
    @IBAction func btn_save(_ sender: Any) {
        
        
        let name: String = tf_name.text!.split(separator: ",").joined().split(separator: " ").joined() as String
        let ftn: String = tf_ftn.text!
        let testtype: String = tf_testtype.text!
        let codes: [String] = tv_codelist.text!.replacingOccurrences(of: ",", with: " ").replacingOccurrences(of: "  ", with: " ").components(separatedBy: " ")
        let path: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let outfile: String = name + "--" + (ftn != "" ? (ftn + "--") : "") + testtype + ".txt"
        l_outfile.text! = outfile
        
        outstring = "Name: " + tf_name.text! + "  FTN: " + tf_ftn.text! + "\n\n"
        
        if sc_switch.selectedSegmentIndex == 0 {
            formatDPE(codes: codes, outstring: &outstring)
        }
        else if sc_switch.selectedSegmentIndex == 1 {
            formatCFI(codes: codes, outstring: &outstring)
        }
        
        do {
            try outstring.write(toFile: path + "/" + outfile, atomically: false, encoding: String.Encoding.utf8)
            
        } catch{
            print("FAILED")
        }
    }
    
    @IBAction func btn_print(_ sender: Any) {
        
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
    
    @IBAction func btn_keypad(_ sender: UIButton) {
        
        if (plt1.text?.isEmpty)! {
            plt1.text = sender.currentTitle
        } else if (plt2.text?.isEmpty)! {
            plt2.text = sender.currentTitle
        } else {
            plt3.text = sender.currentTitle
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
        
        if !(plt1.text?.isEmpty)! && !(plt2.text?.isEmpty)! && !(plt3.text?.isEmpty)! {
            
            let indexPath = IndexPath(item: labels.count, section: 0)
            let code = "PLT" + plt1.text! + plt2.text! + plt3.text!
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: cellsize.width, height: cellsize.height))
            
            
            if Int(String(code.suffix(3)))! > 535 {
                
                let alert = UIAlertController(title: "Oops", message: "\(code) is not a valid PLT code", preferredStyle: UIAlertControllerStyle.alert)
                
                let close = UIAlertAction(title: "Close", style: .cancel, handler: nil)
                
                alert.addAction(close)
                
                // required for the ipad, tell the app where the image picker should appear on screen
                if let popoverController = alert.popoverPresentationController {
                    popoverController.sourceView = self.view
                    popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                    popoverController.permittedArrowDirections = []
                    
                }
                
                self.present(alert, animated:true, completion: nil)
                
            } else {
                label.text = code
                label.adjustsFontSizeToFitWidth = false
                label.font = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.medium)
                
                labels.append(label)
                collectionView.insertItems(at: [indexPath])
            }
            
            btn_clear(sender)
        }
    }
    
    // when done, reload the initial view controller
    @IBAction func btn_done(_ sender: UIButton) {
        
        btn_clear(sender)
        
        var codes = [String]()
        
        for index in 0..<labels.count {
            
            codes.append(labels[index].text! + " ")
            
        }
        
        tv_codelist.text = codes.joined()
        self.view.bringSubview(toFront: mainView)
        PLTView.isHidden = true
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
            outstring +=
                "Re-Train" + "     Validate" + "      Tested" + "\n" +
                "Date By" + "      Date By" + "      Date By" + "\n\n"
            
            
            // find the code in the file that matches the code entered by the user and add it to the output
            for code in codes {
                for pltcode in pltcodes {
                    let plt = pltcode.prefix(6)
                    
                    if (plt == code || plt == "PLT" + code || plt == "PLT0" + code || plt == "PLT00" + code)  {
                        outstring += "____ ____  ____ ____  ____ ____  " + pltcode + "\n\n\n"
                    }
                    
                }
            }
        } catch {
            
        }
    }
    
    func parseOCR(_ string: String) -> [String] {
        
        var originalString = string
        var codes = [String]()
        
        // loop while the string isn't empty and is large enough to contain a code
        while !originalString.isEmpty && originalString.count > 6{
           
            var parsedString = ""
            
            // if it starts with PLT then it's likely a proper code, grab it and remove it from the original string
            if originalString.hasPrefix("PLT") {
                parsedString.append(String(originalString.prefix(6)))
                originalString.removeSubrange(
                    originalString.startIndex..<originalString.index(originalString.startIndex, offsetBy: 6))
                
                // append the parsed PLT code to the code array
                codes.append(parsedString)
            } else {
                
                // remove the first element and look for the code again
                originalString.removeFirst()
            }
            
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
                    self.tv_codelist.text = self.parseOCR(tesseract.recognizedText).joined(separator: " ")
                    
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


























