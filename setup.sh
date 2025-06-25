#!/bin/bash

# Gemini CLI DevContainer Setup Script
# Supports Linux and macOS

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Configuration
CONTAINER_NAME="gemini-cli-dev"
COMPOSE_PROJECT_NAME="gemini-cli"

# ASCII Art Banner
print_banner() {
    echo -e "${CYAN}"
    cat << "EOF"
   ____                _       _    ____ _     ___ 
  / ___| ___ _ __ ___ (_)_ __ (_)  / ___| |   |_ _|
 | |  _ / _ \ '_ ` _ \| | '_ \| | | |   | |    | | 
 | |_| |  __/ | | | | | | | | | | | |___| |___ | | 
  \____|\___|_| |_| |_|_|_| |_|_|  \____|_____|___|
                                                    
EOF
    echo -e "${BOLD}          DevContainer Setup Wizard${NC}"
    echo -e "${MAGENTA}          For Linux and macOS${NC}"
    echo ""
}

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
        DISTRO=$(lsb_release -si 2>/dev/null || echo "unknown")
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        DISTRO="macOS"
    else
        echo -e "${RED}Unsupported operating system: $OSTYPE${NC}"
        exit 1
    fi
}

# Check prerequisites
check_prerequisites() {
    local missing_tools=()
    
    echo -e "${YELLOW}Checking prerequisites...${NC}"
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        missing_tools+=("docker")
    else
        echo -e "  ${GREEN}✓${NC} Docker installed"
    fi
    
    # Check Docker Compose
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        missing_tools+=("docker-compose")
    else
        echo -e "  ${GREEN}✓${NC} Docker Compose installed"
    fi
    
    # Check Git
    if ! command -v git &> /dev/null; then
        missing_tools+=("git")
    else
        echo -e "  ${GREEN}✓${NC} Git installed"
    fi
    
    # Check if Docker daemon is running
    if command -v docker &> /dev/null; then
        if ! docker info &> /dev/null; then
            echo -e "  ${RED}✗${NC} Docker daemon is not running"
            missing_tools+=("docker-daemon")
        else
            echo -e "  ${GREEN}✓${NC} Docker daemon running"
        fi
    fi
    
    echo ""
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        echo -e "${RED}Missing required tools:${NC}"
        for tool in "${missing_tools[@]}"; do
            echo -e "  ${RED}✗${NC} $tool"
            
            # Provide installation instructions
            case $tool in
                docker)
                    echo -e "    ${YELLOW}Install Docker:${NC}"
                    if [[ "$OS" == "macos" ]]; then
                        echo "    brew install --cask docker"
                    else
                        echo "    curl -fsSL https://get.docker.com | sh"
                    fi
                    ;;
                docker-compose)
                    echo -e "    ${YELLOW}Docker Compose is included with Docker Desktop${NC}"
                    ;;
                git)
                    echo -e "    ${YELLOW}Install Git:${NC}"
                    if [[ "$OS" == "macos" ]]; then
                        echo "    brew install git"
                    else
                        echo "    sudo apt-get install git"
                    fi
                    ;;
                docker-daemon)
                    echo -e "    ${YELLOW}Start Docker:${NC}"
                    if [[ "$OS" == "macos" ]]; then
                        echo "    open -a Docker"
                    else
                        echo "    sudo systemctl start docker"
                    fi
                    ;;
            esac
            echo ""
        done
        
        echo -e "${YELLOW}Please install missing tools and try again.${NC}"
        exit 1
    fi
}

# Get user input with default value
get_input() {
    local prompt=$1
    local default=$2
    local result
    
    if [ -n "$default" ]; then
        read -p "$(echo -e ${CYAN}$prompt ${YELLOW}[$default]${NC}: )" result
        result=${result:-$default}
    else
        read -p "$(echo -e ${CYAN}$prompt${NC}: )" result
    fi
    
    echo "$result"
}

# Get yes/no input
get_yes_no() {
    local prompt=$1
    local default=$2
    local result
    
    while true; do
        result=$(get_input "$prompt (y/n)" "$default")
        case $result in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo -e "${RED}Please answer yes (y) or no (n).${NC}";;
        esac
    done
}

