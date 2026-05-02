// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/LuxeLendRWA.sol";

contract LuxeLendRWATest is Test {
    LuxeLendRWA public luxeLend;
    address public admin = address(1);
    address public user = address(2);

    function setUp() public {
        vm.prank(admin);
        luxeLend = new LuxeLendRWA();
    }

    function test_ContractName() public view {
        assertEq(luxeLend.name(), "LuxeLend Real World Assets");
    }

    function test_FailOnlyAdminCanUpdateValuation() public {
        vm.prank(user);
        vm.expectRevert();
        luxeLend.updateValuation(1, 1000000);
    }

    function test_BorrowAgainstProperty() public {
        uint256 propertyId = 101;
        uint256 valuation = 1000000;
        
        vm.prank(admin);
        luxeLend.updateValuation(propertyId, valuation);

        vm.prank(user);
        luxeLend.borrowAgainstProperty(propertyId);

        assertEq(luxeLend.borrowedAmount(user), 600000);
    }
}