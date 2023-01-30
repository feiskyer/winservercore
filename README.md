# Multi-architecture images for Windows containers

## How to use

```sh
docker pull ghcr.io/feiskyer/winservercore:v1.0
```

## How to build

How to build multiarch images for servercore:

```sh
make
```

How to build multiarch images for nanoserver:

```sh
IMAGE_NAME=ghcr.io/feiskyer/winnanoserver TAG=v1.0 BASE=mcr.microsoft.com/windows/nanoserver make
```
