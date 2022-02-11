# squid
Squid Proxy build scripts

## What is it



More info on Squid [configuration examples](https://wiki.squid-cache.org/ConfigExamples).

Dockerfile running Squid Proxy (v4.17) & (v5.2) using SSL on an Alpine base image.

http://www.squid-cache.org/Intro/

## Why you'd use it

http://www.squid-cache.org/Intro/why.html

## How to use 
build image or pull from dockerhub
**Squid Configuration File** -> `config/squid.conf`

For now the `squid.conf` enables a basic SSL configuration. You can apply changes directly to the squid.conf file & it will be copied to the container.



The default Squid version is 4.17, but the following commands will help you run both versions concurrently on your local host.

- **Build Docker image**

**Squid4**

`sudo docker build --pull --rm -t squid4:latest "." --env-file ./env.list`

**Squid5**

`sudo docker build --pull --rm -t squid5:latest --build-arg ALP_IMG=alpine "."`

Since `-t` refers to tags, `squid4` & `squid5` will be reffered to as `{tag_name}` in the following commands.

- **Run Docker container on port forwarding**


`sudo docker run --name squid_proxy -it -d -p 5000:3128 {tag_name}`

Since `--name` refers to container name, make sure that you don't give the same name to more than 1 container, and that different versions are assigned different ports.
`squid_proxy` will be refrred to as `{container_name}` in the following commands.

- **Run Squid**

`sudo docker exec -d {container_name} squid`

- **Verify your container is running**

`sudo docker ps -a`

You should be able to see that the status is Up.

```
CONTAINER ID   IMAGE          COMMAND                  CREATED              STATUS              PORTS                                       NAMES
be0a7b18fef9   dsquid         "/docker-entrypoint.…"   22 seconds ago       Up 21 seconds       0.0.0.0:5001->3128/tcp, :::5001->3128/tcp   squid5_proxy
cd7bb12b2d59   3a61b71fe081   "/docker-entrypoint.…"   About a minute ago   Up About a minute   0.0.0.0:5000->3128/tcp, :::5000->3128/tcp   squid4_proxy
```

- **Verify Squid is running on your local host**

`curl -I http://localhost:{port_number}`

You should be able to see the following response, including Squid's version.


```
HTTP/1.1 400 Bad Request
Server: squid/4.17
Mime-Version: 1.0
Date: Thu, 03 Feb 2022 14:04:27 GMT
Content-Type: text/html;charset=utf-8
Content-Length: 3509
X-Squid-Error: ERR_INVALID_URL 0
Vary: Accept-Language
Content-Language: en
X-Cache: MISS from cd7bb12b2d59
X-Cache-Lookup: NONE from cd7bb12b2d59:3128
Via: 1.1 cd7bb12b2d59 (squid/4.17)
Connection: close
```

- **Copy cert to import into client browser**

`sudo docker cp {container_name}:/etc/squid/cert/ca_cert.der .`

In your client browser, go to proxy settings > Manual proxy configuration > add `127.0.0.1` as the HTTP Proxy & port_number used when running the container.

[x] Also use this proxy for HTTPS.

- **Access container's terminal**

`sudo docker exec -it {container_id} /bin/ash`

For debug and error messages generated by Squid: 

`tail -f /var/log/squid/cache.log`

For key information about HTTP transactions [client IP address (or hostname), requested URI, response size, etc.]:

`tail -f /var/log/squid/access.log`
