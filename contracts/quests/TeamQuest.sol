//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../QuestAchievements.sol";
import "../QuestTools.sol";

contract TeamQuest {
    using SafeMath for uint16;
    using SafeMath for uint256;

    address public rewardNFT;

    address public feeAddress;

    uint256 public nextTeamQuestAvailableAt;

    struct Quest {
        uint256 id;
        address[4] accepted_by;
        uint256 accepted_at;
        uint256[4] wizardId;
        uint16[2][4] positive_affinities;
        uint16[2][4] negative_affinities;
        bool[4] abandoned;
        string name;
        uint256 ends_at;
        uint256 expires_at;
    }
    Quest[] private questLog;

    QuestAchievements public baseQuestAchievements;

    QuestTools private qt;

    address public teamQuestFeeAddress;

    function initialize(
        address _questTools,
        address _teamQuestFeeAddress,
        address _baseQuestAchievements
    ) public {
        require(nextTeamQuestAvailableAt == 0, "Already Initialized");
        teamQuestFeeAddress = _teamQuestFeeAddress;
        baseQuestAchievements = QuestAchievements(_baseQuestAchievements);
        nextTeamQuestAvailableAt = block.timestamp;
        qt = QuestTools(_questTools);
    }

    // generate a new quest using random affinity
    function newTeamQuest() public {
        require(
            nextTeamQuestAvailableAt < block.timestamp,
            "Quest Cooldown not elapsed"
        );

        uint256 nonce = questLog.length.mul(16);
        uint16[2] memory pos_aff1 = [
            qt.getRandomAffinity(nonce.add(1)),
            qt.getRandomAffinity(nonce.add(1))
        ];

        uint16[2] memory neg_aff1 = [
            qt.getRandomAffinity(nonce.add(2)),
            qt.getRandomAffinity(nonce.add(3))
        ];

        uint16[2] memory pos_aff2 = [
            qt.getRandomAffinity(nonce.add(4)),
            qt.getRandomAffinity(nonce.add(5))
        ];

        uint16[2] memory neg_aff2 = [
            qt.getRandomAffinity(nonce.add(6)),
            qt.getRandomAffinity(nonce.add(7))
        ];

        uint16[2] memory pos_aff3 = [
            qt.getRandomAffinity(nonce.add(8)),
            qt.getRandomAffinity(nonce.add(9))
        ];

        uint16[2] memory neg_aff3 = [
            qt.getRandomAffinity(nonce.add(10)),
            qt.getRandomAffinity(nonce.add(11))
        ];

        uint16[2] memory pos_aff4 = [
            qt.getRandomAffinity(nonce.add(12)),
            qt.getRandomAffinity(nonce.add(13))
        ];

        uint16[2] memory neg_aff4 = [
            qt.getRandomAffinity(nonce.add(14)),
            qt.getRandomAffinity(nonce.add(15))
        ];
        Quest memory quest = Quest({
            id: questLog.length,
            accepted_by: [address(0), address(0), address(0), address(0)],
            accepted_at: block.timestamp,
            wizardId: [
                uint256(10000),
                uint256(10000),
                uint256(10000),
                uint256(10000)
            ],
            positive_affinities: [pos_aff1, pos_aff2, pos_aff3, pos_aff4],
            negative_affinities: [neg_aff1, neg_aff2, neg_aff3, neg_aff4],
            abandoned: [false, false, false, false],
            name: "", //baseQuestAchievements.getName(questLog.length),
            ends_at: 0,
            expires_at: block.timestamp + qt.BASE_EXPIRATION().mul(2)
        });
        questLog.push(quest);
        nextTeamQuestAvailableAt = block.timestamp.add(172800); /// 3 days;
    }

    function acceptTeamQuest(uint256 id, uint256 wizardId) public {
        Quest storage quest = questLog[id];

        qt.getWizards().transferFrom(msg.sender, address(this), wizardId);
        uint256 slot = _getLastSlotFilled(quest);
        require(slot < 4, "Quest filled already");
        require(quest.expires_at > block.timestamp, "Quest expired");
        quest.accepted_by[slot] = msg.sender;
        quest.wizardId[slot] = wizardId;
        if (slot == 3) {
            quest.accepted_at = block.timestamp;

            // reverts if wizard is not verified
            uint256 duration1 = qt.getQuestDuration(
                wizardId,
                quest.positive_affinities[0],
                quest.negative_affinities[0]
            );
            uint256 duration2 = qt.getQuestDuration(
                wizardId,
                quest.positive_affinities[1],
                quest.negative_affinities[1]
            );
            uint256 duration3 = qt.getQuestDuration(
                wizardId,
                quest.positive_affinities[2],
                quest.negative_affinities[2]
            );
            uint256 duration4 = qt.getQuestDuration(
                wizardId,
                quest.positive_affinities[3],
                quest.negative_affinities[3]
            );
            uint256 duration = (
                duration1.add(duration2).add(duration3).add(duration4)
            ).div(4);
            quest.ends_at = block.timestamp.add(duration);
        }
    }

    // allow to withdraw wizard after quest duration elapsed
    function completeTeamQuest(uint256 id) public {
        Quest storage quest = questLog[id];

        require(
            quest.accepted_by[0] == msg.sender ||
                quest.accepted_by[1] == msg.sender ||
                quest.accepted_by[2] == msg.sender ||
                quest.accepted_by[3] == msg.sender,
            "Only wizard owner can complete"
        );
        require(quest.ends_at < block.timestamp, "Quest not ended yet");

        uint256 slot = 0;
        for (uint8 i = 0; i < 4; i++) {
            if (quest.accepted_by[i] == msg.sender) {
                slot = i;
                break;
            }
        }

        qt.getWizards().approve(msg.sender, quest.wizardId[slot]);
        qt.getWizards().transferFrom(
            address(this),
            msg.sender,
            quest.wizardId[slot]
        );

        //mint reward NFT to user
        uint256 duration = quest.ends_at - quest.accepted_at;

        uint256 score1 = qt.getQuestScore(
            quest.positive_affinities[0],
            quest.negative_affinities[0]
        );
        uint256 score2 = qt.getQuestScore(
            quest.positive_affinities[1],
            quest.negative_affinities[1]
        );
        uint256 score3 = qt.getQuestScore(
            quest.positive_affinities[2],
            quest.negative_affinities[2]
        );
        uint256 score4 = qt.getQuestScore(
            quest.positive_affinities[3],
            quest.negative_affinities[3]
        );

        uint256 score = (score1.add(score2).add(score3).add(score4)).div(4);

        baseQuestAchievements.mint(
            msg.sender,
            quest.id,
            qt.getGrimoire().getWizardName(quest.wizardId[slot]),
            score,
            duration,
            true
        );
    }

    function abandonTeamQuest(uint256 id) public {
        Quest storage quest = questLog[id];

        uint256 slot = 0;
        for (uint8 i = 0; i < 4; i++) {
            if (quest.accepted_by[i] == msg.sender) {
                slot = i;
                break;
            }
        }
        require(quest.ends_at > block.timestamp, "Quest ended");

        // pay penalty fee based o how early it is abondoned
        uint256 feeAmount = qt
            .BASE_FEE()
            .mul(block.timestamp - quest.accepted_at)
            .div(quest.ends_at - quest.accepted_at);

        qt.getWeth().transferFrom(msg.sender, teamQuestFeeAddress, feeAmount);

        qt.getWizards().approve(msg.sender, quest.wizardId[slot]);
        qt.getWizards().transferFrom(
            address(this),
            msg.sender,
            quest.wizardId[slot]
        );
    }

    function getTeamQuest(uint256 id) public view returns (Quest memory) {
        return questLog[id];
    }

    function getNrOfTeamQuests() public view returns (uint256) {
        return questLog.length;
    }

    function _getLastSlotFilled(Quest memory quest)
        internal
        pure
        returns (uint256)
    {
        for (uint8 i = 0; i < 4; i++) {
            if (quest.accepted_by[i] == address(0)) {
                return i;
            }
        }
        return 4;
    }
}
