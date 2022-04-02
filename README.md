# rpizwsolar-server

Server to assist rpizwsolar Project

## Building the Docker Image

Within the same directory as the Dockerfile:

```
docker build -t rpizwsolar_server_image:latest .
```

## Running the Docker Container, Binding Code in Dev Mode

Within the same directory as the docker-compose.yml file:

```
docker-compose up -d
```
### Exec Into Container in Dev Mode

```
docker exec -it rpizwsolar_server_container  /bin/bash
```
