# tools_image
A container of format, lint, etc. tools

## Tools Included

- clang-format
- clang-tidy

## Building

```bash
docker buildx build --platform linux/amd64,linux/arm64 -t greeng340or/tools_image -f Dockerfile --push .
```

## Getting a shell for development or other purposes

### If it's not already running
```bash
docker run -v .:/opt/repo -w /opt/repo -it greeng340or/tools_image /bin/bash
```

### If it is already running
```bash
docker exec -v .:/opt/repo -w /opt/repo -it greeng340or/tools_image /bin/bash
```

