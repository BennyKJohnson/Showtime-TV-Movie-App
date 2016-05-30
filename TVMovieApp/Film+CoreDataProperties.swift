//
//  Film+CoreDataProperties.swift
//  TVMovieApp
//
//  Created by Ben Johnson on 20/05/2016.
//  Copyright © 2016 CSCI342. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Film {

    @NSManaged var name: String
    @NSManaged var runtime: NSNumber?
    @NSManaged var releaseDate: NSDate?
    @NSManaged var overview: String
    @NSManaged var posterURL: String
    @NSManaged var rating: NSNumber
    @NSManaged var genre: String
    @NSManaged var identifier: String
    @NSManaged var status: NSNumber?
    @NSManaged var sectionTitle: String

}
