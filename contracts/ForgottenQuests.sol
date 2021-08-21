//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./WizardsMock.sol";
import "./WizardStorage.sol";

contract ForgottenQuests {
    using SafeMath for uint16;
    using SafeMath for uint256;

    uint16 MAX_AFFINITY = 285;

    WizardStorage wizardStorage;

    Wizards wizards;

    ERC721 rewardNFT;

    struct Quest {
        uint256 id;
        address accepted_by;
        uint256 accepted_at;
        uint256 wizardId;
        uint16 required_affinity;
        string story;
        uint256 ends_at;
        uint256 expires_at;
    }

    Quest[] private questLog;

    uint256 private lastQuestIssued;

    uint256 private baseExpairation = 64800; // 1 week
    uint256 private baseDuration = 1209600; // 2 weeks

    uint256 private baseFee = 10**16; //0.01 ETH

    constructor(
        address _wizardStorage,
        address _wizard,
        address _rewardNFT,
        address _weth
    ) {
        wizardStorage = WizardStorage(_wizardStorage);
        wizards = Wizards(_wizard);
        rewardNFT = ERC721(_rewardNFT);
        weth = ERC20(_weth)
    }

    // generate a new quest using random affinity
    function newQuest() public {
        // TODO: Add cooldown of 1 quest every 4 hours or so
        Quest memory quest = Quest({
            id: questLog.length,
            accepted_by: address(0),
            accepted_at: block.timestamp,
            wizardId: 10000,
            required_affinity: getAffinity(),
            story: "",
            ends_at: 0,
            expires_at: block.timestamp + baseExpairation
        });
        questLog.push(quest);
    }

    function acceptQuest(
        uint256 id,
        uint256 wizard,
        string memory story
    ) public {
        require(wizards.ownerOf(wizard) == msg.sender, "Can not send wizard");
        wizards.transferFrom(msg.sender, address(this), wizard);

        Quest storage quest = questLog[id];
        require(quest.accepted_by == address(0), "Quest accepted already");
        require(quest.expires_at > block.timestamp, "Quest expired");
        quest.accepted_by = msg.sender;
        quest.accepted_at = block.timestamp;
        quest.story = story;
        quest.wizardId = wizard;

        uint16[] memory wizAffinities = wizardStorage.getWizardaAffinities(
            wizard
        );

        // count how many times selected wizard has affinity
        uint256 affinityCount = 0;
        for (uint8 i = 0; i < wizAffinities.length; i++) {
            if (wizAffinities[i] == quest.required_affinity) {
                affinityCount += 1;
            }
        }

        require(affinityCount > 0, "Wizard does not have required affinity");

        // this is safe because affinityCount can not be greater then 5
        uint256 duration = baseDuration - (affinityCount - 1).mul(172800); //reduce duration by 2 days for every affinity

        quest.ends_at = block.timestamp.add(duration);
    }

    // allow to withdraw wizard efter quest duration elapsed
    function completeQuest(uint256 id) public {
        Quest storage quest = questLog[id];
        require(quest.accepted_by == msg.sender, "Quest accepted already");
        require(quest.ends_at < block.timestamp, "Quest not ended");
        wizards.approve(msg.sender, quest.wizardId);
        wizards.transferFrom(address(this), msg.sender, quest.wizardId);

        //mint reward NFT to user
        uint256 duration = quest.ends_at - quest.accepted_at;
        rewardNFT.mint(
            msg.sender,
            rewardNFT.totalSupply(),
            quest.id,
            quest.wizardId,
            quest.story,
            quest.affinity,
            duration
        );
    }

    function abandonQuest(uint256 id) public {
        Quest storage quest = questLog[id];
        require(quest.accepted_by == msg.sender, "Quest accepted already");
        require(quest.ends_at > block.timestamp, "Quest ended");

        // pay penalty fee based on how early iy is abondoned
        uint256 feeAmount = baseFee
            .mul(block.timestamp - quest.accepted_at)
            .div(quest.ends_at - quest.accepted_at);

        weth.transferFrom(msg.sender, feeAddress, feeAmount);

        wizards.approve(msg.sender, quest.wizardId);
        wizards.transferFrom(address(this), msg.sender, quest.wizardId);
    }

    // TODO: use block.hash for better randomness then this....
    function getAffinity() public view returns (uint16) {
        uint256 nr = block.number + block.basefee;
        return uint16(nr % MAX_AFFINITY);
    }

    function getQuest(uint256 id) public view returns (Quest memory) {
        return questLog[id];
    }

    //TODO: Make custom quests
}
