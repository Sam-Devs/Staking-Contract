## Staking Contract(Unverified)
The Staking Contract is implemented using Diamond standard and deployed on BNB smart chain test. Explore Diamond contract via https://louper.dev/diamond/0x003C3150cF8a4C0b7894615cf2d4862547E080Ec?network=binance_testnet. 

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
- Diamond : 0x003C3150cF8a4C0b7894615cf2d4862547E080Ec
- DiamondCutFacet : 0x5548412D90679dd2c69A4e26A304FeC46d34532C
- DiamondLoupeFacet : 0xbA07ef92AdB9aF50Ed38CCB617f8fb592E3F62A1
- OwnershipFacet : 0xB5FC838C927AC12943DE007F41506049a7E68e38
- Stake : 0x5BCEDb1ff129B45E7C456E4054F7862aB43E6Fca
- Token : 0x231e20F94640EEE53fd4bd4df890B97fB116fA79
- Vault : 0x6DDB1da28725b05a42bb62101ebA296f842cE58C

## Rationale for Architecture
The project utilized Diamond standard and Foundry environment. Foundry abstracts away much of the complexity involved in implementing the Diamond Standard, making it easier to create upgradeable smart contracts or any kind of contract without having to write all the code from scratch, plus the fact that test units can be done using solidity scripting. The Foundry framework has been reviewed and audited by the community, which provides an added layer of confidence in its security, reliability and speed.

The Diamond Standard is a design pattern proposed by Nick Mudge to create modular, upgradable, and gas-efficient smart contracts on the Ethereum blockchain. The key idea behind the Diamond Standard is to break a smart contract's functionality into smaller, individual "facets" that can be individually deployed and upgraded while maintaining a single, shared storage contract.
The rationale for using the Diamond Standard in this staking project lies in the following benefits it offers:
- Modularity: By dividing the smart contract into facets, we can better organize and manage the codebase. Each facet represents a specific feature or functionality, making it easier to maintain and upgrade the contract over time.
- Upgradability: The Diamond Standard allows for seamless upgrades to individual facets without having to redeploy the entire contract. This is essential for evolving projects and fixing potential bugs or vulnerabilities.
- Gas Efficiency: Since the Diamond Standard enables upgrades without redeploying the entire contract, it can help reduce gas costs associated with deploying new versions of the contract.
- Flexibility: Projects built using the Diamond Standard can adapt to changing requirements and add new features more easily by deploying additional facets.

## Architecture
Things to note: Facets, Interfaces, Libraries, upgradeInitializers and standalone contracts.  
The Diamond contract is an upgradeable contract with 4 upgradeable facets and two standalone contract. The facets includes;
- DiamondCutFacet.sol : The Facets that facilitates facet upgrades and updates i.e facet removal and addition.
- DiamondLoupeFacet.sol : This is the diamond explorer. allows to navigate the various facets.
- OwnershipFacet.sol : this is a regular ownership contract that handles the diamond ownership including transfers
- Stake.sol : the main staking contract logic

The interfaces which allows for interaction with various facet and eips includes the following;
- IDiamondCut.sol
- IDiamondLoupe.sol
- IERC165.sol
- IERC173.sol
- IToken.sol

The libraries includes; 
- AppStorage.sol : this is the main storage of the diamond contract. It should be noted that the facets do not have storage, they are basically logic contracts, every info from the stake contract and every other facets are stored here.
- LibDiamond.sol : These are reuseable diamond functionalites that can be called through out the facets and diamond itself.

The Upgradeinitializers includes;
- DiamondInit.sol : This facilitates upgrades alongside DiamondCutfacet. 

the Standalone contract includes;
- Token.sol: The ERC20 contract
- Vault.sol : The contract that holds all stakes and rewards. it has to be a standalone and not a facet since it holds funds.(we wouldn't want any other diamond interacting with the vault).

The main Diamond contract is the 
- Diamond.sol : The main diamond contract has no implementation logic, instead, it routes function calls to their respective implementation contract. IT SHOULD BE NOTED THAT ASIDES THE APPSTORAGE, THE DIAMOND UTILIZES DIAMONDSTORAGE WHERE FUNCTION SIGNATURES AND THEIR RESPECTIVE IMPLEMENTATION CONTRACT ADDRESSES ARE STORED AND FETCHED AT EVERY POINT IN TIME A USER INTERACTS WITH THE DIAMOND CONTRACT.

IT SHOULD ALSO BE NOTED THAT THE DIAMOND CONTRACT ADDRESS SHOULD BE INTERACTED WITH DIRECTLY AND THE ROUTING WILL BE EXECUTED BY THE DIAMOND.
IT SHOULS ALSO BE NOTED THAT, ANOTHER DIAMOND WITH THE SAME STORAGE STRUCTURE CAN USE ANY OF THE FACETS SINCE THEY A BASICALLY IMPLEMENTATION CONTRACTS WITH NO STORAGE.


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

