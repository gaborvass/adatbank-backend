//
//  TeamObject.swift
//  GamebasicsTest
//
//  Created by Vass, Gabor on 17/09/15.
//  Copyright © 2015 Gabor, Vass. All rights reserved.
//

import Foundation

class TeamObject : Codable {

    // team's id
    let teamId : String

    // team's position
    var position : String?

    // team's name
    var teamName : String?
    
    // games played
    var played : String?
    
    // won
    var won : String?
    
    // drawn
    var drawn : String?
    
    // lost
    var lost: String?
    
    // goals scored
    var goalsFor : String?
    
    // goals scored against
    var goalsAgainst : String?
    
    // goal difference
    var goalDiff : String?
    
    // points
    var points : String?
    
    init(_ id : String) {
        teamId = id
    }
 
}

