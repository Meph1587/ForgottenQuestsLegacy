import {DeployConfig} from "../config";
import {Contract} from "ethers";

import {makeProof} from "../helpers/merkletree/make_proof";

import {
    WizardsMock,
    WizardStorage as WS,
} from "../../typechain";
import { getCleanTraits } from "../helpers/get-traits";


const wizardTraits = require("../../data/wizard_traits.json");
const traitsAffinities = require("../../data/traits_to_aff.json");
const WizardStorage = require( "../../abi/WizardStorage.json")

const CHUNK_SIZE = 50;

export async function populateStorage(c: DeployConfig): Promise<DeployConfig> {
    
    let storage = c.storage as WS;
    /*
        let storage = new Contract(
            "0x58681F649B52E42B113BbA5D3806757c114E3578",
            WizardStorage,
            c.ownerAcc
        ) as WS
    */
    console.log(`\n --- POPULATE WIZARD STORAGE ---`);
    console.log(` -- TRAITS --`);


    let wizards: number[][] = wizardTraits.wizards;


    let wizards_flat = [].concat(...wizards);
    let traits_flat = getCleanTraits();
    let proofs_flat = []
    traits_flat.forEach(element =>{
       proofs_flat.push(makeProof(c.merkleTree as any, element))
    })

    let traitsList = traitsAffinities.traits;
    let affinities= traitsAffinities.affinities;
    
    let startIndex = 0;

    for (let i=startIndex; i < wizards_flat.length;i++){
        let tx = await storage.storeWizardTraits(
            wizards_flat[i],
            traits_flat[i],
            proofs_flat[i],
        )
        await tx.wait()
        console.log(`WizardStorage traits populated ${i}`)
    };

    for (let i=0; i < traitsList.length;i++){
        let tx = await storage.storeTraitAffinities(traitsList[i],affinities[i])
        await tx.wait()
        console.log(`WizardStorage affinities populated on id from: ${i*200} to ${(i*200+200)}`)
    };

    for (let i=0; i < wizards_flat.length;i+=100){
        let traits = await storage.getWizardTraits(i);
        let affinities = await storage.getWizardAffinities(i);
        console.log(`Wizard ${i} - traits: ${traits} - affinities ${affinities}`)
    };
    


    return c;
}


