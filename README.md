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
docker run -v .:/workspace -w /workspace -it greeng340or/tools_image:latest /bin/bash
```

### If it is already running

```bash
docker exec -v .:/workspace -w /workspace -it greeng340or/tools_image:latest /bin/bash
```

## Git pre-commit hook

```bash
cp git-pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

## in pyproject.toml

- cmake-format
- cmakelint
- mdformat
- mdformat-gfm
- mdformat-frontmatter
- mdformat-footnote
- autopep8
- isort
- mypy
- mypy-extensions
- pytype
- pylint
- pylint-pytest
- ruff
