"""
Data loader for scraping Hungarian football data from adatbank.mlsz.hu.
Converts Swift URLSession to Python requests library.
"""

import requests
from typing import Optional


class DataLoaderError(Exception):
    """Custom exception for data loading errors."""
    pass


class DataLoader:
    """
    HTTP client for scraping data from adatbank.mlsz.hu.
    Replaces Swift's DefaultDataLoader class.
    """

    BASE_URL = "http://adatbank.mlsz.hu"
    POST_URL = "http://ada1bank.mlsz.hu/libs/ajax.php"
    TIMEOUT = 30  # seconds

    def __init__(self, timeout: int = 30):
        """
        Initialize the data loader.

        Args:
            timeout: Request timeout in seconds (default: 30)
        """
        self.timeout = timeout
        self._session = requests.Session()

    def _get(self, url: str) -> str:
        """
        Execute a GET request.

        Args:
            url: The URL to fetch

        Returns:
            The response content as text

        Raises:
            DataLoaderError: If the request fails
        """
        try:
            response = self._session.get(url, timeout=self.timeout)
            response.raise_for_status()
            # Explicitly set encoding to UTF-8 since the server doesn't specify charset
            # but the content is actually UTF-8
            if response.encoding is None or response.encoding == 'ISO-8859-1':
                response.encoding = 'utf-8'
            return response.text
        except requests.RequestException as e:
            raise DataLoaderError(f"GET request failed for {url}: {str(e)}")

    def _post(self, url: str, data: dict) -> str:
        """
        Execute a POST request with form data.

        Args:
            url: The URL to post to
            data: Form data to send

        Returns:
            The response content as text

        Raises:
            DataLoaderError: If the request fails
        """
        try:
            response = self._session.post(
                url,
                data=data,
                headers={"Content-Type": "application/x-www-form-urlencoded"},
                timeout=self.timeout
            )
            response.raise_for_status()
            # Explicitly set encoding to UTF-8 since the server doesn't specify charset
            # but the content is actually UTF-8
            if response.encoding is None or response.encoding == 'ISO-8859-1':
                response.encoding = 'utf-8'
            return response.text
        except requests.RequestException as e:
            raise DataLoaderError(f"POST request failed for {url}: {str(e)}")

    def load_raw_basic_data(self) -> str:
        """
        Load the basic data page (contains federations and seasons).

        Returns:
            HTML content of the basic data page

        Raises:
            DataLoaderError: If the request fails
        """
        return self._get(self.BASE_URL)

    def load_raw_leagues(self, season_id: str, federation_id: str) -> str:
        """
        Load leagues for a given season and federation.

        Args:
            season_id: The season ID
            federation_id: The federation ID

        Returns:
            JSON response containing leagues data

        Raises:
            DataLoaderError: If the request fails
        """
        data = {
            "type": "getHeaderFilderData",
            "season": season_id,
            "federationId": federation_id,
            "changedType": "federation"
        }
        return self._post(self.POST_URL, data)

    def load_raw_rounds(self, season_id: str, federation_id: str, league_id: str) -> str:
        """
        Load rounds for a given season, federation, and league.

        Args:
            season_id: The season ID
            federation_id: The federation ID
            league_id: The league ID

        Returns:
            JSON response containing rounds data

        Raises:
            DataLoaderError: If the request fails
        """
        data = {
            "type": "getHeaderFilderData",
            "season": season_id,
            "federationId": federation_id,
            "leagueId": league_id,
            "changedType": "league"
        }
        return self._post(self.POST_URL, data)

    def load_raw_results(self, season_id: str, federation_id: str,
                         league_id: str, round_id: str) -> str:
        """
        Load match results for a given round.

        Args:
            season_id: The season ID
            federation_id: The federation ID
            league_id: The league ID
            round_id: The round ID

        Returns:
            HTML content containing match results

        Raises:
            DataLoaderError: If the request fails
        """
        url = f"{self.BASE_URL}/league/{season_id}/{federation_id}/{league_id}/{round_id}.html"
        return self._get(url)

    def load_raw_standings(self, season_id: str, federation_id: str,
                           league_id: str, round_id: str) -> str:
        """
        Load standings for a given round.

        Args:
            season_id: The season ID
            federation_id: The federation ID
            league_id: The league ID
            round_id: The round ID

        Returns:
            HTML content containing standings table

        Raises:
            DataLoaderError: If the request fails
        """
        url = f"{self.BASE_URL}/league/{season_id}/{federation_id}/{league_id}/{round_id}.html"
        return self._get(url)

    def load_raw_penalty_cards(self, season_id: str, federation_id: str,
                               league_id: str, round_id: str) -> str:
        """
        Load penalty cards (yellow/red cards) for a given round.

        Args:
            season_id: The season ID
            federation_id: The federation ID
            league_id: The league ID
            round_id: The round ID

        Returns:
            HTML content containing penalty cards data

        Raises:
            DataLoaderError: If the request fails
        """
        url = f"{self.BASE_URL}/penality_cards/{season_id}/{federation_id}/{league_id}/{round_id}.html"
        return self._get(url)

    def load_raw_top_scorers(self, season_id: str, federation_id: str,
                             league_id: str, round_id: str) -> str:
        """
        Load top scorers for a given round.

        Args:
            season_id: The season ID
            federation_id: The federation ID
            league_id: The league ID
            round_id: The round ID

        Returns:
            HTML content containing top scorers data

        Raises:
            DataLoaderError: If the request fails
        """
        url = f"{self.BASE_URL}/goalshooter/{season_id}/{federation_id}/{league_id}/{round_id}.html"
        return self._get(url)

    def load_raw_match_details(self, match_id: str) -> str:
        """
        Load detailed match information (placeholder for future implementation).

        Args:
            match_id: The match ID

        Returns:
            Empty string (not implemented)

        Note:
            This is a placeholder as the original Swift implementation
            returns an empty string.
        """
        return ""

    def close(self):
        """Close the HTTP session."""
        self._session.close()

    def __enter__(self):
        """Context manager entry."""
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        """Context manager exit."""
        self.close()
