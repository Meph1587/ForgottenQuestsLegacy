//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../WizardsMock.sol";
import "../BaseQuestRewardNFT.sol";
import "../TheLoudTavern/facets/QuestTools.sol";
import "../TheLoudTavern/libraries/LibTavernStorage.sol";

contract BaseQuest {
    using SafeMath for uint16;
    using SafeMath for uint256;

    struct Quest {
        uint256 id;
        address accepted_by;
        uint256 accepted_at;
        uint256 wizardId;
        uint16[2] positive_affinities;
        uint16[2] negative_affinities;
        uint256 ends_at;
        uint256 expires_at;
    }

    Quest[] private questLog;

    QuestTools private qt;

    BaseQuestRewardNFT private baseQuestRewardNFT;

    address public baseQuestFeeAddress;

    uint256 public nextBaseQuestAvailableAt;

    constructor(address _baseQuestFeeAddress, address _baseQuestRewardNFT) {
        baseQuestFeeAddress = _baseQuestFeeAddress;
        baseQuestRewardNFT = BaseQuestRewardNFT(_baseQuestRewardNFT);
        nextBaseQuestAvailableAt = block.timestamp;
        qt = QuestTools(address(this));
    }

    // generate a new quest using random affinity
    function newBaseQuest() public {
        require(
            nextBaseQuestAvailableAt < block.timestamp,
            "Quest Cooldown not elapsed"
        );
        uint256 nonce = questLog.length.mul(4);
        uint16[2] memory pos_aff = [
            qt.getRandomAffinity(nonce),
            qt.getRandomAffinity(nonce.add(1))
        ];

        uint16[2] memory neg_aff = [
            qt.getRandomAffinity(nonce.add(2)),
            qt.getRandomAffinity(nonce.add(3))
        ];
        Quest memory quest = Quest({
            id: questLog.length,
            accepted_by: address(0),
            accepted_at: block.timestamp,
            wizardId: 10000,
            positive_affinities: pos_aff,
            negative_affinities: neg_aff,
            ends_at: 0,
            expires_at: block.timestamp + LibTavernStorage.BASE_EXPIRATION
        });
        questLog.push(quest);
        nextBaseQuestAvailableAt = block.timestamp.add(
            LibTavernStorage.COOLDOWN
        );
    }

    function acceptBaseQuest(
        uint256 id,
        uint256 wizardId,
        string memory lore
    ) public {
        Quest storage quest = questLog[id];
        LibTavernStorage.Storage storage ts = LibTavernStorage.tavernStorage();

        require(
            ts.wizards.ownerOf(wizardId) == msg.sender,
            "Not owner of wizard"
        );
        ts.wizards.transferFrom(msg.sender, address(this), wizardId);

        require(quest.accepted_by == address(0), "Quest accepted already");
        require(quest.expires_at > block.timestamp, "Quest expired");
        quest.accepted_by = msg.sender;
        quest.accepted_at = block.timestamp;
        quest.wizardId = wizardId;

        // reverts if wizard is not verified
        uint256 duration = qt.getQuestDuration(
            wizardId,
            quest.positive_affinities,
            quest.negative_affinities
        );
        quest.ends_at = block.timestamp.add(duration);
    }

    // allow to withdraw wizard after quest duration elapsed
    function completeBaseQuest(uint256 id) public {
        Quest storage quest = questLog[id];
        LibTavernStorage.Storage storage ts = LibTavernStorage.tavernStorage();
        require(quest.accepted_by == msg.sender, "Quest accepted already");
        require(quest.ends_at < block.timestamp, "Quest not ended yet");
        ts.wizards.approve(msg.sender, quest.wizardId);
        ts.wizards.transferFrom(address(this), msg.sender, quest.wizardId);

        //mint reward NFT to user
        uint256 duration = quest.ends_at - quest.accepted_at;

        uint256 score = qt.getQuestScore(
            quest.positive_affinities,
            quest.negative_affinities
        );

        baseQuestRewardNFT.mint(
            msg.sender,
            quest.id, //rewardNFT.totalSupply(),
            ts.wizardStorage.getWizardName(quest.wizardId),
            score,
            duration
        );
    }

    function abandonBaseQuest(uint256 id) public {
        Quest storage quest = questLog[id];
        LibTavernStorage.Storage storage ts = LibTavernStorage.tavernStorage();
        require(
            quest.accepted_by == msg.sender,
            "Quest not accpeted by msg.sender"
        );
        require(quest.ends_at > block.timestamp, "Quest ended");

        // pay penalty fee based o how early it is abondoned
        uint256 feeAmount = LibTavernStorage
            .BASE_FEE
            .mul(block.timestamp - quest.accepted_at)
            .div(quest.ends_at - quest.accepted_at);

        ts.weth.transferFrom(msg.sender, baseQuestFeeAddress, feeAmount);

        ts.wizards.approve(msg.sender, quest.wizardId);
        ts.wizards.transferFrom(address(this), msg.sender, quest.wizardId);
    }

    function getBaseQuest(uint256 id) public view returns (Quest memory) {
        return questLog[id];
    }

    function getNrOfBaseQuests() public view returns (uint256) {
        return questLog.length;
    }
}
