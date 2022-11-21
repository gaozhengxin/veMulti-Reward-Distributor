const hre = require("hardhat");

const chainID = {
    'eth': 1,
    'fantom': 250,
    'bsc': 56
}

const adaptors = {
    'eth': "0xAA14178Cd6CCb6E03AcB316F6d0f304f478c66B4",
    'fantom': "0x0e7Ae79D3C324726f3610233F3d6510815611031",
    'bsc': "0x9C432FD8C5A32C6Cc01792D33Bfb3E1c3C2440aa"
}

const distributors = {
    '1': "0x58FBa1B9550eB423ebb9526Ad262c2DfF2d89270",
    '250': "0x301355c580e62884B0907deA742F9787fED72217",
    '56': "0x103F7d014f46C6bcB9f86217c36368a08aBE426e"
}

const chains = {
    'eth': [250, 56],
    'fantom': [1, 56],
    'bsc': [1, 250]
}

const peers = {
    'eth': ['0x0e7Ae79D3C324726f3610233F3d6510815611031', '0x9C432FD8C5A32C6Cc01792D33Bfb3E1c3C2440aa'],
    'fantom': ['0xAA14178Cd6CCb6E03AcB316F6d0f304f478c66B4', '0x9C432FD8C5A32C6Cc01792D33Bfb3E1c3C2440aa'],
    'bsc': ['0xAA14178Cd6CCb6E03AcB316F6d0f304f478c66B4', '0x0e7Ae79D3C324726f3610233F3d6510815611031']
}

async function main() {
    const [owner] = await ethers.getSigners();
    console.log("owner " + owner.address);

    /*let adaptor = await ethers.getContractAt("AnyCallV6Adaptor", adaptors[hre.network.name]);
    console.log(`adaptor ${adaptor.address}`);
    let admin = await adaptor.admin();
    console.log(admin);
    await adaptor.setPeers(chains[hre.network.name], peers[hre.network.name]);*/

    let distributor = await ethers.getContractAt("RewardDistributor", distributors[chainID[hre.network.name]]);
    console.log(`distributor ${distributor.address}`);
    for (var i in chains[hre.network.name]) {
        var chain = chains[hre.network.name][i];
        console.log(chain);
        await distributor.setPeer(chain, distributors[chain]);
    }

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
