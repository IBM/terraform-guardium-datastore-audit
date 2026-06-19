#!/bin/bash
#
# Copyright IBM Corp. 2026
# SPDX-License-Identifier: Apache-2.0
#
# Enable Cassandra Audit Logging Script
# Modifies cassandra.yaml and logback.xml to enable audit logging

set -e

# Parameters (passed from Terraform)
CONFIG_PATH="${1}"
AUDIT_LOG_PATH="${2:-/var/log/cassandra/audit/audit.log}"
EXCLUDED_KEYSPACES="${3:-system,system_schema,system_virtual_schema}"
EXCLUDED_CATEGORIES="${4:-}"
EXCLUDED_USERS="${5:-}"
RESTART_COMMAND="${6}"

echo "Enabling Cassandra audit logging..."
echo "Config path: $CONFIG_PATH"
echo "Audit log path: $AUDIT_LOG_PATH"

# Backup configuration files
echo "Creating backups..."
sudo cp "$CONFIG_PATH/cassandra.yaml" "$CONFIG_PATH/cassandra.yaml.backup.$(date +%Y%m%d_%H%M%S)" || true
sudo cp "$CONFIG_PATH/logback.xml" "$CONFIG_PATH/logback.xml.backup.$(date +%Y%m%d_%H%M%S)" || true

# Create audit log directory
AUDIT_DIR=$(dirname "$AUDIT_LOG_PATH")
echo "Creating audit log directory: $AUDIT_DIR"
sudo mkdir -p "$AUDIT_DIR"
sudo chown cassandra:cassandra "$AUDIT_DIR" 2>/dev/null || sudo chown dse:dse "$AUDIT_DIR" 2>/dev/null || true
sudo chmod 755 "$AUDIT_DIR"

# Update cassandra.yaml
echo "Updating cassandra.yaml..."
sudo bash -c "cat >> $CONFIG_PATH/cassandra.yaml" <<EOF

# Audit Logging Configuration (Added by Guardium Terraform Module)
audit_logging_options:
    enabled: true
    logger:
      - class_name: FileAuditLogger
    audit_logs_dir: $AUDIT_DIR
    included_keyspaces: ""
    excluded_keyspaces: "$EXCLUDED_KEYSPACES"
    included_categories: ""
    excluded_categories: "$EXCLUDED_CATEGORIES"
    included_users: ""
    excluded_users: "$EXCLUDED_USERS"
EOF

# Update logback.xml - Add AUDIT appender if not present
echo "Updating logback.xml..."
if ! grep -q 'name="AUDIT"' "$CONFIG_PATH/logback.xml"; then
    # Find the closing </configuration> tag and insert before it
    sudo sed -i.bak '/<\/configuration>/i \
  <!-- AUDIT appender (Added by Guardium Terraform Module) -->\
  <appender name="AUDIT" class="ch.qos.logback.core.rolling.RollingFileAppender">\
    <file>'"$AUDIT_LOG_PATH"'</file>\
    <rollingPolicy class="ch.qos.logback.core.rolling.SizeAndTimeBasedRollingPolicy">\
      <fileNamePattern>'"$AUDIT_DIR"'/audit.log.%d{yyyy-MM-dd}.%i.zip</fileNamePattern>\
      <maxFileSize>50MB</maxFileSize>\
      <maxHistory>30</maxHistory>\
      <totalSizeCap>5GB</totalSizeCap>\
    </rollingPolicy>\
    <encoder>\
      <pattern>%-5level [%thread] %date{ISO8601} %F:%L - %msg%n</pattern>\
    </encoder>\
  </appender>\
\
  <!-- Audit Logging (Added by Guardium Terraform Module) -->\
  <logger name="org.apache.cassandra.audit" additivity="false" level="INFO">\
    <appender-ref ref="AUDIT"/>\
  </logger>\
' "$CONFIG_PATH/logback.xml"
else
    echo "AUDIT appender already exists in logback.xml, skipping..."
fi

echo "Audit logging configuration complete!"
echo "Restarting Cassandra..."

# Execute restart command
eval "$RESTART_COMMAND"

# Wait for Cassandra to start
echo "Waiting for Cassandra to start..."
sleep 10

# Verify audit log file is created
if [ -f "$AUDIT_LOG_PATH" ]; then
    echo "SUCCESS: Audit log file created at $AUDIT_LOG_PATH"
else
    echo "WARNING: Audit log file not yet created. It will be created when audit events occur."
fi

echo "Cassandra audit logging enabled successfully!"

# Made with Bob
