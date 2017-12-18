//
//  GetLeaguesResponder.swift
//  backend
//
//  Created by Vass Gábor on 25/08/2017.
//
//

import Foundation
import HTTP

final class GetLeaguesResponder {

    let dm : DataManager
    
    init(_ dataManager : DataManager) {
        dm = dataManager
    }
    
    func respond(_ request: Request) throws -> ResponseRepresentable {
        let seasonId = request.parameters["seasonId"]?.string
        let federationId = request.parameters["federationId"]?.string
        return try Response.async({ (portal) in
            self.dm.getLeagues(seasonId: seasonId, federationId: federationId, callback: { (leagues) in
                let jsonEncoder = JSONEncoder()
                let jsonData = try! jsonEncoder.encode(leagues)
                let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)!
                portal.close(with: jsonString)
            })
        })
    }
    
}
