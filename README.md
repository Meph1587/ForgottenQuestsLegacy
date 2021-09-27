# Forgotten Quests

A framework for questing games for Wizards of the Forgotten Runes Cult

## Introduction

Forgotten Runes Wizard Cult is a NFT collectibles with 10’000 unique wizard characters. Each wizard has between 3 and 6 _traits_ (background, head, body, familiar, prop and rune). Each of these traits has a rarity based on how often it occurs accords the collection. Each trait (excluding background) has one ore more _affinities_ and multiple traits can have the same affinity. For example both the head-trait “hunter” and the prop-trait “wooden stick” have, among others, the affinity “Nature”.  
The affinity alignment of a wizard is defined as the number of traits that have a given affinity - for example if a wizard has 5 traits total and all with the “Nature” affinity it is considered 5/5 (or 100%) aligned to the “Nature” affinity.  
The aim of the Forgotten Quests framework is to provide the tool and the infrastructure necessary for anyone to build basic questing games around the affinities/traits/names and many more wizard-related stats.

## Basic game mechanics

The core mechanic of Forgotten Quests is a very simple locking contract (the Quest) for Wizards. This contract takes a wizard NFT and locks it for a given duration, once the lock is expired the wizard can be withdrawn from the contract with a reward.  
The goal of this mechanic is to allow users holding wizards and that are willing to lock the wizards up for a given time (therefore foregoing the ability to liquidate them) to receive some rewards either provided by the quests themselves (see base quest rewards) or by other users seeking a more interesting way to drop their NFTs to the wizard community.  
There will be many types of quests each using different metrics to define what wizard(s) can take quests and how the rewards are distributed. In the beginning there will be three types of quests:

- BaseQuest
- LoreQuests
- TeamBaseQuest

More quests will be added later on and a template will be provided for other developers to build their own quest types.

## A few technical details

The ForgottenQuests framework uses the EIP-2535 Diamond Standard. This is a novel proxy mechanism that allows to have a single entry-point contract that can forward transactions to a virtually unlimited number of other contracts (so long as all function identifiers of those contracts are unique).  
This allows each quest type to be its own contract an part of a fully upgradable system. New quest types can be added to the Diamond at will and existing quest contracts can be updated or even removed.  
A set of tooling contracts will be added as well to make the development of new quests as seamless as possible.
The Diamond contract itself will be controlled by an multisig account owned by the development team. This is to allow for at least some quality and security control of new quests that want to be added. The ownership of the Diamond can be passed over to a more decentralized body if the project grows enough to make such a transition feasible or even required.

## Base Quests

In the most basic form of a quest, the ‘BaseQuest’, the contract allows user to generate a new quest every 10 hours. The duration of the quest is determined by the wizard’s alignment to a set of 4 affinities set randomly during the quest creation. 2 out of the 4 are “positive affinities” and the other 2 are “negative affinities”. For a wizard to take the quest it needs to have at least 1 of the positive affinities. The duration if the lock is then calculated as follows:  
`2 weeks - (positiveNr _ 1day) + (negativeNr _ 1day)`  
So, for example if the quest’s positive affinities are 234 and 56 and the negative affinities are 76 and 136 a wizard that has 5/5 alignment to 234 and 3/5 alignment to 56 and also 1/5 alignment to 76 and 0/5 alignment to 136 the duration of the lock would be of:  
`2 weeks - (8 _ 1day) + (1 _ 1day) = 7 days`

But if the wizard would have very little alignment to the positive affinities and a strong alignment to the negative ones the lock duration can go up to 3weeks.
(The exact numbers for the durations will be set for each quest type individually)

## Base Quest Rewards

Of course no wizard goes on quests for free. The rewards for ‘BaseQuests’ are ‘WizardTrophies’. These are ERC1155 tokens with three categories “Gold, Silver, Bronze”. These tokens are minted on completion of the quests depending on the difficulty of the quest. The difficulty is determined by using the rarity of the positive an negative affinities of the quest. A quest that has two very rare positive affinities is more difficult as very few wizards can complete it in reasonable time. Such a quest will have a Gold trophy as reward - a quest with very common affinities will be easier as many wizards can take it and will therefore give a Bronze trophy.  
The scarcity of these trophies is solely determined by the amount of new quests (ca 876 per year) and the willingness of wizard holders to lock their wizards up.

## Lore Quests

Lore Quests are an expansion of the base quests. They have the same 4 affinity mechanism to determine the duration of the lockup.  
They differ from base Quests because they can only be created by whitelisted “QuestMasters” and there can only be 1 new Lore Quest every 3 days.  
The QuestMasters creating the Quests needs to write a basic lore for the quest and can choose an NFT held by them to be set as Reward for the quest. This NFT will be stored in the quest contract until a wizard completes the quest and receivers it as reward. If no wizard takes the quest the NFT before the expiration time it can be withdrawn by the quest creator.  
QuestMaster can set a price for the quest in WETH this price needs to be paid by the wizard holder when taking the quest and is directly sent to the quest creator. This mechanism allows Lore Quests to be used by Artists and other creators to sell their NFTs to Wizard holders in a more fun way.  
There is also the option so set some required traits for the quests to allow for example to have kobold specific art and lore that can only be received by sending kobolds to the quest. If this is done, at least 1 of the 2 positive affinities will be related to at least one of the required traits to avoid a situation where no wizard could take the quest.

## Team Base Quest

Team quests will require multiple wizards to come together to solve the quest.  
There will be only 1 team quest that can be generated per week. The team quest can take 3-5 wizards and there are 8 positive and 8 negative affinities for the quest. The duration of the lock is computed based on the combined alignments of all participating wizards and all wizards are locked for the duration. It is therefore of interest to assemble a team of highly aligned and complementary wizards. The rewards for the Team Based Quests will also be WizardTrophies and each participating wizard will receive one. The rarity of the trophy will be determined by the combined rarity of the quest affinities. This will potentially create up to 260 additional trophies per year.  
If some wizards join the party for the team quest but not enough others join the wizards can be withdrawn after the expiration time of the quest.

## Other quest ideas

While developing the first three quest types many more idea surfaced. These will require more thought and complex implementations but its worth publishing them to gauge interest, collect feedback and potentially source some help.  
Spell based quest: thanks to the amazing work by the wizard community there are now wizard Spells. These could be used for a new quest type where 1 ore more spell of a specific school may be required to complete the quest.

- **PVP Quests**: these quest may have 2 or more wizards competing for the rewards. The metrics under which they compete could be certain affinities or traits set after the wizards accepted the quest - or some events the wizards have betted on in advance.
- **Off-chain Game Quest**: these quests would not have a lock-duration not set by the contract but instead quests can be ended upon providing a specific key-word pre-set and then issued by an off-chain game.
- **Interactive quests**: these quest may require users to execute specific actions during the the quest to avoid the duration of the lock to increase. These events may be triggered programmatically or by a QuestMaster. For example during the quest there could be a time window in which a wizard needs to solve a puzzle or enigma.
- **Storyline Quests**: these would be similar to interactive quests where a QuestMaster is giving the participating wizards challenges to solve in order to get to the next phase of the quest. (Yes this is starting to sound like onchain DnD with wizards, and I love it)

# Next Steps

The development of ForgottenQuests is well on its way and you can keep track of the progress on this github repo.
Once a first stable version is finished it will be deployed on rinkeby for public testing before going o to mainnet.
