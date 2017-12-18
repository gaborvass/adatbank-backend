//
//  SeasonObject.swift
//  Adatbank
//
//  Created by Vass Gábor on 29/01/16.
//  Copyright © 2016 Gabor, Vass. All rights reserved.
//

import Foundation

struct SeasonObject : Codable{
    
    private let seasonId : String
    private let seasonName : String
    private let isCurrent : Bool
    
    init(seasonId: String, seasonName: String, isCurrent: Bool) {
        self.seasonId = seasonId
        self.seasonName = seasonName
        self.isCurrent = isCurrent
    }
}
