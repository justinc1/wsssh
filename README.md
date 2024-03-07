
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

On proxy box - huproxy server SRVIP.

```commandline
/bin/rm -i users.proxy
touch users.proxy 
htpasswd -b users.proxy user1 pass1
## htpasswd -b users.proxy user2 pass2
# while read line; do htpasswd -b users.proxy $line; done < users.plain

echo "ssh_user1 ssh_pass1" > ssh_users.plain

docker run --rm --name wsssh -v $PWD/users.proxy:/etc/nginx/users.proxy:ro -v $PWD/ssh_users.plain:/ssh_users.plain:ro -p8443:80 -p8022:22 -d wsssh:1
```

On client - device behind firewall

```commandline
sudo cp huproxyclient /usr/local/bin/

SRVIP=
SSHPASS=ssh_pass1 sshpass -e ssh -o "ProxyCommand=huproxyclient -auth=user1:pass1 ws://$SRVIP:8443/proxy/%h/%p" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ssh_user1@localhost -R 2222:localhost:22 hostname

# The client needs to login to SRVIP.
# User account, SSH key etc. are needed.
```

On admin workstation

```commandline
SRVIP=
ssh -J user3@SRVIP user4@localhost -p 2222

ssh -i .ssh/id_ed25519 -J root@$SRVIP,ssh_user1@$CONTAINER_IP some_user@127.0.0.1 -p2200 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null
```

## SSL https wss

```commandline
mkdir certs
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout certs/nginx-selfsigned.key -out certs/nginx-selfsigned.crt
openssl dhparam -out certs/dhparam.pem 2048

docker run --rm --name wsssh -v $PWD/users.proxy:/etc/nginx/users.proxy:ro -v $PWD/ssh_users.plain:/ssh_users.plain:ro -p8443:443 -v $PWD/certs:/etc/ssl/certs -v $PWD/default.conf:/etc/nginx/conf.d/default.conf -d wsssh:1
docker logs -f wsssh
```
