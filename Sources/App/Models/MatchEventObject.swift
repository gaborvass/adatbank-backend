//
//  MatchEventObject.swift
//  backend
//
//  Created by Vass Gábor on 05/09/2017.
//
//

import Foundation

class MatchEventObject {
    
    enum MatchEventType {
        case Goal
        case YellowCard
        case RedCard
        case Substitution
    }
    
    enum MatchEventTeam {
        case Home
        case Away
    }
    
    var minStr: String?
    var minInt: Int?
    var type: MatchEventType?
    var player1: String?
    var player2: String?
    var team: String?
    
}
