# Gemini CLI DevContainer

A comprehensive development container setup for Google's Gemini CLI, inspired by Claude Code's devcontainer implementation. This setup provides a secure, fully-featured development environment that works seamlessly on both Linux and macOS.

## 🚀 Quick Start

### Prerequisites

- **Docker** (with Docker Compose)
- **Git**
- **VS Code** (optional, for devcontainer integration)

### One-Command Setup

```bash
# Clone and setup in one command
git clone <this-repo-url> gemini-cli-container && cd gemini-cli-container && ./setup.sh
```

### Manual Setup

1. **Clone the repository:**
   ```bash
   git clone <this-repo-url> gemini-cli-container
   cd gemini-cli-container
   ```

2. **Run the guided setup:**
   ```bash
   ./setup.sh
   ```

3. **Enter the container:**
   ```bash
   docker exec -it gemini-cli-dev zsh
   ```

4. **Start using Gemini CLI:**
   ```bash
   gemini
   ```

## 🛡️ Security Features

This devcontainer includes robust security features similar to Claude Code:

- **Network Firewall**: Restricts outbound connections to approved services only
- **Approved Domains**: Pre-configured allow-list for essential services:
  - Google Gemini API endpoints
  - NPM registry and Node.js
  - GitHub and package CDNs
  - Development tools and package managers

- **Container Security**: Non-root user execution with minimal required privileges

## 🔧 Features

### Development Environment
- **Node.js 20** with TypeScript support
- **Gemini CLI** pre-installed and ready to use
- **Zsh** with Oh My Zsh and Powerlevel10k theme
- **Essential tools**: git, git-delta, build tools, vim, nano, htop
- **VS Code extensions**: ESLint, Prettier, GitLens, Docker support

### Persistence
- **Command history** persisted across container restarts
- **Gemini CLI configuration** persisted in dedicated volume
- **NPM cache** and VS Code extensions cached for faster startup

### Cross-Platform Support
- **Linux**: Full support with all features
- **macOS**: Optimized for Apple Silicon and Intel Macs
- **Windows**: Via WSL2 (Windows Subsystem for Linux)

## 📁 Project Structure

```
gemini-cli-container/
├── .devcontainer/
│   ├── devcontainer.json     # VS Code devcontainer configuration
│   ├── Dockerfile           # Container image definition
│   ├── init-firewall.sh     # Security firewall setup
│   ├── post-create.sh       # Post-creation setup script
│   └── entrypoint.sh        # Container entrypoint
├── docker-compose.yml       # Docker Compose configuration
├── setup.sh                # Guided setup script
└── README.md               # This file
```

## ⚙️ Configuration

### Environment Variables

Create a `.env` file or set these environment variables:

```bash
# Required
GEMINI_API_KEY=your-api-key-here  # Optional: for API key authentication

# Optional
ENABLE_FIREWALL=true              # Enable network security (default: false)
APP_PORT=3000                     # Application port (default: 3000)
CONTAINER_NAME=gemini-cli-dev     # Container name
COMPOSE_PROJECT_NAME=gemini-cli   # Docker Compose project name
```

### Gemini CLI Authentication

Two authentication methods are supported:

1. **Google Account** (Default):
   - No API key required
   - 60 requests/minute, 1,000 requests/day
   - Interactive authentication flow

2. **API Key**:
   - Get your key from [Google AI Studio](https://aistudio.google.com)
   - Higher rate limits
   - Set `GEMINI_API_KEY` environment variable

## 🐳 Container Management

### Start the container:
```bash
docker-compose up -d
```

### Stop the container:
```bash
docker-compose stop
```

### View logs:
```bash
docker-compose logs -f
```

### Rebuild container:
```bash
docker-compose build --no-cache
```

### Enter container shell:
```bash
docker exec -it gemini-cli-dev zsh
```

### Run Gemini CLI:
```bash
# From host
docker exec -it gemini-cli-dev gemini

# From inside container
gemini
```

## 🔍 VS Code Integration

### Using Dev Containers Extension

1. Install the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
2. Open the folder in VS Code
3. When prompted, click "Reopen in Container"
4. VS Code will automatically build and connect to the container

### Manual VS Code Setup

```bash
code /path/to/gemini-cli-container
```

Then use Command Palette (`Cmd/Ctrl + Shift + P`) → "Dev Containers: Reopen in Container"

## 🛠️ Development Workflow

### Basic Usage

1. **Start a new project:**
   ```bash
   mkdir my-gemini-project
   cd my-gemini-project
   npm init -y
   ```

2. **Use Gemini CLI for development:**
   ```bash
   gemini  # Interactive mode
   ```

3. **Build and test:**
   ```bash
   npm run build
   npm test
   ```

### Working with Files

The container mounts your workspace at `/workspace`, so any changes you make are immediately reflected on your host system.

### Port Forwarding

The following ports are automatically forwarded:
- `3000`: Main application port
- `8080`: Secondary application port  
- `8888`: Development server port

## 🔒 Security Considerations

### Firewall Configuration

When `ENABLE_FIREWALL=true`, the container restricts network access to:

- **Google Services**: Gemini API, Google AI Studio, OAuth endpoints
- **Development Tools**: NPM, GitHub, package CDNs
- **Essential Services**: DNS, NTP, package repositories

### Disabling Security (Not Recommended)

To disable the firewall for debugging:

```bash
ENABLE_FIREWALL=false docker-compose up -d
```

## 🐛 Troubleshooting

### Container Won't Start

1. **Check Docker daemon:**
   ```bash
   docker info
   ```

2. **Check port conflicts:**
   ```bash
   lsof -i :3000
   ```

3. **View container logs:**
   ```bash
   docker-compose logs gemini-dev
   ```

### Gemini CLI Issues

1. **Authentication problems:**
   ```bash
   # Clear stored credentials
   rm -rf ~/.config/gemini
   gemini  # Re-authenticate
   ```

2. **API rate limits:**
   - Switch to API key authentication
   - Check your usage at [Google AI Studio](https://aistudio.google.com)

3. **Network connectivity:**
   ```bash
   # Test from inside container
   docker exec -it gemini-cli-dev curl -I https://generativelanguage.googleapis.com
   ```

### Performance Issues

1. **Increase memory allocation:**
   ```yaml
   # In docker-compose.yml
   deploy:
     resources:
       limits:
         memory: 8G  # Increase from 4G
   ```

2. **Clear npm cache:**
   ```bash
   docker exec -it gemini-cli-dev npm cache clean --force
   ```

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Test your changes thoroughly
4. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Inspired by [Claude Code's devcontainer implementation](https://github.com/anthropics/claude-code/tree/main/.devcontainer)
- Built for [Google Gemini CLI](https://github.com/google-gemini/gemini-cli)
- Security patterns adapted from enterprise DevSecOps practices

## 📚 Additional Resources

- [Gemini CLI Documentation](https://github.com/google-gemini/gemini-cli)
- [Google AI Studio](https://aistudio.google.com)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [VS Code Dev Containers](https://code.visualstudio.com/docs/devcontainers/containers)

---

**Happy coding with Gemini CLI! 🚀**