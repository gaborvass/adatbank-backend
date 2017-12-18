import Vapor

extension Droplet {


    func setupRoutes() throws {
        
        let dataManager = DataManager(dataLoader: DefaultDataLoader(), dataParser: DefaultDataParser())
        let getLeaguesResponder = GetLeaguesResponder(dataManager)
        let getFederationsResponder = GetFederationsResponder(dataManager)
        let getSeasonsResponder = GetSeasonsResponder(dataManager)
        let getRoundsResponder = GetRoundsResponder(dataManager)
        let getResultsResponder = GetResultsResponder(dataManager)
        let getStandingsResponder = GetStandingsResponder(dataManager)
        let getBasicDataResponder = GetBasicDataResponder(dataManager)
        
        get("getFederations", handler: getFederationsResponder.respond)
        get("getSeasons", handler: getSeasonsResponder.respond)
        get("getLeagues",":seasonId",":federationId", handler: getLeaguesResponder.respond)
        get("getRounds",":seasonId",":federationId",":leagueId", handler: getRoundsResponder.respond)
        get("getResults",":seasonId",":federationId",":leagueId",":roundId", handler: getResultsResponder.respond)
        get("getStandings",":seasonId",":federationId",":leagueId",":roundId", handler: getStandingsResponder.respond)
        get("getBasicData", handler: getBasicDataResponder.respond)

    }
}
