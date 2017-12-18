//
//  MatchObject.swift
//  GamebasicsTest
//
//  Created by Vass, Gabor on 17/09/15.
//  Copyright © 2015 Gabor, Vass. All rights reserved.
//

import Foundation

/**
 MatchObject
 */
class MatchObject : Codable {

	let matchId: String

	// home team
	var homeTeam: String?

	// away team
	var awayTeam: String?

	// home team goals
	var homeTeamGoals: String?

	// away team goals
	var awayTeamGoals: String?

    // home team logo
    var homeTeamLogoUrl: String?

    // away team logo
    var awayTeamLogoUrl: String?

	// match info
	var matchInfo: String?
    
    // match date
    var matchDate: String?
    
    // match time
    var matchTime: String?
    
	init(_ id: String) {
		matchId = id
	}
}

