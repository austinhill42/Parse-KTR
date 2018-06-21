//
//  TableViewCell.swift
//  Parse-KTR
//
//  Created by Austin Hill on 6/21/18.
//  Copyright © 2018 Austin Hill. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if let viewController = parentViewController as? TableViewController {
        
            // hide the keyboard if it isn't the one being touched
            if touches.first?.view != viewController.viewController.keyboardViewController.view && viewController.viewController.keyboardShowing{
               
                viewController.viewController.hideKeyboard(0.75)
                
            }
        }
        
    }

}

extension UIView {
    
    var parentViewController: UIViewController? {
        
        var parentResponder: UIResponder? = self
        
        while parentResponder != nil {
           
            parentResponder = parentResponder!.next
            
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
