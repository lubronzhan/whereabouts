#!/bin/sh

set -u -e

source lib.sh

echo "Sleep and Watching for service account token and CA file changes..."
# enter sleep/watch loop
while true; do
  # Check the md5sum of the service account token and ca.
  svcaccountsum=$(md5sum $SERVICE_ACCOUNT_TOKEN_PATH | awk '{print $1}')
  if [ -f "$KUBE_CA_FILE" ]; then
    casum=$(md5sum $KUBE_CA_FILE | awk '{print $1}')
  fi
  if [ "$svcaccountsum" != "$LAST_SERVICEACCOUNT_MD5SUM" ] || ! [ "$SKIP_TLS_VERIFY" == "true" ] && [ "$casum" != "$LAST_KUBE_CA_FILE_MD5SUM" ]; then
    log "Detected service account or CA file change, regenerating kubeconfig..."
    generateKubeConfig
    LAST_SERVICEACCOUNT_MD5SUM="$(get_token_md5sum)"
    if [ -f "$KUBE_CA_FILE" ]; then
      LAST_KUBE_CA_FILE_MD5SUM="$(get_ca_file_md5sum)"
    fi
  fi

  sleep 1s
done
