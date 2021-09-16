
import {deployContract} from "../helpers/deploy";
import {diamondAsFacet, getSelectors, FacetCutAction} from "../helpers/diamond";
import {zeroAddress} from "../helpers/chain";
import {DeployConfig} from "./define-0-deploy_config";
import {Contract} from "ethers";


import {
    DiamondCutFacet,
    DiamondLoupeFacet
} from "../../typechain";

export async function addQuest(c: DeployConfig): Promise<DeployConfig> {
    console.log(`\n --- ADD CUSTOM QUEST TO TAVERN---`);


    let cut = await diamondAsFacet(c.tavern as Contract, "DiamondCutFacet") as DiamondCutFacet;

    const customQuest = await deployContract('CustomQuest',[c.owner]);
    console.log(`CustomQuest deployed to: ${customQuest.address.toLowerCase()}`);

    let diamondCut = [];
    diamondCut.push([
        customQuest.address,
        FacetCutAction.Add,
        getSelectors(customQuest),
    ]);

    await cut.connect(c.ownerAcc).diamondCut(diamondCut, zeroAddress, [])
    console.log(`Facet Added `)


    let loupe = await diamondAsFacet(c.tavern as Contract, "DiamondLoupeFacet") as DiamondLoupeFacet;

    console.log(`Facets Now: \n${await loupe.facets()} `)

    return c;
}