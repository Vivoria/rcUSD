// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Vault.sol";
import "../src/RCUSD.sol";
import "../src/MockRealTProperty.sol";

contract VaultTest is Test {
    
    PersonalVault vault;
    RCUSD rcUSD;
    RealTProperty monicaPropertyToken;
    address admin = address(1);
    address deployer = address(2);
    address user = address(3);
    

    function setUp() public {
        rcUSD = new RCUSD(admin);
        
        vm.startPrank(deployer);
        monicaPropertyToken = new RealTProperty("Monica", "Monica", 0);
        vm.stopPrank();

        vm.startPrank(user);
        vault = new PersonalVault(address(monicaPropertyToken), address(rcUSD));

        vm.stopPrank();
    }

    

}
