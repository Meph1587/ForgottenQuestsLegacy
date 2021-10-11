import {DeployConfig} from "./define-0-deploy_config";
import {Contract} from "ethers";

import {
    Grimoire as GR,
} from "../../typechain";

let Grimoire = require("wizard-storage/abi/Grimoire.json")

export async function connectContracts(c: DeployConfig): Promise<DeployConfig> {
    console.log(`\n --- CONNECT WIZARD STORAGE ---`);

    const grimoire = new Contract(
        c.storageAddr,
        Grimoire,
        c.ownerAcc
    ) as GR
    c.storage = grimoire
    console.log(`Grimoire connected at: ${grimoire.address.toLowerCase()}`);

    return c;
}


