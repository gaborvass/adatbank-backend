//
//  DataParserProtocol.swift
//  backend
//
//  Created by Vass Gábor on 13/08/2017.
//
//

import Foundation

protocol DataParserProtocol {

    func parseSeasons(_ raw: String) -> Array<SeasonObject>

    func parseFederations(_ raw: String) -> Array<FederationObject>

    func parseLeagues(_ raw: String) -> Array<LeagueObject>

    func parseRounds(_ raw: String) -> Array<RoundObject>

    func parseMatches(_ raw: String) -> Array<MatchObject>
    
    func parsePenaltyCards(_ raw: String) -> Array<PlayerObject>

    func parseTopscorers(_ raw: String) -> Array<PlayerObject>

    func parseStandings(_ raw: String) -> Array<TeamObject>

    func parseMatchDetails(_ raw: String) -> Array<MatchDetailsObject>

}
