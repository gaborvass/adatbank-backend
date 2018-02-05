import Vapor

extension Droplet {


    func setupRoutes() throws {
        
        let dataManager = DataManager(dataLoader: DefaultDataLoader(), dataParser: DefaultDataParser())
        let leaguesResponder = LeaguesResponder(dataManager)
        let federationsResponder = FederationsResponder(dataManager)
        let seasonsResponder = SeasonsResponder(dataManager)
        let roundsResponder = RoundsResponder(dataManager)
        let resultsResponder = ResultsResponder(dataManager)
        let standingsResponder = StandingsResponder(dataManager)
        let basicDataResponder = BasicDataResponder(dataManager)
        
        // routes
        get("federations", handler: federationsResponder.respond)
        get("seasons", handler: seasonsResponder.respond)
        get("leagues",":seasonId",":federationId", handler: leaguesResponder.respond)
        get("rounds",":seasonId",":federationId",":leagueId", handler: roundsResponder.respond)
        get("results",":seasonId",":federationId",":leagueId",":roundId", handler: resultsResponder.respond)
        get("standings",":seasonId",":federationId",":leagueId",":roundId", handler: standingsResponder.respond)
        get("basicData", handler: basicDataResponder.respond)

    }
}
