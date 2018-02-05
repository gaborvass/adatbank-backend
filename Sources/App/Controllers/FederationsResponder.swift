//
//  GetFederationsResponder.swift
//  backend
//
//  Created by Vass Gábor on 25/08/2017.
//
//

import Foundation
import HTTP

final class FederationsResponder {

    let dm : DataManager
    
    init(_ dataManager : DataManager) {
        dm = dataManager
    }
    
    func respond(_ request: Request) throws -> ResponseRepresentable {
        return try Response.async({ (portal) in
            self.dm.getFederations({ (federations) in
                let jsonEncoder = JSONEncoder()
                let jsonData = try! jsonEncoder.encode(federations)
                let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)!
                portal.close(with: jsonString)
            })
        })
    }
    
}
