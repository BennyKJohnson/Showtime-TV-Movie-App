//
//  Extensions.swift
//  TVMovieApp
//
//  Created by Ben Johnson on 27/05/2016.
//  Copyright © 2016 CSCI342. All rights reserved.
//

import Foundation

extension String {
    var length: Int {
        return characters.count
    }
}

extension String {
    
    subscript (i: Int) -> Character {
        return self[self.startIndex.advancedBy(i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        let start = startIndex.advancedBy(r.startIndex)
        let end = start.advancedBy(r.endIndex - r.startIndex)
        return self[Range(start ..< end)]
    }
}

extension NSDate {
    
    var stringFormat: String? {
        
        return Formatter.sharedFormatter.dateFormatter.stringFromDate(self)
        
    }

 
}

// http://stackoverflow.com/questions/26198526/nsdate-comparison-using-swift
extension NSDate: Comparable { }

public func ==(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs === rhs || lhs.compare(rhs) == .OrderedSame
}

public func <(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == .OrderedAscending
}
