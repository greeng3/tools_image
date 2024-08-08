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
docker run -v .:/workspace -w /workspace -it greeng340or/tools_image /bin/bash
```

### If it is already running
```bash
docker exec -v .:/workspace -w /workspace -it greeng340or/tools_image /bin/bash
```

## Git pre-commit hook

```bash
cp git-pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```