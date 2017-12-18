//
//  DataLoader.swift
//  backend
//
//  Created by Vass Gábor on 13/08/2017.
//
//

import Foundation

class DefaultDataLoader : DataLoaderProtocol {
    
    private static let postURL = "http://ada1bank.mlsz.hu/libs/ajax.php"
    
    func loadRawBasicData(success: @escaping (_: String) -> Void, failure: @escaping (_: Error) -> Void) {
        executeGETRequest(urlString: "http://adatbank.mlsz.hu", success: success, failure: failure)
    }
    
    func loadRawLeagues(seasonId: String!, federationId : String!, success: @escaping (_: String) -> Void, failure: @escaping (_: Error) -> Void) {
        
        executePOSTRequest(postBody: "type=getHeaderFilderData&season=\(seasonId!)&federationId=\(federationId!)&changedType=federation", success: success, failure: failure)
        
    }
    
    func loadRawRounds(seasonId: String!, federationId : String!, leagueId: String!, success: @escaping (_: String) -> Void, failure: @escaping (_: Error) -> Void) {
        executePOSTRequest(postBody: "type=getHeaderFilderData&season=\(seasonId!)&federationId=\(federationId!)&leagueId=\(leagueId!)&changedType=league", success: success, failure: failure)
    }
    
    func loadRawResults(seasonId: String!, federationId : String!, leagueId: String!, roundId: String!, success: @escaping (_: String) -> Void, failure: @escaping (_: Error) -> Void) {
        executeGETRequest(urlString: "http://adatbank.mlsz.hu/index/\(seasonId!)/\(federationId!)/\(leagueId!)/\(roundId!).html", success: success, failure: failure)
    }

    func loadRawStandings(seasonId: String!, federationId : String!, leagueId: String!, roundId: String!, success: @escaping (_: String) -> Void, failure: @escaping (_: Error) -> Void) {
        executeGETRequest(urlString: "http://adatbank.mlsz.hu/index/\(seasonId!)/\(federationId!)/\(leagueId!)/\(roundId!).html", success: success, failure: failure)
    }

    func loadRawMatchDetails(matchId: String!, success: @escaping (_: String) -> Void, failure: @escaping (_: Error) -> Void) {
        success("")
    }
    
    func loadRawPenaltyCards(seasonId: String!, federationId : String!, leagueId: String!, roundId: String!, success: @escaping (_: String) -> Void, failure: @escaping (_: Error) -> Void) {
        executeGETRequest(urlString: "http://adatbank.mlsz.hu/penality_cards/\(seasonId!)/\(federationId!)/\(leagueId!)/\(roundId!).html", success: success, failure: failure)
    }

    func loadRawTopScorers(seasonId: String!, federationId : String!, leagueId: String!, roundId: String!, success: @escaping (_: String) -> Void, failure: @escaping (_: Error) -> Void) {
        executeGETRequest(urlString: "http://adatbank.mlsz.hu/goalshooter/\(seasonId!)/\(federationId!)/\(leagueId!)/\(roundId!).html", success: success, failure: failure)
    }

    // MARK: private methods
    
    private func executeGETRequest(urlString: String!, success: @escaping (_: String) -> Void, failure: @escaping (_: Error) -> Void) {
        let request = URLRequest.init(url: URL(string: urlString)!)
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            var localError: Error? = error
            var content: String?
            if (localError == nil) {
                let httpResponse = response as! HTTPURLResponse
                if httpResponse.statusCode == 200 {
                    content = String(data: data!, encoding: String.Encoding.utf8)!
                } else {
                    localError = NSError(domain: "DefaultDataLoader", code: 1, userInfo: [NSLocalizedDescriptionKey: "Response status is: \(httpResponse.statusCode) "])
                }
            }
            if localError != nil {
                failure(localError!)
            } else {
                success(content!)
            }
        })
        task.resume()
    }
    
    private func executePOSTRequest(postBody: String!, success: @escaping (_: String) -> Void, failure: @escaping (_: Error) -> Void) {
        var postRequest = URLRequest.init(url: URL(string: DefaultDataLoader.postURL)!)
        postRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        postRequest.httpMethod = "POST"
        postRequest.httpBody = postBody.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: postRequest, completionHandler: { (data, response, error) -> Void in
            var localError: Error? = error
            var content: String?
            if (localError == nil) {
                let httpResponse = response as! HTTPURLResponse
                if httpResponse.statusCode == 200 {
                    content = String(data: data!, encoding: String.Encoding.utf8)!
                } else {
                    localError = NSError(domain: "DefaultDataLoader", code: 1, userInfo: [NSLocalizedDescriptionKey: "Response status is: \(httpResponse.statusCode) "])
                }
            }
            if localError != nil {
                failure(localError!)
            } else {
                success(content!)
            }
        })
        task.resume()
        
    }
    
    
}
