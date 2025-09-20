#!/bin/bash
set -e

# Create dedicated system user for htu21 service
sudo useradd --system --no-create-home --shell /usr/sbin/nologin htu21 || true

# Extract files to /opt/htu21
sudo mkdir -p /opt/htu21
sudo cp htu21 /opt/htu21/
sudo chmod +x /opt/htu21/htu21

# Set ownership to htu21 user
sudo chown -R htu21:htu21 /opt/htu21

# Add htu21 user to i2c group for sensor access
sudo usermod -a -G i2c htu21

# Install systemd unit
sudo cp htu21.service /etc/systemd/system/htu21.service

# Enable + start
sudo systemctl daemon-reload
sudo systemctl enable --now htu21.service

echo "htu21 service installed and started."
echo "Check status: sudo systemctl status htu21.service"