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
    static let airDateKey = "air_date"
    static let episodesKey = "episodes"
    static let seasonNumberKey = "season_number"
    static let episodeCountKey = "episode_count"
    static let episodeNumberKey = "episode_number"
    static let runtimeKey = "runtime"
}
