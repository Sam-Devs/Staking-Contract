## Staking Contract(Unverified)
The staking contract accepts a certain erc20 token which can be staked and withdrawn at any point in time. Staking rewards is dynamically calculated based on the amount staked and the duration it was staked for. Tentatively, the contract allows for rewards up to 20% of the amount staked which could be adjusted. It should be noted that the staking contract is part of the diamond facet while the Token contract is a standalone contract. 

Contract is implemented using Diamond standard and deployed on BNB smart chain test. Explore Diamond contract via https://louper.dev/diamond/0x77D34272511965cDDa9E4dba2Fd59D3a1b1B5ada?network=binance_testnet.

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
calculated. Thus, if the network has no support for EIP 1559, it is imperative to switch network. Encountered unavailability issues claiming Fuji testnet Token;  hence, deployment to Fuji was impossible.
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

