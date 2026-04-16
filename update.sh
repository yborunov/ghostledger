#!/bin/bash

# GhostLedger Boilerplate Update Script
# Usage: curl -sL https://raw.githubusercontent.com/yborunov/ghostledger/main/update.sh | bash
#
# This script updates a working repository from the GhostLedger boilerplate.
# It creates backups, auto-replaces placeholders, and preserves user data.

set -e

BOILERPLATE_URL="https://github.com/yborunov/ghostledger"
BOILERPLATE_REF="main"
TEMP_DIR=$(mktemp -d)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Files and directories that should NEVER be touched (user data)
PROTECTED_PATTERNS=(
  "imports/"
  "expenses/"
  "transaction-imports/"
  "reports/"
  "tax/*/*"
  "*.ledger"
)

# Files to update from boilerplate
BOILERPLATE_FILES=(
  "skills/accounting/SKILL.md"
  "skills/tax-us/SKILL.md"
  "skills/tax-ca/SKILL.md"
  "README.md"
  ".gitignore"
  "tax/<YEAR>/README.md"
)

# Template files that need placeholder replacement
TEMPLATE_FILES=(
  "main.ledger"
)

cleanup() {
  rm -rf "$TEMP_DIR"
}

trap cleanup EXIT

print_header() {
  echo -e "${BLUE}================================${NC}"
  echo -e "${BLUE}GhostLedger Boilerplate Updater${NC}"
  echo -e "${BLUE}================================${NC}"
  echo ""
}

print_success() {
  echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
  echo -e "${RED}✗${NC} $1"
}

detect_placeholders() {
  local company_name=""
  local year=""

  # Try to detect COMPANY_NAME from main.ledger
  # Look for pattern: "; Company Name Ledger"
  if [[ -f "main.ledger" ]]; then
    company_name=$(head -1 main.ledger | sed 's/^; //' | sed 's/ Ledger$//' || true)
  fi

  # Try to detect YEAR from folder structure
  if [[ -d "imports" ]]; then
    year=$(ls -d imports/*/ 2>/dev/null | head -1 | sed 's/imports\///' | sed 's/\///' || true)
  fi

  # If not detected, use defaults
  if [[ -z "$company_name" ]]; then
    company_name="<COMPANY_NAME>"
    print_warning "Could not auto-detect company name. Using placeholder."
  fi

  if [[ -z "$year" ]]; then
    year="<YEAR>"
    print_warning "Could not auto-detect year. Using placeholder."
  fi

  echo "COMPANY_NAME=$company_name"
  echo "YEAR=$year"
}

replace_placeholders() {
  local file="$1"
  local company_name="$2"
  local year="$3"

  # macOS uses BSD sed which requires different syntax
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/<COMPANY_NAME>/$company_name/g" "$file"
    sed -i '' "s/<YEAR>/$year/g" "$file"
  else
    sed -i "s/<COMPANY_NAME>/$company_name/g" "$file"
    sed -i "s/<YEAR>/$year/g" "$file"
  fi
}

is_protected() {
  local file="$1"
  for pattern in "${PROTECTED_PATTERNS[@]}"; do
    if [[ "$file" == $pattern ]] || [[ "$file" == */$pattern* ]]; then
      return 0
    fi
  done
  return 1
}

download_boilerplate() {
  echo "Downloading latest boilerplate..."
  cd "$TEMP_DIR"
  git clone --depth 1 --branch "$BOILERPLATE_REF" "$BOILERPLATE_URL" . 2>/dev/null || {
    print_error "Failed to download boilerplate. Check your internet connection."
    exit 1
  }
  print_success "Downloaded boilerplate from $BOILERPLATE_REF"
}

get_boilerplate_commit() {
  cd "$TEMP_DIR"
  git rev-parse HEAD
}

backup_file() {
  local file="$1"
  if [[ -f "$file" ]]; then
    cp "$file" "${file}.bak"
    echo "  Backup: ${file}.bak"
  fi
}

