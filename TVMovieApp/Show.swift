//
//  Show.swift
//  TVMovieApp
//
//  Created by Ben Johnson on 20/05/2016.
//  Copyright © 2016 CSCI342. All rights reserved.
//

import Foundation
import CoreData


class Show: Film {

// Insert code here to add functionality to your managed object subclass

    var showSeasons: [Season] {
        return seasons?.array as? [Season] ?? []
    }
    
    var seasonsCount: Int {
        return showSeasons.count
    }
    
    var lastEpisodeToAir: Episode? {
        
        var currentEpisode: Episode?
        
        for episode in showSeasons.last?.seasonEpisodes ?? [] {
            
            let episodeAir = episode.airDate
            
            if(episodeAir < NSDate())
            {
                currentEpisode = episode
                
            }
            
        }
        
        
        return currentEpisode
    }
    
    var nextEpisodeAirDate: NSDate? {
        
        let date = NSDate()
        if let releaseDate = releaseDate {
            
            if !hasBeenReleased {
                return releaseDate
            } else {
                
                // Has already been release
                if let lastSeason = showSeasons.last {
                    if let seasonReleaseDate = lastSeason.airDate {

                        if  date <= seasonReleaseDate {
                            // Latest Season hasn't started
                            return seasonReleaseDate
                        } else {
                            
                            // Season has already started
                            // Get the next episode to air
                            for episode in lastSeason.seasonEpisodes where !episode.hasAired {
                                return episode.airDate!
                            }
                            
                        }
                        
                        
                    }
                }
            }
            
        }
        
        return nil
    }
}
