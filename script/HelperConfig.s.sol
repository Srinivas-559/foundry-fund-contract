//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
//Deploy Mocks whwn we run on local anvil chains 
//keep the track of address on diffferent chains 
import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_ANSWER = 2000e8;


     struct NetworkConfig  {
         address priceFeed ;//ETH/USD priceFeed address 
     }
     NetworkConfig public activeNetworkConfig;

     constructor(){
        if(block.chainid == 11155111){
            activeNetworkConfig = getSepoliaEthconfig();

        }
        else if(block.chainid==1){
            activeNetworkConfig = getMainnetEthConfig();
        }
        
         else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
     }
    //If we are on local chain we will deploy mocks 
    //Otherwise will will grab an address from the live networks 
    function getSepoliaEthconfig() public pure returns( NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed:0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
        //pricefeed address 
    }
    function getOrCreateAnvilEthConfig() public  returns(NetworkConfig memory) {
        if(activeNetworkConfig.priceFeed != address(0)){
            return activeNetworkConfig;
        }
        
        //Deplying mocks
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS,INITIAL_ANSWER);
        vm.stopBroadcast();
        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed:address(mockPriceFeed)
        });
        return anvilConfig;
        //pricefeed address 
    }
    function getMainnetEthConfig() public pure returns(NetworkConfig memory){
        NetworkConfig memory mainnetConfig = NetworkConfig( {
            priceFeed:0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return mainnetConfig;
    }


}
