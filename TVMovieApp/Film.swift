//
//  Film.swift
//  TVMovieApp
//
//  Created by Ben Johnson on 20/05/2016.
//  Copyright © 2016 CSCI342. All rights reserved.
//

import Foundation
import CoreData


class Film: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    /*
    var sectionTitle: String {
        if let movie = self as? Movie {
            return "Movies"
        } else {
            return "TV Shows"
        }
    }
    */
    var hasBeenReleased: Bool {
        if let releaseDate = releaseDate {
            return NSDate() >= releaseDate
        }
        return false
    }
}
