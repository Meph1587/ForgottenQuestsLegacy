import {DeployConfig} from "./define-0-deploy_config";
import {Contract} from "ethers";
import {deployContract, deployDiamond} from "../helpers/deploy"

import {
    LoudTavern,
} from "../../typechain";



export async function deployTavern(c: DeployConfig): Promise<DeployConfig> {
    
    console.log(`\n --- DEPLOY REIGN DAO ---`);
    

    ///////////////////////////
    // Deploy 'Facet' contracts:
    ///////////////////////////
    const cutFacet = await deployContract('DiamondCutFacet');
    console.log(`DiamondCutFacet deployed to: ${cutFacet.address.toLowerCase()}`);

    const loupeFacet = await deployContract('DiamondLoupeFacet');
    console.log(`DiamondLoupeFacet deployed to: ${loupeFacet.address.toLowerCase()}`);

    const ownershipFacet = await deployContract('OwnershipFacet');
    console.log(`OwnershipFacet deployed to: ${ownershipFacet.address.toLowerCase()}`);

    const tavernTools = await deployContract('TavernTools');
    console.log(`TavernTools deployed to: ${tavernTools.address.toLowerCase()}`);

    const baseQuest = await deployContract('BaseQuest',[c.owner, c.rewardAddr]);
    console.log(`BaseQuest deployed to: ${baseQuest.address.toLowerCase()}`);


    ///////////////////////////
    // Deploy "ReignDiamond" contract:
    ///////////////////////////
    const tavern = await deployDiamond(
        'LoudTavern',
        [cutFacet, loupeFacet, ownershipFacet, tavernTools, baseQuest],
        c.owner,
    );
    c.tavern = tavern;
    console.log(`LoudTavern deployed at: ${tavern.address.toLowerCase()}`);


    return c;
}


