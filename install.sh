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

prompt_company_name() {
  local company_name=""
  while [[ -z "$company_name" ]]; do
    # Read from /dev/tty to work when script is piped
    read -r -p "Enter company name (e.g., 'BYREASON LLC'): " company_name < /dev/tty
    if [[ -z "$company_name" ]]; then
      print_error "Company name is required."
    fi
  done
  echo "$company_name"
}

prompt_target_path() {
  local target_path=""
  while [[ -z "$target_path" ]]; do
    # Read from /dev/tty to work when script is piped
    read -r -p "Enter target directory path (e.g., './my-company-accounting' or '/full/path/to/dir'): " target_path < /dev/tty
    if [[ -z "$target_path" ]]; then
      print_error "Target path is required."
    fi
  done
  
  # Expand tilde to home directory
  target_path="${target_path/#\~/$HOME}"
  
  echo "$target_path"
}

validate_path() {
  local path="$1"
  
  # Check if path already exists
  if [[ -e "$path" ]]; then
    print_error "Path already exists: $path"
    read -r -p "Do you want to overwrite it? (y/N): " confirm < /dev/tty
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
      rm -rf "$path"
      print_warning "Removed existing directory: $path"
    else
      print_error "Installation cancelled."
      exit 1
    fi
  fi
  
  # Check if parent directory exists
  local parent_dir=$(dirname "$path")
  if [[ ! -d "$parent_dir" ]]; then
    read -r -p "Parent directory doesn't exist. Create it? (Y/n): " confirm < /dev/tty
    if [[ "$confirm" =~ ^[Nn]$ ]]; then
      print_error "Installation cancelled."
      exit 1
    fi
    mkdir -p "$parent_dir"
    print_success "Created parent directory: $parent_dir"
  fi
}

download_boilerplate() {
  echo ""
  echo "Downloading boilerplate from GitHub..."
  echo "  Source: ${BOILERPLATE_URL} (${BOILERPLATE_REF} branch)"
  echo "  This may take a few seconds..."
  echo ""
  
  cd "$TEMP_DIR"
  local download_url="${BOILERPLATE_URL}/archive/refs/heads/${BOILERPLATE_REF}.tar.gz"
  
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
    local rel_path="${file#$TEMP_DIR/}"
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
    
    # Copy file
    cp "$file" "$dest_file"
    
    # Replace placeholders in text files
    if file "$dest_file" | grep -q "text\|ASCII"; then
      replace_placeholders "$dest_file" "$company_name" "$year"
    fi
    
  done < <(find "$TEMP_DIR" -type f 2>/dev/null)
  
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
  
  # Prompt for company name
  echo "Step 1 of 2: Configuration"
  echo "--------------------------"
  local company_name=$(prompt_company_name)
  echo ""
  
  # Prompt for target path
  local target_path=$(prompt_target_path)
  echo ""
  
  # Validate and prepare path
  print_info "Using year: $CURRENT_YEAR"
  validate_path "$target_path"
  
  # Download boilerplate
  echo ""
  echo "Step 2 of 2: Download and Setup"
  echo "--------------------------------"
  download_boilerplate
  
  # Setup working directory
  setup_working_directory "$target_path" "$company_name" "$CURRENT_YEAR"
  
  # Print next steps
  print_next_steps "$target_path" "$company_name" "$CURRENT_YEAR"
}

main "$@"
