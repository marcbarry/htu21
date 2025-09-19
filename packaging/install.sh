#!/bin/bash
set -e

# Extract files to /opt/htu21
sudo mkdir -p /opt/htu21
sudo cp htu21 /opt/htu21/
sudo chmod +x /opt/htu21/htu21

# Install systemd unit
sudo cp htu21.service /etc/systemd/system/htu21.service

# Enable + start
sudo systemctl daemon-reload
sudo systemctl enable --now htu21.service

echo "htu21 service installed and started."
echo "Check status: sudo systemctl status htu21.service"