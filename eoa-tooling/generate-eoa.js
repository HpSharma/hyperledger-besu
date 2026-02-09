require("dotenv").config();

const { Wallet } = require("ethers");
const fs = require("fs");
const path = require("path");

async function main() {
  const password = process.env.EOA_KEY_PASSWORD;
  
  const wallet = Wallet.createRandom();
  const keystoreJson = await wallet.encrypt(password);

  const outputDir = path.join(__dirname, "../eth-keys");

  if (!fs.existsSync(outputDir)) {
    console.log(`Output directory ${outputDir} does not exist.`);
    process.exit(1);
  } 

  const filename = "UTC--" + new Date().toISOString().replace(/[:]/g, "-") + "--" + wallet.address.slice(2);

  const outputPath = path.join(outputDir, filename);
  fs.writeFileSync(outputPath, keystoreJson, { mode: 0o600 });

  const addressPath = path.join(outputDir, "address.addr");
  fs.writeFileSync(addressPath, wallet.address);

  console.log(`Generated new EOA: ${wallet.address}`); 
  console.log(`Keystore file saved to: ${outputPath}`);
  console.log(`Address saved to: ${addressPath}`);
} 

main().catch((error) => {
  console.error("Error generating EOA:", error);
  process.exit(1);
});