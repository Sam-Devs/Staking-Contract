// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/IToken.sol";
import {Storage, StakerDetails} from "../libraries/AppStorage.sol";
import { LibDiamond, ECDSA } from "../libraries/LibDiamond.sol";

contract Stake {
        Storage ds;

    function stake(uint _amount)external{
        IToken(ds.TokenAddress).transferFrom(msg.sender, ds.VaultAddress, _amount);
        if(ds.Details[msg.sender].StakeStatus == true){
        uint accumulatedReward = ClaimableAmount(msg.sender);
        ds.Details[msg.sender].TokenEarned += accumulatedReward;
        ds.Details[msg.sender].amountStaked += _amount;
        ds.Details[msg.sender].StakeTime = block.timestamp;  
        } 
        else if(ds.Details[msg.sender].StakeStatus == false){
        ds.Details[msg.sender].amountStaked = _amount;
        ds.Details[msg.sender].StakeTime = block.timestamp;
        ds.Details[msg.sender].StakeStatus = true;
        }
        ds.TotalStaked += _amount;
        ds.TotalStakeHolders += 1; 
    }

    function Claim(uint _amount)external{
         uint claimAbleAmount =  ClaimableAmount(msg.sender);
        require( claimAbleAmount != 0, "You have no reward");
        require(_amount <= claimAbleAmount, "Can't withdraw more than your reward");
        require(_amount < IToken(ds.TokenAddress).balanceOf(ds.VaultAddress), "check back to claim reward");
        if(ds.Details[msg.sender].FractionalWithdrawal == true){
             if(_amount < claimAbleAmount){
                IToken(ds.TokenAddress).transferFrom(ds.VaultAddress, msg.sender, _amount);
                uint rewardRemaining = claimAbleAmount - _amount;
                ds.Details[msg.sender].TokenEarned = rewardRemaining;
                ds.Details[msg.sender].StakeTime = block.timestamp;
             }else if(_amount == claimAbleAmount){
                IToken(ds.TokenAddress).transferFrom(ds.VaultAddress, msg.sender, claimAbleAmount);
                ds.Details[msg.sender].TokenEarned = 0;
                ds.Details[msg.sender].FractionalWithdrawal = false;
             }      
        }else if(ds.Details[msg.sender].FractionalWithdrawal == false){
              if(_amount == claimAbleAmount){
                IToken(ds.TokenAddress).transferFrom(ds.VaultAddress, msg.sender, claimAbleAmount);
                ds.Details[msg.sender].TokenEarned = 0;
              }else if(_amount < claimAbleAmount){
                IToken(ds.TokenAddress).transferFrom(ds.VaultAddress, msg.sender, _amount);
                 uint rewardLeft = claimAbleAmount - _amount;
                 ds.Details[msg.sender].TokenEarned = rewardLeft;
                 ds.Details[msg.sender].FractionalWithdrawal = true;
                 ds.Details[msg.sender].StakeTime = block.timestamp;
              }  
        }
    }

    function WithdrawStake() external {
        StakerDetails memory _stakersDetails = ds.Details[msg.sender];
        require(_stakersDetails.StakeStatus, "nonstaker");
        uint stakeAmount = _stakersDetails.amountStaked;
        uint reward = ClaimableAmount(msg.sender);
        uint withdrawal = stakeAmount + reward;
        require(withdrawal < IToken(ds.TokenAddress).balanceOf(ds.VaultAddress), "check back to claim reward");
        IToken(ds.TokenAddress).transferFrom(ds.VaultAddress, msg.sender, withdrawal);
        ds.Details[msg.sender].amountStaked = 0;
        ds.Details[msg.sender].StakeTime = 0;
        ds.Details[msg.sender].StakeStatus = false;
        ds.Details[msg.sender].TokenEarned = 0;
        ds.Details[msg.sender].FractionalWithdrawal = false;
        ds.TotalStakeHolders -= 1; 
    }

    //Non-autoCompound ClaimableAmount function
    function ClaimableAmount(address account) public view returns(uint reward) {      
        StakerDetails memory _stakersDetails = ds.Details[msg.sender];
        uint amount = _stakersDetails.amountStaked;
        uint rewardTime = block.timestamp - _stakersDetails.StakeTime;
        uint initialEarning = ds.Details[account].TokenEarned;
        uint expectedReward = (amount * rewardTime) * Distributables() / (ds.TotalStaked * 31536000);
        reward = initialEarning + expectedReward;
    }

    function TotalStaked() public view returns(uint _total) {
        _total = ds.TotalStaked;
    }

    function Distributables() public view returns (uint _distributable){
        _distributable = IToken(ds.TokenAddress).balanceOf(ds.VaultAddress) - ds.TotalStaked;
    }

    function UpdateTokenAddress(address _newToken) internal {
        require(_newToken != address(0), "Non-zero address");
        ds.TokenAddress = _newToken;
    }

    function executeTokenUpdate(bytes memory signature,address newTokenAddr, uint256 deadline) external {
            bytes32 digest = LibDiamond._hashTypedDataV4(keccak256(abi.encode(
            keccak256("UpdateTokenAddress(address owner,address newTokenAddr,uint256 nonce,uint256 deadline)"),
            LibDiamond.contractOwner(),
            newTokenAddr,
            ds.nonces[LibDiamond.contractOwner()],
            deadline
        )));
        address signer = ECDSA.recover(digest, signature);
        require(signer == LibDiamond.contractOwner(), "UpdateToken: invalid signature");
        require(signer != address(0), "ECDSA: invalid signature");

        require(block.timestamp < deadline, "UpdateTokenAddress: signed transaction expired");
        ds.nonces[LibDiamond.contractOwner()]++;
        UpdateTokenAddress(newTokenAddr);
    }

    //Compound stake feature Logic 
    //@audit
    // function CompoundStake() external {
    //     StakerDetails memory _stakersDetails = ds.Details[msg.sender];
    //     uint rewardTime = block.timestamp - _stakersDetails.StakeTime;
    //     //Only compound if stake time is more than 30 days
    //     require(rewardTime >= 31536000, "Only compounds after 1 year");
    //     uint initialReward = ClaimableAmount(msg.sender);
    //     ds.Details[msg.sender].amountStaked += initialReward;
    //     ds.Details[msg.sender].StakeTime = block.timestamp;
    // }

}