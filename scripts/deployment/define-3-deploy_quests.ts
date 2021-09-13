
import * as deploy from "../helpers/deploy";
import {DeployConfig} from "../config";
import {Contract} from "ethers";

const WizardStorage = require( "../../abi/WizardStorage.json")

import {
    ForgottenQuests,
    RewardNFT
} from "../../typechain";

export async function deployQuests(c: DeployConfig): Promise<DeployConfig> {
    console.log(`\n --- DEPLOY REWARDS NFT ---`);



    const rewardsNFT = await deploy.deployContract('RewardNFT') as RewardNFT;
    console.log(`RewardNFT deployed to: ${rewardsNFT.address.toLowerCase()}`);
    console.log(`npx hardhat verify --network rinkeby ${rewardsNFT.address.toLowerCase()}`);

    console.log(`\n --- DEPLOY FORGOTTEN QUEST ---`);

    const FEE_ADDR = "0x8518507f317709fcF2F7fEDfAB4a7F75dfe56cfa"

    const forgottenQuest = await deploy.deployContract('ForgottenQuests',
    [
        c.storageAddr,
        c.wizardsAddr,
        rewardsNFT.address,
        rewardsNFT.address,
        FEE_ADDR
    ]
    ) as ForgottenQuests;
    console.log(`ForgottenQuests deployed to: ${forgottenQuest.address.toLowerCase()}`);
    console.log(`npx hardhat verify --network rinkeby 
    ${c.storageAddr.toLowerCase()}
    ${c.wizardsAddr.toLowerCase()} 
    ${rewardsNFT.address.toLowerCase()} 
    ${rewardsNFT.address.toLowerCase()}
    ${FEE_ADDR.toLowerCase()} ` );


    await rewardsNFT.transferOwnership(forgottenQuest.address)
    console.log(`RewardNFT ownership moved to ForgottenQuests}`);

    return c;
}