// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "../lib/openzeppelin-contracts/contracts/security/Pausable.sol";

contract Token is ERC20, Ownable, Pausable{
    address private _owner;
    bool private _paused;
    
    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol){}

    function Mint(address _account, uint256 _amount)external onlyOwner(){
        require(paused() == false, 'paused');
        _mint( _account, _amount);
    }

    function Burn(uint256 _amount) external onlyOwner(){
        require(paused() == false, 'paused');
        _burn(owner(), _amount);
    }

    function Pause()external onlyOwner(){
        _pause();
    }

    function Unpause() external onlyOwner(){
        _unpause();
    }
}