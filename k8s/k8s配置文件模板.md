## Pod
```yaml
apiVersion: v1
kind: Pod
metadata:
    name: myweb # name属性为Pod的名字
spec:
    replicas: 2
    selector:
        app: myweb
    template:
        metadata:
            labels:
                app: myweb
        spec:
            containers:  # 包含的容器组的定义
             - name: myweb
               image: kubeguide/tomcat-app:v1
               ports:
               - containerPort: 8080 # Pod.IP加上端口表示对外通信的地址
               env:
               - name: MYSQL_SERVICE_HOST
                 value: 'mysql'
               - name: MYSQL_SERVICE_PORTT
                 value: '3306'
```

## RC
```yaml
apiVersion: v1
kind: ReplicationController
metadata:
  name: frontend
spec:
  replicas: 1
  selector:
    tier: frontend
template:
  metadata:
    labels:
      app: app-demo
      tier: frontend
  spec:
    containers:
     - name: tomcat-demo
       image: tomcat
       ports:
       imagePullPolicy: IfNotPresent
       env:
       - name: GET_HOSTS_FROM
         value: dns
       ports:
       - containerPort: 80
```

## Service
```yaml
apiVersion: v1
kind: Service
metadata:
  name: myweb
spec:
  selector:
    app: myweb
  ports:
  - port: 8080
```








