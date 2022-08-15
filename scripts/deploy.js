// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  //const lockedAmount = hre.ethers.utils.parseEther("1");

  /*  TODO: The current `npx hardhat circom` command generates verifier
   *  Solidity files that contain a contract named "Verifier." However,
   *  the deployment only works if these contracts are named after the
   *  Solidity files that contain them (i.e. the contract inside 
   *  BoardsetupVerifier.sol should be called BoardsetupVerifier and similarly
   *  for FireshotVerifier.). The verifiers in the current project were manually
   *  edited to make this script work. Ideally, the `npx hardhat circom` command
   *  should produce valid verifiers automatically. One thing to notice is the
   *  older pragma statements in the verifiers (^0.6.11). That smells of a circom
   *  compiler version issue. Sus.
   */
  const BoardsetupVerifier = await hre.ethers.getContractFactory("BoardsetupVerifier");
  const boardsetupVerifier = await BoardsetupVerifier.deploy();
  await boardsetupVerifier.deployed();
  console.log(
    `BoardsetupVerifier.sol deployed to ${boardsetupVerifier.address}. Time: ${Date.now()}`
  );

  const FireshotVerifier = await hre.ethers.getContractFactory("FireshotVerifier");
  const fireshotVerifier = await FireshotVerifier.deploy();
  await fireshotVerifier.deployed();
  console.log(
    `FireshotVerifier.sol deployed to ${fireshotVerifier.address}. Time: ${Date.now()}`
  );

  const BattleshipGame = await hre.ethers.getContractFactory("BattleshipGame");
  const battleshipGame = await BattleshipGame.deploy(boardsetupVerifier.address, fireshotVerifier.address);
  await battleshipGame.deployed();
  console.log(
    `BattleshipGame.sol deployed to ${battleshipGame.address}. Time: ${Date.now()}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
