import {DeployConfig} from "./define-0-deploy_config";
import {deployContract} from "../../helpers/deploy"

export async function deployQuests(c: DeployConfig): Promise<DeployConfig> {

    console.log(`\n --- DEPLOY QUESTS ---`);


    const baseQuest = await deployContract('BaseQuest',[c.owner, c.rewardAddr]);
    console.log(`BaseQuest deployed to: ${baseQuest.address.toLowerCase()}`);


    const customQuest = await deployContract('CustomQuest',[c.owner]);
    console.log(`CustomQuest deployed to: ${customQuest.address.toLowerCase()}`);


    return c;
}


