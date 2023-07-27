// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
	FundMe fundMe;

	address MOCK_USER = makeAddr("fake-user");

	uint256 constant SEND_VALUE = 0.1 ether; // 0.1 ETH

	uint256 constant STARTING_BALANCE = 1 ether;

	// uint256 public constant GAS_PRICE = 1;

	modifier funded {
		vm.prank(MOCK_USER);
		fundMe.fund{value: SEND_VALUE}();
		_;
	}

	function setUp() external {
		DeployFundMe deployFundMeInstance = new DeployFundMe();
		fundMe = deployFundMeInstance.run();
		vm.deal(MOCK_USER, STARTING_BALANCE); // Funding MOCK_USER with some starting balance
	}

	function testMinimumUSDInFundMe() public {
		assertEq(fundMe.MINIMUM_USD(), 5 * 1e18);
	}

	function testOwnerIsMsgSender() public {
		assertEq(fundMe.getOwner(), msg.sender);
	}

	function testPriceFeedVersionIsAccurate() public {
		uint256 version = fundMe.getVersion();
		assertEq(version, 4);
	}

	function testFundFailsWithoutEnoughETH() public {
		vm.expectRevert(); // Fails if there is no revert
		fundMe.fund(); // 0 ETH sent
	}

	function testFundUpdatesFundedDataStuctures() public {
		vm.prank(MOCK_USER); // Next TX call will be sent by MOCK_USER
		fundMe.fund{value: SEND_VALUE}(); // 0.1 ETH
		uint256 amountFunded = fundMe.getAddressToAmountFunded(MOCK_USER);
		assertEq(amountFunded, SEND_VALUE);
	}

	function testFunderArrayUpdatesWithNewFunder() public funded { // using funded modifier here
		address funder = fundMe.getFunder(0);
		assertEq(funder, MOCK_USER);
	}

	function testOnlyOwnerCanWithdraw() public funded {
		vm.prank(MOCK_USER);
		vm.expectRevert();
		fundMe.withdraw();
	}

    function testWithdrawFromASingleFunder() public funded {
        // Arrange
        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.getOwner().balance;

        // vm.txGasPrice(GAS_PRICE);
        // uint256 gasStart = gasleft();

        // Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        // uint256 gasEnd = gasleft();
        // uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;

        // Assert
        uint256 endingFundMeBalance = address(fundMe).balance;
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance // + gasUsed
        );
    }

    function testWithDrawFromMultipleFunders() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders + startingFunderIndex; i++) {
            // we get hoax from forge std cheats
            // hoax => same as doing a prank + deal
            hoax(address(i), STARTING_BALANCE);
            console.log(address(i));
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.getOwner().balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        assertEq(address(fundMe).balance, 0);
        assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
        assert(((numberOfFunders + 1) * SEND_VALUE) == (fundMe.getOwner().balance - startingOwnerBalance));
    }

    function testWithDrawFromMultipleFundersCheaper() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders + startingFunderIndex; i++) {
            // we get hoax from forge std cheats
            // hoax => same as doing a prank + deal
            hoax(address(i), STARTING_BALANCE);
            console.log(address(i));
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.getOwner().balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        assertEq(address(fundMe).balance, 0);
        assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
        assert(((numberOfFunders + 1) * SEND_VALUE) == (fundMe.getOwner().balance - startingOwnerBalance));
    }
}





