import {SignerWithAddress} from "@nomiclabs/hardhat-ethers/dist/src/signer-with-address";
import {BigNumber, Contract, Signer} from "ethers";
import { impersonateAccount, getAccount} from "../../helpers/accounts";


import {
    QuestAchievements,
    WizardsMock,
    Grimoire
} from "../../typechain";

export async function deployConfig(owner:string): Promise<DeployConfig> {



    const storageAddr = '0x11398bf5967cd37bc2482e0f4e111cb93d230b05'
    const rewardAddr = '0x56188fd7dbec0061e90a9e8eded8ae77b1eb9725'

    let account;
    try{
        account = await getAccount(owner)
    }catch{
        account = await impersonateAccount(owner)
    }
    return new DeployConfig(owner, account, storageAddr, rewardAddr)
}

export class DeployConfig {
    public owner: string;
    public ownerAcc: Signer;
    public storage?: Grimoire;
    public storageAddr: string;
    public baseRewardNFT?: QuestAchievements;
    public rewardAddr: string;
    public tavern?: Contract;
    public wizards?: WizardsMock;
    public merkleTree?: any;

    constructor(owner: string, ownerAcc: Signer, storageAddr:string, rewardAddr:string)
        {
            this.owner = owner;
            this.ownerAcc = ownerAcc ;
            this.storageAddr = storageAddr;
            this.rewardAddr = rewardAddr;
        }
}