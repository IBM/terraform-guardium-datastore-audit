#!/bin/bash
#
# Copyright IBM Corp. 2026
# SPDX-License-Identifier: Apache-2.0
#
# Cassandra Deployment Detection Script
# Detects Cassandra deployment type, installation paths, and configuration locations

set -e

# Output variables
DEPLOYMENT_TYPE=""
INSTALL_PATH=""
CONFIG_PATH=""
RESTART_COMMAND=""
AUDIT_LOG_PATH=""

# Function to detect systemd-managed Cassandra
detect_systemd() {
    if systemctl list-units --type=service --all 2>/dev/null | grep -q "cassandra.service"; then
        DEPLOYMENT_TYPE="systemd-cassandra"
        RESTART_COMMAND="sudo systemctl restart cassandra"
        CONFIG_PATH="/etc/cassandra"
        AUDIT_LOG_PATH="/var/log/cassandra/audit/audit.log"
        return 0
    elif systemctl list-units --type=service --all 2>/dev/null | grep -q "dse.service"; then
        DEPLOYMENT_TYPE="systemd-dse"
        RESTART_COMMAND="sudo systemctl restart dse"
        CONFIG_PATH="/etc/dse/cassandra"
        AUDIT_LOG_PATH="/var/log/cassandra/audit/audit.log"
        return 0
    fi
    return 1
}

# Function to detect DSE standalone installation
detect_dse_standalone() {
    local dse_paths=(
        /opt/dse-*
        /usr/local/dse-*
        /home/*/dse-*
    )
    
    for pattern in "${dse_paths[@]}"; do
        for path in $pattern; do
            if [ -d "$path" ] && [ -f "$path/bin/dse" ]; then
                DEPLOYMENT_TYPE="dse-standalone"
                INSTALL_PATH="$path"
                CONFIG_PATH="$path/resources/cassandra/conf"
                RESTART_COMMAND="sudo $path/bin/dse cassandra-stop && sleep 5 && sudo $path/bin/dse cassandra -R"
                AUDIT_LOG_PATH="/var/log/cassandra/audit/audit.log"
                return 0
            fi
        done
    done
    return 1
}

# Function to detect Apache Cassandra standalone installation
detect_apache_standalone() {
    local cassandra_paths=(
        /opt/cassandra-*
        /opt/apache-cassandra-*
        /usr/local/cassandra-*
        /usr/local/apache-cassandra-*
        /home/*/cassandra-*
        /home/*/apache-cassandra-*
    )
    
    for pattern in "${cassandra_paths[@]}"; do
        for path in $pattern; do
            if [ -d "$path" ] && [ -f "$path/bin/cassandra" ]; then
                DEPLOYMENT_TYPE="apache-standalone"
                INSTALL_PATH="$path"
                CONFIG_PATH="$path/conf"
                # For standalone, we need to find the PID and restart
                RESTART_COMMAND="sudo pkill -f 'org.apache.cassandra.service.CassandraDaemon' || true && sleep 5 && sudo $path/bin/cassandra -R"
                AUDIT_LOG_PATH="/var/log/cassandra/audit/audit.log"
                return 0
            fi
        done
    done
    return 1
}

# Main detection logic
echo "Detecting Cassandra deployment type..." >&2

# Try detection in order of preference
if detect_systemd; then
    echo "Detected systemd-managed Cassandra" >&2
elif detect_dse_standalone; then
    echo "Detected DSE standalone installation" >&2
elif detect_apache_standalone; then
    echo "Detected Apache Cassandra standalone installation" >&2
else
    echo "ERROR: Could not detect Cassandra installation" >&2
    echo "Please specify deployment type and paths manually" >&2
    exit 1
fi

# Verify config path exists
if [ ! -d "$CONFIG_PATH" ]; then
    echo "WARNING: Config path $CONFIG_PATH does not exist" >&2
fi

# Output results as JSON for easy parsing
cat <<EOF
{
  "deployment_type": "$DEPLOYMENT_TYPE",
  "install_path": "$INSTALL_PATH",
  "config_path": "$CONFIG_PATH",
  "restart_command": "$RESTART_COMMAND",
  "audit_log_path": "$AUDIT_LOG_PATH"
}
EOF

# Made with Bob
