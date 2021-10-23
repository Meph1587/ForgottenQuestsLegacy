import { ethers } from 'hardhat';
import { BigNumber, Contract, Signer } from 'ethers';
import { expect } from 'chai';
import { QuestTools } from '../typechain';
import * as chain from '../helpers/chain';
import * as deploy from '../helpers/deploy';

describe('Quest Tool', function () {

   
    let tools:QuestTools;
    let user: Signer, userAddress: string;
    let happyPirate: Signer, happyPirateAddress: string;
    let feeReceiver: Signer, feeReceiverAddress: string;

    let Mephistopheles = 1587;

    const storageAddress = "0x11398bf5967Cd37BC2482e0f4E111cb93D230B05";
    const spellsAddress = "0x11398bf5967Cd37BC2482e0f4E111cb93D230B05";


    let snapshotId: any;

    before(async function () {
        await setupSigners();
        
        tools = await deploy.deployContract('QuestTools') as QuestTools;
        
        await tools.initialize(chain.testAddress, storageAddress, chain.testAddress,spellsAddress);

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
            expect(tools.address).to.not.equal(0);
            expect(await tools.getWeth()).to.be.equal(chain.testAddress);
            expect(await tools.getWizards()).to.be.equal(chain.testAddress);
            expect(await tools.sqrt(1)).to.be.equal(1);
            expect(await tools.sqrt(0)).to.be.equal(0);
            await expect(
                tools.initialize(chain.zeroAddress, storageAddress, chain.testAddress,chain.testAddress)
            ).to.be.revertedWith("WETH must not be 0x0");
            await expect(
                tools.initialize(chain.testAddress, storageAddress, chain.testAddress,chain.testAddress)
            ).to.be.revertedWith("Tavern: already initialized");

        });

    });

    describe('Get Random Affinity', function () {
        it('it gets a random number in the correct range', async function () {
            expect( await tools.getRandomAffinity(1)).to.be.gte(0).and.to.be.lt(286)
            expect( await tools.getRandomAffinity(2)).to.be.gte(0).and.to.be.lt(286)
            expect( await tools.getRandomAffinity(3)).to.be.gte(0).and.to.be.lt(286)
            expect( await tools.getRandomAffinity(4)).to.be.gte(0).and.to.be.lt(286)
            expect( await tools.getRandomAffinity(5)).to.be.gte(0).and.to.be.lt(286)
            expect( await tools.getRandomAffinity(6)).to.be.gte(0).and.to.be.lt(286)
            expect( await tools.getRandomAffinity(7)).to.be.gte(0).and.to.be.lt(286)
        });
    });


    describe('Get Random Affinity from trait', function () {
        it('it gets an affinity of at lest one trait', async function () {
            let affinity = await tools.getRandomAffinityFromTraits(1,[47,7777,7777,7777,7777])

            expect(affinity).to.eq(102)

            affinity = await tools.getRandomAffinityFromTraits(1,[47,51,7777,7777,7777])

            expect(affinity).to.be.oneOf([102,118,257])

            // in case no are provided returns a random one
            affinity = await tools.getRandomAffinityFromTraits(1,[7777,7777,7777,7777,7777])

            expect(affinity).to.be.gte(0).and.to.be.lt(341)
            
        });
    });

    describe('Get Random Trait', function () {
        it('it gets a random number in the correct range', async function () {
            expect( await tools.getRandomTrait(1)).to.be.gte(0).and.to.be.lt(341)
            expect( await tools.getRandomTrait(2)).to.be.gte(0).and.to.be.lt(341)
            expect( await tools.getRandomTrait(3)).to.be.gte(0).and.to.be.lt(341)
            expect( await tools.getRandomTrait(4)).to.be.gte(0).and.to.be.lt(341)
            expect( await tools.getRandomTrait(5)).to.be.gte(0).and.to.be.lt(341)
            expect( await tools.getRandomTrait(6)).to.be.gte(0).and.to.be.lt(341)
            expect( await tools.getRandomTrait(7)).to.be.gte(0).and.to.be.lt(341)
        });
    });

    describe('Get if Wizard has Trait', function () {
        it('returns correct responses', async function () {
            expect( await tools.wizardHasOneOfTraits(Mephistopheles, [3,7777,7777,7777,7777] )).to.be.true
            expect( await tools.wizardHasOneOfTraits(Mephistopheles, [3,19,120,189,1] )).to.be.true

            expect( await tools.wizardHasOneOfTraits(Mephistopheles, [1,7777,7777,7777,7777] )).to.be.false
            expect( await tools.wizardHasOneOfTraits(Mephistopheles, [4,20,121,190,2] )).to.be.false



            expect( await tools.wizardHasOneOfTraits(Mephistopheles, [7777,7777,7777,7777,7777] )).to.be.true
        });
    });


    describe('Get Correct Quest Score', function () {
        it('return correct responses', async function () {
            // 73 has occurrence: 8
            // 209 has occurrence: 7129

            // absolute max score: floor( sqrt( (7129+7129) * 100000/(8+8) ) ) = 9439
            expect(await tools.getQuestScore([73,73],[209,209])).to.eq(9439)

            // absolute min score: floor( sqrt( (8+8) * 100000/(7129+7129) ) ) = 10
            expect(await tools.getQuestScore([209,209],[73,73])).to.eq(10)


            // 200 has occurrence: 108
            // 150 has occurrence: 122

            // random score: floor( sqrt( (122+122) * 100000/(108+108) ) ) = 336
            expect(await tools.getQuestScore([200,200],[150,150])).to.eq(336)


            // random score: floor( sqrt( (108+108) * 100000/(122+122) ) ) = 297
            expect(await tools.getQuestScore([150,150],[200,200])).to.eq(297)
            
        });
    });

    describe('Get Correct Quest Duration', function () {
        it('return correct responses', async function () {

            let base = (await tools.BASE_DURATION()).toNumber();
            let adj = (await tools.TIME_ADJUSTMENT()).toNumber();

            // no matches on positive or negative
            expect(await tools.getQuestDuration(Mephistopheles, [1,1],[1,1])).to.eq(base)

            // 1 match on positive 
            expect(await tools.getQuestDuration(Mephistopheles, [22,1],[1,1])).to.eq(base-adj)

            // 2 match on positive 
            expect(await tools.getQuestDuration(Mephistopheles, [22,34],[1,1])).to.eq(base-adj-adj)

            // 8 match on positive 
            expect(await tools.getQuestDuration(Mephistopheles, [201,201],[1,1])).to.eq(base-(adj*8))



            // 1 match on negative 
            expect(await tools.getQuestDuration(Mephistopheles, [1,1],[22,1])).to.eq(base+adj)

            // 2 match on negative 
            expect(await tools.getQuestDuration(Mephistopheles, [1,1],[22,34])).to.eq(base+adj+adj)

            // 8 match on negative 
            expect(await tools.getQuestDuration(Mephistopheles, [1,1],[201,201])).to.eq(base+(adj*8))



            // 1 match on positive and 1 match on positive 
            expect(await tools.getQuestDuration(Mephistopheles, [1,34],[22,1])).to.eq(base)
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

});