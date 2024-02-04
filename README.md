# tools_image
A container of format, lint, etc. tools

## Building

docker buildx build --platform linux/amd64,linux/arm64 -t greeng340or/tools_image -f Dockerfile --push .
