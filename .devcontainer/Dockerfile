FROM mcr.microsoft.com/vscode/devcontainers/base:ubuntu-18.04

ARG user=vscode

RUN useradd -s /bin/bash ${user} \
    && usermod -aG sudo ${user}

USER ${user}