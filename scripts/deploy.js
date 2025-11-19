import hre from "hardhat";

async function main() {
  const { ethers, run } = hre;

  // --- Deploy FriendshipBracelets ---
  console.log("Deploying FriendshipBracelets...");
  const FriendshipBracelets = await ethers.getContractFactory("FriendshipBracelets");
  const frndAbi = FriendshipBracelets.interface.fragments.find(f => f.type === "constructor");
  const frndInputs = frndAbi ? frndAbi.inputs.length : 0;

  let frnd;
  let frndConstructorArgs = [];

  if (frndInputs === 0) {
    frnd = await FriendshipBracelets.deploy();
  } else if (frndInputs === 3) {
    const initialSupply = ethers.parseUnits("1000000", 18);
    frndConstructorArgs = ["Friendship Bracelets", "FRND", initialSupply];
    frnd = await FriendshipBracelets.deploy("Friendship Bracelets", "FRND", initialSupply);
  } else {
    throw new Error(`Unexpected constructor inputs count: ${frndInputs}`);
  }

  await frnd.waitForDeployment();
  console.log("FriendshipBracelets deployed to:", frnd.target);

  // Wait for confirmations before verifying
  console.log("Waiting for block confirmations...");
  await new Promise(resolve => setTimeout(resolve, 30000)); // Wait 30 seconds

  try {
    await run("verify:verify", {
      address: frnd.target,
      constructorArguments: frndConstructorArgs
    });
    console.log("FriendshipBracelets verified on Etherscan");
  } catch (err) {
    console.log("Verification failed:", err.message);
  }

  // --- Deploy DecentralizedCasino ---
  console.log("\nDeploying DecentralizedCasino...");
  const DecentralizedCasino = await ethers.getContractFactory("DecentralizedCasino");
  const casino = await DecentralizedCasino.deploy();

  await casino.waitForDeployment();
  console.log("DecentralizedCasino deployed to:", casino.target);

  // Wait for confirmations before verifying
  console.log("Waiting for block confirmations...");
  await new Promise(resolve => setTimeout(resolve, 30000)); // Wait 30 seconds

  try {
    await run("verify:verify", {
      address: casino.target,
      constructorArguments: []
    });
    console.log("DecentralizedCasino verified on Etherscan");
  } catch (err) {
    console.log("Verification failed:", err.message);
  }

  console.log("\n=== Deployment Summary ===");
  console.log("FriendshipBracelets:", frnd.target);
  console.log("DecentralizedCasino:", casino.target);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});