import { ethers } from 'hardhat';
import { BigNumber, Contract, Signer } from 'ethers';
import * as helpers from '../helpers/accounts';
import { expect } from 'chai';
import { LoreQuest, ERC20Mock, WizardsMock,QuestTools, QuestAchievements} from '../typechain';
import * as chain from '../helpers/chain';
import * as deploy from '../helpers/deploy';
import {diamondAsFacet} from "../helpers/diamond";

describe('LoreQuest', function () {

    let quests: LoreQuest, weth: ERC20Mock, wizards:WizardsMock, rewardsNFT: QuestAchievements;
    let tools:QuestTools;
    let user: Signer, userAddress: string;
    let happyPirate: Signer, happyPirateAddress: string;
    let feeReceiver: Signer, feeReceiverAddress: string;

    let Mephistopheles = 1587;
    let AleisterCrowley = 1875;
    let SacredKeyMaster = 777;
    let ColorMaster = 1234;

    let questName = "A Ceremony with an Old Man and the Boleskine House"

    let startBalance = chain.tenPow18.mul(200)

    const storageAddress = "0x11398bf5967Cd37BC2482e0f4E111cb93D230B05";


    let snapshotId: any;

    before(async function () {
        await setupSigners();
        weth = (await deploy.deployContract('ERC20Mock')) as ERC20Mock;
        wizards = (await deploy.deployContract('WizardsMock')) as WizardsMock;
        rewardsNFT = (await deploy.deployContract('QuestAchievements')) as QuestAchievements;

        await wizards.mint(userAddress, Mephistopheles);
        await wizards.mint(userAddress, AleisterCrowley);
        await wizards.mint(userAddress, SacredKeyMaster);
        await wizards.mint(userAddress, ColorMaster);
        await prepareAccount(user, startBalance)

        const cutFacet = await deploy.deployContract('DiamondCutFacet');
        const loupeFacet = await deploy.deployContract('DiamondLoupeFacet');
        const ownershipFacet = await deploy.deployContract('OwnershipFacet');
        let questTools = await deploy.deployContract('QuestTools');
        let baseQuest = await deploy.deployContract('LoreQuest')
        const diamond = await deploy.deployDiamond(
            'Tavern',
            [cutFacet, loupeFacet, ownershipFacet, questTools, baseQuest],
            userAddress,
        );

        quests = (await diamondAsFacet(diamond, 'LoreQuest')) as LoreQuest;

        await quests.initLoreQuests(diamond.address, feeReceiverAddress, rewardsNFT.address);
        
        tools = (await diamondAsFacet(diamond, 'QuestTools')) as QuestTools;
        
        await tools.initialize(weth.address, storageAddress, wizards.address);

    });

    beforeEach(async function () {
        snapshotId = await ethers.provider.send('evm_snapshot', []);
    });

    afterEach(async function () {

        await ethers.provider.send('evm_revert', [snapshotId]);
    });

    describe('General tests', function () {
        it('should be deployed', async function () {
            expect(quests.address).to.not.equal(0);
            expect(await quests.loreQuestFeeAddress()).to.be.equal(feeReceiverAddress);
            expect(await quests.baseQuestAchievements()).to.be.equal(rewardsNFT.address);
            expect(await quests.getNrOfLoreQuests()).to.be.equal(0);
            expect(await quests.questMaster()).to.be.equal(userAddress);
            expect(await quests.canMakeQuest(userAddress)).to.be.true;
        });

        it('can set quest master', async function () {
            await quests.setQuestMaster(happyPirateAddress);
            expect(await quests.questMaster()).to.be.equal(happyPirateAddress);

            await expect(
                quests.connect(user).setQuestMaster(happyPirateAddress)
            ).to.be.revertedWith("Only quest master can edit this");
        });

        it('can allow to make quest', async function () {
            expect(await quests.canMakeQuest(happyPirateAddress)).to.be.false;
            await quests.setCanMakeQuest(happyPirateAddress, true);
            expect(await quests.canMakeQuest(happyPirateAddress)).to.be.true;

            await expect(
                quests.connect(happyPirate).setCanMakeQuest(happyPirateAddress, true)
            ).to.be.revertedWith("Only quest master can edit this");
        
        
        });

    });

    describe('Create Quest', function () {
        it('can creat a quest', async function () {

            await wizards.approve(quests.address, AleisterCrowley);
            await quests.newLoreQuest(questName, wizards.address, AleisterCrowley, 0, [7777,7777,7777,7777,7777]);

            expect(await quests.getNrOfLoreQuests()).to.be.equal(1);

            let quest = await quests.getLoreQuest(0);

            expect(quest.negative_affinities.length).to.eq(2);
            expect(quest.positive_affinities.length).to.eq(2);
            expect(quest.expires_at).to.not.eq(0);
        });

        it('can not create a quest during cooldown', async function () {

            await wizards.approve(quests.address, AleisterCrowley);
            await quests.newLoreQuest(questName, wizards.address, AleisterCrowley, 0, [7777,7777,7777,7777,7777]);


            expect(await quests.getNrOfLoreQuests()).to.be.equal(1);

            await wizards.approve(quests.address, SacredKeyMaster);
            await expect(
                quests.newLoreQuest(questName, wizards.address, SacredKeyMaster, 0, [7777,7777,7777,7777,7777])
            ).to.be.revertedWith("Quest Cooldown not elapsed");
        });


        it('can not create a quest if not allowed', async function () {
            await wizards.approve(quests.address, AleisterCrowley);

            await expect( 
                quests.connect(happyPirate).newLoreQuest(questName, wizards.address, AleisterCrowley, 0, [7777,7777,7777,7777,7777])
            ).to.be.revertedWith("Not allowed to make Lore quests");
        });

    });

    describe('Accept Quest', function () {

        beforeEach(async function () {
            await wizards.approve(quests.address, AleisterCrowley);
            await quests.newLoreQuest(questName, wizards.address, AleisterCrowley, 0, [7777,7777,7777,7777,7777]);

            await quests.setCanMakeQuest(happyPirateAddress, true);
        })

        it('can accept a quest', async function () {
            await wizards.approve(quests.address, Mephistopheles);
            await quests.acceptLoreQuest(0, Mephistopheles)

            let quest = await quests.getLoreQuest(0);

            expect(quest.wizardId).to.eq(Mephistopheles);
            expect(quest.accepted_by).to.eq(userAddress);
            expect(quest.name).to.eq(questName)
            expect(quest.entryFee).to.eq(0);
            expect(quest.ends_at.sub(quest.accepted_at)).to.eq(
                await tools.getQuestDuration(Mephistopheles, quest.positive_affinities, quest.negative_affinities) 
            );
        });

        it('can not accept a quest if traits not stored', async function () {
            await wizards.approve(quests.address, SacredKeyMaster);
            await expect(quests.acceptLoreQuest(0, SacredKeyMaster)).to.be.revertedWith("Wizard does not have traits stored")
        });

        it('can not accept an already accepted quest', async function () {
            await wizards.approve(quests.address, Mephistopheles);
            await quests.acceptLoreQuest(0, Mephistopheles)

            await wizards.approve(quests.address, SacredKeyMaster);
            await expect(quests.acceptLoreQuest(0, SacredKeyMaster)).to.be.revertedWith("Quest accepted already")
        });

        it('can not accept quest after expiry', async function () {
            let quest = await quests.getLoreQuest(0);

            await chain.increaseBlockTime(quest.expires_at.toNumber() + 1000);

            await wizards.approve(quests.address, Mephistopheles);
            await expect(quests.acceptLoreQuest(0, Mephistopheles)).to.be.revertedWith("Quest expired")

        });

        it('can accept paid quest with payment', async function () {
            let quest = await quests.getLoreQuest(0);
            await chain.increaseBlockTime(quest.expires_at.toNumber() + 1000);


            await wizards.approve(happyPirateAddress, SacredKeyMaster);
            await wizards.transferFrom(userAddress, happyPirateAddress, SacredKeyMaster);
            await wizards.connect(happyPirate).approve(quests.address, SacredKeyMaster);
            await quests.connect(happyPirate).newLoreQuest(questName, wizards.address, SacredKeyMaster, 939393, [7777,7777,7777,7777,7777]);


            quest = await quests.getLoreQuest(1);
            expect(quest.nftId).to.eq(SacredKeyMaster);
            expect(quest.rewardNFT).to.eq(wizards.address);
            expect(quest.creator).to.eq(happyPirateAddress);
            expect(quest.entryFee).to.eq(939393);

            await weth.approve(quests.address, 939393);
            await wizards.approve(quests.address, ColorMaster);
            await quests.acceptLoreQuest(1, ColorMaster)

            expect(await weth.balanceOf(userAddress)).to.eq(startBalance.sub(939393))
            expect(await weth.balanceOf(happyPirateAddress)).to.eq(939393)

        });

        it('can not accept paid quest without payment', async function () {
            let quest = await quests.getLoreQuest(0);
            await chain.increaseBlockTime(quest.expires_at.toNumber() + 1000);

            await wizards.approve(happyPirateAddress, SacredKeyMaster);
            await wizards.transferFrom(userAddress, happyPirateAddress, SacredKeyMaster);
            await wizards.connect(happyPirate).approve(quests.address, SacredKeyMaster);
            await quests.connect(happyPirate).newLoreQuest(questName, wizards.address, SacredKeyMaster, 939393, [7777,7777,7777,7777,7777]);

            await wizards.approve(quests.address, ColorMaster);
            await expect(quests.acceptLoreQuest(1, ColorMaster)).to.be.reverted;

        });

        it('can not accept without required trait', async function () {
            let quest = await quests.getLoreQuest(0);
            await chain.increaseBlockTime(quest.expires_at.toNumber() + 1000);

            await wizards.approve(happyPirateAddress, SacredKeyMaster);
            await wizards.transferFrom(userAddress, happyPirateAddress, SacredKeyMaster);
            await wizards.connect(happyPirate).approve(quests.address, SacredKeyMaster);
            await quests.connect(happyPirate).newLoreQuest(questName, wizards.address, SacredKeyMaster, 939393, [3,7777,7777,7777,7777]);

            await wizards.approve(quests.address, ColorMaster);
            await weth.approve(quests.address, 939393);
            await expect(quests.acceptLoreQuest(1, ColorMaster)).to.be.revertedWith("Wizard does not have trait");

        });

    });

    describe('Complete Quest', function () {


        beforeEach(async function () {

            await wizards.approve(quests.address, AleisterCrowley);
            await quests.newLoreQuest(questName, wizards.address, AleisterCrowley, 0, [7777,7777,7777,7777,7777]);
            await wizards.approve(quests.address, Mephistopheles);
            await quests.acceptLoreQuest(0, Mephistopheles) 
            await rewardsNFT.setMintingAllowance(quests.address, true);

        })

        it('can complete a quest after it ends', async function () {
            let quest = await quests.getLoreQuest(0);
            await chain.moveAtTimestamp(quest.ends_at.toNumber() + 1000);

            // nft is in contract
            expect(await wizards.ownerOf(AleisterCrowley)).to.eq(quests.address)

            await quests.completeLoreQuest(0);

            //returns wizard
            expect(await wizards.ownerOf(Mephistopheles)).to.eq(userAddress)

            //sends base reward
            expect(await rewardsNFT.ownerOf(0)).to.eq(userAddress)

            //sends reward nft
            expect(await wizards.ownerOf(AleisterCrowley)).to.eq(userAddress)
        });

        it('can not complete quest before it ends', async function () {
            let quest = await quests.getLoreQuest(0);
            await chain.moveAtTimestamp(quest.ends_at.toNumber() - 1000);

            await expect(quests.completeLoreQuest(0)).to.be.revertedWith("Quest not ended yet")
        });

        it('can not complete quest for other user', async function () {
            let quest = await quests.getLoreQuest(0);
            await chain.moveAtTimestamp(quest.ends_at.toNumber() - 1000);

            await expect(quests.connect(happyPirate).completeLoreQuest(0)).to.be.revertedWith("Only wizard owner can complete")
        });

    });



    describe('Abandon Quest', function () {


        beforeEach(async function () {

            await wizards.approve(quests.address, AleisterCrowley);
            await quests.newLoreQuest(questName, wizards.address, AleisterCrowley, 0, [7777,7777,7777,7777,7777]);


            await wizards.approve(quests.address, Mephistopheles);
            await quests.acceptLoreQuest(0, Mephistopheles) 
        })

        it('can abandon a quest before it ends', async function () {
            let quest = await quests.getLoreQuest(0);

            await weth.approve(quests.address, chain.tenPow18.mul(10));
            await quests.abandonLoreQuest(0);

            //returns wizard
            expect(await wizards.ownerOf(Mephistopheles)).to.eq(userAddress)


            // fee was transferred
            expect(await weth.balanceOf(feeReceiverAddress)).to.be.eq(
                startBalance.sub(await weth.balanceOf(userAddress))
            )
        });

        it('can not abandon quest after it ends', async function () {
            let quest = await quests.getLoreQuest(0);
            await chain.moveAtTimestamp(quest.ends_at.toNumber() + 1000);

            await expect(quests.abandonLoreQuest(0)).to.be.revertedWith("Quest ended")
        });

        it('can not abandon quest for other user', async function () {
            let quest = await quests.getLoreQuest(0);
            await chain.moveAtTimestamp(quest.ends_at.toNumber() - 1000);

            await expect(quests.connect(happyPirate).abandonLoreQuest(0)).to.be.revertedWith("Only wizard owner can abandon")
        });

    });



    async function setupSigners () {
        const accounts = await ethers.getSigners();
        user = accounts[0];
        happyPirate = accounts[3];
        feeReceiver = accounts[4];

        userAddress = await user.getAddress();
        happyPirateAddress = await happyPirate.getAddress();
        feeReceiverAddress = await feeReceiver.getAddress();
    }

    async function prepareAccount (account: Signer, balance: BigNumber) {
        await weth.mint(await account.getAddress(), balance);
    }
});