Generate an Ethereum EOA - Externally Owned Account.

```bash
# Check block counts
curl -s -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  --data '{
    "jsonrpc": "2.0",
    "method": "eth_blockNumber",
    "params": [],
    "id": 1
  }'

# Get chainId
curl -s -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  --data '{
    "jsonrpc": "2.0",
    "method": "eth_chainId",
    "params": [],
    "id": 1
  }'
```

```bash
podman run -d \s
  --name firefly-core-org1 \
  --restart=unless-stopped \
  --network firefly-network \
  --env-file $(pwd)/firefly/firefly.env \
  -v $(pwd)/firefly:/config:z \
  -v $(pwd)/eth-keys:/keys:ro,z \
  -p 5000:5000 \
  -p 6000:6000 \
  hyperledger/firefly:v1.3.3 \
  -f /config/core.yaml


1. Create the Namespace (Exaclty Once)
curl -s -X POST http://localhost:5100/api/v1/namespaces \
  -H "Content-Type: application/json" \
  -d '{
    "name": "bankA",
    "description": "BankA primary Firefly namespace for Besu QBFT"
  }'

2. Check Namespace
curl -s http://localhost:5100/api/v1/namespaces

curl -s http://localhost:5000/api/v1/status
```


```bash
  # ws event listener
  wscat -c ws://localhost:8575
  { "jsonrpc": "2.0", "method": "eth_subscribe", "params": ["newHeads"], "id": 101  }
```


```bash
# execute postgres

podman exec -it firefly-postgres psql -U postgres


```