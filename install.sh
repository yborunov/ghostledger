#!/bin/bash

# GhostLedger Boilerplate Install Script
# Usage: curl -sL https://raw.githubusercontent.com/yborunov/GhostLedger/main/install.sh | bash
#
# This script creates a new working repository from the GhostLedger boilerplate.
# It downloads the latest boilerplate, prompts for configuration, and sets up the working directory.

set -e

BOILERPLATE_URL="https://github.com/yborunov/GhostLedger"
BOILERPLATE_REF="main"
TEMP_DIR=$(mktemp -d)
CURRENT_YEAR=$(date +%Y)
INVOCATION_DIR=$(pwd -P)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

cleanup() {
  rm -rf "$TEMP_DIR"
}

trap cleanup EXIT

print_header() {
  echo -e "${BLUE}================================${NC}"
  echo -e "${BLUE}GhostLedger Boilerplate Installer${NC}"
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

print_info() {
  echo -e "${CYAN}ℹ${NC} $1"
}

validate_target_path() {
  local path="$1"
  
  # Check if path already exists
  if [[ -e "$path" ]]; then
    print_error "Directory already exists: $path"
    print_info "Remove it first with: rm -rf $path"
    exit 1
  fi
}

download_boilerplate() {
  echo ""
  echo "Downloading boilerplate from GitHub..."
  echo "  Source: ${BOILERPLATE_URL} (${BOILERPLATE_REF} branch)"
  echo "  This may take a few seconds..."
  echo ""
  
  local download_url="${BOILERPLATE_URL}/archive/refs/heads/${BOILERPLATE_REF}.tar.gz"
  local original_dir=$(pwd)
  
  cd "$TEMP_DIR"
  
  # Download using curl or wget with progress
  if command -v curl &> /dev/null; then
    echo -n "  [0%] Downloading..."
    if ! curl -#L "$download_url" --progress-bar | tar -xz --strip-components=1 2>/dev/null; then
      echo ""
      print_error "Failed to download boilerplate. Check your internet connection."
      echo "  URL: $download_url"
      exit 1
    fi
    echo "  [100%]"
  elif command -v wget &> /dev/null; then
    echo -n "  [0%] Downloading..."
    if ! wget --progress=dot -qO- "$download_url" 2>&1 | tar -xz --strip-components=1 2>/dev/null; then
      echo ""
      print_error "Failed to download boilerplate. Check your internet connection."
      echo "  URL: $download_url"
      exit 1
    fi
    echo "  [100%]"
  else
    print_error "Neither curl nor wget found. Please install one of them."
    exit 1
  fi
  
  # Count files
  local file_count=$(find . -type f ! -path "./.git/*" 2>/dev/null | wc -l)
  print_success "Downloaded boilerplate (${file_count} files)"
  
  # Return to original directory
  cd "$original_dir"
}

replace_placeholders() {
  local file="$1"
  local company_name="$2"
  local year="$3"

  # macOS uses BSD sed which requires different syntax
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/<COMPANY_NAME>/$company_name/g" "$file" 2>/dev/null || true
    sed -i '' "s/<YEAR>/$year/g" "$file" 2>/dev/null || true
  else
    sed -i "s/<COMPANY_NAME>/$company_name/g" "$file" 2>/dev/null || true
    sed -i "s/<YEAR>/$year/g" "$file" 2>/dev/null || true
  fi
}

setup_working_directory() {
  local target_path="$1"
  local company_name="$2"
  local year="$3"
  
  echo ""
  echo "Setting up working directory..."
  
  # Create target directory
  mkdir -p "$target_path"
  
  # Copy all boilerplate files except install.sh, update.sh, and git files
  while IFS= read -r file; do
    # Remove ./ prefix from relative paths
    local rel_path="${file#./}"
    local dest_file="$target_path/$rel_path"
    
    # Skip certain files
    if [[ "$rel_path" == "install.sh" ]] || [[ "$rel_path" == "update.sh" ]] || [[ "$rel_path" == "update-test.sh" ]]; then
      continue
    fi
    
    # Skip .git directory and git files
    if [[ "$rel_path" == .git* ]] || [[ "$rel_path" == *.git* ]]; then
      continue
    fi
    
    # Create directory if needed
    mkdir -p "$(dirname "$dest_file")" 2>/dev/null || true
    
    # Copy file (use full path to source since we're not in TEMP_DIR)
    cp "$TEMP_DIR/$file" "$dest_file"
    
    # Replace placeholders in text files
    if file "$dest_file" | grep -q "text\|ASCII"; then
      replace_placeholders "$dest_file" "$company_name" "$year"
    fi
    
  done < <(cd "$TEMP_DIR" && find . -type f -print 2>/dev/null)
  
  # Rename <YEAR> folders to actual year
  find "$target_path" -type d -name "*<YEAR>*" 2>/dev/null | while read -r dir; do
    local new_dir="${dir/<YEAR>/$year}"
    if [[ "$dir" != "$new_dir" ]]; then
      mv "$dir" "$new_dir" 2>/dev/null || true
    fi
  done
  
  print_success "Created working directory: $target_path"
}

print_next_steps() {
  local target_path="$1"
  local company_name="$2"
  local year="$3"
  
  echo ""
  echo -e "${BLUE}================================${NC}"
  echo -e "${GREEN}Installation Complete!${NC}"
  echo -e "${BLUE}================================${NC}"
  echo ""
  echo "Your working repository is ready at:"
  echo -e "  ${CYAN}$target_path${NC}"
  echo ""
  echo "Configuration:"
  echo "  Company: $company_name"
  echo "  Year: $year"
  echo ""
  echo "Next steps:"
  echo "  1. cd $target_path"
  echo "  2. Add your transaction files to transaction-imports/${year}/"
  echo "  3. Add invoices/receipts to expenses/${year}/"
  echo "  4. Create ledger entries in imports/${year}/"
  echo "  5. Update main.ledger with your bank/card file names"
  echo ""
  echo "To pull updates from the boilerplate later, run:"
  echo -e "  ${CYAN}curl -sL https://raw.githubusercontent.com/yborunov/GhostLedger/main/update.sh | bash${NC}"
  echo ""
  echo "For help, see the README.md in your working directory."
}

main() {
  print_header
  
  # Check prerequisites
  if ! command -v curl &> /dev/null && ! command -v wget &> /dev/null; then
    print_error "Neither curl nor wget is installed. Please install one of them."
    exit 1
  fi
  
  # Configuration
  echo "Configuration"
  echo "-------------"
  local company_name="<COMPANY_NAME>"
  local target_path="ghostledger"
  print_info "Using year: $CURRENT_YEAR"
  print_info "Target directory: $target_path"
  print_info "Company name: $company_name (configure manually in main.ledger)"
  
  # Validate target path
  validate_target_path "$target_path"
  
  # Download boilerplate
  echo ""
  echo "Download and Setup"
  echo "------------------"
  download_boilerplate
  
  # Setup working directory
  setup_working_directory "$target_path" "$company_name" "$CURRENT_YEAR"
  
  # Print next steps
  print_next_steps "$target_path" "$company_name" "$CURRENT_YEAR"
}

main "$@"
