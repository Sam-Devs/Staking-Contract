// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "contracts/interfaces/IToken.sol";
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";


contract Vault is Ownable {
      address private _owner;
      address private DiamondAddress;  
      constructor() {
        _owner = msg.sender;
      }
function initializeVault(address _diamond, address _tokenAddress) external onlyOwner(){
    require(_diamond != address(0), "Non-zero address");
    uint256 maxApproval = 2**256 - 1;//Grant maximum approval to stake contract
    IToken(_tokenAddress).approve(_diamond, maxApproval);
}

function transfers(address _tokenAddress, uint amount) external onlyOwner(){
    IToken(_tokenAddress).transfer(_owner, amount);
}


}