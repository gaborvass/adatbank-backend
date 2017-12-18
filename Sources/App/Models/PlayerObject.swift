//
//  PlayerObject.swift
//  backend
//
//  Created by Vass Gábor on 13/08/2017.
//
//

import Foundation

class PlayerObject {
    
    let playerId: String
    var playerNum: String?
    var playerName: String?
    var playerTeam: String?
    var numberOfGoals: String?
    var numberOfYellowCards: String?
    var numberOfRedCards: String?

    init(_ id: String) {
        playerId = id
    }
}
