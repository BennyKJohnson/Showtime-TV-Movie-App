//
//  Formatter.swift
//  Showtime
//
//  Created by Benjamin Johnson on 29/05/2016.
//  Copyright © 2016 CSCI342. All rights reserved.
//

import Foundation

class Formatter {
    static let sharedFormatter = Formatter()
    
    let dateFormatter = NSDateFormatter()
    
    private init() {
        
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        
        
    }
}
