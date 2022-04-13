FROM alpine:latest

RUN apk update
RUN apk add bash zsh curl

RUN eval "$(curl --fail https://get.x-cmd.com)"
RUN cp /root/.shinit /root/.bashrc
RUN cp /root/.shinit /root/.zshrc
RUN cp /root/.shinit /root/.kshrc
