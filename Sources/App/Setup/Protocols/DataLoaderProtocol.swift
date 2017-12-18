//
//  DataLoaderProtocol.swift
//  backend
//
//  Created by Vass Gábor on 13/08/2017.
//
//

import Foundation

protocol DataLoaderProtocol {

    func loadRawBasicData(success: @escaping (_: String) -> Void, failure: @escaping (_: Error) -> Void)
    
    func loadRawLeagues(seasonId: String!, federationId : String!, success: @escaping (_: String) -> Void, failure: @escaping (_: Error) -> Void)
    
    func loadRawRounds(seasonId: String!, federationId : String!, leagueId: String!, success: @escaping (_: String) -> Void, failure: @escaping (_: Error) -> Void)
    
    func loadRawResults(seasonId: String!, federationId : String!, leagueId: String!, roundId: String!, success: @escaping (_: String) -> Void, failure: @escaping (_: Error) -> Void)

    func loadRawStandings(seasonId: String!, federationId : String!, leagueId: String!, roundId: String!, success: @escaping (_: String) -> Void, failure: @escaping (_: Error) -> Void)

    func loadRawMatchDetails(matchId: String!, success: @escaping (_: String) -> Void, failure: @escaping (_: Error) -> Void)

    func loadRawPenaltyCards(seasonId: String!, federationId : String!, leagueId: String!, roundId: String!, success: @escaping (_: String) -> Void, failure: @escaping (_: Error) -> Void)

    func loadRawTopScorers(seasonId: String!, federationId : String!, leagueId: String!, roundId: String!, success: @escaping (_: String) -> Void, failure: @escaping (_: Error) -> Void)

}
