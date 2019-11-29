## 查看某个库所有表行数和占用空间
```sql
SELECT TABLE_NAME, DATA_LENGTH + INDEX_LENGTH, TABLE_ROWS, CONCAT( ROUND( (
DATA_LENGTH + INDEX_LENGTH
) /1024 /1024, 2 ) ,  'MB' ) AS data
FROM information_schema.tables
WHERE TABLE_SCHEMA =  'database_name'
ORDER BY DATA_LENGTH + INDEX_LENGTH DESC 
```


```

```