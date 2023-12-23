//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
 
import {Test,console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe,WithdrawFundMe} from "../../script/Interactions.s.sol";

contract InterationsTest  is Test {
    FundMe fundMe;
    uint256 number ;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether ;
    uint256 constant STARTING_BALANCE= 10 ether ;//used to set ether 
    uint256 constant GAS_PRICE = 1;///setting GasPrice for vm.txGasPrice

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        //  fundMe = new FundMe( 0x694AA1769357215DE4FAC081bf1f309aDC325306);
        // number =2 ;
        vm.deal(USER,STARTING_BALANCE);

    }
    function testUserCanFundInteractions() public {
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe));

        WithdrawFundMe withDrawFundMe = new WithdrawFundMe();
        withDrawFundMe.withdrawFundMe(address(fundMe));
        assert(address(fundMe).balance == 0);
       
    }
}