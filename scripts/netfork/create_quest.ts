
import * as deploy from "../helpers/deploy";
const WizardStorage = require( "../../abi/WizardStorage.json")
import {Contract} from "ethers";

import {
    WizardStorage as WS,
    WizardsMock,
    ForgottenQuests
} from "../../typechain";

export async function deployStorage() {
    console.log(`\n --- DEPLOY FORGOTTEN QUEST ---`);

    let storage = new Contract(
        "0x58681F649B52E42B113BbA5D3806757c114E3578",
        WizardStorage,
    ) as WS


    const forgottenQuest = await deploy.deployContract('ForgottenQuests') as ForgottenQuests;
    console.log(`ForgottenQuests deployed to: ${forgottenQuest.address.toLowerCase()}`);
}