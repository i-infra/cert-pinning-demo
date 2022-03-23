#!/bin/bash
set -exu
echo "Welcome to the Flyer-Fuller-Service-Launcher!\n"

# silly way of generating a list of random words that would make good service names
echo -ne $(python3 -c 'import urllib.request; wordlist = urllib.request.urlopen("https://raw.githubusercontent.com/bitcoin/bips/master/bip-0039/english.txt").read().decode().split();print("\\n".join(("-".join(sorted(wordlist, key=lambda _ : int.from_bytes(open("/dev/urandom", "rb").read(4), "little"))[0:4]).rjust(40)) for _ in range(10)))')
echo "Please enter your favourite name!"
read APPNAME

DEPLOY=$APPNAME.deploy
STORAGENAME=$(echo -n $APPNAME | sed -e 's/-/_/g')_data
REGION=iad

# select testnet or mainnet
echo "Do you want to run on testnet or mainnet"
read MOB_CHAIN

# get fly org interactively
echo "What fly.io organization to use?"
read FLY_ORG

# build keys for the specified app
./create_keychain.sh $APPNAME

mkdir -p $DEPLOY
cat fly.toml | sed -e "s/rose-gadget-abstract-high/$APPNAME/" | sed -e "s/rose_gadget_abstract_high_data/$STORAGENAME/" > $DEPLOY/fly.toml
cp Dockerfile stunnel.docker.conf run.sh $DEPLOY/
mv $APPNAME.secrets $APPNAME.clientsecrets $DEPLOY/
if [[ "$MOB_CHAIN" == testnet ]]; then
    cp run-test.sh $DEPLOY/run.sh
fi

# set the chain target
sed -i "s/mainnet/$MOB_CHAIN/g" $DEPLOY/Dockerfile

# do the deploy on Fly
cd $DEPLOY

flyctl create --org $FLY_ORG --name $APPNAME || true

if [ -z "$(flyctl volumes list --app $APPNAME --config $APPNAME/fly.toml | grep -v No\ Volumes | grep $STORAGENAME)" ]
then
    flyctl volumes create --app $APPNAME --config $APPNAME/fly.toml --region $REGION --size 2 $STORAGENAME
fi

flyctl deploy --app $APPNAME --build-only

echo "Setting secrets!"
set +x
flyctl secrets --app $APPNAME set $(cat $APPNAME.secrets) || true
set -x

flyctl deploy --app $APPNAME
