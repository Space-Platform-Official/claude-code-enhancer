#!/bin/bash

# System installation script for Claude Flow tools
# Usage: ./install.sh [--user|--system|--uninstall]

set -e

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Get script directory
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Installation paths
USER_BIN_DIR="$HOME/.local/bin"
USER_DATA_DIR="$HOME/.local/share/claude-flow"
SYSTEM_BIN_DIR="/usr/local/bin"
SYSTEM_DATA_DIR="/usr/local/share/claude-flow"

# Repository configuration
REPO_URL="https://github.com/Space-Platform-Official/claude-flow-enhancer.git"
REPO_DIR="$HOME/.claude-flow-repo"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to detect installation type
detect_install_type() {
    if [[ $EUID -eq 0 ]]; then
        echo "system"
    elif [[ -w "/usr/local/bin" && -w "/usr/local/share" ]]; then
        echo "system"
    else
        echo "user"
    fi
}

# Function to check if directory is in PATH
is_in_path() {
    local dir="$1"
    case ":$PATH:" in
        *":$dir:"*) return 0 ;;
        *) return 1 ;;
    esac
}

# Function to add repository mode configuration to shell config
add_repo_config() {
    local shell_config="$1"
    
    if [[ -f "$shell_config" ]]; then
        # Check if already configured
        if ! grep -q "CLAUDE_TEMPLATES_DIR" "$shell_config" 2>/dev/null; then
            echo "" >> "$shell_config"
            echo "# Claude Flow repository mode configuration" >> "$shell_config"
            echo "export CLAUDE_TEMPLATES_DIR=\"$REPO_DIR/templates\"" >> "$shell_config"
            echo "" >> "$shell_config"
            echo "# Function to update Claude Flow templates" >> "$shell_config"
            echo "claude-update() {" >> "$shell_config"
            echo "    echo \"🔄 Updating Claude Flow templates...\"" >> "$shell_config"
            echo "    cd \"$REPO_DIR\" && git pull" >> "$shell_config"
            echo "    echo \"✅ Claude Flow templates updated!\"" >> "$shell_config"
            echo "}" >> "$shell_config"
            print_success "Added repository configuration to $shell_config"
        else
            print_status "Repository configuration already exists in $shell_config"
        fi
    fi
}

# Function to add directory to PATH in shell config
add_to_path() {
    local dir="$1"
    local shell_config=""
    
    # Detect shell and config file
    if [[ -n "$ZSH_VERSION" ]] || [[ "$SHELL" == *"zsh"* ]]; then
        shell_config="$HOME/.zshrc"
    elif [[ -n "$BASH_VERSION" ]] || [[ "$SHELL" == *"bash"* ]]; then
        shell_config="$HOME/.bashrc"
    else
        shell_config="$HOME/.profile"
    fi
    
    if [[ -f "$shell_config" ]]; then
        echo "" >> "$shell_config"
        echo "# Added by Claude Flow installer" >> "$shell_config"
        echo "export PATH=\"$dir:\$PATH\"" >> "$shell_config"
        print_success "Added $dir to PATH in $shell_config"
        print_warning "Please run: source $shell_config"
    else
        print_warning "Could not find shell config file. Please add $dir to your PATH manually."
    fi
}

# Function to install files
install_files() {
    local install_type="$1"
    local install_mode="$2"
    local bin_dir data_dir
    
    if [[ "$install_type" == "system" ]]; then
        bin_dir="$SYSTEM_BIN_DIR"
        data_dir="$SYSTEM_DATA_DIR"
        print_status "Installing system-wide to $bin_dir and $data_dir"
    else
        bin_dir="$USER_BIN_DIR"
        data_dir="$USER_DATA_DIR"
        print_status "Installing for user to $bin_dir and $data_dir"
    fi
    
    # Create directories
    mkdir -p "$bin_dir" "$data_dir"
    
    # Handle templates based on mode
    if [[ "$install_mode" == "repo" ]]; then
        # Clone repository instead of copying templates
        print_status "Using repository mode - cloning templates from Git"
        if [[ -d "$REPO_DIR" ]]; then
            print_status "Repository already exists at $REPO_DIR, updating..."
            cd "$REPO_DIR" && git pull
        else
            print_status "Cloning repository to $REPO_DIR"
            git clone "$REPO_URL" "$REPO_DIR"
        fi
        
        # Set up shell configuration for repo mode
        local shell_config=""
        if [[ -n "$ZSH_VERSION" ]] || [[ "$SHELL" == *"zsh"* ]]; then
            shell_config="$HOME/.zshrc"
        elif [[ -n "$BASH_VERSION" ]] || [[ "$SHELL" == *"bash"* ]]; then
            shell_config="$HOME/.bashrc"
        else
            shell_config="$HOME/.profile"
        fi
        add_repo_config "$shell_config"
    else
        # Traditional mode - copy templates
        print_status "Copying templates to $data_dir/templates"
        cp -r "$SCRIPT_DIR/templates" "$data_dir/"
    fi
    
    # Install scripts
    print_status "Installing scripts to $bin_dir"
    
    # Install and rename scripts
    cp "$SCRIPT_DIR/install-claude-flow.sh" "$bin_dir/claude-install-flow"
    cp "$SCRIPT_DIR/smart-merge-claude.sh" "$bin_dir/claude-merge"
    
    # Make executable
    chmod +x "$bin_dir/claude-install-flow"
    chmod +x "$bin_dir/claude-merge"
    
    print_success "Files installed successfully"
    
    # Handle PATH for user installation
    if [[ "$install_type" == "user" ]]; then
        if ! is_in_path "$bin_dir"; then
            print_warning "$bin_dir is not in your PATH"
            read -p "Would you like to add it automatically? (y/n): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                add_to_path "$bin_dir"
            else
                print_warning "Please add $bin_dir to your PATH manually"
            fi
        fi
    fi
    
    print_success "Installation completed!"
    print_status "Available commands:"
    print_status "  claude-install-flow [target-dir]  # Install Claude templates"
    print_status "  claude-merge [target-dir]        # Smart merge CLAUDE.md"
    if [[ "$install_mode" == "repo" ]]; then
        print_status "  claude-update                    # Update templates from repository"
        print_warning "Please run: source $shell_config"
    fi
}

