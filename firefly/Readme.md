Generate an Ethereum EOA - Externally Owned Account.
podman run --rm -it \
  -v $(pwd)/eth-keys:/keys:Z \
  hyperledger/besu:25.12.0 \
    account new --keystore-path=/keys


podman run -d \
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


