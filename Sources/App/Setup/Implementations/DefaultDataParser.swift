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
        for link in doc.xpath("//*[@id=\"match_panel\"]") {
            let innerHtml = link.innerHTML
            let matchesTable = try! HTML(html: innerHtml!, encoding: String.Encoding.utf8)
            for matchItem in matchesTable.xpath("//*[@class=\"schedule \"]") {
                retValue.append(parseMatchItem(matchItem))
            }
        }
        return retValue
    }
    
    func parseMatchItem(_ item: Kanna.XMLElement) -> MatchObject {
        let innerHtml = item.innerHTML
        let matchItemHTML = try! HTML(html: innerHtml!, encoding: String.Encoding.utf8)

        let matchIdHTML = matchItemHTML.at_xpath("//*[@class=\"result-cont\"]//a")!
        let matchId = matchIdHTML["href"]?.string.split(separator: "/").last?.split(separator: ".").first
        let mo = MatchObject(String(matchId!))
        let matchResult = matchItemHTML.at_xpath("//*[@class=\"schedule-points\"]")?.content
        if matchResult != nil {
            let parsedMatchResult = parseMatchResult(matchResult!)
            mo.homeTeamGoals = parsedMatchResult.homeGoals
            mo.awayTeamGoals = parsedMatchResult.awayGoals
        }

        let matchTime = matchItemHTML.at_xpath("//*[@class=\"team_sorsolas_date\"]//span")?.content
        if matchTime != nil {
            mo.matchTime = matchTime
        }

        let matchDate = matchItemHTML.at_xpath("//*[@class=\"team_sorsolas_date\"]")?.content
        if matchDate != nil {
            if (matchTime != nil) {
                mo.matchDate = matchDate?.replacingOccurrences(of: matchTime!, with: "")
            } else {
                mo.matchDate = matchDate
            }
        }
        let matchLocation = matchItemHTML.at_xpath("//*[@class=\"team_sorsolas_arena\"]")?.content
        if matchLocation != nil {
            mo.matchInfo = matchLocation
        }

        let teamLeft = matchItemHTML.at_xpath("//*[@class=\"home_team\"]")?.content
        let teamRight = matchItemHTML.at_xpath("//*[@class=\"away_team\"]")?.content
        
        mo.homeTeam = teamLeft
        //mo.homeTeamLogoUrl = t
        
        mo.awayTeam = teamRight
        //mo.awayTeamLogoUrl = parsedTeamAway.teamLogoUrl
        return mo
    }
    
    func parseMatchResult(_ rawResult: String) -> (homeGoals: String, awayGoals: String) {
        let resultParts = rawResult.components(separatedBy: "-")
        return (resultParts[0], resultParts[1])
    }
    
    func parseMatchDate(_ rawInfo : String) -> (matchDate: String, matchTime: String) {
        let infoParts = rawInfo.components(separatedBy: "<span>")

//        var matchTime = infoParts[1]
//        if matchTime.hasSuffix("</span>") {
//            matchTime = matchTime.replacingOccurrences(of: "</span>", with: "")
//        }

        return (infoParts[0],"NA")
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
        let json : [String: Any] =  (try! JSONSerialization.jsonObject(with: raw.data(using: .utf8)!, options: .allowFragments) as? [String: Any])!
        if let leagues = json["leagues"] as? Array<Dictionary<String, String>> {
            for i in 0 ..< leagues.count {
                let id = leagues[i]["id"]
                let name = leagues[i]["name"]
                
                let league: LeagueObject = LeagueObject(id!)
                league.leagueName = name
                
                retValue.append(league)
            }
        }
        return retValue;
    }
    
    func parseRounds(_ raw: String) -> Array<RoundObject> {
        var retValue: Array<RoundObject> = Array<RoundObject>()
        let json : [String: Any] =  (try! JSONSerialization.jsonObject(with: raw.data(using: .utf8)!, options: .allowFragments) as? [String: Any])!
        
        if let rounds : Array<Dictionary<String, String>> = json["turns"] as? Array<Dictionary<String, String>>  {
            for i in 0 ..< rounds.count {
                let id = rounds[i]["turn"]!.string
                
                let ro: RoundObject = RoundObject(id)
                ro.roundName = id
                ro.isCurrent = false
                retValue.append(ro)
            }
        }
        if let actualTurn = json["actualTurn"] as? Dictionary<String, String> {
            if let turnId = actualTurn["turn"] {
                let actualTurnInt = Int.init(turnId)!
                retValue[actualTurnInt - 1].isCurrent = true
            }
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
                let clickRef = standingsRow["onclick"]
                let teamId = clickRef?.split(separator: "/").last?.split(separator: ".").first
                let to = TeamObject(String(teamId!))
                let standingsRowHtml = standingsRow.innerHTML
                let standingsRowItem = try! HTML(html: standingsRowHtml!, encoding: String.Encoding.utf8)
                var counter : Int = 0
                for standingsRowColumn in standingsRowItem.xpath("//td") {
                    if counter == 0 {
                        to.position = standingsRowColumn.content?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    }
                    if counter == 2 {
                        to.teamName = standingsRowColumn.content?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    }
                    if counter == 3 {
                        to.played = standingsRowColumn.content?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    }
                    if counter == 4 {
                        to.won = standingsRowColumn.content?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    }
                    if counter == 5 {
                        to.drawn = standingsRowColumn.content?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    }
                    if counter == 6 {
                        to.lost = standingsRowColumn.content?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    }
                    if counter == 7 {
                        to.goalsFor = standingsRowColumn.content?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    }
                    if counter == 8 {
                        to.goalsAgainst = standingsRowColumn.content?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    }
                    if counter == 9 {
                        to.goalDiff = standingsRowColumn.content?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    }
                    if counter == 10 {
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

