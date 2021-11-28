#!/bin/bash
echo $ROOTCRT | base64 -d | gzip -d > cacert.pem
echo $SERVERCRT | base64 -d | gzip -d > servercert.pem
set -exu
stunnel stunnel.conf &
./full-service \
  --wallet-db /data/wallet.db \
  --ledger-db /data/ledger-db/ \
  --peer mc://node1.prod.mobilecoinww.com/ \
  --peer mc://node2.prod.mobilecoinww.com/ \
  --tx-source-url https://ledger.mobilecoinww.com/node1.prod.mobilecoinww.com/ \
  --tx-source-url https://ledger.mobilecoinww.com/node2.prod.mobilecoinww.com/ \
  --fog-ingest-enclave-css ./ingest-enclave.css \
  --listen-host 127.0.0.1
