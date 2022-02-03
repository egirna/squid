# squid
Squid Proxy build scripts

Dockerfile running Squid Proxy (v4.17) using SSL on an Alpine (3.12) base image.

- Build Docker image

`sudo docker build --pull --rm -f "Dockerfile" -t squid4:latest "."`

- Run Docker container on port forwarding

`sudo docker run --name squid4_proxy -it -d -p 5000:3128 squid4`

- Verify your container is running

`sudo docker ps -a`

```
CONTAINER ID   IMAGE          COMMAND                  CREATED         STATUS                     PORTS                                       NAMES
2eaeb923fa38   squid          "sh /docker-entrypoi…"   4 seconds ago   Up 3 seconds               0.0.0.0:5000->3128/tcp, :::5000->3128/tcp   squid_proxy
```

- Copy cert to import in client browser

`sudo docker cp {container_name}:/etc/squid/cert/ca_cert.der .`

In your client browser, go to proxy settings > Manual proxy configuration > add `127.0.0.1` as the HTTP Proxy & port_number used when running the container.

[x] Also use this proxy for HTTPS.

- Access container's terminal

`sudo docker exec -it {container_id} /bin/ash`