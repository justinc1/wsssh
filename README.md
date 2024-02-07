
Demo for huproxy, ssh over web socket.

```
git clone https://github.com/ThomasHabets/huproxy
cd huproxy
docker build -t huproxy:1 .
```

```
htpasswd -cb users.proxy thomas thomasp
docker build -t wsssh:1 .
docker run --rm --name wsssh wsssh:1
SRVIP=$(docker inspect -f '{{ .NetworkSettings.IPAddress }}' wsssh)
ssh -o 'ProxyCommand=./huproxyclient -auth=thomas:thomasp ws://$SRVIP/proxy/%h/%p' 172.17.0.1 -R 2222:localhost:22
ssh localhost -p 2222
```
