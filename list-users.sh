#!/bin/bash

# GitHub API base URL
API_URL="https://api.github.com"

# Check if required arguments are provided
if [ $# -lt 2 ]; then
  echo "Usage: $0 <repo_owner> <repo_name>"
  exit 1
fi

REPO_OWNER="$1"
REPO_NAME="$2"

# Prompt for GitHub credentials
read -p "Enter your GitHub username: " USERNAME
read -s -p "Enter your GitHub token: " TOKEN
echo ""

# Function to make GET request to GitHub API
function github_api_get {
    local endpoint="$1"
    local url="${API_URL}/${endpoint}"
    curl -s -u "${USERNAME}:${TOKEN}" "$url"
}

# Function to list users with read access
function list_users_with_read_access {
    local endpoint="repos/${REPO_OWNER}/${REPO_NAME}/collaborators"
    collaborators="$(github_api_get "$endpoint")"

    if echo "$collaborators" | grep -q '"message":'; then
        echo "GitHub API Error:"
        echo "$collaborators" | jq
        exit 1
    fi

    echo "Users with read access to ${REPO_OWNER}/${REPO_NAME}:"
    echo "$collaborators" | jq -r '.[] | "\(.login) (\(.permissions | to_entries[] | select(.value == true).key))"'
}

# Run it
echo "Listing users with read access to ${REPO_OWNER}/${REPO_NAME}..."
list_users_with_read_access

