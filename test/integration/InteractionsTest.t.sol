// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

contract InteractionsTest is Test {
	FundMe public fundMe;
	HelperConfig public helperConfig;

	uint256 public constant SEND_VALUE = 0.1 ether; // 0.1 ETH
	uint256 public constant STARTING_BALANCE = 1 ether;
	uint256 public constant GAS_PRICE = 1;
	address USER_MOCK = address(1);

	function setUp() external {
		DeployFundMe deployFundMeInstance = new DeployFundMe();
		fundMe = deployFundMeInstance.run();
		vm.deal(USER_MOCK, STARTING_BALANCE);
	}

	function testUserCanFundAndOwnerWithdraw() public {
		FundFundMe fundFundMeInstance = new FundFundMe();
        fundFundMeInstance.fundFundMe(address(fundMe));

        WithdrawFundMe withdrawFundMeInstance = new WithdrawFundMe();
        withdrawFundMeInstance.withdrawFundMe(address(fundMe));

        assert(address(fundMe).balance == 0);
	}
}