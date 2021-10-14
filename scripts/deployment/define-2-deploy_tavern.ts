import {DeployConfig} from "./define-0-deploy_config";
import {deployContract} from "../../helpers/deploy"

import {
    QuestAchievements,
} from "../../typechain";
export async function deployTools(c: DeployConfig): Promise<DeployConfig> {

    console.log(`\n --- DEPLOY QUEST ACHIEVEMENTS ---`);

    const rewardNFT = await deployContract('QuestAchievements') as QuestAchievements;
    console.log(`QuestAchievements deployed to: ${rewardNFT.address.toLowerCase()}`);

    await rewardNFT.setMintingAllowance(c.owner, true);

    await rewardNFT.connect(c.owner).mint(
        c.owner,
        "An Initiation with Aleister Crowley at The Valley of the Void Disciple",
        "Archmage Orpheus of the Quantum Shadow",
        1875,
        431000,
        false
    )

    console.log(`npx hardhat verify --network rinkeby ${rewardNFT.address}`)
    

    console.log(`\n --- DEPLOY TAVERN ---`);
    

    const questTools = await deployContract('QuestTools');
    console.log(`QuestTools deployed to: ${questTools.address.toLowerCase()}`);

    return c;
}


