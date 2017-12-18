//
//  GetSeasonsResponder.swift
//  backend
//
//  Created by Vass Gábor on 25/08/2017.
//
//

import Foundation
import HTTP

final class GetSeasonsResponder {
    
    let dm : DataManager
    
    init(_ dataManager : DataManager) {
        dm = dataManager
    }
    
    func respond(_ request: Request) throws -> ResponseRepresentable {
        return try Response.async({ (portal) in
            self.dm.getSeasons({ (seasons) in
                let jsonEncoder = JSONEncoder()
                let jsonData = try! jsonEncoder.encode(seasons)
                let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)!
                portal.close(with: jsonString)
            })
        })
    }
}

