//
//  DataManager.swift
//  backend
//
//  Created by Vass Gábor on 13/08/2017.
//
//

import Foundation

class DataManager {
    
    let dataParserImpl : DataParserProtocol
    let dataLoaderImpl : DataLoaderProtocol
    
    init(dataLoader: DataLoaderProtocol, dataParser: DataParserProtocol) {
        dataLoaderImpl = dataLoader
        dataParserImpl = dataParser
    }
    
    func getFederations(_ callback: @escaping (Array<FederationObject>) -> Void) {
        dataLoaderImpl.loadRawBasicData(success: { (raw ) in
            callback(self.dataParserImpl.parseFederations(raw))
        }) { (error) in
            callback(Array())
        }
    }
    
    func getSeasons(_ callback: @escaping (Array<SeasonObject>) -> Void) {
        dataLoaderImpl.loadRawBasicData(success: { (raw ) in
            callback(self.dataParserImpl.parseSeasons(raw))
        }) { (error) in
            callback(Array())
        }
    }
    
    func getBasicData(_ callback: @escaping (Array<FederationObject>, Array<SeasonObject>) -> Void) {
        dataLoaderImpl.loadRawBasicData(success: { (raw ) in
            let federations = self.dataParserImpl.parseFederations(raw)
            let seasons = self.dataParserImpl.parseSeasons(raw)
            callback(federations, seasons)
        }) { (error) in
            callback(Array(), Array())
        }
    }
    
    func getLeagues(seasonId: String!, federationId: String!, callback: @escaping (Array<LeagueObject>) -> Void) {
        dataLoaderImpl.loadRawLeagues(seasonId: seasonId, federationId: federationId, success: { (raw) in
            callback(self.dataParserImpl.parseLeagues(raw))
        }) { (error) in
            callback(Array())
        }
    }
    
    func getRounds(seasonId: String!, federationId: String!, leagueId: String!, callback: @escaping (Array<RoundObject>) -> Void) {
        dataLoaderImpl.loadRawRounds(seasonId: seasonId, federationId: federationId, leagueId: leagueId, success: { (raw) in
            callback(self.dataParserImpl.parseRounds(raw))
        }) { (error) in
            callback(Array())
        }
    }
    
    func getResults(seasonId: String!, federationId: String!, leagueId: String!, roundId: String!, callback: @escaping (Array<MatchObject>) -> Void) {
        dataLoaderImpl.loadRawResults(seasonId: seasonId, federationId: federationId, leagueId: leagueId, roundId: roundId, success: { (raw) in
            callback(self.dataParserImpl.parseMatches(raw))
        }) { (error) in
            callback(Array())
        }
    }

    func getStandings(seasonId: String!, federationId: String!, leagueId: String!, roundId: String!, callback: @escaping (Array<TeamObject>) -> Void) {
        dataLoaderImpl.loadRawStandings(seasonId: seasonId, federationId: federationId, leagueId: leagueId, roundId: roundId, success: { (raw) in
            callback(self.dataParserImpl.parseStandings(raw))
        }) { (error) in
            callback(Array())
        }
    }

    func getPenaltyCards(seasonId: String!, federationId: String!, leagueId: String!, roundId: String!, callback: @escaping (Array<PlayerObject>) -> Void) {
        dataLoaderImpl.loadRawPenaltyCards(seasonId: seasonId, federationId: federationId, leagueId: leagueId, roundId: roundId, success: { (raw) in
            callback(self.dataParserImpl.parsePenaltyCards(raw))
        }) { (error) in
            callback(Array())
        }
    }

    func getTopScorers(seasonId: String!, federationId: String!, leagueId: String!, roundId: String!, callback: @escaping (Array<PlayerObject>) -> Void) {
        dataLoaderImpl.loadRawTopScorers(seasonId: seasonId, federationId: federationId, leagueId: leagueId, roundId: roundId, success: { (raw) in
            callback(self.dataParserImpl.parseTopscorers(raw))
        }) { (error) in
            callback(Array())
        }
    }

}
