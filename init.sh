#!/bin/sh

rm -rf ~/.simapp

BINARY=simd
CHAINID=sim
LOGDIR="$HOME/.simapp/log"
GENESIS=$HOME/.simapp/config/genesis.json
VALIDATOR_KEY=$HOME/.simapp/config/priv_validator_key.json
TMP_GENESIS=$HOME/.simapp/config/tmp_genesis.json

MNEMONIC_1="guard cream sadness conduct invite crumble clock pudding hole grit liar hotel maid produce squeeze return argue turtle know drive eight casino maze host"
MNEMONIC_2="friend excite rough reopen cover wheel spoon convince island path clean monkey play snow number walnut pull lock shoot hurry dream divide concert discover"
MNEMONIC_3="fuel obscure melt april direct second usual hair leave hobby beef bacon solid drum used law mercy worry fat super must ritual bring faculty"
MNEMONIC_4="trend cancel uncle tired that room day emerge source march laugh wall govern maple assume slab near omit hood item twice now aisle cube"
GENESIS_COINS=10000000000000stake,10000000000000uatom

# Initialize chain
$BINARY init test --chain-id ${CHAINID}

# Add keys
echo $MNEMONIC_1 | $BINARY keys add validator --recover --keyring-backend=test 
echo $MNEMONIC_2 | $BINARY keys add user1 --recover --keyring-backend=test 
echo $MNEMONIC_3 | $BINARY keys add user2 --recover --keyring-backend=test
echo $MNEMONIC_4 | $BINARY keys add recipient --recover --keyring-backend=test

# Add genesis accounts
$BINARY genesis add-genesis-account $($BINARY keys show validator --keyring-backend test -a) $GENESIS_COINS
$BINARY genesis add-genesis-account $($BINARY keys show user1 --keyring-backend test -a) $GENESIS_COINS
$BINARY genesis add-genesis-account $($BINARY keys show user2 --keyring-backend test -a) $GENESIS_COINS

jq -r --argjson val '{"pub_key": {"ed25519": '$(jq '.pub_key["value"]' $VALIDATOR_KEY)'},"power": 1}' '.app_state["poa"]["validators"][0] |= .+$val' $GENESIS > "$TMP_GENESIS" && mv "$TMP_GENESIS" "$GENESIS"

# mkdir $LOGDIR
# $BINARY start > $LOGDIR/$CHAINID.log 2>&1 &

# sleep 3