# Setup configuration
setup_configuration() {
    echo -e "${BOLD}${BLUE}Configuration Setup${NC}"
    echo -e "${YELLOW}Let's configure your Gemini CLI development environment${NC}"
    echo ""
    
    # Workspace directory
    WORKSPACE_DIR=$(get_input "Workspace directory path" "$(pwd)")
    WORKSPACE_DIR=$(realpath "$WORKSPACE_DIR" 2>/dev/null || echo "$WORKSPACE_DIR")
    
    # Gemini API Key setup
    echo ""
    echo -e "${YELLOW}Gemini API Configuration:${NC}"
    echo "1. Use personal Google Account (default, no API key needed)"
    echo "2. Use API Key from Google AI Studio"
    
    API_CHOICE=$(get_input "Choose authentication method (1 or 2)" "1")
    
    if [ "$API_CHOICE" == "2" ]; then
        GEMINI_API_KEY=$(get_input "Enter your Gemini API key" "")
        if [ -z "$GEMINI_API_KEY" ]; then
            echo -e "${YELLOW}No API key provided. Will use Google Account authentication.${NC}"
        fi
    fi
    
    # Security options
    echo ""
    if get_yes_no "Enable firewall security (restricts network access)" "y"; then
        ENABLE_FIREWALL="true"
    else
        ENABLE_FIREWALL="false"
    fi
    
    # VS Code integration
    echo ""
    if command -v code &> /dev/null; then
        if get_yes_no "Open in VS Code after setup" "y"; then
            OPEN_VSCODE="true"
        else
            OPEN_VSCODE="false"
        fi
    else
        OPEN_VSCODE="false"
    fi
    
    # Port configuration
    echo ""
    echo -e "${YELLOW}Port Configuration:${NC}"
    APP_PORT=$(get_input "Application port" "3000")
    
    echo ""
    echo -e "${GREEN}Configuration Summary:${NC}"
    echo -e "  Workspace: ${BOLD}$WORKSPACE_DIR${NC}"
    echo -e "  Auth Method: ${BOLD}${API_CHOICE}${NC}"
    echo -e "  Firewall: ${BOLD}$ENABLE_FIREWALL${NC}"
    echo -e "  App Port: ${BOLD}$APP_PORT${NC}"
    echo ""
    
    if ! get_yes_no "Proceed with this configuration" "y"; then
        echo -e "${YELLOW}Setup cancelled.${NC}"
        exit 0
    fi
}

# Create environment file
create_env_file() {
    echo -e "${YELLOW}Creating environment configuration...${NC}"
    
    cat > "$WORKSPACE_DIR/.env" << EOF
# Gemini CLI DevContainer Environment Configuration
# Generated by setup.sh on $(date)

# Container settings
COMPOSE_PROJECT_NAME=$COMPOSE_PROJECT_NAME
CONTAINER_NAME=$CONTAINER_NAME

# Security
ENABLE_FIREWALL=$ENABLE_FIREWALL

# Ports
APP_PORT=$APP_PORT

# Workspace
WORKSPACE_DIR=$WORKSPACE_DIR

# Gemini API Configuration
EOF

    if [ -n "$GEMINI_API_KEY" ]; then
        echo "GEMINI_API_KEY=$GEMINI_API_KEY" >> "$WORKSPACE_DIR/.env"
    else
        echo "# GEMINI_API_KEY=your-api-key-here" >> "$WORKSPACE_DIR/.env"
    fi
    
    # Set appropriate permissions
    chmod 600 "$WORKSPACE_DIR/.env"
    
    echo -e "  ${GREEN}✓${NC} Environment file created"
}

# Build and start container
start_container() {
    echo ""
    echo -e "${YELLOW}Building and starting DevContainer...${NC}"
    
    cd "$WORKSPACE_DIR"
    
    # Use docker compose or docker-compose based on availability
    if docker compose version &> /dev/null; then
        COMPOSE_CMD="docker compose"
    else
        COMPOSE_CMD="docker-compose"
    fi
    
    # Build the container
    echo -e "${CYAN}Building container image...${NC}"
    $COMPOSE_CMD build
    
    # Start the container
    echo -e "${CYAN}Starting container...${NC}"
    $COMPOSE_CMD up -d
    
    # Wait for container to be ready
    echo -e "${CYAN}Waiting for container to be ready...${NC}"
    sleep 5
    
    # Check if container is running
    if docker ps | grep -q $CONTAINER_NAME; then
        echo -e "  ${GREEN}✓${NC} Container started successfully"
    else
        echo -e "  ${RED}✗${NC} Container failed to start"
        echo -e "${YELLOW}Checking logs...${NC}"
        $COMPOSE_CMD logs --tail=50
        exit 1
    fi
}

# Post-setup instructions
show_post_setup() {
    echo ""
    echo -e "${GREEN}${BOLD}✅ Setup Complete!${NC}"
    echo ""
    echo -e "${CYAN}${BOLD}Quick Start Commands:${NC}"
    echo ""
    echo -e "${YELLOW}Enter the container:${NC}"
    echo "  docker exec -it $CONTAINER_NAME zsh"
    echo ""
    echo -e "${YELLOW}Run Gemini CLI:${NC}"
    echo "  docker exec -it $CONTAINER_NAME gemini"
    echo ""
    echo -e "${YELLOW}Stop the container:${NC}"
    echo "  cd $WORKSPACE_DIR && docker-compose stop"
    echo ""
    echo -e "${YELLOW}View logs:${NC}"
    echo "  cd $WORKSPACE_DIR && docker-compose logs -f"
    echo ""
    
    if [ "$OPEN_VSCODE" == "true" ]; then
        echo -e "${CYAN}Opening VS Code...${NC}"
        code "$WORKSPACE_DIR"
    fi
    
    echo -e "${MAGENTA}${BOLD}Happy coding with Gemini CLI! 🚀${NC}"
}

# Main setup flow
main() {
    clear
    print_banner
    detect_os
    
    echo -e "${YELLOW}Detected OS: ${BOLD}$DISTRO${NC}"
    echo ""
    
    check_prerequisites
    setup_configuration
    create_env_file
    
    # Ensure docker-compose.yml exists
    if [ ! -f "$WORKSPACE_DIR/docker-compose.yml" ]; then
        echo -e "${RED}Error: docker-compose.yml not found in $WORKSPACE_DIR${NC}"
        echo -e "${YELLOW}Please ensure you're running this script from the gemini-cli-container directory${NC}"
        exit 1
    fi
    
    start_container
    show_post_setup
}

# Run main function
main "$@"