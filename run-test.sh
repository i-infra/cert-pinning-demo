#!/bin/bash
echo $ROOTCRT | base64 -d | gzip -d > cacert.pem
echo $SERVERCRT | base64 -d | gzip -d > servercert.pem
set -exu
stunnel stunnel.conf &
./full-service \
  --wallet-db /data/wallet.db \
  --ledger-db /data/ledger-db/ \
  --peer mc://node1.test.mobilecoin.com/ \
  --peer mc://node2.test.mobilecoin.com/ \
  --tx-source-url https://s3-us-west-1.amazonaws.com/mobilecoin.chain/node1.test.mobilecoin.com/ \
  --tx-source-url https://s3-us-west-1.amazonaws.com/mobilecoin.chain/node2.test.mobilecoin.com/ \
  --fog-ingest-enclave-css ./ingest-enclave.css \
  --listen-host 127.0.0.1
