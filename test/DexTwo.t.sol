// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {DexTwo, SwappableTokenTwo} from "../src/DexTwo.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DexTwoTest is Test {
    SwappableTokenTwo public swappabletoken1;
    SwappableTokenTwo public swappabletoken2;
    
    DexTwo public dexTwo;
    address attacker = makeAddr("attacker");

    function setUp() public {
        dexTwo = new DexTwo();
        swappabletoken1 = new SwappableTokenTwo(address(dexTwo),"Swap","SW", 110);
        vm.label(address(swappabletoken1), "Token 1");
        swappabletoken2 = new SwappableTokenTwo(address(dexTwo),"Swap","SW", 110);
        vm.label(address(swappabletoken2), "Token 2");
        dexTwo.setTokens(address(swappabletoken1), address(swappabletoken2));

        dexTwo.approve(address(dexTwo), 100);
        dexTwo.add_liquidity(address(swappabletoken1), 100);
        dexTwo.add_liquidity(address(swappabletoken2), 100);

        vm.label(attacker, "Attacker");
        // Set up the attacker with some initial balance
        swappabletoken1.transfer(attacker, 10);
        swappabletoken2.transfer(attacker, 10);

        //DO_NOT_TOUCH
    }

    function test_Exploit() public {
       //Execute the attacker here.
     

        is_Drained();
    }

    function is_Drained () internal view{
        require(swappabletoken1.balanceOf(address(dexTwo)) == 0);
        require(swappabletoken2.balanceOf(address(dexTwo)) == 0);
    }

}

