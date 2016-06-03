//
//  TVDBRequest.swift
//  TVMovieApp
//
//  Created by Ben Johnson on 20/05/2016.
//  Copyright © 2016 CSCI342. All rights reserved.
//

import Foundation
import Alamofire

enum TVDBRequest: URLRequestConvertible {
    
    case Auth
    
    case Search(query: String, authKey: String)
    
    case GetSeries(identifier: String, authKey: String)
    
    case GetEpisodes(identifier: String, authKey: String)
    
    static let  baseURL = NSURL(string: "https://api.thetvdb.com/")!
    
    static let bannerURL = "http://thetvdb.com/banners"
    
    static let APIKey = "39B1C9521E930A9C"
    
    var method: Alamofire.Method {
        switch self {
        case .Auth:
            return .POST
        default:
            return .GET
        }
    }
    
    var path: String {
        switch self {
        case .Search:
            return "search/series"
        case .Auth:
            return "login"
        case .GetSeries(let identifier):
            return "series/\(identifier)"
        case .GetEpisodes(let identifier):
            return "series/\(identifier)/episodes"
        }
    }
    
    var parameters:[String: AnyObject] {
        
        switch self {
        case .Search(let query, _):
            return ["name": query]
        case .Auth:
            return ["apikey": TVDBRequest.APIKey]
        default:
            return [:]
        }
    }
    
    var parameterEncoding: ParameterEncoding {
        switch self {
        case .Auth:
            return .JSON
        default:
            return .URL
        }
    }
    
    var headers: [String: String] {
        switch self {
        case .Auth:
            return [:]
        case .Search(_, let authKey):
            return ["Authorization": "Bearer \(authKey)"]
        case .GetSeries(_, let authKey):
            return ["Authorization": "Bearer \(authKey)"]
        case .GetEpisodes(_, let authKey):
            return ["Authorization": "Bearer \(authKey)"]
        }
    }
    
    var URLRequest: NSMutableURLRequest {
        let request = parameterEncoding.encode(NSMutableURLRequest(URL: TVDBRequest.baseURL.URLByAppendingPathComponent(path)), parameters: parameters).0.mutableCopy() as! NSMutableURLRequest
        request.HTTPMethod = method.rawValue
        
        // Set HTTP Headers
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        print(request.URLString)
        return request
    }
}

