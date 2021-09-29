FROM mcr.microsoft.com/vscode/devcontainers/base:alpine

RUN apk add --no-cache \
    # Dlang requirements
    dub dmd ldc gcc-gdc \
    # Blas requirements
    openblas-dev
