//
//  Utils.swift
//  Eventr
//
//  Created by Jerry on 22/9/18.
//  Copyright © 2018 Jerry. All rights reserved.
//

import Foundation

class Utils {
    func isEqual<T: Equatable>(type: T.Type, a: Any, b: Any) -> Bool? {
        guard let a = a as? T, let b = b as? T else { return nil }
        
        return a == b
    }
}
