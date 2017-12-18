//
//  OrganizationObject.swift
//  Adatbank
//
//  Created by Vass Gábor on 29/01/16.
//  Copyright © 2016 Gabor, Vass. All rights reserved.
//

import Foundation

struct FederationObject : Codable {

	let federationId: String
	let federationName: String
    
    init(federationId : String, federationName : String) {
        self.federationId = federationId
        self.federationName = federationName
	}
}


