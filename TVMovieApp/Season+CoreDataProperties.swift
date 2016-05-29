//
//  Season+CoreDataProperties.swift
//  Showtime
//
//  Created by Benjamin Johnson on 29/05/2016.
//  Copyright © 2016 CSCI342. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Season {

    @NSManaged var identifier: String?
    @NSManaged var name: String?
    @NSManaged var overview: String?
    @NSManaged var airDate: NSDate?
    @NSManaged var number: NSNumber
    @NSManaged var episodeCount: NSNumber?
    @NSManaged var posterURL: String?
    @NSManaged var episodes: NSOrderedSet?
    @NSManaged var show: Show?

}
