# Setting Up CLI User for SSH Access in Guardium

## Overview
This document describes how to enable SSH access for the `cli` user in IBM Guardium Data Protection (GDP) to support Terraform provisioning.

## Problem
By default, the `cli` user in Guardium uses a restricted shell (`/opt/IBM/Guardium/bin/cli_wrapper`) that only allows specific Guardium CLI commands. This prevents SSH-based provisioning tools like Terraform from executing commands.

## Solution
To enable SSH access for the `cli` user for Terraform provisioning:

### 1. Change the CLI User Shell
```bash
# As root user, change the cli user's shell to bash
usermod -s /bin/bash cli
```

### 2. Set Up SSH Keys
```bash
# Create .ssh directory if it doesn't exist
mkdir -p /home/cli/.ssh

# Copy authorized keys (or add your public key)
cat /root/.ssh/authorized_keys > /home/cli/.ssh/authorized_keys

# Set proper ownership and permissions
chown -R cli:cli /home/cli/.ssh
chmod 700 /home/cli/.ssh
chmod 600 /home/cli/.ssh/authorized_keys
```

### 3. Fix Password Expiry
```bash
# Set password to never expire
chage -d $(( $(date +%s) / 86400 )) -M 99999 cli
```

### 4. Set Up Log Directory Permissions
```bash
# Create and set permissions for the log directory
mkdir -p /var/log/guardium
chown -R cli:cli /var/log/guardium
chmod 755 /var/log/guardium
```

## Terraform Configuration
In your `terraform.tfvars` file, set:
```hcl
gdp_ssh_username = "cli"
log_directory    = "/var/log/guardium"  # Optional, this is the default
```

## Verification
Test SSH access:
```bash
ssh -i /path/to/private/key cli@your-guardium-host "whoami && pwd"
```

Expected output:
```
cli
/home/cli
```

## Security Considerations
- The `cli` user now has bash shell access, which provides more capabilities than the restricted CLI wrapper
- Ensure proper SSH key management and access controls
- The `/var/log/guardium` directory is owned by the `cli` user for write access
- CSV configuration files are stored in `/var/log/guardium` instead of `/tmp`

## Official IBM Documentation
For the official IBM-supported method of enabling SSH key pairs, refer to:
https://www.ibm.com/docs/en/gdp/12.x?topic=mdarasb-enabling-ssh-key-pairs-data-archive-data-export-data-mart

## Reverting Changes
To revert the `cli` user back to the restricted shell:
```bash
usermod -s /opt/IBM/Guardium/bin/cli_wrapper cli