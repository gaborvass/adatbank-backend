#!/usr/bin/env python3
"""
Simple CLI test script for Lambda handlers.
Tests handlers directly without any web server.

Usage:
    python test_handlers_cli.py                    # Test basic endpoints
    python test_handlers_cli.py leagues 2023 1     # Test leagues endpoint
    python test_handlers_cli.py rounds 2023 1 1    # Test rounds endpoint
    python test_handlers_cli.py results 2023 1 1 1 # Test results endpoint
    python test_handlers_cli.py standings 2023 1 1 1 # Test standings endpoint
"""

import sys
import os
import json

# Add lambda directory to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'lambda'))

from handlers import federations, seasons, basic_data, leagues, rounds, results, standings


def call_lambda_handler(handler_func, path_params=None, name="Handler"):
    """
    Call a Lambda handler with an API Gateway-like event structure.

    Args:
        handler_func: The Lambda handler function
        path_params: Dictionary of path parameters
        name: Name of the handler for display
    """
    event = {
        'pathParameters': path_params,
        'body': None,
        'queryStringParameters': None,
        'headers': {},
        'httpMethod': 'GET'
    }

    print(f"\n{'=' * 60}")
    print(f"Testing: {name}")
    print(f"{'=' * 60}")

    if path_params:
        print(f"Path Parameters: {json.dumps(path_params, indent=2)}")

    print(f"\nCalling handler...")

    try:
        result = handler_func.lambda_handler(event, None)
        status_code = result.get('statusCode', 500)
        body = result.get('body', '{}')

        print(f"Status Code: {status_code}")

        # Try to parse and pretty-print JSON
        try:
            body_json = json.loads(body)
            print(f"\nResponse:")
            print(json.dumps(body_json, indent=2, ensure_ascii=False))
        except json.JSONDecodeError:
            print(f"\nResponse (raw):")
            print(body)

        return status_code, body

    except Exception as e:
        print(f"ERROR: {str(e)}")
        import traceback
        traceback.print_exc()
        return 500, json.dumps({'error': str(e)})


def main():
    """Main entry point for CLI testing."""
    print("=" * 60)
    print("Hungarian Football Data API - CLI Test Tool")
    print("=" * 60)

    # Parse command line arguments
    if len(sys.argv) < 2:
        # Test all basic endpoints
        print("\nTesting basic endpoints (no parameters required)...\n")

        call_lambda_handler(federations, name="GET /federations")
        call_lambda_handler(seasons, name="GET /seasons")
        call_lambda_handler(basic_data, name="GET /basicData")

        print("\n" + "=" * 60)
        print("Tip: Test parameterized endpoints with:")
        print("  python test_handlers_cli.py leagues <seasonId> <federationId>")
        print("  python test_handlers_cli.py rounds <seasonId> <federationId> <leagueId>")
        print("  python test_handlers_cli.py results <seasonId> <federationId> <leagueId> <roundId>")
        print("  python test_handlers_cli.py standings <seasonId> <federationId> <leagueId> <roundId>")
        print("=" * 60)

        return

    # Parse specific endpoint
    endpoint = sys.argv[1].lower()

    if endpoint == "leagues":
        if len(sys.argv) < 4:
            print("Usage: python test_handlers_cli.py leagues <seasonId> <federationId>")
            return
        call_lambda_handler(leagues, {
            'seasonId': sys.argv[2],
            'federationId': sys.argv[3]
        }, name=f"GET /leagues/{sys.argv[2]}/{sys.argv[3]}")

    elif endpoint == "rounds":
        if len(sys.argv) < 5:
            print("Usage: python test_handlers_cli.py rounds <seasonId> <federationId> <leagueId>")
            return
        call_lambda_handler(rounds, {
            'seasonId': sys.argv[2],
            'federationId': sys.argv[3],
            'leagueId': sys.argv[4]
        }, name=f"GET /rounds/{sys.argv[2]}/{sys.argv[3]}/{sys.argv[4]}")

    elif endpoint == "results":
        if len(sys.argv) < 6:
            print("Usage: python test_handlers_cli.py results <seasonId> <federationId> <leagueId> <roundId>")
            return
        call_lambda_handler(results, {
            'seasonId': sys.argv[2],
            'federationId': sys.argv[3],
            'leagueId': sys.argv[4],
            'roundId': sys.argv[5]
        }, name=f"GET /results/{sys.argv[2]}/{sys.argv[3]}/{sys.argv[4]}/{sys.argv[5]}")

    elif endpoint == "standings":
        if len(sys.argv) < 6:
            print("Usage: python test_handlers_cli.py standings <seasonId> <federationId> <leagueId> <roundId>")
            return
        call_lambda_handler(standings, {
            'seasonId': sys.argv[2],
            'federationId': sys.argv[3],
            'leagueId': sys.argv[4],
            'roundId': sys.argv[5]
        }, name=f"GET /standings/{sys.argv[2]}/{sys.argv[3]}/{sys.argv[4]}/{sys.argv[5]}")

    else:
        print(f"Unknown endpoint: {endpoint}")
        print("Available endpoints: leagues, rounds, results, standings")
        print("Or run without arguments to test basic endpoints (federations, seasons, basicData)")


if __name__ == '__main__':
    main()
