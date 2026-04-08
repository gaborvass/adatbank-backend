"""
Lambda handler for basic data endpoint (combined federations + seasons).
GET /basicData
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
    Lambda handler for fetching basic data (federations and seasons combined).

    Args:
        event: API Gateway Lambda proxy event
        context: Lambda context object

    Returns:
        API Gateway Lambda proxy response
    """
    try:
        # Load raw data once
        raw_data = loader.load_raw_basic_data()

        # Parse both federations and seasons from same HTML
        federations = parser.parse_federations(raw_data)
        seasons = parser.parse_seasons(raw_data)

        # Convert to JSON-serializable format
        federations_data = [f.to_dict() for f in federations]
        seasons_data = [s.to_dict() for s in seasons]

        response_body = {
            'federations': federations_data,
            'seasons': seasons_data
        }

        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json; charset=utf-8',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps(response_body, ensure_ascii=False)
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
