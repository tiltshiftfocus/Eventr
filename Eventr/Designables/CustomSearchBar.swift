//
//  CustomSearchBar.swift
//  Eventr
//
//  Created by Jerry on 23/9/18.
//  Copyright © 2018 Jerry. All rights reserved.
//

import UIKit

@IBDesignable
class CustomSearchBar: UISearchBar {

    override func layoutSubviews() {
        super.layoutSubviews()
        
        let textFieldInsideSearchBar = self.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.white
    }

}
