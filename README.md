## Staking Contract(Unverified)
The staking contract is implemented using Diamond standard and deployed on BNB smart chain test. Explore Diamond contract via https://louper.dev/diamond/0x77D34272511965cDDa9E4dba2Fd59D3a1b1B5ada?network=binance_testnet. 

The staking contract accepts a certain erc20 token which can be staked and withdrawn at any point in time. Staking rewards is dynamically calculated based on the amount staked and the duration it was staked for as well as total stakes and rewards as illustrated below 
```shell
    Let:
- `A` be the amount staked by an individual.
- `T` be the total amount staked by all stakeholders.
- `R` be the total reward to be distributed.
- `t` be the time (in days or any other appropriate unit) that an individual has staked.
- `Tt` be the total time (in days or any other appropriate unit) of the staking period.

The proportion of time an individual stake was active is given by `t/Tt`.

The proportion of the total reward an individual should receive is then `(A / T) * R`.

The staking reward for an individual stake considering the time staked would be:
`(A / T) * R * (t / Tt)`.

Here's an example:

Let's say there are three stakeholders with the following stakes and staking times:
1. Stakeholder 1: Staked 100 tokens for 30 days.
2. Stakeholder 2: Staked 200 tokens for 60 days.
3. Stakeholder 3: Staked 50 tokens for 15 days.

The total amount staked by all stakeholders `T` is 350 tokens (100 + 200 + 50).

Now, let's assume the total reward to be distributed `R` is 1000 tokens.

1. Stakeholder 1 reward:
   `(100 / 350) * 1000 * (30 / 105)` ≈ 85.71 tokens

2. Stakeholder 2 reward:
   `(200 / 350) * 1000 * (60 / 105)` ≈ 244.44 tokens

3. Stakeholder 3 reward:
   `(50 / 350) * 1000 * (15 / 105)` ≈ 10.71 tokens

```
Note: The Diamond contract maintains a single central storage, as such the facet of the diamond are basically implementation contracts i.e. they have no storage.
any calls made should be made directly to the diamond contract address and the diamond will re-route to respective implementation contract. To make updates (upgrade) to the facets,
the DiamondCutFacet will be interacted with 

## Deployment Addresses 
Deployed on BNB SmartChain testnet https://testnet.bscscan.com/
- Diamond : 0x77D34272511965cDDa9E4dba2Fd59D3a1b1B5ada
- DiamondCutFacet : 0xbb435960540C89df00CF4e70232e7010C4FC1687
- DiamondLoupeFacet : 0x28652761D993187e739508355508B3F9852a7b00
- OwnershipFacet : 0x1Bd2f25AEf09d6560076B37f93c925AE7e4bbe6b
- Stake : 0x8E7B9289Eb39987f8ED3827175cdAa589ac4bDDd
- Token : 0x234e334ADAfF21CBdeBB8D1C75aF0AFc67Ba2eF0

## Rationale for Architecture
The project utilized Diamond standard and Foundry environment. Foundry abstracts away much of the complexity involved in implementing the Diamond Standard, making it easier to create upgradeable smart contracts or any kind of contract without having to write all the code from scratch, plus the fact that test units can be done using solidity scripting. The Foundry framework has been reviewed and audited by the community, which provides an added layer of confidence in its security, reliability and speed.

The Diamond Standard is a design pattern proposed by Nick Mudge to create modular, upgradable, and gas-efficient smart contracts on the Ethereum blockchain. The key idea behind the Diamond Standard is to break a smart contract's functionality into smaller, individual "facets" that can be individually deployed and upgraded while maintaining a single, shared storage contract.
The rationale for using the Diamond Standard in this staking project lies in the following benefits it offers:
- Modularity: By dividing the smart contract into facets, we can better organize and manage the codebase. Each facet represents a specific feature or functionality, making it easier to maintain and upgrade the contract over time.
- Upgradability: The Diamond Standard allows for seamless upgrades to individual facets without having to redeploy the entire contract. This is essential for evolving projects and fixing potential bugs or vulnerabilities.
- Gas Efficiency: Since the Diamond Standard enables upgrades without redeploying the entire contract, it can help reduce gas costs associated with deploying new versions of the contract.
- Flexibility: Projects built using the Diamond Standard can adapt to changing requirements and add new features more easily by deploying additional facets.
## Issues 
Deployment to polygon Mumbai, Elastos Testnet and Telos Testnet all returned the below error:
```bash
error: Failed to get EIP 1559 fees.
```
This error implies that these networks do not support the new Ethereum improvement proposal that changes the way gas fees are being 
calculated. Thus, if the network has no support for EIP 1559, it is imperative to switch network. 

Encountered unavailability issues claiming Fuji testnet Token;  hence, deployment to Fuji was impossible.
## Installation

- Clone this repo
- Install dependencies

```bash
$ yarn && forge update
```

### Compile

```bash
$ npx hardhat compile
```

## Deployment

### Hardhat

```bash
$ npx hardhat run scripts/deploy.js
```

### Foundry testing

```bash
$ forge t
```

