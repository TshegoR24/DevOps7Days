import os
import sys

# Ensure tests can import sample_app when running from repo root
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))
