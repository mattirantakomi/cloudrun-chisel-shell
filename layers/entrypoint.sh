#!/usr/bin/env bash

_term() {
  >&2 echo "TERM (entrypoint.sh)"
  exit 0
}
trap "_term" TERM

CONF_DIR="/etc/dropbear"
SSH_KEY_DSS="${CONF_DIR}/dropbear_dss_host_key"
SSH_KEY_RSA="${CONF_DIR}/dropbear_rsa_host_key"

# Check if conf dir exists
if [ ! -d ${CONF_DIR} ]; then
    mkdir -p ${CONF_DIR}
fi
chown root:root ${CONF_DIR}
chmod 755 ${CONF_DIR}

# Check if keys exists
if [ ! -f ${SSH_KEY_DSS} ]; then
    dropbearkey  -t dss -f ${SSH_KEY_DSS}
fi
chown root:root ${SSH_KEY_DSS}
chmod 600 ${SSH_KEY_DSS}

if [ ! -f ${SSH_KEY_RSA} ]; then
    dropbearkey  -t rsa -f ${SSH_KEY_RSA} -s 2048
fi
chown root:root ${SSH_KEY_RSA}
chmod 600 ${SSH_KEY_RSA}

if [ ! -z "${AUTHORIZED_KEYS}" ]; then
  mkdir -p /root/.ssh
  echo "${AUTHORIZED_KEYS}" > /root/.ssh/authorized_keys
  chmod 700 /root/.ssh
  chmod 600 /root/.ssh/authorized_keys
fi

/usr/sbin/dropbear -j -k -s -p 2222 -E
echo "dropbear started"

PROJECT_ID=$(curl -s "http://metadata.google.internal/computeMetadata/v1/project/project-id" -H "Metadata-Flavor: Google")
REGION=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/region" -H "Metadata-Flavor: Google" | sed "s/.*\///")
TOKEN=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token" -H "Metadata-Flavor: Google" | jq -r '.access_token')
PUBLIC_URL=$(curl -s "https://${REGION}-run.googleapis.com/apis/serving.knative.dev/v1/namespaces/${PROJECT_ID}/services/${K_SERVICE}" -H "Authorization: Bearer ${TOKEN}" | jq -r '.status.url')

echo "Connect with ssh using the following command:"
echo
echo "ssh -o ProxyCommand='chisel client --auth ${CHISEL_USER}:${CHISEL_PASS} ${PUBLIC_URL} stdio:localhost:2222' root@localhost"

while true; do curl -s -A "ping-pong" --output /dev/null --connect-timeout 5 ${PUBLIC_URL} || true; sleep 5; done &

while true; do
  set +e
    chisel server -v --auth "$CHISEL_USER:$CHISEL_PASS" --port $PORT --reverse
  set -e
  sleep 1
done