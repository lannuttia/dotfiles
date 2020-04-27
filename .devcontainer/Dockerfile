ARG version=latest
FROM ubuntu:${version}

ARG user=vscode

RUN useradd ${user} \
    && usermod -aG sudo ${user}

USER ${user}