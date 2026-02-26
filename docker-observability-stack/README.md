# HTU21 Docker Observability Stack

This directory contains a minimal Docker-based observability pipeline for ingesting, storing, and visualising HTU21 sensor data.

- This Docker stack does **not** run the sensor service itself, just the observability stack.
- The stack ingests HTTP JSON output from an existing sensor endpoint, and assumes network line-of-sight to the htu21 service's api.

<img src="grafana-screenshot.png" alt="HTU21 Grafana observability stack">

## Components

- Telegraf
    Polls the sensor HTTP endpoint every 10 seconds and writes metrics to InfluxDB.
- InfluxDB (v2)
    Stores time-series data in the sensors bucket.
- Grafana
    Provides a web UI for visualising temperature and humidity data. Anonymous access is enabled.

## Data Flow

```
Sensor HTTP endpoint
→ Telegraf (inputs.http)
→ InfluxDB bucket sensors
→ Grafana dashboard
```

## Configuration

The stack is fully self-contained in this directory. InfluxDB is initialised via environment variables in docker-compose.yml:

```
Organisation: home
Bucket: sensors
Token: password
Retention: 0 (infinite)
```

## Running

From this directory:

```
docker compose up -d
```

Grafana is available at:

```
http://<host>:3000
```

No login required.