#!/bin/bash

# Generate CHANGELOG.md from git history since last tag

# Get the latest tag
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null)

if [ -z "$LATEST_TAG" ]; then
    echo "No tags found. Generating changelog from all commits."
    COMMIT_RANGE="HEAD"
    PREVIOUS_TAG="Initial"
else
    echo "Generating changelog since $LATEST_TAG"
    COMMIT_RANGE="$LATEST_TAG..HEAD"
    PREVIOUS_TAG="$LATEST_TAG"
fi

# Check if there are any commits
COMMIT_COUNT=$(git log --oneline $COMMIT_RANGE | wc -l)
if [ "$COMMIT_COUNT" -eq 0 ]; then
    echo "No commits found since last tag."
    exit 0
fi

# Create CHANGELOG.md
{
    echo "# Changelog"
    echo ""
    echo "All notable changes to this project will be documented in this file."
    echo ""
    
    # Get current version info
    VERSION=$(git describe --tags 2>/dev/null || echo "Unreleased")
    DATE=$(date +%Y-%m-%d)
    
    echo "## [Unreleased]"
    echo ""
    
    # Arrays to hold commits by category
    ADDED=()
    FIXED=()
    CHANGED=()
    REMOVED=()
    
    # Process commits
    while IFS=$'\t' read -r hash subject; do
        # Skip merge commits
        if [[ "$subject" =~ ^Merge ]]; then
            continue
        fi
        
        # Convert to lowercase for matching
        lower_subject=$(echo "$subject" | tr '[:upper:]' '[:lower:]')
        
        if [[ "$lower_subject" =~ ^feat|^add|^feature ]]; then
            ADDED+=("- $subject")
        elif [[ "$lower_subject" =~ ^fix|^bug|^hotfix ]]; then
            FIXED+=("- $subject")
        elif [[ "$lower_subject" =~ ^remove|^delete ]]; then
            REMOVED+=("- $subject")
        else
            # Default to Changed for other commits (docs, chore, refactor, etc.)
            CHANGED+=("- $subject")
        fi
    done < <(git log --pretty=format:"%H%x09%s" $COMMIT_RANGE)
    
    # Output sections
    if [ ${#ADDED[@]} -gt 0 ]; then
        echo "### Added"
        echo ""
        printf '%s\n' "${ADDED[@]}"
        echo ""
    fi
    
    if [ ${#CHANGED[@]} -gt 0 ]; then
        echo "### Changed"
        echo ""
        printf '%s\n' "${CHANGED[@]}"
        echo ""
    fi
    
    if [ ${#FIXED[@]} -gt 0 ]; then
        echo "### Fixed"
        echo ""
        printf '%s\n' "${FIXED[@]}"
        echo ""
    fi
    
    if [ ${#REMOVED[@]} -gt 0 ]; then
        echo "### Removed"
        echo ""
        printf '%s\n' "${REMOVED[@]}"
        echo ""
    fi
    
} > CHANGELOG.md

chmod +x changelog.sh
echo "CHANGELOG.md generated successfully!"
