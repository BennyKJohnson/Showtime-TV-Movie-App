//
//  TVMClient.swift
//  TVMovieApp
//
//  Created by Ben Johnson on 20/05/2016.
//  Copyright © 2016 CSCI342. All rights reserved.
//

import Foundation
import Alamofire
import CoreData




final class ShowtimeClient {
    
    var tvdbAuthKey: String?
    
    var tvdbAuthExpiryDate: NSDate?
    
    let managedObjectContext: NSManagedObjectContext
    
    let moviedbAuthKey: String = "50aeadc8dc1f5c15525c77b278dacd73"
    
    let RFC3339DateFormatter: NSDateFormatter = NSDateFormatter()
    
    init(context: NSManagedObjectContext) {
        
        self.managedObjectContext = context
        
        // Setup dateFormatter
        RFC3339DateFormatter.dateFormat = "yyyy-MM-dd"
        
        
    }
    
    func getTVDBAuthKey(completition: (authKey: String?, error: TVMClientError?) -> ()) {
     
        Alamofire.request(TVDBRequest.Auth).responseJSON { (response) in
            
            switch response.result {
            case .Success:
                print("Validation Successful")
                
                if let dictionary = response.result.value as? [String: AnyObject] {
                    
                    let authKey = dictionary["token"] as! String
                    completition(authKey: authKey, error: nil)
                
                } else {
                    completition(authKey: nil, error: TVMClientError.InvalidData)
                }
                
            case .Failure(let error):
                completition(authKey: nil, error: TVMClientError.Response(error: error))
            }
            
        }
    }
    
    func queryMovie(query: String, completition: (results:[SearchResult]?, error: TVMClientError?) -> ()) {
        
        Alamofire.request(MovieDBRequest.Search(query: query)).responseJSON { (response) in
        
            switch response.result {
            case .Success:
            
                guard let dictionary = response.result.value as? [String: AnyObject] else {
                    completition(results: [], error: TVMClientError.InvalidData)
                    return
                }
                
                if let results = dictionary[MovieDBPropertyKey.searchResultsKey] as? [[String: AnyObject]] {
                    
                    let filmResults = results.filter({ (dictionary) -> Bool in
                        let mediaType = dictionary["media_type"] as! String
                        
                        switch mediaType {
                        case "movie", "tv":
                            return true
                        default:
                            return false
                        }
                        
                    })
                    
                    let searchResults = filmResults.map({ (dictionary) -> SearchResult in
                        
                        let filmType = FilmType(rawValue: dictionary["media_type"] as! String)!
                        let name: String
                        switch filmType {
                            case .Movie:
                                name = dictionary[MovieDBPropertyKey.titleKey] as! String
                            case .Show:
                                name = dictionary[MovieDBPropertyKey.nameKey] as! String
                        }
                        
                        let posterURL = MovieDBRequest.imageBaseURL + ((dictionary[MovieDBPropertyKey.posterURLKey] as? String) ?? "")
                        
                        let id = "\(dictionary[MovieDBPropertyKey.identifierKey] as! Int)"
                        
                        
                        return SearchResult(name: name, posterURL: posterURL, identifier: id, type: filmType)
                        
                    })
                    
                    completition(results: searchResults, error: nil)
                    
                } else {
                    completition(results: nil, error: TVMClientError.InvalidData)
                }
                
            case .Failure(let error):
                print(error)
                completition(results: nil, error: TVMClientError.Response(error: error))
                return
            }
        }
    }
    
    
    func query(query: String, completition: (results:[SearchResult]?, error: TVMClientError?) -> ()) {
        
        guard let authKey = tvdbAuthKey else {
            getTVDBAuthKey({ (authKey, error) in
                if let authKey = authKey {
                    // Set TVDB Auth Key
                    self.tvdbAuthKey = authKey
                    // Recall query
                    self.query(query, completition: completition)
                } else {
                    completition(results: [], error: TVMClientError.ServerError)
                }
             
            })
            return 
        }
        
        Alamofire.request(TVDBRequest.Search(query: query, authKey: authKey)).responseJSON { (response) in
            
            switch response.result {
            case .Success:
                print("Validation Successful")
                
                guard let dictionary = response.result.value as? [String: AnyObject] else {
                    completition(results: [], error: TVMClientError.InvalidData)
                    return
                }
                
                if let error = dictionary["Error"] as? String {
                    completition(results: [], error: TVMClientError.ServerError)
                    print(error)
                }
                
                if let dataArray = dictionary["data"] as? [[String: AnyObject]] {
                    let searchResults = dataArray.map({ (dictionary) -> SearchResult in
                        
                        let name = dictionary["seriesName"] as! String
                        
                        let posterURL = TVDBRequest.baseURL.absoluteString + (dictionary["banner"] as! String)
                        
                        let id = "\(dictionary["id"] as! Int)"
                        
                        
                        return SearchResult(name: name, posterURL: posterURL, identifier: id, type: .Show)
                        
                    })
                    
                    completition(results: searchResults, error: nil)
                }
                else {
                    completition(results: [], error: nil)
                }
                
              
                
            case .Failure(let error):
                print(error)
                completition(results: [], error: TVMClientError.Response(error: error))
                return
            }
            
        }
        
    }
    
