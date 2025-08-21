# Day 3  CI/CD Pipelines

## Overview
This folder contains a minimal Python app and tests used to demonstrate CI/CD with GitHub Actions.

## What's included
- app.py: tiny example function
- test_app.py: pytest test for the app
- conftest.py: makes the package importable during tests

## Workflows
- .github/workflows/ci-hello.yml: Hello World pipeline
- .github/workflows/ci-tests.yml: Minimal pytest + deploy + artifact + optional Slack
- .github/workflows/day3-ci.yml: Full CI (flake8 scoped to Day3, pytest, ShellCheck, PSScriptAnalyzer, optional Slack)

## Running tests locally
```bash
pip install -U pip pytest
pytest -q Day3_CICD
```

## Optional: Slack notifications
1) In GitHub  Settings  Secrets and variables  Actions  New repository secret
2) Name: SLACK_WEBHOOK
3) Value: Your Slack Incoming Webhook URL

## Artifacts (CI)
- The minimal workflow uploads a deploy/ folder as an artifact
- Download it from the workflow run page under Artifacts

## Troubleshooting
- If CI fails on flake8, check spacing/blank lines and fix per errors
- If pytest fails, run tests locally to reproduce: `pytest -q Day3_CICD`
- If Slack step fails, ensure SLACK_WEBHOOK is set or leave it unset (it is guarded)

## Screenshots (placeholders)
![Actions runs](./images/actions_runs.png)
![Green tests](./images/green_tests.png)

## Jenkins (optional)
If you prefer Jenkins, install it and create a freestyle job or Pipeline that:
- Checks out this repo
- Sets up Python and runs pytest
- Archives the deploy/ artifact

