#!/bin/bash
# Script to add a new Linux user

if [ -z "$1" ]; then
  echo "Usage: $0 username"
  exit 1
fi

sudo useradd -m $1
echo "User $1 created successfully."
