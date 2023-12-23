//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {FundMe} from "../src/FundMe.sol";
import {Script} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";



contract DeployFundMe is Script{
    FundMe fundMe;
    HelperConfig helperConfig = new HelperConfig();
     address ethUsdPriceFeed = helperConfig.activeNetworkConfig();
    
    function run()  external returns (FundMe) {
        vm.startBroadcast();
         fundMe = new FundMe( ethUsdPriceFeed);
        vm.stopBroadcast();
        return fundMe;

    }

    

}