    func parseEpisode(dictionary: [String: AnyObject]) -> Episode {
        
        let episodeEntity = NSEntityDescription.entityForName("Episode", inManagedObjectContext: self.managedObjectContext)!
        
        let episode = Episode(entity: episodeEntity, insertIntoManagedObjectContext: managedObjectContext)
        
        episode.name = dictionary[MovieDBPropertyKey.nameKey] as? String
        
        if let airDate = dictionary[MovieDBPropertyKey.airDateKey] as? String {
            episode.airDate = self.RFC3339DateFormatter.dateFromString(airDate)
        }
        
        episode.seasonNumber = dictionary[MovieDBPropertyKey.seasonNumberKey] as? NSNumber
        episode.episodeNumber = dictionary[MovieDBPropertyKey.episodeNumberKey] as? NSNumber
        episode.identifier = "\(dictionary[MovieDBPropertyKey.identifierKey] as! NSNumber)"
        
        return episode
    }
    
    func getSeasonForShowWithIdentifier(showIdentifier: String, season: Season, completition: (season: Season?, error: TVMClientError?) -> ()) {
        
        Alamofire.request(MovieDBRequest.GetSeason(identifier: showIdentifier, season: season.number.integerValue)).responseJSON { (response) in
        
            guard let dictionary = response.result.value as? [String: AnyObject] else {
                completition(season: nil, error: TVMClientError.InvalidData)
                return
            }
            
            let airDate = dictionary[MovieDBPropertyKey.airDateKey] as! String
            let name = dictionary[MovieDBPropertyKey.nameKey] as! String
            let identifier = dictionary[MovieDBPropertyKey.identifierKey] as! NSNumber
            let episodesDictionary = dictionary[MovieDBPropertyKey.episodesKey] as! [[String: AnyObject]]
            
            // Get Episodes
            let episodes = episodesDictionary.map({ (episodeDictionary) -> Episode in
                return self.parseEpisode(episodeDictionary)
            })
            
            // Set Episode Season
            for episode in episodes {
                episode.season = season
            }
            
            // Set Properties
            season.airDate = self.RFC3339DateFormatter.dateFromString(airDate)
            season.name = name
            season.identifier = "\(identifier)"
            season.episodes = NSOrderedSet(array: episodes)
            season.number = dictionary[MovieDBPropertyKey.seasonNumberKey] as! NSNumber

            // Set Overview
            if let overview = dictionary[MovieDBPropertyKey.overviewKey] as? String where !overview.isEmpty {
                season.overview = overview
            }
            
            completition(season: season, error: nil)
        }
    }
    
    func parseMovie(dictionary: [String: AnyObject]) -> Movie {
        
        let name = dictionary[MovieDBPropertyKey.titleKey] as! String
        let releaseDate = dictionary[MovieDBPropertyKey.releaseDateKey] as! String
        
        let posterURL = MovieDBRequest.imageBaseURL + ((dictionary[MovieDBPropertyKey.posterURLKey] as? String) ?? "")
        
        let id = "\(dictionary[MovieDBPropertyKey.identifierKey] as! Int)"
        
        let genres = (dictionary["genres"] as! [[String: AnyObject]]).map({ (genre) -> String in
            return genre["name"] as! String
        })
        
        let film: Film

        let movieEntity = NSEntityDescription.entityForName("Movie", inManagedObjectContext: self.managedObjectContext)!
        
        let movie = Movie(entity: movieEntity, insertIntoManagedObjectContext: self.managedObjectContext)
        film = movie
        
        film.identifier = id
        film.posterURL = MovieDBRequest.imageBaseURL + posterURL
        film.name = name
        film.overview = dictionary[MovieDBPropertyKey.overviewKey] as! String
        film.rating = dictionary[MovieDBPropertyKey.ratingKey] as! NSNumber
        film.genre = genres.first ?? "Unknown"
        film.releaseDate = self.RFC3339DateFormatter.dateFromString(releaseDate)!
        film.runtime = dictionary[MovieDBPropertyKey.runtimeKey] as? NSNumber
        film.sectionTitle = "Movies"

        
        return movie
    }
    
