import {DeployConfig} from "./define-0-deploy_config";
import {deployContract, deployDiamond} from "../helpers/deploy"

import {
    BaseQuestRewardNFT,
} from "../../typechain";
export async function deployTavern(c: DeployConfig): Promise<DeployConfig> {


    const rewardNFT = await deployContract('BaseQuestRewardNFT') as BaseQuestRewardNFT;
    console.log(`BaseQuestRewardNFT deployed to: ${rewardNFT.address.toLowerCase()}`);

    await rewardNFT.mint(c.owner,0,"Mephistopheles",99,999);
    
    let uri = await rewardNFT.tokenURI(0);
    console.log(uri)

    console.log(`\n --- DEPLOY LOUD TAVERN ---`);
    

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
        'LoudTavern',
        [cutFacet, loupeFacet, ownershipFacet, baseQuest,questTools],
        c.owner,
    );
    c.tavern = tavern;
    console.log(`LoudTavern deployed at: ${tavern.address.toLowerCase()}`);


    return c;
}


