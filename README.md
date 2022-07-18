Dockerfile for emulating x86_64 or amd64 Windows programs on arm64 using wine and box with ubuntu. **Must be in privileged mode for binfmts to be working!**

# Running
Using docker-compose
```bash
sudo docker-compose -d up 
sudo docker attach boxwine
```
Using docker
```bash
sudo docker build -t box-wine . 
sudo docker run --name boxwine -ti --privileged box-wine
```
