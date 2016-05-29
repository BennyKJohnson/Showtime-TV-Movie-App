//
//  TruncateTextView.swift
//  Showtime
//
//  Created by Benjamin Johnson on 29/05/2016.
//  Copyright © 2016 CSCI342. All rights reserved.
//

import UIKit

class TruncateTextView: UITextView {

    var content: String = "" {
        didSet {
          setContentAttributedString()
        }
        
    }
    
    var truncateCharacterLimit = 250
    
    var shouldTruncated: Bool = true {
        didSet {
            setContentAttributedString()
        }
    }
    
    var truncatedString: String {
        if shouldTruncated {
            if content.length > truncateCharacterLimit {
                return content[0...truncateCharacterLimit] + "..."
            }
        }
        
        return content
    }
    
    func setContentAttributedString() {
        
        if shouldTruncated {
            let contentAttributeString = NSMutableAttributedString(string: truncatedString + "more")
            contentAttributeString.addAttribute(NSLinkAttributeName, value: "showtime://more", range: NSRange(location: truncatedString.length, length: 4))
            self.attributedText = contentAttributeString

        } else {
            self.attributedText = nil
            self.text = truncatedString
        }

    }
    
    
}

