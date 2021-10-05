import { ethers } from 'hardhat';
import { BigNumber, Contract, Signer } from 'ethers';
import * as helpers from '../helpers/accounts';
import { expect } from 'chai';
import { BaseQuest, ERC20Mock, WizardsMock,QuestTools, QuestAchievements, Grimoire} from '../typechain';
import * as chain from '../helpers/chain';
import * as deploy from '../helpers/deploy';
import {diamondAsFacet} from "../helpers/diamond";

describe('BaseQuest', function () {

    let quests: BaseQuest, weth: ERC20Mock, wizards:WizardsMock, rewardsNFT: QuestAchievements, storage: Grimoire;

    let user: Signer, userAddress: string;
    let happyPirate: Signer, happyPirateAddress: string;
    let flyingParrot: Signer, flyingParrotAddress: string;

    let snapshotId: any;

    const storageAddress = "0x11398bf5967Cd37BC2482e0f4E111cb93D230B05";

    before(async function () {
        await setupSigners();
        weth = (await deploy.deployContract('ERC20Mock')) as ERC20Mock;
        wizards = (await deploy.deployContract('WizardsMock')) as WizardsMock;
        rewardsNFT = (await deploy.deployContract('QuestAchievements')) as QuestAchievements;

        wizards.mint(userAddress, 1587);
        await prepareAccount(user, chain.tenPow18.mul(200))

        const cutFacet = await deploy.deployContract('DiamondCutFacet');
        const loupeFacet = await deploy.deployContract('DiamondLoupeFacet');
        const ownershipFacet = await deploy.deployContract('OwnershipFacet');
        let tools = await deploy.deployContract('QuestTools');
        const diamond = await deploy.deployDiamond(
            'Tavern',
            [cutFacet, loupeFacet, ownershipFacet, tools],
            userAddress,
        );

        quests = (await deploy.deployContract('BaseQuest', [userAddress, rewardsNFT.address])) as BaseQuest;
        
        tools = (await diamondAsFacet(diamond, 'QuestTools')) as QuestTools;
        
        await tools.initialize(weth.address, storageAddress, wizards.address);

        await chain.setTime(await chain.getCurrentUnix());
    });

    beforeEach(async function () {
        snapshotId = await ethers.provider.send('evm_snapshot', []);
    });

    afterEach(async function () {
        const ts = await chain.getLatestBlockTimestamp();

        await ethers.provider.send('evm_revert', [snapshotId]);

        await chain.moveAtTimestamp(ts + 5);
    });

    describe('General tests', function () {
        it('should be deployed', async function () {
            expect(quests.address).to.not.equal(0);
        });
    });



    async function setupSigners () {
        const accounts = await ethers.getSigners();
        user = accounts[0];
        happyPirate = accounts[3];
        flyingParrot = accounts[4];

        userAddress = await user.getAddress();
        happyPirateAddress = await happyPirate.getAddress();
        flyingParrotAddress = await flyingParrot.getAddress();
    }

    async function prepareAccount (account: Signer, balance: BigNumber) {
        await weth.mint(await account.getAddress(), balance);
    }
});