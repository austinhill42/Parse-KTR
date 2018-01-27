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
    @IBOutlet weak var l_outfile: UILabel!
    
    @IBAction func btn_save(_ sender: Any) {
        
        let name: String = tf_name.text!.split(separator: ",").joined().split(separator: " ").joined() as String
        let ftn: String = tf_ftn.text!
        let testtype: String = tf_testtype.text!
        let path: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let outfile: String = path + "/" + name + "--" + (ftn != "" ? (ftn + "--") : "") + testtype + ".txt"
        l_outfile.text! = outfile
        
        var outstring: String = "Name: " + tf_name.text! + "  FTN: " + tf_ftn.text!
        var instring: String = ""
        do {
            try outstring.write(toFile: outfile, atomically: false, encoding: String.Encoding.utf8)
            instring = try String(contentsOfFile: outfile, encoding: String.Encoding.utf8)
            
        } catch{
            
        }
    
        print(instring)
    }
    
    @IBAction func btn_print(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

