//
//  TVMClient.swift
//  TVMovieApp
//
//  Created by Ben Johnson on 20/05/2016.
//  Copyright © 2016 CSCI342. All rights reserved.
//

import Foundation
import Alamofire

enum FilmType {
    case Movie
    case Show
}

struct SearchResult {
    
    let name: String
    
    let posterURL: String
    
    let identifier: String
    
    let type: FilmType
    
}

enum TVMClientError: ErrorType {
    case Response(error:NSError)
    case InvalidData
    case ServerError
    
}


final class TVMClient {
    
    var tvdbAuthKey: String?
    
    var tvdbAuthExpiryDate: NSDate?
    
    let moviedbAuthKey: String = "50aeadc8dc1f5c15525c77b278dacd73"
    
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
    
    
    func query(query: String, completition: (results:[SearchResult], error: TVMClientError?) -> ()) {
        
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
                
                let dataArray = dictionary["data"] as! [[String: AnyObject]]
                
                let searchResults = dataArray.map({ (dictionary) -> SearchResult in
                    
                    let name = dictionary["seriesName"] as! String
                    
                    let posterURL = dictionary["banner"] as! String
                    
                    let id = "\(dictionary["id"] as! Int)"
                
                    
                    return SearchResult(name: name, posterURL: posterURL, identifier: id, type: .Show)
                    
                })
                
                completition(results: searchResults, error: nil)
                
            case .Failure(let error):
                print(error)
                completition(results: [], error: TVMClientError.Response(error: error))
                return
            }
            
        }
        
    }
    
    func getFilmDetail(searchResult: SearchResult, completition: (film: Film?, error: TVMClientError?) -> ()) {
        
        switch searchResult.type {
        case .Movie:
            // Send Request to MovieDB
            Alamofire.request(MovieDBRequest.GetMovie(identifier: searchResult.identifier)).responseJSON(completionHandler: { (response) in
                
                
                
                completition(film: nil, error: nil)
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
                
                completition(film: nil, error: nil)

            })
        }
    }
    
}