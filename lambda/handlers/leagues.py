"""
Lambda handler for leagues endpoint.
GET /leagues/{seasonId}/{federationId}
"""

import json
from typing import Any, Dict
from data_loader import DataLoader, DataLoaderError
from data_parser import DataParser


# Initialize outside handler for connection reuse
loader = DataLoader()
parser = DataParser()


def lambda_handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """
    Lambda handler for fetching leagues for a given season and federation.

    Path Parameters:
        seasonId: The season ID
        federationId: The federation ID

    Args:
        event: API Gateway Lambda proxy event
        context: Lambda context object

    Returns:
        API Gateway Lambda proxy response
    """
    try:
        # Extract path parameters
        path_params = event.get('pathParameters', {})
        season_id = path_params.get('seasonId', '')
        federation_id = path_params.get('federationId', '')

        if not season_id or not federation_id:
            return {
                'statusCode': 400,
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                'body': json.dumps({'error': 'Missing required parameters: seasonId, federationId'})
            }

        # Load raw data
        raw_data = loader.load_raw_leagues(season_id, federation_id)

        # Parse leagues
        leagues = parser.parse_leagues(raw_data)

        # Convert to JSON-serializable format
        response_data = [l.to_dict() for l in leagues]

        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json; charset=utf-8',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps(response_data, ensure_ascii=False)
        }

    except DataLoaderError as e:
        return {
            'statusCode': 502,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({'error': f'Failed to load data: {str(e)}'})
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({'error': f'Internal server error: {str(e)}'})
        }
