## account-updatable

A smart contract wallet that allows key rotation.

## License

(c) larry0x, 2023 - [All rights reserved](../../../LICENSE).

- When you start simd, the following keys are prepared.
```
simd keys list --keyring-backend=test
- address: cosmos1zkhqjtch44akf5aqu4xnf4wknd04nshlq339x3
  name: recipient
  pubkey: '{"@type":"/cosmos.crypto.secp256k1.PubKey","key":"AuoXG8QIvgm7Xfg9xyOchqSzX37r2U/xJCEuXH0Dn5MJ"}'
  type: local
- address: cosmos1mzgucqnfr2l8cj5apvdpllhzt4zeuh2cshz5xu
  name: user1
  pubkey: '{"@type":"/cosmos.crypto.secp256k1.PubKey","key":"AuXpdpSX+8fH7lerOczty2EgGFd9MMoJADPcZ7pdaLir"}'
  type: local
- address: cosmos185fflsvwrz0cx46w6qada7mdy92m6kx4gqx0ny
  name: user2
  pubkey: '{"@type":"/cosmos.crypto.secp256k1.PubKey","key":"AuFUt9g9uckLNgVlO7BCzqUCOL8OUg+zIgeHTxxeG4Fy"}'
  type: local
- address: cosmos1zaavvzxez0elundtn32qnk9lkm8kmcszzsv80v
  name: validator
  pubkey: '{"@type":"/cosmos.crypto.secp256k1.PubKey","key":"AvzwBOriY8sVwEXrXf1gXanhT9imlfWeUWLQ8pMxrRsg"}'
  type: local
```

# Store contract
```
simd tx wasm store ./cosmwasm/artifacts/account_updatable.wasm --from user1 --keyring-backend=test --chain-id sim --gas auto --gas-adjustment 1.4 -y
```

# Register AA
```bash
simd tx abstract-account register 1 '{"pubkey":"AuXpdpSX+8fH7lerOczty2EgGFd9MMoJADPcZ7pdaLir"}'  --salt "demo" --funds 100000000stake --from user1 --keyring-backend=test --chain-id sim --gas auto --gas-adjustment 1.4 -y
gas estimate: 252520
code: 0
codespace: ""
data: ""
events: []
gas_used: "0"
gas_wanted: "0"
height: "0"
info: ""
logs: []
raw_log: '[]'
timestamp: ""
tx: null
txhash: 5D07769845B320FDA0DCC54DD76E7D38B30E0BF869ED58529D5D437018D12A04
```

# Check Contract Address
- The contract_addr in the account_registered attribute is the Contract Address you registered.
```bash
simd q tx 5D07769845B320FDA0DCC54DD76E7D38B30E0BF869ED58529D5D437018D12A04
```

# Check registered pub key to AA
```bash
simd q wasm contract-state smart cosmos1g5qa5vqmrcazpgqxxywwfyrm7sva6y9flgywlc9rx057hq048w8srz2mu6 '{"pubkey":{}}' --output json | jq
{
  "data": "AuXpdpSX+8fH7lerOczty2EgGFd9MMoJADPcZ7pdaLir"
}
```

# Check AA balance
```bash
simd q bank balances cosmos1g5qa5vqmrcazpgqxxywwfyrm7sva6y9flgywlc9rx057hq048w8srz2mu6
balances:
- amount: "100000000"
  denom: stake
pagination:
  next_key: null
  total: "0"
```

# Sign for tx
- Change rootDir according to your environment.
- Create signed tx data using sign/main.go
```bash
cd testdata
go run sign/main.go
Signed tx written to ./1-bank-send.json
```

# Broadcast signed tx
```bash
simd tx broadcast 1-bank-send.json 
code: 0
codespace: ""
data: ""
events: []
gas_used: "0"
gas_wanted: "0"
height: "0"
info: ""
logs: []
raw_log: '[]'
timestamp: ""
tx: null
txhash: A0A61FCFE1861EB5E43AA466CBCA7CE616956C07B708B5D1C63ABFD91152CD5A
```

# Check AA balance
```bash
simd q bank balances cosmos1g5qa5vqmrcazpgqxxywwfyrm7sva6y9flgywlc9rx057hq048w8srz2mu6
balances:
- amount: "99987655"
  denom: stake
pagination:
  next_key: null
  total: "0"
```

# Update the pubkey associated with AA
- Change the file name of main.go.
```
	fileIn         = "./2-update-key-unsigned.json"
	fileOut        = "./2-update-key.json"
```
```bash
go run sign/main.go

# Broadcast signed tx
simd tx broadcast 2-update-key.json
code: 0
codespace: ""
data: ""
events: []
gas_used: "0"
gas_wanted: "0"
height: "0"
info: ""
logs: []
raw_log: '[]'
timestamp: ""
tx: null
txhash: BDFD9D9A3C14D290B466BF83CF3521154191A3F336C5291111F21EA24271D6A2
```

- Change the file name of main.go to 1-bank-send again and sign the tx keeping the keyName as user1.
```bash
go run sign/main.go
Signed tx written to ./1-bank-send.json
```

- Signing is successful but broadcasting this tx fails.
```bash
simd tx broadcast 1-bank-send.json 
code: 5
codespace: wasm
data: ""
events: []
gas_used: "0"
gas_wanted: "0"
height: "0"
info: ""
logs: []
raw_log: 'signature is invalid: execute wasm contract failed'
timestamp: ""
tx: null
txhash: 7BB0D85BE409DD8B4ECB0BA83C182B74A934390830F398B69457D6F11E842D54
```

- Change the keyName in main.go to user2, which has the priv_key linked to the updated pub_key, sign the tx again, and broadcast it successfully.
```bash
go run sign/main.go 
Signed tx written to ./1-bank-send.json
simd tx broadcast 1-bank-send.json
code: 0
codespace: ""
data: ""
events: []
gas_used: "0"
gas_wanted: "0"
height: "0"
info: ""
logs: []
raw_log: '[]'
timestamp: ""
tx: null
txhash: 4A9319F444407A53EDD8A38873C4A40AC80480FD18A25AF16EA00A66A5DCC1D1
simd q bank balances cosmos1g5qa5vqmrcazpgqxxywwfyrm7sva6y9flgywlc9rx057hq048w8srz2mu6
balances:
- amount: "99975310"
  denom: stake
pagination:
  next_key: null
  total: "0"
```
