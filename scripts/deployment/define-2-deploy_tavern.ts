import {DeployConfig} from "./define-0-deploy_config";
import {deployContract, deployDiamond} from "../../helpers/deploy"

import {
    QuestAchievements,
} from "../../typechain";
export async function deployTavern(c: DeployConfig): Promise<DeployConfig> {


    const rewardNFT = await deployContract('QuestAchievements') as QuestAchievements;
    console.log(`QuestAchievements deployed to: ${rewardNFT.address.toLowerCase()}`);

    await rewardNFT.setMintingAllowance(c.owner, true);

    await rewardNFT.connect(c.owner).mint(
        c.owner,
        "An Initiation with Aleister Crowley at The Valley of the Void Disciple",
        "Archmage Orpheus of the Quantum Shadow",
        1875,
        431000
    )

    console.log(`npx hardhat verify --network rinkeby ${rewardNFT.address}`)
    
    let uri = await rewardNFT.tokenURI(0);
    console.log(uri)

    console.log(`\n --- DEPLOY TAVERN ---`);
    

    ///////////////////////////
    // Deploy 'Facet' contracts:
    ///////////////////////////
    const cutFacet = await deployContract('DiamondCutFacet');
    console.log(`DiamondCutFacet deployed to: ${cutFacet.address.toLowerCase()}`);

    const loupeFacet = await deployContract('DiamondLoupeFacet');
    console.log(`DiamondLoupeFacet deployed to: ${loupeFacet.address.toLowerCase()}`);

    const ownershipFacet = await deployContract('OwnershipFacet');
    console.log(`OwnershipFacet deployed to: ${ownershipFacet.address.toLowerCase()}`);

    const questTools = await deployContract('QuestTools');
    console.log(`QuestTools deployed to: ${questTools.address.toLowerCase()}`);

    const baseQuest = await deployContract('BaseQuest',[c.owner, c.rewardAddr]);
    console.log(`BaseQuest deployed to: ${baseQuest.address.toLowerCase()}`);


    ///////////////////////////
    // Deploy "ReignDiamond" contract:
    ///////////////////////////
    const tavern = await deployDiamond(
        'Tavern',
        [cutFacet, loupeFacet, ownershipFacet, baseQuest,questTools],
        c.owner,
    );
    c.tavern = tavern;
    console.log(`Tavern deployed at: ${tavern.address.toLowerCase()}`);


    return c;
}


