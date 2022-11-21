const hre = require("hardhat");

const ve = {
    "eth": "0xbbA4115ecB1F811061eCb5A8DC8FcdEE2748ceBa",
    "fantom": "0xE564cBcD78A76fD0Bb716a8e4252DFF06C2e4AE7",
    "bsc": "0x3f6727DefB15996d13b3461DAE0Ba7263CA3CAc5"
}

const destChains = {
    "eth": [250, 56],
    "fantom": [1, 56],
    "bsc": [1, 250]
}

async function main() {
    const [owner] = await ethers.getSigners();
    console.log("owner " + owner.address);
    let AnyCallAdaptor = await ethers.getContractFactory("AnyCallV6Adaptor");
    let anyCallAdaptor = await AnyCallAdaptor.deploy("0xC10Ef9F491C9B59f936957026020C321651ac078");
    await anyCallAdaptor.deployed();
    console.log("anyCallAdaptor " + anyCallAdaptor.address);
    let RewardDistributor = await ethers.getContractFactory("RewardDistributor");
    let rewardDistributor = await RewardDistributor.deploy(ve[hre.network.name], "0x0000000000000000000000000000000000000000", destChains[hre.network.name]);
    await rewardDistributor.deployed();
    console.log("rewardDistributor " + rewardDistributor.address);

    rewardDistributor.setMessageChannel(anyCallAdaptor.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
