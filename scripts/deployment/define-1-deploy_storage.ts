import {DeployConfig} from "../config";

import * as deploy from "../helpers/deploy";
import {makeTreeFromTraits} from "../helpers/merkletree/make_tree";

import {
    WizardStorage,
} from "../../typechain";

export async function deployStorage(c: DeployConfig): Promise<DeployConfig> {
    console.log(`\n --- DEPLOY WIZARD STORAGE ---`);

    let tree = await makeTreeFromTraits();
    let root = tree.getHexRoot();
    console.log(`Merkle Tree generated with root: ${root}`);

    const wizardStorage = await deploy.deployContract('WizardStorage',[root]) as WizardStorage;
    c.storage = wizardStorage;
    c.merkleTree = tree;
    console.log(`WizardStorage deployed to: ${wizardStorage.address.toLowerCase()}`);

    return c;
}


