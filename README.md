# htu21

`htu21` Small HTTP service targeting the Raspberry Pi that reads temperature and humidity from an HTU21D/SHT21 sensor over I²C and makes it available on the network by returning JSON to a simple HTTP API.

Default port: **273** (configurable via `HTU21_PORT` environment variable).

- Endpoints:
  - `GET /` → `{"temperature_c":..,"humidity_percent":..,"timestamp_utc":".."}`
  - `GET /health` → `{"status":"ok"}`

## Prerequisites

- Raspberry Pi with I²C enabled: (`sudo raspi-config` → *Interface Options* → *I2C* → Enable)
- Check your user is in the `i2c` group.
- Wiring:  
  - VCC → 3.3V (pin 1)
  - GND → GND (pin 9)
  - SDA → GPIO2 (pin 3)
  - SCL → GPIO3 (pin 5)

![HTU21 sensor wiring diagram](htu21.jpg)

---

## Quick run (no install)

1. Download and extract the release tarball:
   ```bash
   tar xzf htu21-linux-arm.tar.gz
   cd htu21-linux-arm
   ```

2. Run:
   ```bash
   sudo ./htu21             # listens on port 273 by default
   ```
   Optional: allow binding to ports <1024 without sudo
   ```bash
   sudo setcap 'cap_net_bind_service=+ep' ./htu21
   ./htu21
   ```
   Or change the port:
   ```bash
   HTU21_PORT=8080 ./htu21
   ```

3. Test:
   ```bash
   curl http://localhost:273/
   curl http://localhost:273/health
   ```

---

## Install as a `systemd` service

```bash
tar xzf htu21-linux-arm.tar.gz
cd htu21-linux-arm
./install.sh
```

Check status and logs:

```bash
systemctl status htu21
journalctl -u htu21 -f
```


---

## Change the port

### 1. Edit the service (recommended)

```bash
sudo nano /etc/systemd/system/htu21.service
# in the [Service] section, set:
Environment=PORT=273
```

Reload and restart:

```bash
sudo systemctl daemon-reload
sudo systemctl restart htu21
```

---

## Uninstall

```bash
cd htu21-linux-arm
./uninstall.sh
```

---

### JSON examples

```bash
curl -s http://localhost:273/ | jq .
# {
#   "sensor": "HTU21D/SHT21",
#   "temperature_c": 21.37,
#   "humidity_percent": 48.12,
#   "timestamp_utc": "2025-09-20T00:00:00.0000000Z"
# }

curl -s http://localhost:273/health
# {"status":"ok"}
```