//
//  Show+CoreDataProperties.swift
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

extension Show {

    @NSManaged var airsDayOfWeek: String
    @NSManaged var airsTime: String
    @NSManaged var network: String
    @NSManaged var episodes: NSManagedObject?

}
