const { ethers } = require("hardhat");

async function main() {
    // Deploy the Verifier contract
    const Verifier = await ethers.getContractFactory("Verifier");
    const verifier = await Verifier.deploy();
    await verifier.deployed();
    console.log("Verifier deployed to:", verifier.address);

    // Deploy the LaborerAttestation contract with the address of the Verifier contract
    const LaborerAttestation = await ethers.getContractFactory("LaborerAttestation");
    const laborerAttestation = await LaborerAttestation.deploy(verifier.address);
    await laborerAttestation.deployed();
    console.log("LaborerAttestation deployed to:", laborerAttestation.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });