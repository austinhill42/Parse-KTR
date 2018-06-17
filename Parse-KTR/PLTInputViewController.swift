//
//  PLTInputViewController.swift
//  Parse-KTR
//
//  Created by Austin Hill on 6/10/18.
//  Copyright © 2018 Austin Hill. All rights reserved.
//


/* Each key has an individual tag according to: tag = (10 * group number) + button number
   so the button number = tag - (10 * group number) */


import UIKit

class PLTInputViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var plt1: UITextView!
    @IBOutlet weak var plt2: UITextView!
    @IBOutlet weak var plt3: UITextView!
    @IBOutlet weak var collectionView: UICollectionView!
    var viewController: ViewController = ViewController()
    var cellsize = CGSize(width: 75, height: 50)
    var labels = [UILabel]()
    
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
        //print("\n\n\n***  " + (cell?.label.text)! + " ***\n\n\n")
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.collectionView.backgroundColor = UIColor(red: 149, green: 191, blue: 255, alpha: 1)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: "cell")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // enter the number pressed by the user on the keypad
    @IBAction func btn_keypad(_ sender: UIButton) {
        
        if plt1.text.isEmpty {
            plt1.text = sender.currentTitle
        } else if plt2.text.isEmpty {
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
        
        if !plt3.text.isEmpty {
            plt3.text = ""
        } else if !plt2.text.isEmpty {
            plt2.text = ""
        } else if !plt1.text.isEmpty {
            plt1.text = ""
        }
    }
    
    // add the PLT code entered by the user to the list of PLT codes
    @IBAction func btn_enter(_ sender: UIButton) {
        
        if !plt1.text.isEmpty && !plt2.text.isEmpty && !plt3.text.isEmpty {
            
            let indexPath = IndexPath(item: labels.count, section: 0)
            let code = "PLT" + plt1.text + plt2.text + plt3.text
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
                //collectionView.cellForItem(at: indexPath)?.contentView.addSubview(label)
            }
            
            btn_clear(sender)
        }
    }
    
    // when done, reload the initial view controller
    @IBAction func btn_done(_ sender: UIButton) {
        
        for index in 0..<labels.count {
            
            //let indexPath = IndexPath(item: index, section: 0)
            //let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewCell
            //let label = cell?.label
            //print("\n\n** " + (label?.text!)! + " **\n\n")
            viewController.tf_codelist.text.append(labels[index].text! + " ")
            
        }
        
        // get the main storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // get the initial view controller
        let controller = storyboard.instantiateInitialViewController()
        
        // load the initial view controller
        self.present(controller!, animated: true, completion: nil)
    }
    
}
