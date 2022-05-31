FROM ubuntu:22.04

RUN apt-get update && apt-get install -y curl wget screen git dnsutils iputils-ping traceroute nano dropbear net-tools

COPY layers/ /
COPY --from=jpillora/chisel /app/chisel /usr/bin

ENTRYPOINT ["/entrypoint.sh"]