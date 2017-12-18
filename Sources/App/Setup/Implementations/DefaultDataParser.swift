//
//  Transformator.swift
//  Parser
//
//  Created by Vass Gábor on 12/08/2017.
//  Copyright © 2017 gaborvass. All rights reserved.
//

import Foundation
import Kanna
import JSON

class DefaultDataParser : DataParserProtocol {

    func parseMatches(_ raw: String) -> Array<MatchObject> {
        var retValue: Array<MatchObject> = Array<MatchObject>()
        let doc = try! HTML(html: raw, encoding: String.Encoding.utf8)
        // must be only one
        for link in doc.xpath("//*[@id=\"matchContent\"]") {
            let innerHtml = link.innerHTML
            let matchesTable = try! HTML(html: innerHtml!, encoding: String.Encoding.utf8)
            for matchItem in matchesTable.xpath("//*[@class=\"matchItem\"]") {
                retValue.append(parseMatchItem(matchItem))
            }
        }
        return retValue
    }
    
    func parseMatchItem(_ item: Kanna.XMLElement) -> MatchObject {
        let matchId : String = item["rel"]!
        let mo = MatchObject(matchId)
        
        let innerHtml = item.innerHTML
        let matchItemHTML = try! HTML(html: innerHtml!, encoding: String.Encoding.utf8)
        let matchInfo = matchItemHTML.at_xpath("//*[@class=\"matchInfo\"]")?.content
        if matchInfo != nil {
            let parsedMatchInfo = parseMatchInfo(matchInfo!)
            mo.matchInfo = parsedMatchInfo.matchLocation
            mo.matchDate = parsedMatchInfo.matchDate
            mo.matchTime = parsedMatchInfo.matchTime
        }
        let matchResult = matchItemHTML.at_xpath("//*[@class=\"matchResult\"]")?.content
        if matchResult != nil {
            let parsedMatchResult = parseMatchResult(matchResult!)
            mo.homeTeamGoals = parsedMatchResult.homeGoals
            mo.awayTeamGoals = parsedMatchResult.awayGoals
        }
        let teamLeft = matchItemHTML.at_xpath("//*[@class=\"teamLeft\"]")
        let teamRight = matchItemHTML.at_xpath("//*[@class=\"teamRight\"]")
        let parsedTeamHome = parseMatchTeam(teamLeft)
        let parsedTeamAway = parseMatchTeam(teamRight)
        mo.homeTeam = parsedTeamHome.teamName
        mo.homeTeamLogoUrl = parsedTeamHome.teamLogoUrl
        
        mo.awayTeam = parsedTeamAway.teamName
        mo.awayTeamLogoUrl = parsedTeamAway.teamLogoUrl
        return mo
    }
    
    func parseMatchResult(_ rawResult: String) -> (homeGoals: String, awayGoals: String) {
        let resultParts = rawResult.components(separatedBy: "-")
        return (resultParts[0], resultParts[1])
    }
    
    func parseMatchInfo(_ rawInfo : String) -> (matchDate: String, matchTime: String, matchLocation: String) {
        let infoParts = rawInfo.components(separatedBy: " ")

        var matchTime = infoParts[1]
        if matchTime.hasSuffix(",") {
            matchTime = matchTime.replacingOccurrences(of: ",", with: "")
        }

        var location : String = ""
        for i in 2 ..< infoParts.count {
            if infoParts[i].count > 0 {
                location += "\(infoParts[i]) "
            }
        }
        
        return (infoParts[0], matchTime, location)
    }
    
    func parseMatchTeam(_ item: Kanna.XMLElement?) -> (teamName: String, teamLogoUrl: String) {
        var teamName = ""
        var teamLogoUrl = ""
        let innerHtml = item?.innerHTML
        let teamItemHTML = try! HTML(html: innerHtml!, encoding: String.Encoding.utf8)
        if teamItemHTML.at_xpath("//*[@class=\"teamName\"]")?.content != nil {
            teamName = (teamItemHTML.at_xpath("//*[@class=\"teamName\"]")?.content!)!
        }
        if teamItemHTML.at_xpath("//*[@class=\"teamLogo\"]")?.content != nil {
            teamLogoUrl = (teamItemHTML.at_xpath("//*[@class=\"teamLogo\"]")?.content!)!
        }
        return (teamName, teamLogoUrl)
    }
    