update_file() {
  local src="$1"
  local dest="$2"
  local company_name="$3"
  local year="$4"

  if [[ -f "$src" ]]; then
    backup_file "$dest"
    cp "$src" "$dest"
    replace_placeholders "$dest" "$company_name" "$year"
    print_success "Updated: $dest"
    return 0
  fi
  return 1
}

main() {
  print_header

  # Detect placeholders from current repo
  echo "Detecting current values..."
  local placeholder_output
  placeholder_output=$(detect_placeholders)
  COMPANY_NAME=$(echo "$placeholder_output" | grep "^COMPANY_NAME=" | cut -d'=' -f2-)
  YEAR=$(echo "$placeholder_output" | grep "^YEAR=" | cut -d'=' -f2-)
  echo "  Company: $COMPANY_NAME"
  echo "  Year: $YEAR"
  echo ""

  # Download boilerplate
  download_boilerplate
  BOILERPLATE_COMMIT=$(get_boilerplate_commit)
  echo "  Commit: ${BOILERPLATE_COMMIT:0:7}"
  echo ""

  # Track changes
  local updated_count=0
  local added_count=0
  local skipped_count=0

  # Update boilerplate files
  echo "Updating boilerplate files..."
  for file in "${BOILERPLATE_FILES[@]}"; do
    # Replace <YEAR> placeholder in path
    local dest_file="${file/<YEAR>/$YEAR}"
    local src_file="$TEMP_DIR/$file"

    if [[ -f "$src_file" ]]; then
      if update_file "$src_file" "$dest_file" "$COMPANY_NAME" "$YEAR"; then
        ((updated_count++))
      fi
    else
      print_warning "Source file not found: $src_file"
    fi
  done
  echo ""

  # Update template files
  echo "Updating template files..."
  for file in "${TEMPLATE_FILES[@]}"; do
    local src_file="$TEMP_DIR/$file"
    if [[ -f "$src_file" ]]; then
      backup_file "$file"
      cp "$src_file" "$file"
      replace_placeholders "$file" "$COMPANY_NAME" "$YEAR"
      print_success "Updated: $file"
      ((updated_count++))
    fi
  done
  echo ""

  # Copy new files from boilerplate
  echo "Checking for new files..."
  while IFS= read -r src_file; do
    local rel_path="${src_file#$TEMP_DIR/}"
    # Replace <YEAR> in path with actual year
    local dest_file="${rel_path/<YEAR>/$YEAR}"

    # Skip protected patterns
    if is_protected "$rel_path"; then
      continue
    fi

    # Skip if file already exists
    if [[ -f "$dest_file" ]]; then
      continue
    fi

    # Create directory if needed
    mkdir -p "$(dirname "$dest_file")" 2>/dev/null || true

    cp "$src_file" "$dest_file"
    replace_placeholders "$dest_file" "$COMPANY_NAME" "$YEAR"
    print_success "Added new: $dest_file"
    ((added_count++))
  done < <(find "$TEMP_DIR" -type f ! -path "*/.git/*" ! -name ".gitignore" ! -name "update.sh" ! -name "update-test.sh" ! -name "*.bak" 2>/dev/null)
  echo ""

  # Create/update version file
  echo "$BOILERPLATE_COMMIT" > .boilerplate-version
  echo "Boilerplate version: ${BOILERPLATE_COMMIT:0:7}" > .boilerplate-version
  print_success "Updated .boilerplate-version"
  echo ""

  # Summary
  echo -e "${BLUE}================================${NC}"
  echo -e "${GREEN}Update Complete!${NC}"
  echo -e "${BLUE}================================${NC}"
  echo ""
  echo "Summary:"
  echo "  Files updated: $updated_count"
  echo "  Files added: $added_count"
  echo "  Boilerplate version: ${BOILERPLATE_COMMIT:0:7}"
  echo ""
  echo "Notes:"
  echo "  - .bak files created for any replaced files"
  echo "  - User data (imports, expenses, reports) was not touched"
  echo "  - Placeholders auto-replaced with detected values"
  echo ""
  echo "To see what changed, check:"
  echo "  - .boilerplate-version (current version)"
  echo "  - Any .bak files (previous versions of updated files)"
}

main "$@"
