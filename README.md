Dockerfile for emulating win32 and win64 programs on arm64 using wine and box in Debian.

## Using
Docker compose
```bash
docker-compose -d up 
docker attach winebox64
```
Docker
```bash
docker build -t winebox64 . 
docker run --name winebox64 -ti winebox64
```
