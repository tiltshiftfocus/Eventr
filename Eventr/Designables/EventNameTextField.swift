//
//  EventNameTextField.swift
//  Eventr
//
//  Created by Jerry on 23/9/18.
//  Copyright © 2018 Jerry. All rights reserved.
//

import UIKit

@IBDesignable
class EventNameTextField: UITextField {

    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.borderColor = UIColor(white: 1, alpha: 1).cgColor
        self.layer.borderWidth = 1
        
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 8, dy: 7)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }

}
