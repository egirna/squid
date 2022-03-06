# Squid
Squid Proxy build scripts


## What is it



More info on Squid [configuration examples](https://wiki.squid-cache.org/ConfigExamples).

Dockerfile running Squid Proxy (v4.17) & (v5.2) using SSL on an Alpine base image.

http://www.squid-cache.org/Intro/

------

## Why you'd use it

http://www.squid-cache.org/Intro/why.html

--------

## How to use 


## todo
- push image to dockerhub
- add blog articles

### 1. Prerequisites
This setup was tested on Linux Ubuntu.    

- Install Docker Engine for [Ubuntu](https://docs.docker.com/engine/install/ubuntu/) 
- Git

### 2. Setup Environment

- Clone the project:

    ```
    $ git clone https://github.com/egirna/squid.git

    ## git checkout develop  -> staging version
    ```
- Change directory & list all files and directories:

    ```
    cd squid & ls
    ```
- Understanding Files & Directories

|File/Directory |How to Use   |
|---|---|
|config/   |contains squid configuration files.<br> modify or add `squid.conf` files here   |
|Dockerfile   |contains Squid default version, system dependencies, entrypoint   |
|configs   |map squid options to their configuration arguments <br> only modify when adding options <br> You can find the index of all options [here](http://www.squid-cache.org/Versions/v4/cfgman/index_all.html) for Squid4  & [here](http://www.squid-cache.org/Versions/v5/cfgman/index_all.html) for Squid5  |
|configs_switch | controls which arguments (from `configs`) are run while configuring & compiling Squid <br> set an option to **1** when you want to use it while compiling Squid, **0** otherwise|
|configure_squid.sh| bash script functions to download & setup squid, check enabled services from `configs_switch`, download their dependent packages, and compile Squid with configuration options from `configs`. <br> if SSL is enabled, then a self-signed certificate is created and the SSL DB is created and cleared. <br> if you'd like to modify certificate details > go to create_cert()|
|docker-entrypoint.sh| log permissions + keep container running|


**Note:** Make sure you've modified required files before building the docker image. If not, it'll run it's current default: ICAP + SSL enabled configuration for Squid 4.17.

- Understanding placeholders for Docker commands

|Placeholders|Usage|
|---|---|
|{version_number}| Default is 4 for Squid4.17, Modify to 5 for Squid5.4|
|{host_port_number}|port number of host device <br> ports used in this document are `8080` and `8081`|
|{tag_name}|refers to tags <br> tags used in this document are `squid4` & `squid5`|
|{container_name}|name assigned to container <br> names used in this document are `squid4_proxy` & `squid5_proxy`|
{container_id}|you can get the id of a container by running `sudo docker ps -a` <br> container id's used in this document are `d8ddfe0c3670` and `825cc1cdde56`|

### 3. Build & Run Docker Image

- Build Docker image 
```
sudo docker build --pull --rm -t {tag_name}:latest --build-arg version={version_number} "."
```
**Squid4**

```
sudo docker build --pull --rm -t squid4:latest "."
```

**Squid5**

```
sudo docker build --pull --rm -t squid5:latest --build-arg version=5 "."
```

- Run Docker container on port forwarding

```
sudo docker run --name {container_name} -it -d -p {host_port_number}:3128 {tag_name}
```

**Squid4**

```
sudo docker run --name squid4_proxy -it -d -p 8080:3128 squid4
```

**Squid5**

```
sudo docker run --name squid5_proxy -it -d -p 8081:3128 squid5
```


- Start Squid in container:

```
sudo docker exec -d {container_name} squid
```

**Squid4**

```
sudo docker exec -d squid4_proxy squid
```

**Squid5**

```
sudo docker exec -d squid5_proxy squid
```

- Verify your container is running by listing all containers:

```
sudo docker ps -a
```

You should be able to see that the status is Up.

```
CONTAINER ID   IMAGE     COMMAND                  CREATED         STATUS         PORTS                                       NAMES
825cc1cdde56   squid5    "/docker-entrypoint.…"   2 minutes ago   Up 2 minutes   0.0.0.0:8081->3128/tcp, :::8081->3128/tcp   squid5_proxy

d8ddfe0c3670   squid4    "/docker-entrypoint.…"   3 seconds ago   Up 2 seconds                0.0.0.0:8080->3128/tcp, :::8080->3128/tcp   squid4_proxy
```

- Verify Squid is running on your local host

```
curl -I http://localhost:{port_number}
```

**Squid4**

```
curl -I http://localhost:8080
```

You should be able to see the following response, including Squid's version.


```
HTTP/1.1 400 Bad Request
Server: squid/4.17
Mime-Version: 1.0
Date: Thu, 03 Mar 2022 15:11:21 GMT
Content-Type: text/html;charset=utf-8
Content-Length: 3509
X-Squid-Error: ERR_INVALID_URL 0
Vary: Accept-Language
Content-Language: en
X-Cache: MISS from d8ddfe0c3670
Via: 1.1 d8ddfe0c3670 (squid/4.17)
Connection: close
```

**Squid5**

```
curl -I http://localhost:8081
```

You should be able to see the following response, including Squid's version.


```
HTTP/1.1 400 Bad Request
Server: squid/5.4.1
Mime-Version: 1.0
Date: Thu, 03 Mar 2022 14:40:41 GMT
Content-Type: text/html;charset=utf-8
Content-Length: 3510
X-Squid-Error: ERR_INVALID_URL 0
Vary: Accept-Language
Content-Language: en
X-Cache: MISS from 825cc1cdde56
Via: 1.1 825cc1cdde56 (squid/5.4.1)
Connection: close
```


- Using SSL & importing self-signed certificate to client browser
    - in your host machine, copy the certificate to your current directory

    ```
    sudo docker cp {container_name}:/etc/squid/cert/ca_cert.der .
    ```
    **Squid4**

    ```
    sudo docker cp squid4_proxy:/etc/squid/cert/ca_cert.der .
    ```

    **Squid5**

    ```
    sudo docker cp squid5_proxy:/etc/squid/cert/ca_cert.der .
    ```
    - to import on Firefox:
        - settings > search for `certificates` > `view certificates` button > you should be able to see the certificates manager > click on `Import`

        ![image](https://user-images.githubusercontent.com/60857664/156594733-373a8f39-577a-42f5-bda7-f5866aec9285.png)

    
        - you'll be prompted the following when you choose your certificate > trust to identify websites and email users.

         ![image](https://user-images.githubusercontent.com/60857664/156596368-9f658d95-b617-4d40-8361-0d4bba06f238.png)

        - in settings > search for `proxy` > input manual proxy data & enable for HTTPS

          ![image](https://user-images.githubusercontent.com/60857664/156597131-26d79f12-ab75-448f-8f84-8626aea34192.png)

    
- To check certificate data in browser
    - navigate to an HTTPS based website
    - click on the lock in the address bar

    ![image](https://user-images.githubusercontent.com/60857664/156928457-b5ae5fd0-2e62-4f46-abbd-6847b682f4da.png)

    - you should be able to see the data for **Verified by:** as **Organization (O) or Organization Unit (OU)** modified in [configure squid script](configure_squid.sh)


    ![image](https://user-images.githubusercontent.com/60857664/156928495-23180721-d57a-4356-97a0-805507684a82.png)

    - 'view certificate' should show you the subject name as per [configure squid script](configure_squid.sh)


    ![image](https://user-images.githubusercontent.com/60857664/156928637-18503927-7449-47e7-8676-39f5f8562458.png)


- Access container terminal for logs

```
sudo docker exec -it {container_id} /bin/ash
```

**Squid4**

```
sudo docker exec -it d8ddfe0c3670 /bin/ash
```

 **Squid5**

```
sudo docker exec -it 825cc1cdde56 /bin/ash
```

- For debug and error messages generated by Squid: 

```
tail -f /var/log/squid/cache.log
```

For key information about HTTP transactions [client IP address (or hostname), requested URI, response size, etc.]:

```
tail -f /var/log/squid/access.log
```
