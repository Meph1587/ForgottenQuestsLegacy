import { ethers } from 'hardhat';
import { BigNumber, Contract, Signer } from 'ethers';
import * as helpers from '../helpers/accounts';
import { expect } from 'chai';
import { BaseQuest, ERC20Mock, WizardsMock,QuestTools, QuestAchievements, Grimoire} from '../typechain';
import * as chain from '../helpers/chain';
import * as deploy from '../helpers/deploy';
import {diamondAsFacet} from "../helpers/diamond";

describe('QuestAchievements', function () {

    let rewards: QuestAchievements;
    
    let user: Signer, userAddress: string;

    let snapshotId: any;


    before(async function () {
        await setupSigners();
        rewards = (await deploy.deployContract('QuestAchievements')) as QuestAchievements;

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
            expect(rewards.address).to.not.equal(0);

            for(let i=0;i<200;i++){
                console.log(await rewards.getName(i))
            }
        });
    });



    async function setupSigners () {
        const accounts = await ethers.getSigners();
        user = accounts[0];
     
        userAddress = await user.getAddress();
    }
});