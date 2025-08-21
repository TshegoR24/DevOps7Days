import sys
from pathlib import Path

# Add Day3_CICD to sys.path so tests can import app.py
BASE_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(BASE_DIR))
