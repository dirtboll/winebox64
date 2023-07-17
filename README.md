Dockerfile for emulating win32 and win64 programs on arm64 using wine and box in Debian. Tested on Oracle Cloud Infrastructure Ampere A1.

## Using
Docker
```bash
docker build -t winebox64 . 
docker run --name winebox64 -ti winebox64
```
Docker compose
```bash
docker-compose -d up 
docker attach winebox64
```

## Examples
Running a windows-only game server from Steam (The Forest).
```bash
docker run -i --rm -p 8766:8766 -p 27015:27015 -p 27016:27016 winebox64 bash << EOF
apt update && apt install unzip
mkdir steamcmd && cd steamcmd
wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip
unzip steamcmd.zip
wine steamcmd.exe +force_install_dir ../theforest +login anonymous +app_update 556450 validate +quit
cd ../theforest
xvfb-run sh -c 'wine64 TheForestDedicatedServer.exe -serverip 0.0.0.0 -serversteamport 8766 -servergameport 27015 -serverqueryport 27016 -servername TheForestGameDS -serverplayers 8 -difficulty Normal -inittype Continue -slot 1 -showlogs'
EOF
```
