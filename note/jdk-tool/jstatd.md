Java启动命令开启jmx

-Djava.rmi.server.hostname=172.26.5.250
-Dcom.sun.management.jmxremote.port=9010
-Dcom.sun.management.jmxremote.authenticate=false
-Dcom.sun.management.jmxremote.ssl=false

jstatd命令

jstatd -J-Djava.security.policy=/home/sankuai/jstatd.policy -J-Djava.rmi.server.logCalls=true -J-Djava.rmi.server.hostname=172.26.5.250 -J-Dcom.sun.management.jmxremote.port=9010 -J-Dcom.sun.management.jmxremote.authenticate=false -J-Dcom.sun.management.jmxremote.ssl=false

```
grant codebase "file:/usr/local/java/lib/tools.jar" {
    permission java.security.AllPermission;
};
```
