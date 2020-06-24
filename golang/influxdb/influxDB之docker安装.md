```bash
docker pull influxdb
docker run -p 8083:8083 -p 8086:8086 --expose 8090 --expose 8099 --name influxdb influxdb
```