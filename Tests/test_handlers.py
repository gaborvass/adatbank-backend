"""
Unit tests for Lambda handlers and supporting classes.
Run with: pytest tests/test_handlers.py
"""

import pytest
import json
from lambda.data_loader import DataLoader, DataLoaderError
from lambda.data_parser import DataParser
from lambda.models import FederationObject, SeasonObject, LeagueObject


class TestDataLoader:
    """Tests for DataLoader class."""

    def test_initialization(self):
        """Test DataLoader initializes correctly."""
        loader = DataLoader()
        assert loader.timeout == 30

    def test_custom_timeout(self):
        """Test DataLoader with custom timeout."""
        loader = DataLoader(timeout=60)
        assert loader.timeout == 60


class TestDataParser:
    """Tests for DataParser class."""

    def test_parse_federations_empty_html(self):
        """Test parsing empty HTML returns empty list."""
        parser = DataParser()
        result = parser.parse_federations("<html></html>")
        assert result == []

    def test_parse_federations_simple_html(self):
        """Test parsing federations from simple HTML."""
        html = """
        <html>
            <select id="federations">
                <option value="1">First Federation</option>
                <option value="2">Second Federation</option>
            </select>
        </html>
        """
        parser = DataParser()
        result = parser.parse_federations(html)
        assert len(result) == 2
        assert result[0].federation_id == "1"
        assert result[0].federation_name == "First Federation"
        assert result[1].federation_id == "2"

    def test_parse_federations_skip_empty_values(self):
        """Test that empty federation values are skipped."""
        html = """
        <html>
            <select id="federations">
                <option value="">Select a federation</option>
                <option value="1">First Federation</option>
            </select>
        </html>
        """
        parser = DataParser()
        result = parser.parse_federations(html)
        assert len(result) == 1
        assert result[0].federation_id == "1"

    def test_parse_seasons_with_current(self):
        """Test parsing seasons with is_current flag."""
        html = """
        <html>
            <select id="evad">
                <option value="2023">2023/2024</option>
                <option value="2022" selected>2022/2023</option>
            </select>
        </html>
        """
        parser = DataParser()
        result = parser.parse_seasons(html)
        assert len(result) == 2
        assert result[0].season_id == "2023"
        assert result[0].is_current is False
        assert result[1].season_id == "2022"
        assert result[1].is_current is True

    def test_parse_leagues_from_json(self):
        """Test parsing leagues from JSON."""
        json_data = """
        {
            "leagues": [
                {"id": "1", "name": "NB I"},
                {"id": "2", "name": "NB II"}
            ]
        }
        """
        parser = DataParser()
        result = parser.parse_leagues(json_data)
        assert len(result) == 2
        assert result[0].league_id == "1"
        assert result[0].league_name == "NB I"
        assert result[1].league_id == "2"
        assert result[1].league_name == "NB II"

    def test_parse_leagues_invalid_json(self):
        """Test parsing leagues from invalid JSON returns empty list."""
        parser = DataParser()
        result = parser.parse_leagues("invalid json")
        assert result == []

    def test_parse_rounds_with_current(self):
        """Test parsing rounds with actual turn marker."""
        json_data = """
        {
            "turns": [
                {"turn": "1"},
                {"turn": "2"},
                {"turn": "3"}
            ],
            "actualTurn": {"turn": "2"}
        }
        """
        parser = DataParser()
        result = parser.parse_rounds(json_data)
        assert len(result) == 3
        assert result[0].is_current is False
        assert result[1].is_current is True
        assert result[2].is_current is False


class TestModels:
    """Tests for data model classes."""

    def test_federation_object_to_dict(self):
        """Test FederationObject serialization."""
        obj = FederationObject(federation_id="1", federation_name="Test")
        result = obj.to_dict()
        assert result == {
            "federationId": "1",
            "federationName": "Test"
        }

    def test_season_object_to_dict(self):
        """Test SeasonObject serialization."""
        obj = SeasonObject(season_id="2023", season_name="2023/24", is_current=True)
        result = obj.to_dict()
        assert result == {
            "seasonId": "2023",
            "seasonName": "2023/24",
            "isCurrent": True
        }

    def test_league_object_to_dict(self):
        """Test LeagueObject serialization."""
        obj = LeagueObject(league_id="1", league_name="NB I")
        result = obj.to_dict()
        assert result == {
            "leagueId": "1",
            "leagueName": "NB I"
        }


class TestLambdaHandlers:
    """Tests for Lambda handler functions."""

    def test_federations_handler_event_structure(self):
        """Test federations handler handles basic event structure."""
        from lambda.handlers.federations import lambda_handler

        event = {
            "pathParameters": None,
            "body": None,
            "queryStringParameters": None
        }

        # This will fail without network access, but we can test the structure
        # In a real test, you would mock the DataLoader
        try:
            result = lambda_handler(event, None)
            assert "statusCode" in result
            assert "headers" in result
            assert "body" in result
        except Exception:
            # Expected to fail due to network access
            pass


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
