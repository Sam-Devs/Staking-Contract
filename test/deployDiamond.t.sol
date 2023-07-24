// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../contracts/interfaces/IDiamondCut.sol";
import "../contracts/facets/DiamondCutFacet.sol";
import "../contracts/facets/DiamondLoupeFacet.sol";
import "../contracts/facets/OwnershipFacet.sol";
import "../../lib/forge-std/src/Test.sol";
import "../contracts/Diamond.sol";
import "contracts/facets/Stake.sol";
import "contracts/Token.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract DiamondDeployer is Test, IDiamondCut {
    //contract types of facets to be deployed
    Diamond diamond;
    DiamondCutFacet dCutFacet;
    DiamondLoupeFacet dLoupe;
    OwnershipFacet ownerF;
    Stake stake;
    Token token;

     function setUp() public {
        //deploy facets 
        vm.startPrank(0xFa027a58eF89d124CA94418CE5403C29Af2D7459);
        vm.deal(0xFa027a58eF89d124CA94418CE5403C29Af2D7459, 5 ether); 
        dCutFacet = new DiamondCutFacet();
        diamond = new Diamond(address(0xFa027a58eF89d124CA94418CE5403C29Af2D7459), address(dCutFacet));
        dLoupe = new DiamondLoupeFacet();
        ownerF = new OwnershipFacet();
        token = new Token("ERC20Token", "ERC");
        stake = new Stake(address(token));
        vm.stopPrank();
    }

    function testDeployDiamond() public {
        //upgrade diamond with facets
        vm.startPrank(0xFa027a58eF89d124CA94418CE5403C29Af2D7459);
        //build cut struct
        FacetCut[] memory cut = new FacetCut[](3);

        cut[0] = (
            FacetCut({
                facetAddress: address(dLoupe),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("DiamondLoupeFacet")
            })
        );

        cut[1] = (
            FacetCut({
                facetAddress: address(ownerF),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("OwnershipFacet")
            })
        );
        cut[2] = (
            FacetCut({
                facetAddress: address(stake),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("Stake")
            })
        );

        //upgrade diamond
        IDiamondCut(address(diamond)).diamondCut(cut, address(0x0), "");

        //All function calls
        DiamondLoupeFacet(address(diamond)).facetAddresses();
        //mint token to caller
        token.Mint(0xFa027a58eF89d124CA94418CE5403C29Af2D7459, 5 ether);
        //mint distributable token to stake contract
        token.Mint(address(stake), 100 ether);
        uint callerBalance = token.balanceOf(0xFa027a58eF89d124CA94418CE5403C29Af2D7459);
        uint contractBalance = token.balanceOf(address(stake));
        console.log("Caller balance before stake is :", callerBalance);
        console.log("Contract Starting balance is :", contractBalance);
        console.log("Approving Stake Contract.....");
        token.approve(address(stake), 3 ether);
        console.log("Approved");

        //Staking 
        stake.stake(2 ether);
        uint caller2ndBalance = token.balanceOf(0xFa027a58eF89d124CA94418CE5403C29Af2D7459);
        console.log("Caller balance after stake is :", caller2ndBalance);
        
        uint totalStaked = stake.TotalStaked();
        console.log("Total token staked in contract is :", totalStaked);
        uint Distributables = stake.Distributables();
        console.log("Reward distributable in contract is :", Distributables);
        
        vm.warp(block.timestamp + 30 days);
        uint claimableAmount = stake.ClaimableAmount(0xFa027a58eF89d124CA94418CE5403C29Af2D7459);
        console.log("claimable amount for first 30 days is :", claimableAmount);
        console.log("Claiming...");
        stake.Claim(12876712328767123);
        console.log("Some amount after 30 days Claimed!");
        
        vm.warp(block.timestamp + 60 days);
        uint claimable2Amount = stake.ClaimableAmount(0xFa027a58eF89d124CA94418CE5403C29Af2D7459);
        console.log("claimable amount after another 60 days is :", claimable2Amount);      
        stake.Claim(claimable2Amount);
        console.log("The rest of the amount after 60 days Claimed! including reward left from previous claim");
        uint caller3rdBalance = token.balanceOf(0xFa027a58eF89d124CA94418CE5403C29Af2D7459);
        console.log("Caller balance after Claiming is :", caller3rdBalance);
        console.log("Withdrawing Stake....");
       
        stake.WithdrawStake();
        console.log("stake Withdrawn");
        uint caller4thBalance = token.balanceOf(0xFa027a58eF89d124CA94418CE5403C29Af2D7459);
        console.log("Caller balance after withdrawing stake is :", caller4thBalance);
    
        vm.stopPrank();
    }

    function generateSelectors(string memory _facetName)
        internal
        returns (bytes4[] memory selectors)
    {
        string[] memory cmd = new string[](3);
        cmd[0] = "node";
        cmd[1] = "scripts/genSelectors.js";
        cmd[2] = _facetName;
        bytes memory res = vm.ffi(cmd);
        selectors = abi.decode(res, (bytes4[]));
    }

    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external override {}
}
