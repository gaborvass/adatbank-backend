//
//  GetBasicDataResponder.swift
//  backend
//
//  Created by Vass Gábor on 25/08/2017.
//
//

import Foundation
import HTTP

final class BasicDataResponder {
    
    let dm : DataManager
    
    init(_ dataManager : DataManager) {
        dm = dataManager
    }
    
    func respond(_ request: Request) throws -> ResponseRepresentable {
        return try Response.async({ (portal) in
            self.dm.getBasicData({ (federations, seasons) in
                let jsonEncoder = JSONEncoder()
                let federationsData = try! jsonEncoder.encode(federations)
                let seasonsData = try! jsonEncoder.encode(seasons)
                let federationsString = String(data: federationsData, encoding: String.Encoding.utf8)!
                let seasonsString = String(data: seasonsData, encoding: String.Encoding.utf8)!

                portal.close(with: "{\"federations:\(federationsString), \"seasons\":\(seasonsString)}")
            })
        })
    }
    
}
