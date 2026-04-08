# Testing Lambda Handlers Locally

This document describes how to test the Lambda handlers locally without deploying to AWS.

## Prerequisites

Install Python dependencies for local testing:

```bash
pip install -r requirements.txt
pip install flask  # For the local test server
```

## Option 1: CLI Test Script (Simplest)

The CLI test script calls Lambda handlers directly without any web server.

### Test Basic Endpoints (no parameters)

```bash
python test_handlers_cli.py
```

This will test:
- GET /federations
- GET /seasons
- GET /basicData

### Test Parameterized Endpoints

```bash
# Get leagues for season 2023, federation 1
python test_handlers_cli.py leagues 2023 1

# Get rounds for season 2023, federation 1, league 1
python test_handlers_cli.py rounds 2023 1 1

# Get results for round 1
python test_handlers_cli.py results 2023 1 1 1

# Get standings for round 1
python test_handlers_cli.py standings 2023 1 1 1
```

## Option 2: Local Web Server (Flask)

The Flask server mimics API Gateway and runs a local HTTP server.

### Start the Server

```bash
python test_local_server.py
```

The server will start on `http://localhost:5000`

### Test with curl

```bash
# Get API documentation
curl http://localhost:5000/

# Get federations
curl http://localhost:5000/federations

# Get seasons
curl http://localhost:5000/seasons

# Get basic data
curl http://localhost:5000/basicData

# Get leagues
curl http://localhost:5000/leagues/2023/1

# Get rounds
curl http://localhost:5000/rounds/2023/1/1

# Get results
curl http://localhost:5000/results/2023/1/1/1

# Get standings
curl http://localhost:5000/standings/2023/1/1/1
```

### Test with Browser

Simply open `http://localhost:5000/` in your browser for API documentation, then navigate to any endpoint.

## Option 3: Python Shell

For quick debugging, you can also test directly in a Python shell:

```bash
python
```

```python
import sys
sys.path.insert(0, 'lambda')

from data_loader import DataLoader
from data_parser import DataParser

loader = DataLoader()
parser = DataParser()

# Test federations
raw = loader.load_raw_basic_data()
federations = parser.parse_federations(raw)
print(f"Found {len(federations)} federations")
for f in federations:
    print(f"  - {f.federation_name} (ID: {f.federation_id})")

# Test seasons
seasons = parser.parse_seasons(raw)
print(f"Found {len(seasons)} seasons")
for s in seasons:
    print(f"  - {s.season_name} (ID: {s.season_id}, Current: {s.is_current})")
```

## Option 4: Run Unit Tests

```bash
# Install pytest
pip install pytest

# Run tests
pytest tests/test_handlers.py -v

# Run with coverage
pip install pytest-cov
pytest tests/test_handlers.py -v --cov=lambda --cov-report=html
```

## Troubleshooting

### SSL Certificate Errors

If you get SSL certificate errors when connecting to adatbank.mlsz.hu, the external website may be using self-signed certificates or have certificate issues. This is outside our control.

### Timeout Errors

If requests timeout, the external website may be slow or unavailable. You can increase the timeout in `lambda/data_loader.py`:

```python
loader = DataLoader(timeout=60)  # 60 seconds instead of 30
```

### Empty Results

If you get empty results, the HTML structure of adatbank.mlsz.hu may have changed. You'll need to update the CSS selectors in `lambda/data_parser.py`.

### Import Errors

Make sure you're running from the project root directory:

```bash
cd /Users/gabor.vass/code/adatbank-backend
python test_handlers_cli.py
```

## What Gets Tested

| Endpoint | Data Source | What It Returns |
|----------|-------------|-----------------|
| `/federations` | HTML page | List of football federations |
| `/seasons` | HTML page | List of seasons with current flag |
| `/basicData` | HTML page | Combined federations + seasons |
| `/leagues/{s}/{f}` | JSON API | Leagues for season/federation |
| `/rounds/{s}/{f}/{l}` | JSON API | Rounds with current flag |
| `/results/.../{r}` | HTML page | Match results for round |
| `/standings/.../{r}` | HTML page | League standings table |

## Comparison with AWS Lambda

These local tests use the exact same code that will run in AWS Lambda. The only difference is:

- **Local**: Python/Flask server calls handler functions directly
- **AWS**: API Gateway calls handler functions via Lambda

The Lambda handlers receive the same event structure in both cases, so if it works locally, it should work in AWS (assuming networking/permissions are correct).
