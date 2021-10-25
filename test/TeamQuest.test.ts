import { ethers } from 'hardhat';
import { BigNumber, Contract, Signer } from 'ethers';
import { expect } from 'chai';
import { TeamQuest, ERC20Mock, WizardsMock,QuestTools, QuestAchievements, StorageMock} from '../typechain';
import * as chain from '../helpers/chain';
import * as deploy from '../helpers/deploy';

describe('TeamQuest', function () {

    let quests: TeamQuest, weth: ERC20Mock, wizards:WizardsMock, rewardsNFT: QuestAchievements;
    let tools:QuestTools, storage:StorageMock;
    let user: Signer, userAddress: string;
    let happyPirate: Signer, happyPirateAddress: string;
    let feeReceiver: Signer, feeReceiverAddress: string;

    let Mephistopheles = 1587;
    let AleisterCrowley = 1875;
    let SacredKeyMaster = 777;
    let ColorMaster = 1234;
    let BringerOfEnd = 9999;
    let HeadlessWizard = 8888;

    let questName = "A Ceremony with an Old Man and the Boleskine House"

    let startBalance = chain.tenPow18.mul(200)

    let snapshotId: any;

    before(async function () {
        await setupSigners();
        weth = (await deploy.deployContract('ERC20Mock')) as ERC20Mock;
        wizards = (await deploy.deployContract('WizardsMock')) as WizardsMock;
        storage = (await deploy.deployContract('StorageMock')) as StorageMock;
        rewardsNFT = (await deploy.deployContract('QuestAchievements')) as QuestAchievements;


        await wizards.mint(userAddress, Mephistopheles);
        await wizards.mint(userAddress, AleisterCrowley);
        await wizards.mint(userAddress, SacredKeyMaster);
        await wizards.mint(userAddress, ColorMaster);
        await wizards.mint(userAddress, BringerOfEnd);
        await wizards.mint(userAddress, HeadlessWizard);
        await prepareAccount(user, startBalance)

        await storage.setStored(Mephistopheles);
        await storage.setStored(AleisterCrowley);
        await storage.setStored(SacredKeyMaster);
        await storage.setStored(ColorMaster);
      
        quests = await deploy.deployContract('TeamQuest') as TeamQuest;
        tools = await deploy.deployContract('QuestTools')as QuestTools;

        await quests.initialize(tools.address, feeReceiverAddress, rewardsNFT.address);
        await tools.initialize(weth.address, storage.address, wizards.address, chain.testAddress);


        await rewardsNFT.setMintingAllowance(quests.address, true);

    });

    beforeEach(async function () {
        snapshotId = await ethers.provider.send('evm_snapshot', []);
    });

    afterEach(async function () {

        await ethers.provider.send('evm_revert', [snapshotId]);

    });

    describe('General tests', function () {
        it('general checks', async function () {
            expect(quests.address).to.not.equal(0);
            expect(await quests.feeAddress()).to.be.equal(feeReceiverAddress);
            expect(await quests.questAchievements()).to.be.equal(rewardsNFT.address);
            expect(await quests.getNrOfQuests()).to.be.equal(0);
            await expect(
                quests.initialize(chain.testAddress, chain.testAddress, chain.testAddress)
            ).to.be.revertedWith("Already Initialized")
        });


    });

    describe('Create Quest', function () {
        it('can creat a quest', async function () {

            await wizards.approve(quests.address, AleisterCrowley);
            await quests.newQuest();

            expect(await quests.getNrOfQuests()).to.be.equal(1);

            let quest = await quests.getQuest(0);

            expect(quest.negative_affinities.length).to.eq(4);
            expect(quest.positive_affinities.length).to.eq(4);
            expect(quest.negative_affinities[0].length).to.eq(2);
            expect(quest.positive_affinities[0].length).to.eq(2);
            expect(quest.expires_at).to.not.eq(0);
        });

        it('can not create a quest during cooldown', async function () {

            await wizards.approve(quests.address, AleisterCrowley);
            await quests.newQuest();


            expect(await quests.getNrOfQuests()).to.be.equal(1);

            await wizards.approve(quests.address, SacredKeyMaster);
            await expect(
                quests.newQuest()
            ).to.be.revertedWith("Quest Cooldown not elapsed");
        });

    });

    describe('Accept Quest', function () {

        beforeEach(async function () {
            await wizards.approve(quests.address, AleisterCrowley);
            await quests.newQuest();

        })

        it('can accept a quest', async function () {
            await wizards.approve(quests.address, Mephistopheles);
            await wizards.approve(quests.address, SacredKeyMaster);
            await wizards.approve(quests.address, AleisterCrowley);
            await wizards.approve(quests.address, ColorMaster);
            await quests.acceptQuest(0, Mephistopheles)
            await quests.acceptQuest(0, SacredKeyMaster)
            await quests.acceptQuest(0, AleisterCrowley)
            await quests.acceptQuest(0, ColorMaster)

            let quest = await quests.getQuest(0);

            expect(quest.wizardId[0]).to.eq(Mephistopheles);
            expect(quest.wizardId[1]).to.eq(SacredKeyMaster);
            expect(quest.wizardId[2]).to.eq(AleisterCrowley);
            expect(quest.wizardId[3]).to.eq(ColorMaster);
            expect(quest.accepted_by[0]).to.eq(userAddress);
            expect(quest.ends_at.sub(quest.accepted_at)).to.eq(
                (
                    (await tools.getQuestDuration(Mephistopheles, quest.positive_affinities[0], quest.negative_affinities[0])).add(
                    (await tools.getQuestDuration(SacredKeyMaster, quest.positive_affinities[1], quest.negative_affinities[1])).add(
                    (await tools.getQuestDuration(AleisterCrowley, quest.positive_affinities[2], quest.negative_affinities[2])).add(
                    (await tools.getQuestDuration(ColorMaster, quest.positive_affinities[3], quest.negative_affinities[3]))))
                ))
                .div(4)
            );
        });

        it('can not accept a quest if traits not stored', async function () {
            await wizards.approve(quests.address, HeadlessWizard);
            await expect(quests.acceptQuest(0, HeadlessWizard)).to.be.revertedWith("Wizard does not have traits stored")
        });

        it('can not accept an already quest is full', async function () {
            await wizards.approve(quests.address, Mephistopheles);
            await wizards.approve(quests.address, SacredKeyMaster);
            await wizards.approve(quests.address, AleisterCrowley);
            await wizards.approve(quests.address, ColorMaster);
            await quests.acceptQuest(0, Mephistopheles)
            await quests.acceptQuest(0, SacredKeyMaster)
            await quests.acceptQuest(0, AleisterCrowley)
            await quests.acceptQuest(0, ColorMaster)

            await storage.setStored(BringerOfEnd);
            await wizards.approve(quests.address, BringerOfEnd);
            await expect(quests.acceptQuest(0, BringerOfEnd)).to.be.revertedWith("Quest filled already")
        });

        it('can not accept quest after expiry', async function () {
            let quest = await quests.getQuest(0);

            await chain.increaseBlockTime(quest.expires_at.toNumber() + 50);

            await wizards.approve(quests.address, Mephistopheles);
            await expect(quests.acceptQuest(0, Mephistopheles)).to.be.revertedWith("Quest expired")

        });


    });

    describe('Complete Quest', function () {


        beforeEach(async function () {

            await wizards.approve(quests.address, Mephistopheles);
            await wizards.approve(quests.address, SacredKeyMaster);
            await wizards.approve(quests.address, AleisterCrowley);
            await wizards.approve(quests.address, ColorMaster);
            await quests.newQuest();
            await quests.acceptQuest(0, Mephistopheles)
            await quests.acceptQuest(0, SacredKeyMaster)
            await quests.acceptQuest(0, AleisterCrowley)
            await quests.acceptQuest(0, ColorMaster)

        })

        it('can complete a quest after it ends', async function () {
            let quest = await quests.getQuest(0);
            await chain.moveAtTimestamp(quest.ends_at.toNumber() + 50);

            await quests.completeQuest(0);

            //returns wizard
            expect(await wizards.ownerOf(Mephistopheles)).to.eq(userAddress)

            //sends base reward
            expect(await rewardsNFT.ownerOf(0)).to.eq(userAddress)

        });

        it('can not complete quest before it ends', async function () {
            let quest = await quests.getQuest(0);
            await chain.moveAtTimestamp(quest.ends_at.toNumber() - 50);

            await expect(quests.completeQuest(0)).to.be.revertedWith("Quest not ended yet")
        });

        it('can not complete quest for other user', async function () {
            let quest = await quests.getQuest(0);
            await chain.moveAtTimestamp(quest.ends_at.toNumber() - 50);

            await expect(quests.connect(happyPirate).completeQuest(0)).to.be.revertedWith("Only wizard owner can complete")
        });

    });



    describe('Abandon Quest', function () {


        beforeEach(async function () {

            await wizards.approve(quests.address, Mephistopheles);
            await wizards.approve(quests.address, SacredKeyMaster);
            await wizards.approve(quests.address, AleisterCrowley);
            await wizards.approve(quests.address, ColorMaster);
            await quests.newQuest();
            await quests.acceptQuest(0, Mephistopheles)
            await quests.acceptQuest(0, SacredKeyMaster)
            await quests.acceptQuest(0, AleisterCrowley)
            await quests.acceptQuest(0, ColorMaster)

        })

        it('can abandon a quest before it ends', async function () {
            let quest = await quests.getQuest(0);
            await chain.moveAtTimestamp(quest.ends_at.toNumber() - 50);

            await weth.approve(quests.address, chain.tenPow18.mul(10));
            await quests.abandonQuest(0);

            //returns wizard
            expect(await wizards.ownerOf(Mephistopheles)).to.eq(userAddress)


        });

        it('can not abandon quest after it ends', async function () {
            let quest = await quests.getQuest(0);
            await chain.moveAtTimestamp(quest.ends_at.toNumber() + 100);

            await weth.approve(quests.address, chain.tenPow18.mul(100));
            await expect(quests.abandonQuest(0)).to.be.revertedWith("Quest ended")
        });

        it('can not abandon quest for other user', async function () {
            let quest = await quests.getQuest(0);
            await chain.moveAtTimestamp(quest.ends_at.toNumber() - 50);

            await weth.approve(quests.address, chain.tenPow18.mul(100));
            await expect(quests.connect(happyPirate).abandonQuest(0)).to.be.revertedWith("Only wizard owner can abandon")
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