# Function to uninstall files
uninstall_files() {
    print_status "Uninstalling Claude Flow tools..."
    
    local files_removed=0
    
    # Remove from both user and system locations
    for bin_dir in "$USER_BIN_DIR" "$SYSTEM_BIN_DIR"; do
        for cmd in "claude-install-flow" "claude-merge"; do
            if [[ -f "$bin_dir/$cmd" ]]; then
                rm -f "$bin_dir/$cmd"
                print_status "Removed $bin_dir/$cmd"
                ((files_removed++))
            fi
        done
    done
    
    # Remove data directories
    for data_dir in "$USER_DATA_DIR" "$SYSTEM_DATA_DIR"; do
        if [[ -d "$data_dir" ]]; then
            rm -rf "$data_dir"
            print_status "Removed $data_dir"
            ((files_removed++))
        fi
    done
    
    if [[ $files_removed -eq 0 ]]; then
        print_warning "No Claude Flow installations found"
    else
        print_success "Uninstallation completed ($files_removed items removed)"
    fi
}

# Function to show usage
show_usage() {
    echo "Claude Flow Installation Script"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --user      Install for current user only (~/.local/)"
    echo "  --system    Install system-wide (/usr/local/)"
    echo "  --repo      Use repository mode (auto-updatable templates)"
    echo "  --uninstall Remove Claude Flow tools"
    echo "  --help      Show this help message"
    echo ""
    echo "If no option is specified, installation type is auto-detected."
}

# Main function
main() {
    local install_type=""
    local install_mode="copy"
    local action="install"
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --user)
                install_type="user"
                shift
                ;;
            --system)
                install_type="system"
                shift
                ;;
            --repo)
                install_mode="repo"
                shift
                ;;
            --uninstall)
                action="uninstall"
                shift
                ;;
            --help)
                show_usage
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Handle uninstall
    if [[ "$action" == "uninstall" ]]; then
        uninstall_files
        exit 0
    fi
    
    # Validate source files exist
    if [[ ! -f "$SCRIPT_DIR/install-claude-flow.sh" ]]; then
        print_error "Source file not found: $SCRIPT_DIR/install-claude-flow.sh"
        exit 1
    fi
    
    if [[ ! -f "$SCRIPT_DIR/smart-merge-claude.sh" ]]; then
        print_error "Source file not found: $SCRIPT_DIR/smart-merge-claude.sh"
        exit 1
    fi
    
    # Only check templates directory if not using repo mode
    if [[ "$install_mode" != "repo" && ! -d "$SCRIPT_DIR/templates" ]]; then
        print_error "Templates directory not found: $SCRIPT_DIR/templates"
        exit 1
    fi
    
    # Check git availability for repo mode
    if [[ "$install_mode" == "repo" ]] && ! command_exists git; then
        print_error "Git is required for repository mode but not found"
        exit 1
    fi
    
    # Auto-detect installation type if not specified
    if [[ -z "$install_type" ]]; then
        install_type="$(detect_install_type)"
        print_status "Auto-detected installation type: $install_type"
    fi
    
    # Confirm system installation
    if [[ "$install_type" == "system" && $EUID -ne 0 ]]; then
        print_warning "System installation requires sudo privileges"
        print_status "You may be prompted for your password"
    fi
    
    # Perform installation
    if [[ "$install_type" == "system" && $EUID -ne 0 ]]; then
        # Re-run with sudo for system installation
        exec sudo "$0" --system
    else
        install_files "$install_type" "$install_mode"
    fi
}

# Run main function with all arguments
main "$@"