    func parseShow(dictionary: [String: AnyObject]) -> Show {
        
        let name = dictionary[MovieDBPropertyKey.nameKey] as! String
        let releaseDate = dictionary[MovieDBPropertyKey.firstAirDateKey] as! String
        let posterURL = MovieDBRequest.imageBaseURL + ((dictionary[MovieDBPropertyKey.posterURLKey] as? String) ?? "")
        
        let id = "\(dictionary[MovieDBPropertyKey.identifierKey] as! Int)"
        
        let genres = (dictionary["genres"] as! [[String: AnyObject]]).map({ (genre) -> String in
            return genre["name"] as! String
        })
        
        let networks = (dictionary["networks"] as! [[String: AnyObject]]).map({ (network) -> String in
            return network["name"] as! String
        })
        
        let runtimes = dictionary["episode_run_time"] as! [NSNumber]
        
        // Parse Seasons
        let seasons = (dictionary["seasons"] as! [[String: AnyObject]]).map({ (seasonDictionary) -> Season in
            
            let identifier = seasonDictionary[MovieDBPropertyKey.identifierKey] as! NSNumber
            let posterURL: String?
            if let relativePosterURL = seasonDictionary[MovieDBPropertyKey.posterURLKey] as? String {
                posterURL = MovieDBRequest.imageBaseURL + relativePosterURL
            } else {
                posterURL = nil
            }
            
            // Create Season
            let seasonEntity = NSEntityDescription.entityForName("Season", inManagedObjectContext: self.managedObjectContext)!
            let season = Season(entity: seasonEntity, insertIntoManagedObjectContext: managedObjectContext)
            if let airDate = seasonDictionary[MovieDBPropertyKey.airDateKey] as? String {
                season.airDate = RFC3339DateFormatter.dateFromString(airDate)
            }
            season.episodeCount = seasonDictionary[MovieDBPropertyKey.episodeCountKey] as? NSNumber
            season.number = seasonDictionary[MovieDBPropertyKey.seasonNumberKey] as! NSNumber
            season.identifier = "\(identifier)"
            season.posterURL = posterURL
        
            return season
            
        })
        
        
        
        let film: Film
        let showEntity = NSEntityDescription.entityForName("Show", inManagedObjectContext: self.managedObjectContext)!
        let show = Show(entity: showEntity, insertIntoManagedObjectContext: managedObjectContext)
        show.seasons = NSOrderedSet(array: seasons)
        show.network = networks.first
        film = show

        film.identifier = id
        film.posterURL = MovieDBRequest.imageBaseURL + posterURL
        film.name = name
        film.overview = dictionary[MovieDBPropertyKey.overviewKey] as! String
        film.rating = dictionary[MovieDBPropertyKey.ratingKey] as! NSNumber
        film.genre = genres.first ?? "Unknown"
        film.releaseDate = self.RFC3339DateFormatter.dateFromString(releaseDate)!
        film.runtime = runtimes.first
        film.sectionTitle = "TV Shows"
        
        return show
    }
    
    
    func getFilmDetail(searchResult: SearchResult, completition: (film: Film?, error: TVMClientError?) -> ()) {
        
        switch searchResult.type {
        case .Movie, .Show:
            // Send Request to MovieDB
            Alamofire.request(MovieDBRequest.GetMovie(identifier: searchResult.identifier, type: searchResult.type)).responseJSON(completionHandler: { (response) in
                
                guard let dictionary = response.result.value as? [String: AnyObject] else {
                    completition(film: nil, error: TVMClientError.InvalidData)
                    return
                }
                
            
                switch searchResult.type {
                case .Movie:
                    let movie =  self.parseMovie(dictionary)
                    completition(film: movie, error: nil)

                case .Show:
                    let show = self.parseShow(dictionary)
                    
                    // Get Season
                    if let lastSeason = show.showSeasons.last {
                        
                        self.getSeasonForShowWithIdentifier(show.identifier, season: lastSeason) { (season, error) in
                            
                            // Call completition
                            completition(film: show, error: nil)
                            
                        }
                        
                    }
                    
                }
                
            })
            
        }
    }

}