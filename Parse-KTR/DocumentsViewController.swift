//
//  DocumentsViewController.swift
//  Parse-KTR
//
//  Created by Austin Hill on 6/24/18.
//  Copyright © 2018 Austin Hill. All rights reserved.
//

import UIKit

class DocumentsViewController: UITableViewController, UIPopoverPresentationControllerDelegate {

    private var userDefaults = UserDefaults.standard
    
    var viewController: ViewController!
    
    var labels = [UILabel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.popoverPresentationController?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        darkMode(userDefaults.bool(forKey: "dark"))
        
        self.popoverPresentationController?.sourceRect = CGRect(x: self.viewController.view.bounds.midX, y: self.viewController.view.bounds.midY, width: 0, height: 0)
        
        //self.preferredContentSize = CGSize(width: 300, height: CGFloat(self.labels.count) + self.tableView.rowHeight)
        
        self.accessibilityFrame.size = CGSize(width: 300, height: CGFloat(self.labels.count) + self.tableView.rowHeight)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return labels.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        labels[indexPath.item].frame.size.height = self.tableView.rowHeight
        
        cell.addSubview(labels[indexPath.item])
        
        return cell
    }
    
    
    func darkMode(_ value: Bool) {
        
        if value {
            
            tableView.separatorColor = userDefaults.color(forKey: "tableViewCellSeperatorDark")
            
            for cell in self.tableView.visibleCells {
                
                cell.backgroundColor = userDefaults.color(forKey: "tableCellDark")
                
                for view in cell.contentView.subviews {
                    
                    if view is UILabel {
                        
                        view.backgroundColor = userDefaults.color(forKey: "labelDark")
                        (view as? UILabel)?.textColor = userDefaults.color(forKey: "labelTextDark")
                    }
                }
            }
            
        } else {
            
            tableView.separatorColor = userDefaults.color(forKey: "tableViewCellSeperatorLight")
            
            for cell in self.tableView.visibleCells {
                
                cell.backgroundColor = userDefaults.color(forKey: "tableCellLight")
                
                for view in cell.contentView.subviews {
                    
                    if view is UILabel {
                        
                        view.backgroundColor = userDefaults.color(forKey: "labelLight")
                        (view as? UILabel)?.textColor = userDefaults.color(forKey: "labelTextlight")
                    }
                }
            }
            
        }
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
