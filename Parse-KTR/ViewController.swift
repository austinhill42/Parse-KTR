//
//  ViewController.swift
//  Parse-KTR
//
//  Created by Austin Hill on 12/22/17.
//  Copyright © 2017 Austin Hill. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tf_name: UITextField!
    @IBOutlet weak var tf_ftn: UITextField!
    @IBOutlet weak var tf_testtype: UITextField!
    @IBOutlet weak var tf_codelist: UITextField!
    @IBOutlet weak var l_outfile: UITextView!
    @IBOutlet weak var sc_switch: UISegmentedControl!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var outstring: String = ""
    
    @IBAction func btn_ocr(_ sender: Any) {
        //view.endEditing(true)
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
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func formatDPE(codes: [String], outstring: inout String) {
        
        do {
            let pltpath: String = Bundle.main.path(forResource: "ALL_PLTS", ofType: "txt")!
            let pltcodes: [String] = try String(contentsOfFile: pltpath, encoding: String.Encoding.utf8).components(separatedBy: "\n")
            
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
    
    func formatCFI(codes: [String], outstring: inout String) {
        
        do {
            let pltpath: String = Bundle.main.path(forResource: "ALL_PLTS", ofType: "txt")!
            let pltcodes: [String] = try String(contentsOfFile: pltpath, encoding: String.Encoding.utf8).components(separatedBy: "\n")
            
            outstring += "Re-Train".padding(toLength: 11, withPad: " ", startingAt: 0) + "Validate".padding(toLength: 11, withPad: " ", startingAt: 0) + "Tested".padding(toLength: 11, withPad: " ", startingAt: 0) + "\n" + "Date By".padding(toLength: 11, withPad: " ", startingAt: 0) + "Date By".padding(toLength: 11, withPad: " ", startingAt: 0) + "Date By".padding(toLength: 11, withPad: " ", startingAt: 0) + "\n\n"
            
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
    
    func performImageRecognition(_ image: UIImage) {
        
        self.view.bringSubview(toFront: self.activityIndicator)
        activityIndicator.startAnimating()
        
        
        
        activityIndicator.stopAnimating()


    }
    
    func output(_ string: String) {
        
        l_outfile.text = string
    }

}

extension ViewController: UINavigationControllerDelegate {
    
}

extension ViewController: UIImagePickerControllerDelegate {

    func presentImagePicker() {
        
        let imagePickerActionSheet = UIAlertController(title: "Take/Upload Image", message: nil, preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraButton = UIAlertAction(title: "Take Photo",
                                             style: .default,
                                             handler: { (alert) ->Void in
                                                let imagePicker = UIImagePickerController()
                                                imagePicker.delegate = self
                                                imagePicker.sourceType = .camera
                                                self.present(imagePicker, animated: true)
            })
            imagePickerActionSheet.addAction(cameraButton)
        }
        
        let libraryButton = UIAlertAction(title: "Choose Existing",
                                          style: .default,
                                          handler: { (alert) -> Void in
                                            let imagePicker = UIImagePickerController()
                                            imagePicker.delegate = self
                                            imagePicker.sourceType = .photoLibrary
                                            self.present(imagePicker, animated: true)
        })
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel)
        
        
        imagePickerActionSheet.addAction(libraryButton)
        imagePickerActionSheet.addAction(cancelButton)
        
        if let popoverController = imagePickerActionSheet.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
            
        }
        
        self.present(imagePickerActionSheet, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        
        let scaledImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        dismiss(animated: true, completion: { self.performImageRecognition(scaledImage!)})
    }
    
}

extension UIImage {
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


























