# Hungarian Football Data API - AWS Lambda

Serverless implementation of the Hungarian Football Data API using AWS Lambda and API Gateway.

## Overview

This project converts the Swift Vapor 2 application to AWS Lambda functions written in Python. The Lambda functions scrape football data from adatbank.mlsz.hu and expose it via API Gateway.

## Architecture

- **7 Lambda Functions** (one per endpoint)
- **API Gateway** for REST API exposure
- **Lambda Layer** for shared dependencies
- **AWS SAM** for infrastructure as code deployment

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/federations` | Get all football federations |
| GET | `/seasons` | Get all seasons |
| GET | `/basicData` | Get federations and seasons combined |
| GET | `/leagues/{seasonId}/{federationId}` | Get leagues for a season/federation |
| GET | `/rounds/{seasonId}/{federationId}/{leagueId}` | Get rounds for a league |
| GET | `/results/{seasonId}/{federationId}/{leagueId}/{roundId}` | Get match results |
| GET | `/standings/{seasonId}/{federationId}/{leagueId}/{roundId}` | Get league standings |

## Project Structure

```
adatbank-backend/
├── template.yaml              # AWS SAM template
├── requirements.txt           # Python dependencies
├── lambda/
│   ├── models.py              # Data models (dataclasses)
│   ├── data_loader.py         # HTTP client for scraping
│   ├── data_parser.py         # HTML/JSON parsing logic
│   └── handlers/
│       ├── federations.py     # GET /federations
│       ├── seasons.py         # GET /seasons
│       ├── basic_data.py      # GET /basicData
│       ├── leagues.py         # GET /leagues/{...}
│       ├── rounds.py          # GET /rounds/{...}
│       ├── results.py         # GET /results/{...}
│       └── standings.py       # GET /standings/{...}
└── dependencies/              # Lambda layer (created during build)
    └── python/
        └── ... (installed packages)
```

## Prerequisites

- AWS CLI installed and configured
- AWS SAM CLI installed
- Python 3.11+
- An AWS account with appropriate permissions

## Local Development

1. **Install dependencies locally:**
   ```bash
   pip install -r requirements.txt
   ```

2. **Run SAM locally (optional):**
   ```bash
   sam build
   sam local start-api
   ```

3. **Test endpoints:**
   ```bash
   curl http://localhost:3000/federations
   curl http://localhost:3000/seasons
   ```

## Deployment

### Step 1: Build the Lambda Layer

First, create the dependencies directory for the Lambda layer:

```bash
# Create dependencies directory structure
mkdir -p dependencies/python

# Install dependencies into the layer directory
pip install -r requirements.txt -t dependencies/python

# Verify the structure
ls dependencies/python/
# Should see: beautifulsoup4, bs4, lxml, requests, etc.
```

### Step 2: Build the SAM Application

```bash
sam build
```

### Step 3: Deploy to AWS

First-time deployment (guided mode):

```bash
sam deploy --guided
```

You'll be prompted for:
- Stack name (e.g., `hungarian-football-api`)
- AWS Region (e.g., `eu-central-1`)
- Confirm changes before deploy
- Allow SAM CLI IAM role creation
- Save arguments to `samconfig.toml`

Subsequent deployments:

```bash
sam deploy
```

### Step 4: Get the API URL

After deployment, SAM will output the API URL:

```
ApiUrl https://xxxxxxxxxx.execute-api.eu-central-1.amazonaws.com/Prod
```

Or retrieve it later:

```bash
aws cloudformation describe-stacks \
  --stack-name hungarian-football-api \
  --query 'Stacks[0].Outputs[?OutputKey==`ApiUrl`].OutputValue' \
  --output text
```

## Testing the Deployed API

```bash
# Set your API URL
API_URL="https://xxxxxxxxxx.execute-api.eu-central-1.amazonaws.com/Prod"

# Get federations
curl $API_URL/federations

# Get seasons
curl $API_URL/seasons

# Get basic data (both federations and seasons)
curl $API_URL/basicData

# Get leagues for a specific season and federation
curl $API_URL/leagues/2023/1

# Get rounds
curl $API_URL/rounds/2023/1/1

# Get results
curl $API_URL/results/2023/1/1/1

# Get standings
curl $API_URL/standings/2023/1/1/1
```

## Monitoring and Logs

### View CloudWatch Logs

```bash
# List all log groups for the functions
aws logs describe-log-groups \
  --log-group-name-prefix /aws/lambda/hungarian-football-api

# Tail logs for a specific function
sam logs --tail --name FederationsFunction
```

### Check Lambda Metrics

```bash
# Via AWS Console: CloudWatch > Metrics > Lambda
# Or via AWS CLI for specific metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/Lambda \
  --metric-name Invocations \
  --dimensions Name=FunctionName,Value=FederationsFunction \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-01T23:59:59Z \
  --period 3600 \
  --statistics Sum
```

## Troubleshooting

### Common Issues

1. **Timeout Errors**: Increase timeout in `template.yaml` (default: 30 seconds)
2. **Memory Issues**: Increase memory size (default: 512 MB)
3. **External API Down**: Check if adatbank.mlsz.hu is accessible
4. **CORS Errors**: Verify CORS settings in API Gateway

### Local Testing

Test individual handlers locally:

```bash
# Install dependencies
pip install -r requirements.txt

# Run Python to test
python -c "
from lambda.data_loader import DataLoader
from lambda.data_parser import DataParser

loader = DataLoader()
parser = DataParser()

raw = loader.load_raw_basic_data()
federations = parser.parse_federations(raw)
print(f'Found {len(federations)} federations')
"
```

## Cleanup

To remove all deployed resources:

```bash
sam delete
```

## Cost Optimization

- Lambda pricing is based on execution time and memory
- API Gateway has a free tier and pay-per-request pricing
- Consider enabling Lambda concurrency limits if needed
- Monitor usage with AWS Cost Explorer

## Security Considerations

- API keys can be added via API Gateway usage plans if needed
- Lambda functions have least-privilege IAM roles
- Consider adding WAF for production deployments
- External website scraping should comply with the site's terms of service

## License

This project is a conversion of the original Swift Vapor application for AWS Lambda.
