//
//  FilmNotification.swift
//  Showtime
//
//  Created by Phizo on 30/05/2016.
//  Copyright © 2016 CSCI342. All rights reserved.
//

import Foundation
import UIKit

struct FilmNotification {
    let name:        String
    let message:     String
    let action:      String
    let releaseDate: NSDate
 
}

protocol NotificationSystemDelegate {
    func failedToScheduleNotification()
}

struct NotificationSystem {
    let films:    [Film]
    var delegate: NotificationSystemDelegate!
    
    // Notification system functionality.
    func scheduleNotifications() {
        // Setup notification system.
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
        
        for film in films {
            // Schedule notification for movie.
            if film is Movie {
                let notification = FilmNotification(name: film.name, message: "is out now!", action: "movie", releaseDate: film.releaseDate!)
                scheduleFilmForNotification(notification)
                
                // Schedule notifications for the upcoming season and its episodes.
            } else if film is Show {
                let show         = film as! Show
                let nextSeason   = show.showSeasons.last!
                let notification = FilmNotification(name: film.name, message: "- new season out now!", action: "season", releaseDate: nextSeason.airDate!)
                
                scheduleFilmForNotification(notification)
                
                // Schedule notifications for episodes in the upcoming season.
                for episode in nextSeason.seasonEpisodes where episode.airDate != nil {
                    let notification = FilmNotification(name: film.name, message: "- new episode out now!", action: "episode", releaseDate: episode.airDate!)
                    scheduleFilmForNotification(notification)
                }
            } else {
                print("Error: film type not supported.")
            }
        }
    }
    
    func scheduleFilmForNotification(notifyObject: FilmNotification) {
        // If the release date is before now, then there's no reason to schedule a notification.
        if notifyObject.releaseDate < NSDate() {
            return
        }
        
        let settings = UIApplication.sharedApplication().currentUserNotificationSettings()
        
        if settings!.types == .None {
            delegate?.failedToScheduleNotification()
        }
        
        let notification = UILocalNotification()
        
        notification.fireDate    = notifyObject.releaseDate    // NSDate(timeIntervalSinceNow: 5)
        notification.alertBody   = "\(notifyObject.name) \(notifyObject.message)"
        notification.alertAction = notifyObject.action
        notification.soundName   = UILocalNotificationDefaultSoundName
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
}