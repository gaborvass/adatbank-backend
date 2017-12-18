//
//  LeagueObject.swift
//  backend
//
//  Created by Vass Gábor on 13/08/2017.
//
//

import Foundation

class LeagueObject : Codable {

    let leagueId: String
    var leagueName: String?
    
    init(_ id: String) {
        leagueId = id
    }
}

