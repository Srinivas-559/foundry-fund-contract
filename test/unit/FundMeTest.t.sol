//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
 
import {Test,console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
        //we->fundMe ->FundMe
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
    function testMinimumDollarIsFive() public {
        assertEq(fundMe.MINIMUM_USD(),5e18);
     }

    function testOwnerIsMsgSender() public {
        assertEq(fundMe.i_owner(),msg.sender);
    }
    function testPriceFeedVersionIsAccurate() public {
        uint256 fundMeVersion = fundMe.getVersion();
        assertEq(fundMeVersion, 4);

    }  
    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert();
        fundMe.fund();
    }
    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER);
        fundMe.fund{value:SEND_VALUE}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded,SEND_VALUE);

    }
    function testAddsFundersToArrayOfFunders() public {
        vm.prank(USER);
        fundMe.fund{value:SEND_VALUE}();
        address funder = fundMe.getFunder(0);
        assertEq(funder,USER);
    }

    modifier funded(){
        vm.prank(USER);
        fundMe.fund{value:SEND_VALUE}();
        _;
    }
    function testOnlyOwnerCanWithdraw() public funded{
        
        vm.expectRevert();
        fundMe.withdraw();
    }
    function testWithdrawWithASingleFunder() public funded{
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = fundMe.getBalance(); 
        // uint256 GasStart = gasleft();


        vm.txGasPrice(GAS_PRICE);//In envil the gas proce is going to be 0 ,to simulate the transactions to use some  gas proce we use this function from foundry 

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        // uint256 GasEnd = gasleft();
        // console.log("Gas end",GasEnd);
        // console.log("GasUsed",GasStart-GasEnd);

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = fundMe.getBalance();
        assertEq(endingFundMeBalance,0);

        assertEq(startingFundMeBalance + startingOwnerBalance,endingOwnerBalance);


    }
    function testWithdrawFromMultipleFunders() public funded {
        uint160 numberOfFunders =10;
        uint160 startingFunderIndex = 1;
        for (startingFunderIndex; startingFunderIndex < numberOfFunders; startingFunderIndex++){
            //vm.prank()
            //vm.deal();
            //addres()
            hoax(address(startingFunderIndex),SEND_VALUE);
            fundMe.fund{value:SEND_VALUE}();
            
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = fundMe.getBalance();
         
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();



        assert(address(fundMe).balance ==0);
        assert(startingFundMeBalance+startingOwnerBalance==fundMe.getOwner().balance);


    }
    function testWithdrawFromMultipleFundersCheaper() public funded {
        uint160 numberOfFunders =10;
        uint160 startingFunderIndex = 1;
        for (startingFunderIndex; startingFunderIndex < numberOfFunders; startingFunderIndex++){
            //vm.prank()
            //vm.deal();
            //addres()
            hoax(address(startingFunderIndex),SEND_VALUE);
            fundMe.fund{value:SEND_VALUE}();
            
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = fundMe.getBalance();
         
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithDraw();
        vm.stopPrank();



        assert(address(fundMe).balance ==0);
        assert(startingFundMeBalance+startingOwnerBalance==fundMe.getOwner().balance);


    }
        

}