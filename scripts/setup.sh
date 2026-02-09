#!/bin/bash

set -e 

export PROJ="$(pwd)";
echo "$PROJ"

echo "-------------- Cleaning up old directories --------------"
rm -rf "$PROJ/shared-config/addresses" \
        "$PROJ/shared-config/enodes "\
        "$PROJ/shared-config/generated" \
        "$PROJ/shared-config/static-nodes.json" \
        "$PROJ/shared-config/validators.list" \
        "$PROJ/shared-config/validator/"

rm -rf "$PROJ/orgs/"


echo "-------------- Generate keys and Genesis.json --------------"
mkdir -p "$PROJ/shared-config/generated"

#chcon -R -t container_file_t "$PROJ/shared-config"
chown -R 1000:1000 "$PROJ/shared-config/generated"

podman run --rm \
  -v "$PROJ/shared-config:/config:ro,z" \
  -v "$PROJ/shared-config/generated:/out:Z" \
  --entrypoint /opt/besu/bin/besu \
  docker.io/hyperledger/besu:25.12.0 \
    operator generate-blockchain-config \
    --config-file=/config/config.json \
    --to=/out \
    --private-key-file-name=nodekey

echo "-------------- Executing copy-keys-to-orgs --------------"
mkdir -p "$PROJ/orgs/bankA/validator1/data"  \
          "$PROJ/orgs/bankA/validator2/data"  \
          "$PROJ/orgs/bankB/validator3/data"  \
          "$PROJ/orgs/bankB/validator4/data"

# Get only the directory names starting with '0x'
ADDR=( $(ls -1 "$PROJ/shared-config/generated/keys" | grep '^0x' | sort) )

# Check array size
if [ ${#ADDR[@]} -ne 4 ]; then
    echo "Error: Expected 4 keys, but found ${#ADDR[@]}"
    exit 1
fi

# Assign to variables correctly
A1=${ADDR[0]}
A2=${ADDR[1]}
B3=${ADDR[2]}
B4=${ADDR[3]}


mkdir -p "$PROJ/orgs/bankA/validator1/keys"  \
          "$PROJ/orgs/bankA/validator2/keys"  \
          "$PROJ/orgs/bankB/validator3/keys"  \
          "$PROJ/orgs/bankB/validator4/keys"

install -m 600 "$PROJ/shared-config/generated/keys/$A1/nodekey" "$PROJ/orgs/bankA/validator1/keys/nodekey"
install -m 600 "$PROJ/shared-config/generated/keys/$A2/nodekey" "$PROJ/orgs/bankA/validator2/keys/nodekey"
install -m 600 "$PROJ/shared-config/generated/keys/$B3/nodekey" "$PROJ/orgs/bankB/validator3/keys/nodekey"
install -m 600 "$PROJ/shared-config/generated/keys/$B4/nodekey" "$PROJ/orgs/bankB/validator4/keys/nodekey"

mkdir -p "$PROJ/shared-config/enodes"
cp "$PROJ/shared-config/generated/keys/$A1/key.pub" "$PROJ/shared-config/enodes/bankA-validator1.pub"
cp "$PROJ/shared-config/generated/keys/$A2/key.pub" "$PROJ/shared-config/enodes/bankA-validator2.pub"
cp "$PROJ/shared-config/generated/keys/$B3/key.pub" "$PROJ/shared-config/enodes/bankB-validator3.pub"
cp "$PROJ/shared-config/generated/keys/$B4/key.pub" "$PROJ/shared-config/enodes/bankB-validator4.pub"

mkdir -p "$PROJ/shared-config/addresses"
echo "$A1" > "$PROJ/shared-config/addresses/bankA-validator1.addr"
echo "$A2" > "$PROJ/shared-config/addresses/bankA-validator2.addr"
echo "$B3" > "$PROJ/shared-config/addresses/bankB-validator3.addr"
echo "$B4" > "$PROJ/shared-config/addresses/bankB-validator4.addr"

cat \
    "$PROJ/shared-config/addresses/bankA-validator1.addr" \
    "$PROJ/shared-config/addresses/bankA-validator2.addr" \
    "$PROJ/shared-config/addresses/bankB-validator3.addr" \
    "$PROJ/shared-config/addresses/bankB-validator4.addr" \
    > "$PROJ/shared-config/validators.list"

cat "$PROJ/shared-config/validators.list"

cp "$PROJ/shared-config/generated/genesis.json" "$PROJ/shared-config/genesis.json"
echo "Genesis.json generated and copied to shared-config/genesis.json"

# chcon -R -t container_file_t "orgs"
chown -R 1000:1000 "$PROJ/orgs"

echo "-------------- Generating static-nodes.json --------------"
ENODES_DIR="$PROJ/shared-config/enodes"
STATIC_NODES_FILE="$PROJ/shared-config/static-nodes.json"
cat > "$STATIC_NODES_FILE" <<EOL
[
    "enode://$(tr -d '\n\r ' < "$ENODES_DIR/bankA-validator1.pub" | sed 's/0x//')@bankA-v1:30303",
    "enode://$(tr -d '\n\r ' < "$ENODES_DIR/bankA-validator2.pub" | sed 's/0x//')@bankA-v2:30303",
    "enode://$(tr -d '\n\r ' < "$ENODES_DIR/bankB-validator3.pub" | sed 's/0x//')@bankB-v3:30303",
    "enode://$(tr -d '\n\r ' < "$ENODES_DIR/bankB-validator4.pub" | sed 's/0x//')@bankB-v4:30303"
]
EOL

echo "-------------- Setup complete --------------"
podman-compose -f "$PROJ/compose/compose.yaml" up -d