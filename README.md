# docker-api-gateway
An API gateway is a single entry point for APIs in a microservices infrastructure. It provides authentication and authorization layers, routes and load balances requests to API services, and caches previous requests. 

This sample code demonstrates how to deploy an API gateway with [Docker](https://www.docker.com/) and [3scale](https://www.3scale.net/). There is no Docker image, you will need to amend the configuration files in [conf](https://github.com/cirulls/docker-api-gateway/tree/master/conf) according to your own 3scale configuration. These configuration files contain comments in uppercase starting with 'CHANGE' in order to highlight what you need to change. 

Build the Docker image with:
```bash
docker build -t api-gateway .
```
Run the Docker container with:
```bash
docker run -p 80:80 -p 443:443 -d -it api-gateway
```
My 3scale configuration is set up with app_id and app_key as authentication mode. 

Test it on port 80 with:
```bash
curl -v "http://yourdomainname.com/path/to/api" -H'app_id: your3scaleappid' -H'app_key: your3scaleappkey'
```

Test it on port 443 and https with:
```bash
curl -v "https://yourdomainname.com:443/path/to/api" -H'app_id: your3scaleappid' -H'app_key: your3scaleappkey'
```
### 3scale Settings
The configuration files in [conf](https://github.com/cirulls/docker-api-gateway/tree/master/conf) require settings which are specific to 3scale. Here is where to find the values for these settings on your 3scale admin account:

**3SCALE PROVIDER KEY/SECRET TOKEN**

You can find your 3scale provider key in https://youraccount-admin.3scale.net/p/admin/account. 

![alt text](https://github.com/cirulls/docker-api-gateway/blob/master/screenshots/provider_key.png "3scale provider key")

**API SERVICE ID**

You can find your API service ID by going to https://youraccount-admin.3scale.net/apiconfig/services and selecting the API service:

![alt text](https://github.com/cirulls/docker-api-gateway/blob/master/screenshots/api_service_id.png "API Service ID")

**LUA FILE NAME**

You can find the name of the .lua file by downloading the nginx configuration files from https://youraccount-admin.3scale.net/apiconfig/services/123456789/integration/edit (replace the dummy digits in the URL with your API service ID):
 
![alt text](https://github.com/cirulls/docker-api-gateway/blob/master/screenshots/lua_filename.png "Download lua file")

### SSL Certificates
If you want to run the API gateway with HTTPS (recommended for production), put your .crt and .key certificates in [certificates](https://github.com/cirulls/docker-api-gateway/tree/master/certificates) and make sure the file names are correctly set in the server directive of the [nginx conf file](https://github.com/cirulls/docker-api-gateway/blob/master/conf/nginx_123456789.conf), e.g.:
```lua
ssl_certificate /usr/local/openresty/nginx/ssl/bundle.crt;
ssl_certificate_key /usr/local/openresty/nginx/ssl/certificate.key;
```
You can create a self-signed SSL certificate using ```openssl``` (see also [these instructions](https://www.digitalocean.com/community/tutorials/how-to-create-an-ssl-certificate-on-nginx-for-ubuntu-14-04)):
```bash
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt
```
If you are using a self-signed certificate, add ```-k``` to the ```curl``` command. 

You can validate your SSL certificates using a Certificate Authority. Alternatively, you can validate them for free using [Let's Encrypt](https://letsencrypt.org/).

If you want to force the use of HTTPS, remove the configuration for port 80 in the [Dockerfile](https://github.com/cirulls/docker-api-gateway/blob/master/Dockerfile) and [nginx conf file](https://github.com/cirulls/docker-api-gateway/tree/master/conf).

### Debugging
If you have problems in running the API gateway, the best way to debug it is to look at the nginx logs. If you can't start nginx, run the Docker container without the ```-d``` flag:
```bash
docker run -p 80:80 -p 443:443 -it api-gateway
```

If you can start the Docker container but nginx throws errors at you, get inside the container with:
```bash
docker exec -it <container_name> /bin/bash
```

and inspect the logs at ```/usr/local/openresty/nginx/logs```.

### Security
All secrets, passwords, certificates in this repository are clearly dummy. It is a bad security practice to store sensitive files under version control. Instead you can set up environment variables on your server and read them in your code so that sensitive information is replaced by placeholders (e.g. ```$SECRET```). This approach is still not super secure but it is much better than storing secrets under version control. Alternatively, you can encrypt the sensitive information and make sure that your code decrypts it (for this approach see for example [Ansible Vault](http://docs.ansible.com/ansible/playbooks_vault.html)). 
