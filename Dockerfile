FROM ubuntu:22.04

RUN apt-get update && apt-get install -y curl wget screen git dnsutils iputils-ping traceroute nano dropbear net-tools jq gzip

RUN cd /tmp \
    && wget https://github.com/jpillora/chisel/releases/download/v1.8.1/chisel_1.8.1_linux_amd64.gz \
    && gunzip chisel_1.8.1_linux_amd64.gz \
    && cp chisel_1.8.1_linux_amd64 /usr/bin/chisel \
    && chmod +x /usr/bin/chisel

COPY layers/ /

ENTRYPOINT ["/entrypoint.sh"]
