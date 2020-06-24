https://www.infoq.cn/article/662MdX6QNzcL-5D4axKb

```bash
docker run --name influxdb2 -p 9999:9999 quay.io/influxdb/influxdb:2.0.0-beta
influx write --org wuzhc --bucket testdb --precision s "m v=2 $(date +%s)"

influx write --org InfluxData --bucket telegraf --precision s "m v=2 $(date +%s)"

influx query -o wuzhc 'from(bucket:"testdb") |> range(start:-1h)'

export INFLUX_TOKEN=where-were-going-we-dont-need-roads
export INFLUX_TOKEN=qSe0yOicjT9XdwGe1aJ3hIlupHZPXiSOZ9N3k45YW8CTA2_wP2L4ICgSKcy6la9PxE3FMJz6j2h2OUB5ucwJ-g==

influx query -o wuzhc 'from(bucket:"testdb") |> range(start:-10h) |> filter(fn:(r)=>r._measurement == "userlog")'

./influx query -o wuzhc 'from(bucket:"testdb") |> range(start:-10h) |> filter(fn:(r)=>r._measurement == "userlog") |> to(bucket:"testdb_2",org:"wuzhc",timeColumn:"_time",tagColumns: ["tag1", "tag2", "tag3"],fieldFn: (r) => ({ [r._field]: r._value }))'

./influx delete -o wuzhc --bucket=testdb_2 -p '_measurement=userlog' --start=2009-01-02T23:00:00Z --stop=2029-01-02T23:00:00Z

./influx bucket update -i <bucket-id> -r <retention period in nanoseconds>

from(bucket:"testdb")
|>range(start: -18h)
|>filter(fn: (r)=>r._measurement=="testcode2" and r._field=="used")
|>yield()

./influxd --reporting-disabled

from(bucket: "user_log")
  |> range(start: -1mo)
  |> filter(fn: (r) => r["_measurement"] == "userlog")
  |> filter(fn: (r) => r["_field"] == "uid")
  |> aggregateWindow(every: 1h, fn: mean)
  |> yield(name: "mean")
```


## 面板
### 统计每个小时每个省份数据
```bash
from(bucket: "user_log")
  |> range(start: -24h)
  |> filter(fn: (r) => r["_measurement"] == "userlog")
  |> filter(fn: (r) => r["_field"] == "uid")
  |> group(columns: ["province"])
  |> aggregateWindow(every: 1h, fn: count)
  |> yield(name: "mean")
  
  from(bucket: "user_log")
  |> range(start: -48h)
  |> filter(fn: (r) => r["_measurement"] == "userlog")
  |> filter(fn: (r) => r["_field"] == "uid")
  |> filter(fn: (r) => r.province == "广东")
  |> group(columns: ["area"])
  |> aggregateWindow(every: 5h, fn: count)
  |> yield(name: "count")
  
  from(bucket: "user_log")
  |> range(start: 2015-01-22T00:50:01Z, stop: 2015-01-23T20:59:01Z )
  |> filter(fn: (r) => r["_measurement"] == "userlog")
  |> filter(fn: (r) => r["_field"] == "uid")
  |> filter(fn: (r) => r.province == "广东")
  |> group(columns: ["city"])
  |> aggregateWindow(every: 5h, fn: count)
  |> yield(name: "count")
  
  from(bucket: "example-bucket")
  |> range(start: -30m)
  |> columns()
  |> keep(columns: ["_value"])
  |> group()
  |> distinct()
```
