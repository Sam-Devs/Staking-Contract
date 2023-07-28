// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


struct StakerDetails{
    uint amountStaked;
    uint StakeTime;
    uint TokenEarned;
    bool StakeStatus;
    bool FractionalWithdrawal;
}
struct Storage {
    uint TotalStaked;
    uint TotalStakeHolders;
    mapping(address => StakerDetails) Details;
    address TokenAddress;
    address StakeContractAddress;
    address VaultAddress;
}