# SSH Tunnel Systemd Service Setup Guide

This guide explains how to set up and use the systemd service for automatic SSH tunnel creation.

## Files in Directory

1. **`ssh-tunnel.service`** - Systemd unit file for the SSH tunnel service (with placeholders)
2. **`README.md`** - This documentation file

## Placeholders

The service file uses the following placeholders that will be replaced during installation:

- `{{NICETOOLS_PATH}}` - Path to the nicetools directory (e.g., `${HOME}/.nicetools`)
- `{{USERNAME}}` - Current username (e.g., `sheer.rey`)
- `{{HOST}}:{{PORT}}` - Target server and port (e.g., `10.65.46.222:8001`)
- `{{SCRIPT_PARAMS}}` - SSH connection parameters (e.g., `user@10.65.10.11` or `-P My-Jump-Demo`)

## Installation Steps

The easiest way to install the SSH tunnel service is using the PowerBash installer with the `--enable-ssh-tunnel-service` option:

```bash
# Install PowerBash with SSH tunnel service (interactive prompts)
./PowerBash -i --enable-ssh-tunnel-service
```

During installation, the installer will:
1. Prompt for the target server and port (e.g., `10.65.46.222:8001`)
2. Prompt for the jump server (user@ip or SSH profile name, e.g., `user@10.65.10.11` or `My-Jump-Demo`)
3. Validate both inputs using SSH commands
4. Replace all placeholders in the `ssh-tunnel.service` file with actual values
5. Copy the service file to the installation path

After installation, you need to save the service file to systemd:

```bash
# Copy the service file to systemd directory
sudo cp ${HOME}/.nicetools/doc/ssh_tunnel/ssh-tunnel.service /etc/systemd/system/

# Reload systemd daemon
sudo systemctl daemon-reload

# Enable the service to start on boot
sudo systemctl enable ssh-tunnel.service
```

## Usage

### Using systemd directly

```bash
# Start the service
sudo systemctl start ssh-tunnel.service

# Stop the service
sudo systemctl stop ssh-tunnel.service

# Restart the service
sudo systemctl restart ssh-tunnel.service

# Check service status
sudo systemctl status ssh-tunnel.service

# View service logs
sudo journalctl -u ssh-tunnel.service -f
```

## Installation Options

### Using `--enable-ssh-tunnel-service` Option

The `--enable-ssh-tunnel-service` option allows you to configure the SSH tunnel service during PowerBash installation:

1. **Target server and port**: The remote server you want to connect to (e.g., `10.65.46.222:8001`)
2. **Jump server**: Either a user@ip format (e.g., `user@10.65.10.11`) or an SSH profile name (e.g., `My-Jump-Demo`)

**Example: Interactive prompts (recommended)**
```bash
./PowerBash -i --enable-ssh-tunnel-service
```

**Input Validation:**

The installer will validate both inputs using SSH commands:

1. **Validate host:port format**: Checks if the input matches the pattern `IP:PORT` (e.g., `10.65.46.222:8001`)
2. **Validate user@ip format**: Checks if the input matches `user@IP` and attempts to connect to the host using SSH with a 5-second timeout
3. **Validate SSH profile**: Verifies the profile exists in `~/.ssh/config` and attempts to connect using SSH with a 5-second timeout
4. **Skip configuration if invalid**: If either input is invalid or unreachable, the SSH tunnel service will not be configured

## Service Configuration

The service is configured to:
- **Start after** network and SSH services are available
- **Auto-restart** if the tunnel fails (with 5-second delay)
- **Use debug logging** for troubleshooting
- **Connect to** `{{HOST}}:{{PORT}}` via the `{{SCRIPT_PARAMS}}` jump server
- **Run as** user `{{USERNAME}}`
- **Support both direct connection** (user@ip) and SSH profile-based connection
- **Validate connectivity** before configuring the service

## Troubleshooting

### Check if the service is running

```bash
sudo systemctl status ssh-tunnel.service
```

### View recent logs

```bash
sudo journalctl -u ssh-tunnel.service -n 50
```

### Check SSH configuration

Ensure your SSH config file (`~/.ssh/config`) has the `{{SSH_PROFILE}}` profile defined:

```ssh
Host {{SSH_PROFILE}}
    HostName <jump-host>
    User <username>
    # Other configuration options
```

### Test the SSH tunnel manually

```bash
{{NICETOOLS_PATH}}/CreateSSHTunnel {{HOST}}:{{PORT}} -P {{SSH_PROFILE}}
```

### Check if the port is open

```bash
# Check if the tunnel is listening on a local port
lsof -iTCP:LISTEN | grep ssh
```

## Service Behavior

- The service will automatically start when the system boots and SSH is available
- If the tunnel disconnects, the service will automatically restart it after 5 seconds
- The service uses the `Restart=always` directive to ensure continuous operation
- Port files are stored in `/tmp/` directory for tracking

## Notes

- The service requires `sshd` to be running before it can establish SSH connections
- The service runs with restricted security settings (NoNewPrivileges, PrivateTmp, etc.)
- All logs are available via `journalctl` for troubleshooting
