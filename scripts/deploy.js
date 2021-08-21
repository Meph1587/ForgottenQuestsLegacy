const hre = require("hardhat");

async function main() {
 
  const ws = await hre.ethers.getContractFactory("WizardStorage");
  const ws_ = await ws.deploy("Hello, Hardhat!");

  await ws_.deployed();

  console.log("WizardStorage deployed to:", ws_.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
