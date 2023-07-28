// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../contracts/interfaces/IDiamondCut.sol";
import "../contracts/facets/DiamondCutFacet.sol";
import "../contracts/facets/DiamondLoupeFacet.sol";
import "../contracts/facets/OwnershipFacet.sol";
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
}


contract DiamondDeployer is Script, IDiamondCut {
    //contract types of facets to be deployed
    Diamond diamond;
    DiamondCutFacet dCutFacet;
    DiamondLoupeFacet dLoupe;
    OwnershipFacet ownerF;
    Stake stake;
    Token token;
    Vault vault;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);   
        token = new Token("ERC20Token", "ERC");
        vault = new Vault();
        dCutFacet = new DiamondCutFacet();
        diamond = new Diamond(0x7a5863fe6A65377A7cd3F2A6d417F489D9DCF353, address(dCutFacet), address(token), address(vault));
        dLoupe = new DiamondLoupeFacet();
        ownerF = new OwnershipFacet();
        stake = new Stake();

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
        DiamondLoupeFacet(address(diamond)).facetAddresses();
        vault.initializeVault(address(diamond), address(token));
        vm.stopBroadcast();
        // vm.broadcast();
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