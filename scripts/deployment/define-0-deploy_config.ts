import {SignerWithAddress} from "@nomiclabs/hardhat-ethers/dist/src/signer-with-address";
import {BigNumber, Contract, Signer} from "ethers";
import {getAccount, impersonateAccount} from "../helpers/accounts";


import {
    LoudTavern,
    BaseQuestRewardNFT,
    WizardsMock,
    Grimoire
} from "../../typechain";

export async function deployConfig(): Promise<DeployConfig> {



    const storageAddr = '0xe5a0b43035f0cf0b577d176ffc9a3ff307205af3'
    const rewardAddr = '0x56188fd7dbec0061e90a9e8eded8ae77b1eb9725'


    //const owner: string = '0x8518507f317709fcF2F7fEDfAB4a7F75dfe56cfa'; // RINKEBY
    //return new DeployConfig(owner, await getAccount(owner), storageAddr, wizardsAddr)


    const owner: string = '0xCDb2a435a65A5a90Da1dd2C1Fe78A2df70795F91';   // FORKING
    return new DeployConfig(owner, await impersonateAccount(owner), storageAddr, rewardAddr)
}

export class DeployConfig {
    public owner: string;
    public ownerAcc: Signer;
    public storage?: Grimoire;
    public storageAddr: string;
    public baseRewardNFT?: BaseQuestRewardNFT;
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