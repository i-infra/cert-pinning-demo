#!/bin/bash
set -exu

name=${1:-$HOSTNAME}
host=${1:-$HOSTNAME.lan}
if [ -z "$(echo $host | grep '\.' -)" ]
then
    host=$host.fly.dev
fi

config="/CN=$host/"
output="$PWD/output.$name"
password_file="$output/password_file"


function ensure_root_ca_cert_exists () {
    if [ ! -f $output/rootcrt.pem ]
    then
        mkdir -p $output
        cat openssl.cnf | sed -e "s/output/output.$name/g" > $output/openssl.cnf
        cat /dev/urandom | head -c 24 | base64 > $password_file
        touch $output/index
        openssl genrsa -aes256 -passout pass:$password_file -out $output/ca.pass.key 4096
        openssl rsa -passin pass:$password_file -in $output/ca.pass.key -out $output/root.key
        openssl req -nodes -new -newkey rsa:4096 -passin pass:$password_file -in $output/ca.pass.key -keyout $output/root.key -out $output/rootreq.pem -config $output/openssl.cnf
        openssl ca -batch -out $output/rootcrt.pem -days 2652 -keyfile $output/root.key -selfsign -config $output/openssl.cnf -extensions ca_ext -in $output/rootreq.pem -sigopt rsa_padding_mode:pss -sigopt rsa_pss_saltlen:-1 -create_serial
    fi
}

function remove_all_keys() {
    rm -r $output
    mkdir -p $output
}

function generate_and_sign_child_key() {
    child_name=$1
    openssl genrsa -aes256 -passout pass:$password_file -out $output/$child_name.pass.key 4096
    openssl rsa -passin pass:$password_file -in $output/$child_name.pass.key -out $output/$child_name.key
    openssl req -new -subj $config -key $output/$child_name.key -out $child_name.csr
    openssl ca -batch -in $child_name.csr -days 1200 -cert $output/rootcrt.pem -keyfile $output/root.key -sigopt rsa_padding_mode:pss -sigopt rsa_pss_saltlen:-1 -out $output/$child_name.crt.pem -config $output/openssl.cnf -create_serial
    rm $child_name.csr
    openssl verify -CAfile $output/rootcrt.pem $output/$child_name.crt.pem
    cat $output/$child_name.key $output/$child_name.crt.pem > $output/$child_name.full.pem
}


function ensure_child_key_exists() {
    if [ ! -f $output/$1.full.pem ]
    then
        generate_and_sign_child_key $1
    fi
}

ensure_root_ca_cert_exists
ensure_child_key_exists "client"
ensure_child_key_exists "server"
echo "Building secrets file!"
set +x
echo "ROOTCRT=$(cat $output/rootcrt.pem | gzip - | base64 --wrap=0)" > $name.secrets
echo "SERVERCRT=$(cat $output/server.full.pem | gzip - | base64 --wrap=0)" >> $name.secrets

## might be needed for stunnel verif=3
#rm -f *.0 || true
#ln -s rootcrt.pem $(openssl x509 -hash -noout -in rootcrt.pem).0
#ln -s $child_namecrt.pem $(openssl x509 -hash -noout -in $child_namecrt.pem).0


## and now, this works!
#curl -vvvv --cert $child_name.full.pem --cacert $output/rootcrt.pem https://host:9099/wallet

## alternatively
#openssl s_client -showcerts -servername $host -cert $child_name.full.pem -connect $host:9099 > curl-ca-bundle.crt
#curl -vvvv --cert $child_namecrt.pem --key $child_name.key --cacert curl-ca-bundle.crt https://$host:9099/wallet
