// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {StakeStorage, StakerDetails} from "../libraries/AppStorage.sol";
import { LibDiamond } from "../libraries/LibDiamond.sol";

contract Stake {
        StakeStorage ds;
    constructor(address _tokenAddress){
        ds.TokenAddress = _tokenAddress;
    }
    function stake(uint _amount)external{
        IERC20(ds.TokenAddress).transferFrom(msg.sender, address(this), _amount);
        if(ds.Details[msg.sender].StakeStatus == true){
        ds.Details[msg.sender].amountStaked += _amount;
        ds.Details[msg.sender].StakeTime = block.timestamp;  
        } 
        else if(ds.Details[msg.sender].StakeStatus == false){
        ds.Details[msg.sender].amountStaked = _amount;
        ds.Details[msg.sender].StakeTime = block.timestamp;
        ds.Details[msg.sender].StakeStatus = true;
        }
        ds.TotalStaked += _amount;
    }

    function Claim(uint _amount)external{
         uint reward = ClaimableAmount(msg.sender);
         uint claimAbleAmount =  reward;
        require( claimAbleAmount != 0, "You have no reward");
        require(_amount <= claimAbleAmount, "Can't withdraw more than your reward");
        require(_amount < IERC20(ds.TokenAddress).balanceOf(address(this)), "check back to claim reward");
        if (_amount == claimAbleAmount && ds.Details[msg.sender].FractionalWithdrawal == false){
            IERC20(ds.TokenAddress).transfer(msg.sender, claimAbleAmount);
            ds.Details[msg.sender].TokenEarned = 0;
        }else if(_amount < claimAbleAmount && ds.Details[msg.sender].FractionalWithdrawal == false){
            IERC20(ds.TokenAddress).transfer(msg.sender, _amount);
           uint rewardLeft = claimAbleAmount - _amount;
            ds.Details[msg.sender].TokenEarned = rewardLeft;
            ds.Details[msg.sender].FractionalWithdrawal = true;
            ds.Details[msg.sender].StakeTime = block.timestamp;
        }else if(_amount < claimAbleAmount && ds.Details[msg.sender].FractionalWithdrawal == true){
            IERC20(ds.TokenAddress).transfer(msg.sender, _amount);
            uint rewardRemaining = claimAbleAmount - _amount;
            ds.Details[msg.sender].TokenEarned = rewardRemaining;
            ds.Details[msg.sender].StakeTime = block.timestamp;
        }else if (_amount == claimAbleAmount && ds.Details[msg.sender].FractionalWithdrawal == true){
            IERC20(ds.TokenAddress).transfer(msg.sender, claimAbleAmount);
            ds.Details[msg.sender].TokenEarned = 0;
            ds.Details[msg.sender].FractionalWithdrawal = false;
        }
    }

    function WithdrawStake() external {
        StakerDetails memory _stakersDetails = ds.Details[msg.sender];
        uint stakeAmount = _stakersDetails.amountStaked;
        uint reward = ClaimableAmount(msg.sender);
        uint withdrawal = stakeAmount + reward;
        require(withdrawal < IERC20(ds.TokenAddress).balanceOf(address(this)), "check back to claim reward");
        IERC20(ds.TokenAddress).transfer(msg.sender, withdrawal);
        ds.Details[msg.sender].amountStaked = 0;
        ds.Details[msg.sender].StakeTime = 0;
        ds.Details[msg.sender].StakeStatus = false;
        ds.Details[msg.sender].TokenEarned = 0;
        ds.Details[msg.sender].FractionalWithdrawal = false;
    }

    //calculates earning relative to the amount staked, and the duration it was staked.
    //staking for a full year implies earning 20% of staked amount (subject to change).
    function ClaimableAmount(address account) public view returns(uint reward) {      
        StakerDetails memory _stakersDetails = ds.Details[msg.sender];
        uint amount = _stakersDetails.amountStaked;
        uint rewardTime = block.timestamp - _stakersDetails.StakeTime;
        uint initialEarning = ds.Details[account].TokenEarned;
        uint expectedReward = (rewardTime * 20 * amount) / (31536000 * 100);
        reward = initialEarning + expectedReward;
    }

    function TotalStaked() public view returns(uint _total) {
        _total = ds.TotalStaked;
    }

    function Distributables() public view returns (uint _distributable){
        _distributable = IERC20(ds.TokenAddress).balanceOf(address(this)) - ds.TotalStaked;
    }

    function UpdateTokenAddress(address _newToken) external {
        require(msg.sender == LibDiamond.contractOwner(), "not authorized");
        ds.TokenAddress = _newToken;
    }
}

//  uint initialTokenEarned = ds.Details[msg.sender].TokenEarned;
//             uint _reward = claimAbleAmount + initialTokenEarned;