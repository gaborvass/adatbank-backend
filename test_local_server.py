#!/usr/bin/env python3
"""
Local test server for Lambda handlers.
Runs a simple HTTP server that mimics API Gateway and calls Lambda handlers directly.

Usage:
    python test_local_server.py

Then test endpoints:
    curl http://localhost:5000/federations
    curl http://localhost:5000/seasons
    curl http://localhost:5000/basicData
    curl http://localhost:5000/leagues/2023/1
    curl http://localhost:5000/rounds/2023/1/1
    curl http://localhost:5000/results/2023/1/1/1
    curl http://localhost:5000/standings/2023/1/1/1
"""

from flask import Flask, jsonify, Response
import sys
import os

# Add lambda directory to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'lambda'))

from handlers import federations, seasons, basic_data, leagues, rounds, results, standings

app = Flask(__name__)


def call_lambda_handler(handler_func, path_params=None):
    """
    Call a Lambda handler with an API Gateway-like event structure.

    Args:
        handler_func: The Lambda handler function
        path_params: Dictionary of path parameters

    Returns:
        Flask response with status code and JSON body
    """
    event = {
        'pathParameters': path_params,
        'body': None,
        'queryStringParameters': None,
        'headers': {},
        'httpMethod': 'GET'
    }

    try:
        result = handler_func.lambda_handler(event, None)
        status_code = result.get('statusCode', 500)
        body = result.get('body', '{}')
        return Response(response=body, status=status_code, mimetype='application/json')
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/')
def index():
    """Root endpoint with API documentation."""
    return jsonify({
        'name': 'Hungarian Football Data API - Local Test Server',
        'version': '1.0.0',
        'endpoints': {
            'GET /federations': 'Get all football federations',
            'GET /seasons': 'Get all seasons',
            'GET /basicData': 'Get federations and seasons combined',
            'GET /leagues/<seasonId>/<federationId>': 'Get leagues for a season/federation',
            'GET /rounds/<seasonId>/<federationId>/<leagueId>': 'Get rounds for a league',
            'GET /results/<seasonId>/<federationId>/<leagueId>/<roundId>': 'Get match results',
            'GET /standings/<seasonId>/<federationId>/<leagueId>/<roundId>': 'Get standings'
        }
    })


@app.route('/federations', methods=['GET'])
def get_federations():
    """GET /federations - Get all football federations."""
    return call_lambda_handler(federations)


@app.route('/seasons', methods=['GET'])
def get_seasons():
    """GET /seasons - Get all seasons."""
    return call_lambda_handler(seasons)


@app.route('/basicData', methods=['GET'])
def get_basic_data():
    """GET /basicData - Get federations and seasons combined."""
    return call_lambda_handler(basic_data)


@app.route('/leagues/<seasonId>/<federationId>', methods=['GET'])
def get_leagues(seasonId, federationId):
    """GET /leagues/{seasonId}/{federationId} - Get leagues."""
    return call_lambda_handler(leagues, {
        'seasonId': seasonId,
        'federationId': federationId
    })


@app.route('/rounds/<seasonId>/<federationId>/<leagueId>', methods=['GET'])
def get_rounds(seasonId, federationId, leagueId):
    """GET /rounds/{seasonId}/{federationId}/{leagueId} - Get rounds."""
    return call_lambda_handler(rounds, {
        'seasonId': seasonId,
        'federationId': federationId,
        'leagueId': leagueId
    })


@app.route('/results/<seasonId>/<federationId>/<leagueId>/<roundId>', methods=['GET'])
def get_results(seasonId, federationId, leagueId, roundId):
    """GET /results/{seasonId}/{federationId}/{leagueId}/{roundId} - Get match results."""
    return call_lambda_handler(results, {
        'seasonId': seasonId,
        'federationId': federationId,
        'leagueId': leagueId,
        'roundId': roundId
    })


@app.route('/standings/<seasonId>/<federationId>/<leagueId>/<roundId>', methods=['GET'])
def get_standings(seasonId, federationId, leagueId, roundId):
    """GET /standings/{seasonId}/{federationId}/{leagueId}/{roundId} - Get standings."""
    return call_lambda_handler(standings, {
        'seasonId': seasonId,
        'federationId': federationId,
        'leagueId': leagueId,
        'roundId': roundId
    })


@app.errorhandler(404)
def not_found(error):
    """Handle 404 errors."""
    return jsonify({'error': 'Endpoint not found'}), 404


@app.errorhandler(500)
def internal_error(error):
    """Handle 500 errors."""
    return jsonify({'error': 'Internal server error', 'message': str(error)}), 500


if __name__ == '__main__':
    print("=" * 60)
    print("Hungarian Football Data API - Local Test Server")
    print("=" * 60)
    print("\nServer starting on http://localhost:5000")
    print("\nAvailable endpoints:")
    print("  GET http://localhost:5000/")
    print("      - API documentation")
    print("\n  GET http://localhost:5000/federations")
    print("      - Get all football federations")
    print("\n  GET http://localhost:5000/seasons")
    print("      - Get all seasons")
    print("\n  GET http://localhost:5000/basicData")
    print("      - Get federations and seasons combined")
    print("\n  GET http://localhost:5000/leagues/2023/1")
    print("      - Get leagues for season 2023, federation 1")
    print("\n  GET http://localhost:5000/rounds/2023/1/1")
    print("      - Get rounds for season 2023, federation 1, league 1")
    print("\n  GET http://localhost:5000/results/2023/1/1/1")
    print("      - Get results for round 1")
    print("\n  GET http://localhost:5000/standings/2023/1/1/1")
    print("      - Get standings for round 1")
    print("\n" + "=" * 60)
    print("Press Ctrl+C to stop the server")
    print("=" * 60 + "\n")

    app.run(host='0.0.0.0', port=5000, debug=True)
