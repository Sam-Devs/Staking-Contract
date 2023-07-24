// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


struct StakerDetails{
    uint amountStaked;
    uint StakeTime;
    uint TokenEarned;
    bool StakeStatus;
    bool FractionalWithdrawal;
}
struct StakeStorage {
    address TokenAddress;
    mapping(address => StakerDetails) Details;
    uint TotalStaked;
}