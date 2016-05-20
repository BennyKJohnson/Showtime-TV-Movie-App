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
    
    case GetMovie(identifier: String)
    
    static let  baseURL = NSURL(string: "https://api.themoviedb.org")!
    
    static let APIKey = "50aeadc8dc1f5c15525c77b278dacd73"
    
    var method: Alamofire.Method {
        return .GET
    }
    
    var path: String {
        switch self {
        case .Search:
            return "/search/keyword"
        case .GetMovie(let identifier):
            return "/movie/\(identifier)"
        }
    }
    
    var parameters:[String: AnyObject] {
        
        switch self {
        case .Search(let query):
            return ["api_key": MovieDBRequest.APIKey, "query": query]
        default:
            return [:]
        }
    }
    
    var URLRequest: NSMutableURLRequest {
        let request = Alamofire.ParameterEncoding.URL.encode(NSMutableURLRequest(URL: TVDBRequest.baseURL.URLByAppendingPathComponent(path)), parameters: parameters).0.mutableCopy() as! NSMutableURLRequest
        request.HTTPMethod = method.rawValue
        
        print(request.URLString)
        return request
    }
}
