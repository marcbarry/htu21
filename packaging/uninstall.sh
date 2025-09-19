#!/bin/bash
set -e

echo "Stopping htu21 service..."
sudo systemctl stop htu21 || true
sudo systemctl disable htu21 || true

echo "Removing systemd unit..."
sudo rm -f /etc/systemd/system/htu21.service

echo "Reloading systemd..."
sudo systemctl daemon-reload

echo "Removing installed files..."
sudo rm -rf /opt/htu21

echo "htu21 service uninstalled."