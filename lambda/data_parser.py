"""
Data parser for extracting structured data from HTML and JSON responses.
Converts Swift Kanna XPath parsing to Python BeautifulSoup parsing.
"""

from bs4 import BeautifulSoup
import json
import re
from typing import List, Optional
from models import (
    FederationObject, SeasonObject, LeagueObject, RoundObject,
    MatchObject, TeamObject, PlayerObject, MatchDetailsObject
)


class DataParser:
    """
    Parser for Hungarian football data from adatbank.mlsz.hu.
    Replaces Swift's DefaultDataParser class.
    """

    def parse_federations(self, raw: str) -> List[FederationObject]:
        """
        Parse federations from the basic data HTML page.

        Args:
            raw: Raw HTML content

        Returns:
            List of FederationObject instances
        """
        federations = []
        soup = BeautifulSoup(raw, 'html.parser')

        for select in soup.find_all(id='federations'):
            for option in select.find_all('option'):
                value = option.get('value', '')
                if value:  # Skip empty values
                    federations.append(FederationObject(
                        federation_id=value,
                        federation_name=option.get_text(strip=True)
                    ))

        return federations

    def parse_seasons(self, raw: str) -> List[SeasonObject]:
        """
        Parse seasons from the basic data HTML page.

        Args:
            raw: Raw HTML content

        Returns:
            List of SeasonObject instances
        """
        seasons = []
        soup = BeautifulSoup(raw, 'html.parser')

        for select in soup.find_all(id='evad'):
            for option in select.find_all('option'):
                value = option.get('value', '')
                is_current = option.has_attr('selected')
                seasons.append(SeasonObject(
                    season_id=value,
                    season_name=option.get_text(strip=True),
                    is_current=is_current
                ))

        return seasons

    def parse_leagues(self, raw: str) -> List[LeagueObject]:
        """
        Parse leagues from JSON response.

        Args:
            raw: Raw JSON string

        Returns:
            List of LeagueObject instances
        """
        leagues = []
        try:
            data = json.loads(raw)
            for league in data.get('leagues', []):
                leagues.append(LeagueObject(
                    league_id=league.get('id', ''),
                    league_name=league.get('name')
                ))
        except json.JSONDecodeError:
            pass  # Return empty list on JSON parse error

        return leagues

    def parse_rounds(self, raw: str) -> List[RoundObject]:
        """
        Parse rounds from JSON response.

        Args:
            raw: Raw JSON string

        Returns:
            List of RoundObject instances with is_current flag
        """
        rounds = []
        try:
            data = json.loads(raw)

            # Parse all rounds
            for turn in data.get('turns', []):
                turn_id = str(turn.get('turn', ''))
                rounds.append(RoundObject(
                    round_id=turn_id,
                    round_name=turn_id,
                    is_current=False
                ))

            # Mark the current round
            if 'actualTurn' in data:
                current_turn_id = int(data['actualTurn'].get('turn', 0))
                for round_obj in rounds:
                    if int(round_obj.round_id) == current_turn_id:
                        round_obj.is_current = True

        except (json.JSONDecodeError, ValueError, KeyError):
            pass  # Return empty list on error

        return rounds

    def parse_matches(self, raw: str) -> List[MatchObject]:
        """
        Parse matches from HTML content.

        Args:
            raw: Raw HTML content

        Returns:
            List of MatchObject instances
        """
        matches = []
        soup = BeautifulSoup(raw, 'html.parser')

        for panel in soup.find_all(id='match_panel'):
            for match_item in panel.find_all(class_='schedule '):
                match = self._parse_match_item(match_item)
                if match:
                    matches.append(match)

        return matches

    def _parse_match_item(self, match_item) -> Optional[MatchObject]:
        """
        Parse a single match item from HTML.

        Args:
            match_item: BeautifulSoup element for a match

        Returns:
            MatchObject instance or None if parsing fails
        """
        try:
            # Extract match ID from link
            result_cont = match_item.find(class_='result-cont')
            match_id = None
            if result_cont:
                link = result_cont.find('a')
                if link and link.get('href'):
                    # Extract ID from URL like "/match/12345.html"
                    href = link.get('href', '')
                    match_id = href.split('/')[-1].replace('.html', '')

            if not match_id:
                match_id = ""

            match = MatchObject(match_id=match_id)

            # Extract score
            schedule_points = match_item.find(class_='schedule-points')
            if schedule_points:
                score_text = schedule_points.get_text(strip=True)
                if '-' in score_text:
                    home_goals, away_goals = score_text.split('-', 1)
                    match.home_team_goals = home_goals.strip()
                    match.away_team_goals = away_goals.strip()

            # Extract date and time
            date_div = match_item.find(class_='team_sorsolas_date')
            if date_div:
                date_text = date_div.get_text(strip=True)
                # Try to separate date and time (time is often in a span)
                time_span = date_div.find('span')
                if time_span:
                    match.match_time = time_span.get_text(strip=True)
                    match.match_date = date_text.replace(match.match_time, '').strip()
                else:
                    match.match_date = date_text

            # Extract location/venue
            arena_div = match_item.find(class_='team_sorsolas_arena')
            if arena_div:
                match.match_info = arena_div.get_text(strip=True)

            # Extract team names
            home_team = match_item.find(class_='home_team')
            if home_team:
                match.home_team = home_team.get_text(strip=True)

            away_team = match_item.find(class_='away_team')
            if away_team:
                match.away_team = away_team.get_text(strip=True)

            return match

        except Exception:
            return None

    def parse_standings(self, raw: str) -> List[TeamObject]:
        """
        Parse standings table from HTML content.

        Args:
            raw: Raw HTML content

        Returns:
            List of TeamObject instances with standings data
        """
        standings = []
        soup = BeautifulSoup(raw, 'html.parser')

        for panel in soup.find_all(id='tabella_panel'):
            for row in panel.find_all(class_='template-tr-selectable noNb1Tr'):
                team = self._parse_standings_row(row)
                if team:
                    standings.append(team)

        return standings

    def _parse_standings_row(self, row) -> Optional[TeamObject]:
        """
        Parse a single standings row from HTML.

        Args:
            row: BeautifulSoup element for a standings row

        Returns:
            TeamObject instance or None if parsing fails
        """
        try:
            # Extract team ID from onclick attribute
            onclick = row.get('onclick', '')
            team_id = ""
            if onclick:
                # Extract ID from URL like "/team/12345.html"
                match = re.search(r'/(\d+)\.html', onclick)
                if match:
                    team_id = match.group(1)

            team = TeamObject(team_id=team_id)

            # Parse all columns in the row
            cells = row.find_all('td')
            for idx, cell in enumerate(cells):
                text = cell.get_text(strip=True)

                if idx == 0:  # Position
                    team.position = text
                elif idx == 1:  # Team name (may vary)
                    # Skip - usually this is an icon or empty
                    pass
                elif idx == 2:  # Team name
                    team.team_name = text
                elif idx == 3:  # Played
                    team.played = text
                elif idx == 4:  # Won
                    team.won = text
                elif idx == 5:  # Drawn
                    team.drawn = text
                elif idx == 6:  # Lost
                    team.lost = text
                elif idx == 7:  # Goals For
                    team.goals_for = text
                elif idx == 8:  # Goals Against
                    team.goals_against = text
                elif idx == 9:  # Goal Difference
                    team.goal_diff = text
                elif idx == 10:  # Points
                    team.points = text

            return team

        except Exception:
            return None

    def parse_penalty_cards(self, raw: str) -> List[PlayerObject]:
        """
        Parse penalty cards (yellow/red cards) from HTML content.

        Args:
            raw: Raw HTML content

        Returns:
            List of PlayerObject instances with card statistics
        """
        players = []
        soup = BeautifulSoup(raw, 'html.parser')

        for container in soup.find_all(id='db_goal_shooter-results-container'):
            for row in container.find_all(class_='template-tr-selectable'):
                player = self._parse_penalty_cards_row(row)
                if player:
                    players.append(player)

        return players

    def _parse_penalty_cards_row(self, row) -> Optional[PlayerObject]:
        """
        Parse a single penalty cards row from HTML.

        Args:
            row: BeautifulSoup element for a player row

        Returns:
            PlayerObject instance or None if parsing fails
        """
        try:
            player = PlayerObject(player_id="")

            cells = row.find_all('td')
            for idx, cell in enumerate(cells):
                text = cell.get_text(strip=True)

                if idx == 1:  # Player name
                    player.player_name = text
                elif idx == 2:  # Team
                    player.player_team = text
                elif idx == 3:  # Yellow cards
                    player.number_of_yellow_cards = text
                elif idx == 4:  # Red cards
                    player.number_of_red_cards = text

            return player

        except Exception:
            return None

    def parse_top_scorers(self, raw: str) -> List[PlayerObject]:
        """
        Parse top scorers from HTML content.

        Args:
            raw: Raw HTML content

        Returns:
            List of PlayerObject instances with goal statistics
        """
        players = []
        soup = BeautifulSoup(raw, 'html.parser')

        for container in soup.find_all(id='db_goal_shooter-results-container'):
            for row in container.find_all(class_='template-tr-selectable'):
                player = self._parse_top_scorer_row(row)
                if player:
                    players.append(player)

        return players

    def _parse_top_scorer_row(self, row) -> Optional[PlayerObject]:
        """
        Parse a single top scorer row from HTML.

        Args:
            row: BeautifulSoup element for a player row

        Returns:
            PlayerObject instance or None if parsing fails
        """
        try:
            player = PlayerObject(player_id="")

            cells = row.find_all('td')
            for idx, cell in enumerate(cells):
                text = cell.get_text(strip=True)

                if idx == 1:  # Player name
                    player.player_name = text
                elif idx == 2:  # Goals
                    player.number_of_goals = text
                elif idx == 3:  # Team
                    player.player_team = text

            return player

        except Exception:
            return None

    def parse_match_details(self, raw: str) -> List[MatchDetailsObject]:
        """
        Parse detailed match information (placeholder for future implementation).

        Args:
            raw: Raw HTML content

        Returns:
            Empty list (not implemented)

        Note:
            This is a placeholder as the original Swift implementation
            returns an empty array.
        """
        return []
