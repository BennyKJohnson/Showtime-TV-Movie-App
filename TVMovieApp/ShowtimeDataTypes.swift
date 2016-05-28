//
//  ShowtimeDataTypes.swift
//  Showtime
//
//  Created by Ben Johnson on 27/05/2016.
//  Copyright © 2016 CSCI342. All rights reserved.
//

import Foundation

enum FilmType: String {
    case Movie = "movie"
    case Show = "tv"
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
