# MiniGit

Lightweight Alpine container for git hosting with nginx+cgit. HTTP-only git access.

## Features

- **cgit**: Web interface for browsing repositories
- **nginx**: Serves cgit and handles smart HTTP git protocol
- **HTTP Git**: Clone, push, pull via HTTP
- **Rootless**: Runs as gituser for security

## Build & Run

```bash
docker build -t minigit .
docker run -d -p 8080:8080 -v git-repos:/srv/git minigit

# For existing repos, enable HTTP access:
docker exec -it <container> sh -c 'cd /srv/git && touch repo.git/git-daemon-export-ok'
```

## Access

- Web interface: http://localhost:8080
- HTTP clone: `git clone http://localhost:8080/repo.git`
- HTTP push/pull: Full git operations via HTTP

**Note**: Repositories need `git-daemon-export-ok` file to be accessible via HTTP.

## Create Repository

```bash
docker exec -it <container> sh
cd /srv/git
git init --bare myproject.git
chown -R gituser:gituser myproject.git
touch myproject.git/git-daemon-export-ok  # Enable HTTP access
```

## Working Examples

```bash
# Build and run
docker build -t minigit .
docker run -d --name minigit -p 8080:8080 -v git-repos:/srv/git minigit

# Clone via HTTP
git clone http://localhost:8080/sample.git

# View web interface
curl http://localhost:8080/
```

Container runs rootless as gituser. Simple HTTP-only git hosting solution.

## CI/CD Setup

GitHub Actions automatically builds and publishes to GitHub Container Registry on tags.

To trigger a build:
```bash
git tag v1.0.0
git push origin v1.0.0
```

The workflow will build and push:
- `ghcr.io/username/repo:v1.0.0`
- `ghcr.io/username/repo:latest`

Pull the published image:
```bash
docker pull ghcr.io/username/repo:latest
```