//
//  GetRoundsResponder.swift
//  backend
//
//  Created by Vass Gábor on 25/08/2017.
//
//

import Foundation
import HTTP

final class RoundsResponder {
 
    let dm : DataManager
    
    init(_ dataManager : DataManager) {
        dm = dataManager
    }
    
    func respond(_ request: Request) throws -> ResponseRepresentable {
        let seasonId = request.parameters["seasonId"]?.string
        let federationId = request.parameters["federationId"]?.string
        let leagueId = request.parameters["leagueId"]?.string
        return try Response.async({ (portal) in
            self.dm.getRounds(seasonId: seasonId, federationId: federationId, leagueId: leagueId, callback: { (rounds) in
                let jsonEncoder = JSONEncoder()
                let jsonData = try! jsonEncoder.encode(rounds)
                let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)!
                portal.close(with: jsonString)
            })
        })
    }
    
}
