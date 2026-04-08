"""
Data models matching the Swift Codable classes from the original Vapor app.
All models use Python dataclasses for easy JSON serialization.
"""

from dataclasses import dataclass, asdict
from typing import Optional, List, Any


@dataclass
class FederationObject:
    """Represents a football federation/organization."""
    federation_id: str
    federation_name: str

    def to_dict(self) -> dict[str, Any]:
        return {
            "federationId": self.federation_id,
            "federationName": self.federation_name
        }


@dataclass
class SeasonObject:
    """Represents a football season."""
    season_id: str
    season_name: str
    is_current: bool

    def to_dict(self) -> dict[str, Any]:
        return {
            "seasonId": self.season_id,
            "seasonName": self.season_name,
            "isCurrent": self.is_current
        }


@dataclass
class LeagueObject:
    """Represents a league/competition."""
    league_id: str
    league_name: Optional[str] = None

    def to_dict(self) -> dict[str, Any]:
        return {
            "leagueId": self.league_id,
            "leagueName": self.league_name
        }


@dataclass
class RoundObject:
    """Represents a round within a league."""
    round_id: str
    round_name: Optional[str] = None
    is_current: bool = False

    def to_dict(self) -> dict[str, Any]:
        return {
            "roundId": self.round_id,
            "roundName": self.round_name,
            "isCurrent": self.is_current
        }


@dataclass
class MatchObject:
    """Represents a single match with teams, score, date, and venue."""
    match_id: str
    home_team: Optional[str] = None
    away_team: Optional[str] = None
    home_team_goals: Optional[str] = None
    away_team_goals: Optional[str] = None
    home_team_logo_url: Optional[str] = None
    away_team_logo_url: Optional[str] = None
    match_info: Optional[str] = None
    match_date: Optional[str] = None
    match_time: Optional[str] = None

    def to_dict(self) -> dict[str, Any]:
        return {
            "matchId": self.match_id,
            "homeTeam": self.home_team,
            "awayTeam": self.away_team,
            "homeTeamGoals": self.home_team_goals,
            "awayTeamGoals": self.away_team_goals,
            "homeTeamLogoUrl": self.home_team_logo_url,
            "awayTeamLogoUrl": self.away_team_logo_url,
            "matchInfo": self.match_info,
            "matchDate": self.match_date,
            "matchTime": self.match_time
        }


@dataclass
class TeamObject:
    """Represents a team's standings information."""
    team_id: str
    position: Optional[str] = None
    team_name: Optional[str] = None
    played: Optional[str] = None
    won: Optional[str] = None
    drawn: Optional[str] = None
    lost: Optional[str] = None
    goals_for: Optional[str] = None
    goals_against: Optional[str] = None
    goal_diff: Optional[str] = None
    points: Optional[str] = None

    def to_dict(self) -> dict[str, Any]:
        return {
            "teamId": self.team_id,
            "position": self.position,
            "teamName": self.team_name,
            "played": self.played,
            "won": self.won,
            "drawn": self.drawn,
            "lost": self.lost,
            "goalsFor": self.goals_for,
            "goalsAgainst": self.goals_against,
            "goalDiff": self.goal_diff,
            "points": self.points
        }


@dataclass
class PlayerObject:
    """Represents a player's statistics."""
    player_id: str
    player_num: Optional[str] = None
    player_name: Optional[str] = None
    player_team: Optional[str] = None
    number_of_goals: Optional[str] = None
    number_of_yellow_cards: Optional[str] = None
    number_of_red_cards: Optional[str] = None

    def to_dict(self) -> dict[str, Any]:
        return {
            "playerId": self.player_id,
            "playerNum": self.player_num,
            "playerName": self.player_name,
            "playerTeam": self.player_team,
            "numberOfGoals": self.number_of_goals,
            "numberOfYellowCards": self.number_of_yellow_cards,
            "numberOfRedCards": self.number_of_red_cards
        }


@dataclass
class MatchDetailsObject:
    """Represents detailed match events (placeholder for future use)."""
    # Placeholder for match timeline events
    pass