    func parseSeasons(_ raw: String) -> Array<SeasonObject> {
        var retValue: Array<SeasonObject> = Array<SeasonObject>()
        let doc = try! HTML(html: raw, encoding: String.Encoding.utf8)
        for seasonFilter in doc.xpath("//*[@id=\"evad\"]") {
            let innerHtml = seasonFilter.innerHTML
            let seasonFilterHTML = try! HTML(html: innerHtml!, encoding: String.Encoding.utf8)
            for seasonItem in seasonFilterHTML.xpath("//option") {
                let seasonId = seasonItem["value"]!
                let seasonName = seasonItem.content
                let isCurrent = seasonItem["selected"]
                
                let seasonObject = SeasonObject(seasonId: seasonId, seasonName: seasonName!, isCurrent: (isCurrent != nil))
                retValue.append(seasonObject)
            }
        }
        return retValue
    }
    
    func parseFederations(_ raw: String) -> Array<FederationObject> {
        var retValue: Array<FederationObject> = Array<FederationObject>()
        let doc = try! HTML(html: raw, encoding: String.Encoding.utf8)
        for federationFilter in doc.xpath("//*[@id=\"federations\"]") {
            let innerHtml = federationFilter.innerHTML
            let federationFilterHTML = try! HTML(html: innerHtml!, encoding: String.Encoding.utf8)
            for federationItem in federationFilterHTML.xpath("//option") {
                let federationId = federationItem["value"]!
                if federationId.count == 0 {
                    continue
                }
                let federationName = federationItem.content
                
                let federationObject = FederationObject(federationId: federationId, federationName: federationName!)
                retValue.append(federationObject)
            }
        }
        return retValue
    }
    
    func parseLeagues(_ raw: String) -> Array<LeagueObject> {
        var retValue: Array<LeagueObject> = Array<LeagueObject>()
        let json = SwiftyJSON.parse(raw)
        let leagues = json["leagues"].arrayValue
        for i in 0 ..< leagues.count {
            let id = leagues[i]["id"].stringValue
            let name = leagues[i]["name"].stringValue
            
            let league: LeagueObject = LeagueObject(id)
            league.leagueName = name
            
            retValue.append(league)
        }
        return retValue;
    }
    
    func parseRounds(_ raw: String) -> Array<RoundObject> {
        var retValue: Array<RoundObject> = Array<RoundObject>()
        let json = SwiftyJSON.parse(raw)
        let rounds = json["turns"].arrayValue
        for i in 0 ..< rounds.count {
            let id = rounds[i]["turn"].string
            
            let ro: RoundObject = RoundObject(id!)
            ro.roundName = id
            ro.isCurrent = false
            retValue.append(ro)
        }
        let actualTurn = json["actualTurn"]["turn"].string
        if actualTurn != nil && actualTurn!.count > 0 {
            let actualTurnInt = Int.init(actualTurn!)!
            retValue[actualTurnInt - 1].isCurrent = true
        }
        return retValue
    }
    
    func parsePenaltyCards(_ raw: String) -> Array<PlayerObject> {
        var penaltyCards = Array<PlayerObject>()
        let doc = try! HTML(html: raw, encoding: String.Encoding.utf8)
        // must be only one
        for link in doc.xpath("//*[@id=\"db_goal_shooter-results-container\"]") {
            let innerHtml = link.innerHTML
            let penaltiesTable = try! HTML(html: innerHtml!, encoding: String.Encoding.utf8)
            for penaltyRow in penaltiesTable.xpath("//*[@class=\"template-tr-selectable\"]") {
                let po = PlayerObject("")
                let penaltyRowHtml = penaltyRow.innerHTML
                let penaltyRowItem = try! HTML(html: penaltyRowHtml!, encoding: String.Encoding.utf8)
                var counter : Int = 0
                for penaltyRowColumn in penaltyRowItem.xpath("//td") {
                    if counter == 1 {
                        po.playerName = penaltyRowColumn.content?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    }
                    if counter == 2 {
                        po.playerTeam = penaltyRowColumn.content?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    }
                    if counter == 3 {
                        po.numberOfYellowCards = penaltyRowColumn.content?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    }
                    if counter == 4 {
                        po.numberOfRedCards = penaltyRowColumn.content?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    }
                    counter = counter + 1
                }
                penaltyCards.append(po)
            }
        }
        return penaltyCards
    }
    
