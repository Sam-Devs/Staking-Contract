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
import "contracts/Vault.sol";


interface DiamondInteract{
    function initializeVault(address _StakeAddress, address _tokenAddress) external;
    function stake(uint _amount)external;
    function Claim(uint _amount)external;
    function WithdrawStake() external;
    function ClaimableAmount(address account) external view returns(uint reward);
    function TotalStaked() external view returns(uint _total);
    function Distributables() external view returns (uint _distributable);
    function UpdateTokenAddress(address _newToken) external;
    function CompoundStake() external;
    function executeTokenUpdate(bytes memory signature,address newTokenAddr, uint256 deadline) external;
}

contract DiamondDeployer is Test, IDiamondCut {
    //contract types of facets to be deployed
    Diamond diamond;
    DiamondCutFacet dCutFacet;
    DiamondLoupeFacet dLoupe;
    OwnershipFacet ownerF;
    Stake stake;
    Token token;
    Vault vault;

     function setUp() public {
        // Forked Sepolia Testnet to test Signature Validity
        // uint sepolia = vm.createFork("https://eth-sepolia.g.alchemy.com/v2/5ShvcS43c_Wrsfk_jTMZOU0sXXBKaVXP", 3988447);
        // vm.selectFork(sepolia);
        //deploy facets 
        vm.startPrank(0xFa027a58eF89d124CA94418CE5403C29Af2D7459);
        vm.deal(0xFa027a58eF89d124CA94418CE5403C29Af2D7459, 5 ether); 
        token = new Token("ERC20Token", "ERC");
        vault = new Vault();
        address vaultAddress = address(vault);
        dCutFacet = new DiamondCutFacet();
        diamond = new Diamond(address(0xFa027a58eF89d124CA94418CE5403C29Af2D7459), address(dCutFacet), address(token), vaultAddress);
        dLoupe = new DiamondLoupeFacet();
        ownerF = new OwnershipFacet();
        stake = new Stake();
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
        vault.initializeVault(address(diamond), address(token));
        // diamond.initializeVault(address(stake));
        token.Mint(0xFa027a58eF89d124CA94418CE5403C29Af2D7459, 5 ether);
        //mint distributable token to stake contract
        token.Mint(address(vault), 100 ether);
        uint callerBalance = token.balanceOf(0xFa027a58eF89d124CA94418CE5403C29Af2D7459);
        uint contractBalance = token.balanceOf(address(vault));
        console.log("Caller balance before stake is :", callerBalance);
        console.log("Vault Contract Starting balance is :", contractBalance);
        console.log("Approving Stake Contract.....");
        token.approve(address(diamond), 3 ether);
        console.log("Approved");

        //Staking 
        DiamondInteract(address(diamond)).stake(2 ether);
        uint caller2ndBalance = token.balanceOf(0xFa027a58eF89d124CA94418CE5403C29Af2D7459);
        console.log("Caller balance after stake is :", caller2ndBalance);
        
        uint totalStaked = DiamondInteract(address(diamond)).TotalStaked();
        console.log("Total token staked in contract is :", totalStaked);
        uint Distributables = DiamondInteract(address(diamond)).Distributables();
        console.log("Reward distributable in contract is :", Distributables);
        
        vm.warp(block.timestamp + 30 days);
        uint claimableAmount = DiamondInteract(address(diamond)).ClaimableAmount(0xFa027a58eF89d124CA94418CE5403C29Af2D7459);
        console.log("claimable amount for first 30 days is :", claimableAmount);
        console.log("Claiming...");
        DiamondInteract(address(diamond)).Claim(12876712328767123);
        console.log("Some amount after 30 days Claimed!");
        
        vm.warp(block.timestamp + 60 days);
        uint claimable2Amount = DiamondInteract(address(diamond)).ClaimableAmount(0xFa027a58eF89d124CA94418CE5403C29Af2D7459);
        console.log("claimable amount after another 60 days is :", claimable2Amount);      
        DiamondInteract(address(diamond)).Claim(claimable2Amount);
        console.log("The rest of the amount after 60 days Claimed! including reward left from previous claim");
        uint caller3rdBalance = token.balanceOf(0xFa027a58eF89d124CA94418CE5403C29Af2D7459);
        console.log("Caller balance after Claiming is :", caller3rdBalance);
        console.log("Withdrawing Stake....");
       
        DiamondInteract(address(diamond)).WithdrawStake();
        console.log("stake Withdrawn");
        uint caller4thBalance = token.balanceOf(0xFa027a58eF89d124CA94418CE5403C29Af2D7459);
        console.log("Caller balance after withdrawing stake is :", caller4thBalance);
        
        // Tested Digest generated with Sepolia
        // 0x558685c04fd884b29b1859a1491440049f6dd92b63437b3bc7479aab2244b738
        // Tested Signature generated with Sepolia
        // bytes memory sig = hex"ebc148151badd068444cd48618eb536e1009c6369dcaf8bf0d895cc702dbb1c06df3abcbf5f092478f73e68aa68a8c6cda67b5d28d29eee4c35a753ccf843ab61b";
        // DiamondInteract(address(diamond)).executeTokenUpdate(sig, address(token), block.timestamp + 365 days);
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