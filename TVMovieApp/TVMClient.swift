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
    
    
    struct MovieDBPropertyKey {
        static let searchResultsKey = "results"
        static let titleKey = "title"
        static let nameKey = "name"
        static let identifierKey = "id"
        static let posterURLKey = "poster_path"
        static let overviewKey = "overview"
        static let ratingKey = "vote_average"
        static let releaseDateKey = "release_date"
        static let firstAirDateKey = "first_air_date"
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
    
    func getFilmDetail(searchResult: SearchResult, completition: (film: Film?, error: TVMClientError?) -> ()) {
        
        switch searchResult.type {
        case .Movie, .Show:
            // Send Request to MovieDB
            Alamofire.request(MovieDBRequest.GetMovie(identifier: searchResult.identifier, type: searchResult.type)).responseJSON(completionHandler: { (response) in
                
                guard let dictionary = response.result.value as? [String: AnyObject] else {
                    completition(film: nil, error: TVMClientError.InvalidData)
                    return
                }
                
                // Parse Dictionary
                let name: String
                let releaseDate:String

                switch searchResult.type {
                case .Movie:
                    name = dictionary[MovieDBPropertyKey.titleKey] as! String
                    releaseDate = dictionary[MovieDBPropertyKey.releaseDateKey] as! String
                case .Show:
                    name = dictionary[MovieDBPropertyKey.nameKey] as! String
                    releaseDate = dictionary[MovieDBPropertyKey.firstAirDateKey] as! String
                }
                
                let posterURL = MovieDBRequest.imageBaseURL + ((dictionary[MovieDBPropertyKey.posterURLKey] as? String) ?? "")
                
                let id = "\(dictionary[MovieDBPropertyKey.identifierKey] as! Int)"
                
                let genres = (dictionary["genres"] as! [[String: AnyObject]]).map({ (genre) -> String in
                    return genre["name"] as! String
                })
                
                
                
                
                // Create Film
                let film: Film
                
                switch searchResult.type {
                case .Movie:
                    let movieEntity = NSEntityDescription.entityForName("Movie", inManagedObjectContext: self.managedObjectContext)!
                    
                    let movie = Movie(entity: movieEntity, insertIntoManagedObjectContext: nil)
                    film = movie
                    
                case .Show:
                    let showEntity = NSEntityDescription.entityForName("Show", inManagedObjectContext: self.managedObjectContext)!
                    let show = Show(entity: showEntity, insertIntoManagedObjectContext: nil)
                    film = show
                }
                
                film.identifier = id
                film.posterURL = MovieDBRequest.imageBaseURL + posterURL
                film.name = name
                film.overview = dictionary[MovieDBPropertyKey.overviewKey] as! String
                film.rating = dictionary[MovieDBPropertyKey.ratingKey] as! NSNumber
                film.genre = genres.first ?? "Unknown"
                film.releaseDate = self.RFC3339DateFormatter.dateFromString(releaseDate)!
                
                
                
                completition(film: film, error: nil)
            })
            
            
        case .Show:
            
            guard let authKey = tvdbAuthKey else {
                getTVDBAuthKey({ (authKey, error) in
                    if let authKey = authKey {
                        // Set TVDB Auth Key
                        self.tvdbAuthKey = authKey
                        // Recall query
                        self.getFilmDetail(searchResult, completition: completition)
                    } else {
                        completition(film: nil, error: TVMClientError.ServerError)
                    }
                    
                })
                return 
            }
            
            // Send Request to ShowDB
            Alamofire.request(TVDBRequest.GetSeries(identifier: searchResult.identifier, authKey: authKey)).responseJSON(completionHandler: { (response) in
                
                guard let dictionary = response.result.value as? [String: AnyObject] else {
                    completition(film: nil, error: nil)
                    return
                }
                
                
                if let error = dictionary["Error"] as? String {
                    completition(film: nil, error: TVMClientError.ServerError)
                    print(error)
                }
                if let data = dictionary["data"] as? [String: AnyObject] {
                   
                    // Create TV Show
                    let showEntity = NSEntityDescription.entityForName("Show", inManagedObjectContext: self.managedObjectContext)!
                    
                    let show = Show(entity: showEntity, insertIntoManagedObjectContext: nil)
                    show.name = data["seriesName"] as! String
                    show.identifier = data["seriesId"] as! String
                    show.releaseDate = NSDate()
                    show.rating = data["siteRating"] as! NSNumber
                    show.posterURL = TVDBRequest.bannerURL + (data["banner"] as! String)
                    show.overview = data["overview"] as! String
                    show.genre = (data["genre"] as! [String]).first!
                    show.network = data["network"] as! String
                    show.airsDayOfWeek = data["airsDayOfWeek"] as! String
                    show.airsTime = data["airsTime"] as! String
                    show.runtime = NSNumber(integer: Int(data["runtime"] as! String)!)

                    
                    completition(film: show, error: nil)
                    return
                } else {
                    completition(film: nil, error: nil)

                }

            })
        }
    }
    
}