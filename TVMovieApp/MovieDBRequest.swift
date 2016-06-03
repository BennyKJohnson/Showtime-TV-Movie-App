//
//  MovieDBRequest.swift
//  TVMovieApp
//
//  Created by Ben Johnson on 20/05/2016.
//  Copyright © 2016 CSCI342. All rights reserved.
//

import Foundation
import Alamofire

enum MovieDBRequest: URLRequestConvertible {
    
    case Search(query: String)
    
    case GetMovie(identifier: String, type: FilmType)
    
    case GetSeason(identifier: String, season: Int)
    
    static let  baseURL = NSURL(string: "https://api.themoviedb.org/3/")!
    
    static let imageBaseURL = "https://image.tmdb.org/t/p/w185"
    
    static let APIKey = "50aeadc8dc1f5c15525c77b278dacd73"
    
    var method: Alamofire.Method {
        return .GET
    }
    
    var path: String {
        switch self {
        case .Search:
            return "search/multi"
        case .GetMovie(let identifier, let type):
            return "\(type.rawValue)/\(identifier)"
        case .GetSeason(let identifier, let season):
            return "tv/\(identifier)/season/\(season)"

        }
    }
    
    var parameters:[String: AnyObject] {
        
        switch self {
        case .Search(let query):
            return ["api_key": MovieDBRequest.APIKey, "query": query]
        default:
            return ["api_key": MovieDBRequest.APIKey]
        }
    }
    
    var URLRequest: NSMutableURLRequest {
        let request = Alamofire.ParameterEncoding.URL.encode(NSMutableURLRequest(URL: MovieDBRequest.baseURL.URLByAppendingPathComponent(path)), parameters: parameters).0.mutableCopy() as! NSMutableURLRequest
        request.HTTPMethod = method.rawValue        
        return request
    }
}