    func parseTopscorers(_ raw: String) -> Array<PlayerObject> {
        var topscorers = Array<PlayerObject>()
        let doc = try! HTML(html: raw, encoding: String.Encoding.utf8)
        // must be only one
        for link in doc.xpath("//*[@id=\"db_goal_shooter-results-container\"]") {
            let innerHtml = link.innerHTML
            let topscorersTable = try! HTML(html: innerHtml!, encoding: String.Encoding.utf8)
            for topScorerRow in topscorersTable.xpath("//*[@class=\"template-tr-selectable\"]") {
                let po = PlayerObject("")
                let topScorerRowHtml = topScorerRow.innerHTML
                let topScorerRowItem = try! HTML(html: topScorerRowHtml!, encoding: String.Encoding.utf8)
                var counter : Int = 0
                for topScorerRowColumn in topScorerRowItem.xpath("//td") {
                    if counter == 1 {
                        po.playerName = topScorerRowColumn.content?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    }
                    if counter == 2 {
                        po.numberOfGoals = topScorerRowColumn.content?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    }
                    if counter == 3 {
                        po.playerTeam = topScorerRowColumn.content?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    }
                    counter = counter + 1
                }
                topscorers.append(po)
            }

        }
        return topscorers
    }
    
    func parseStandings(_ raw: String) -> Array<TeamObject> {
        var retValue = Array<TeamObject>()

        let doc = try! HTML(html: raw, encoding: String.Encoding.utf8)
        // must be only one
        for standings in doc.xpath("//*[@id=\"tabella_panel\"]") {
            let innerHtml = standings.innerHTML
            let standingsHTML = try! HTML(html: innerHtml!, encoding: String.Encoding.utf8)
            for standingsRow in standingsHTML.xpath("//*[@class=\"template-tr-selectable noNb1Tr\"]") {
                let to = TeamObject("")
                let standingsRowHtml = standingsRow.innerHTML
                let standingsRowItem = try! HTML(html: standingsRowHtml!, encoding: String.Encoding.utf8)
                var counter : Int = 0
                for standingsRowColumn in standingsRowItem.xpath("//td") {
                    if counter == 0 {
                        to.position = standingsRowColumn.content?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    }
                    if counter == 1 {
                        to.teamName = standingsRowColumn.content?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    }
                    if counter == 2 {
                        to.played = standingsRowColumn.content?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    }
                    if counter == 3 {
                        to.won = standingsRowColumn.content?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    }
                    if counter == 4 {
                        to.drawn = standingsRowColumn.content?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    }
                    if counter == 5 {
                        to.lost = standingsRowColumn.content?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    }
                    if counter == 6 {
                        to.goalsFor = standingsRowColumn.content?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    }
                    if counter == 7 {
                        to.goalsAgainst = standingsRowColumn.content?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    }
                    if counter == 8 {
                        to.goalDiff = standingsRowColumn.content?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    }
                    if counter == 9 {
                        to.points = standingsRowColumn.content?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    }
                    counter = counter + 1
                }
                retValue.append(to)
            }

        }

        return retValue
    }
    
    
    
    
    func parseMatchDetails(_ raw: String) -> Array<MatchDetailsObject> {
        // <img src="http://adatbank.mlsz.hu/images/timeline/event_goal.png" title="73' Gól PUNGOR DÁVID" style="margin: auto;" />
        
        return Array()
    }
    
}

