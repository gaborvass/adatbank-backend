//
//  RoundObject.swift
//  Adatbank
//
//  Created by Vass Gábor on 29/01/16.
//  Copyright © 2016 Gabor, Vass. All rights reserved.
//

import Foundation

class RoundObject : Codable {
    
    let roundId : String
    var roundName : String?
    var isCurrent : Bool?
    
    init(_ id: String) {
        roundId = id
    }
}

