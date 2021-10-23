import { ethers } from 'hardhat';
import { BigNumber, Contract, Signer } from 'ethers';
import * as helpers from '../helpers/accounts';
import { expect } from 'chai';
import { BaseQuest, ERC20Mock, WizardsMock,QuestTools, QuestAchievements} from '../typechain';
import * as chain from '../helpers/chain';
import * as deploy from '../helpers/deploy';

describe('QuestAchievements', function () {

    let rewards: QuestAchievements;
    
    let user: Signer, userAddress: string;
    let happyPirate: Signer, happyPirateAddress: string;

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
            expect(await rewards.owner()).to.eq(userAddress);
        });
    });

    describe('Can get name', function () {
        it('returns random names', async function () {
            let name1 = await rewards.getName(1, 1);
            let name2 = await rewards.getName(2, 2);
            expect(name1).to.not.equal(name2);
        });
    });

    describe('Can set mint permissions', function () {
        it('allows owner to set', async function () {
            expect(await rewards.allowedMinterContracts(chain.testAddress)).to.be.false;

            await expect(rewards.setMintingAllowance(chain.testAddress, true)).to.not.be.reverted;

            expect(await rewards.allowedMinterContracts(chain.testAddress)).to.be.true;

            await expect(rewards.setMintingAllowance(chain.testAddress, false)).to.not.be.reverted;

            expect(await rewards.allowedMinterContracts(chain.testAddress)).to.be.false;
        });

        it('denies other users to set', async function () {
            expect(await rewards.allowedMinterContracts(chain.testAddress)).to.be.false;
            
            await expect(
                rewards.connect(happyPirate).setMintingAllowance(chain.testAddress, true)
            ).to.be.revertedWith("Ownable: caller is not the owner");

            expect(await rewards.allowedMinterContracts(chain.testAddress)).to.be.false;
        });
    });

    describe('Can mint tokens', function () {
        it('allows minter to mint', async function () {

            await expect(rewards.setMintingAllowance(happyPirateAddress, true)).to.not.be.reverted;

            await expect(rewards.connect(happyPirate).mint(happyPirateAddress,1,"wizard",939393,86400,false)).to.not.be.reverted;

            expect(await rewards.ownerOf(0)).to.eq(happyPirateAddress);

            expect(await rewards.tokenURI(0)).to.not.be.eq("");
        
            await expect(rewards.connect(happyPirate).mint(
                happyPirateAddress,
                1,
                "Archmage Orpheus of the Quantum Shadow",
                939393,
                431000,
                false
            )).to.not.be.reverted;
            
            expect(await rewards.tokenURI(1)).to.not.be.eq("");


            // check for read consistency
            let first = await rewards.tokenURI(1);
            chain.mineBlocks(2)
            expect(await rewards.tokenURI(1)).to.be.eq(first);


            await expect(rewards.connect(happyPirate).mint(
                happyPirateAddress,
                1,
                "Archmage Orpheus of the Quantum Shadow",
                602,
                431000,
                false
            )).to.not.be.reverted;

           expect(await rewards.tokenURI(2)).to.not.be.eq("");

            await expect(rewards.connect(happyPirate).mint(
                happyPirateAddress,
                1,
                "Archmage Orpheus of the Quantum Shadow",
                190,
                431000,
                true
            )).to.not.be.reverted;

           expect(await rewards.tokenURI(3)).to.not.be.eq("");
            
            for(let i = 4; i<30; i++){
                await expect(rewards.connect(happyPirate).mint(
                    happyPirateAddress,
                    1,
                    "Archmage Orpheus of the Quantum Shadow",
                    90,
                    431000,
                    i%3==0
                )).to.not.be.reverted;

                expect(await rewards.tokenURI(i)).to.not.be.eq("");
                //console.log(await rewards.tokenURI(i))

            }
        
        });

        it('denies other users to mint', async function () {
            await expect(
                rewards.connect(happyPirate).mint(happyPirateAddress,1,"wizard",93,86400, false)
            ).to.be.revertedWith("Not allowed to mint");
        });
    });



    async function setupSigners () {
        const accounts = await ethers.getSigners();
        user = accounts[0];
        happyPirate = accounts[1];
     
        userAddress = await user.getAddress();
        happyPirateAddress = await happyPirate.getAddress();
    }
});