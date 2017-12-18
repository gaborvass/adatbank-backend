//
//  MatchDetailsObject.swift
//  backend
//
//  Created by Vass Gábor on 13/08/2017.
//
//

import Foundation

class MatchDetailsObject {
    
    let matchId : String
    var matchDate: String?
    var matchLocation: String?
    
    var halfTimeResult: String?
    
    var matchEvents: Array<MatchEventObject>? = Array<MatchEventObject>()
    var matchHomeTeam: MatchTeamObject?
    var matchAwayTeam: MatchTeamObject?
    
    init(_ id : String) {
        matchId = id
    }
}

