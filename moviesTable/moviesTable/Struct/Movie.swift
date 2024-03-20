//
//  Movie.swift
//  moviesTable
//
//  Created by Jurymar Colmenares on 19/03/24.
//

import Foundation

struct Movie: Codable {
    let title: String
    let posterPath: String
    
    private enum CodingKeys: String, CodingKey {
        case title
        case posterPath = "poster_path"
    }
}
