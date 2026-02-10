require("dotenv").config();

const { ethers } = require("ethers");
const fs = require("fs");
const path = require("path");

async function main() {
  const RPS_URL = "http://localhost:8545";
  const CHAIN_ID = 20260206;

  const password = process.env.EOA_KEY_PASSWORD;
  if(!password) {
    console.error("EOA_KEY_PASSWORD environment variable is not set.");
    process.exit(1);
  }

  const keystoreDir = path.join(__dirname, "../eth-keys");
  const keystoreFiles = fs.readdirSync(keystoreDir).find(file => file.startsWith("UTC--"));
  if (!keystoreFiles) {
    console.error("No keystore file found in eth-keys directory.");
    process.exit(1);
  }

  const keystoreJson = fs.readFileSync(path.join(keystoreDir, keystoreFiles), "utf-8");
  
  const provide = new ethers.providers.JsonRpcProvider(RPS_URL);

  const wallet = await ethers.Wallet.fromEncryptedJson(keystoreJson, password);
  const signer = wallet.connect(provide);
  
  console.log("Using address:", signer.address);

  const nonce = await provide.getTransactionCount(signer.address, "latest");

  const tx = {
    to: signer.address,
    value: 0,
    gasLimit: 21000,
    gasPrice: 0,
    nonce: nonce,
    chainId: CHAIN_ID
  };

  console.log("Submitting transaction:", tx);

  const response = await signer.sendTransaction(tx);
  console.log("Transaction hash:", response.hash);

  const receipt = await response.wait();
  
  console.log("Transaction receipt:", receipt.blockNumber);
  console.log("Status:", receipt.status);
}

main().catch((error) => {
  console.error("Error sending transaction:", error);
  process.exit(1);
});