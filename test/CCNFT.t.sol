// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {BUSD} from "../src/BUSD.sol";
import {CCNFT} from "../src/CCNFT.sol";


contract CCNFTTest is Test {
    address deployer;
    address c1;
    address c2;
    address funds;
    address fees;
    BUSD busd;
    CCNFT ccnft;

   
    uint256 constant VALOR_NFT = 100 * 10 ** 18;



    function setUp() public {

        deployer = makeAddr("deployer"); 
        c1 = makeAddr("c1"); 
        c2 = makeAddr("c2"); 
        funds = makeAddr("funds"); 
        fees = makeAddr("fees"); 

        vm.startPrank(deployer);
        busd = new BUSD();
        ccnft = new CCNFT();
        vm.stopPrank();
    }


    function testSetFundsCollector() public {
        vm.prank(deployer); 
        ccnft.setFundsCollector(funds);
        assertEq(ccnft.fundsCollector(), funds);
    }


    function testSetFeesCollector() public {
        vm.prank(deployer);
        ccnft.setFeesCollector(fees);
        assertEq(ccnft.feesCollector(), fees);
    }


    function testSetProfitToPay() public {
        vm.prank(deployer);
        ccnft.setProfitToPay(500); 
        assertEq(ccnft.profitToPay(), 500);
    }


    function testSetCanBuy() public {
        vm.startPrank(deployer);
        ccnft.setCanBuy(true);
        assertEq(ccnft.canBuy(), true);

        ccnft.setCanBuy(false);
        assertEq(ccnft.canBuy(), false);
        vm.stopPrank();
    }


    function testSetCanTrade() public {
        vm.startPrank(deployer);
        ccnft.setCanTrade(true);
        assertEq(ccnft.canTrade(), true);

        ccnft.setCanTrade(false);
        assertEq(ccnft.canTrade(), false);
        vm.stopPrank();
    }


    function testSetCanClaim() public {
        vm.startPrank(deployer);
        ccnft.setCanClaim(true);
        assertEq(ccnft.canClaim(), true);

        ccnft.setCanClaim(false);
        assertEq(ccnft.canClaim(), false);
        vm.stopPrank();
    }


    function testSetMaxValueToRaise() public {
        vm.startPrank(deployer);
        ccnft.setMaxValueToRaise(1000 * 10 ** 18);
        assertEq(ccnft.maxValueToRaise(), 1000 * 10 ** 18);

        ccnft.setMaxValueToRaise(5000000 * 10 ** 18);
        assertEq(ccnft.maxValueToRaise(), 5000000 * 10 ** 18);

        ccnft.setMaxValueToRaise(0);
        assertEq(ccnft.maxValueToRaise(), 0);
        vm.stopPrank();
    }


    function testAddValidValues() public {
       
        assertEq(ccnft.validValues(VALOR_NFT), false);

        vm.startPrank(deployer);
        ccnft.addValidValues(VALOR_NFT);
        ccnft.addValidValues(500 * 10 ** 18);
        ccnft.addValidValues(1000 * 10 ** 18);
        vm.stopPrank();

        assertEq(ccnft.validValues(VALOR_NFT), true);
        assertEq(ccnft.validValues(500 * 10 ** 18), true);
        assertEq(ccnft.validValues(1000 * 10 ** 18), true);
       
        assertEq(ccnft.validValues(777), false);
    }


    function testSetMaxBatchCount() public {
        vm.prank(deployer);
        ccnft.setMaxBatchCount(10);
        assertEq(ccnft.maxBatchCount(), 10);
    }


    function testSetBuyFee() public {
        vm.prank(deployer);
        ccnft.setBuyFee(100); 
        assertEq(ccnft.buyFee(), 100);
    }


    function testSetTradeFee() public {
        vm.prank(deployer);
        ccnft.setTradeFee(200); 
        assertEq(ccnft.tradeFee(), 200);
    }

    function testCannotTradeWhenCanTradeIsFalse() public {
        assertEq(ccnft.canTrade(), false);

        vm.expectRevert("No se permite");
        vm.prank(c1);
        ccnft.trade(0);
    }


    function testCannotTradeWhenTokenDoesNotExist() public {
        vm.prank(deployer);
        ccnft.setCanTrade(true);


        vm.expectRevert("No existe el token");
        vm.prank(c1);
        ccnft.trade(999);
    }



    function configurarTodo() internal {
        vm.startPrank(deployer);
        ccnft.setFundsToken(address(busd));
        ccnft.setFundsCollector(funds);
        ccnft.setFeesCollector(fees);
        ccnft.setCanBuy(true);
        ccnft.setCanTrade(true);
        ccnft.setCanClaim(true);
        ccnft.setMaxBatchCount(10);
        ccnft.setMaxValueToRaise(1000000 * 10 ** 18);
        ccnft.addValidValues(VALOR_NFT);
        ccnft.setBuyFee(100); 
        ccnft.setTradeFee(200); 
        ccnft.setProfitToPay(500); 

        busd.transfer(c1, 1000 * 10 ** 18);
        busd.transfer(c2, 1000 * 10 ** 18);
        vm.stopPrank();


        vm.prank(c1);
        busd.approve(address(ccnft), 1000 * 10 ** 18);
        vm.prank(c2);
        busd.approve(address(ccnft), 1000 * 10 ** 18);
    }


    function testBuy() public {
        configurarTodo();

        vm.prank(c1);
        ccnft.buy(VALOR_NFT, 2);

   
        assertEq(ccnft.balanceOf(c1), 2);
        assertEq(ccnft.ownerOf(0), c1);
        assertEq(ccnft.ownerOf(1), c1);
        assertEq(ccnft.values(0), VALOR_NFT);
        assertEq(ccnft.totalValue(), 200 * 10 ** 18);


        assertEq(busd.balanceOf(funds), 200 * 10 ** 18);
        assertEq(busd.balanceOf(fees), 2 * 10 ** 18);
        assertEq(busd.balanceOf(c1), 798 * 10 ** 18);
    }


    function testCannotBuyWhenCanBuyIsFalse() public {
        configurarTodo();
        vm.prank(deployer);
        ccnft.setCanBuy(false);

        vm.expectRevert("No se permite comprar");
        vm.prank(c1);
        ccnft.buy(VALOR_NFT, 1);
    }


    function testCannotBuyWithoutApprove() public {
        configurarTodo();
        vm.prank(c1);
        busd.approve(address(ccnft), 0); 

        vm.expectRevert(); 
        vm.prank(c1);
        ccnft.buy(VALOR_NFT, 1);
    }


    function testPutOnSaleAndTrade() public {
        configurarTodo();

        vm.startPrank(c1);
        ccnft.buy(VALOR_NFT, 1); 
        ccnft.putOnSale(0, 150 * 10 ** 18); 
        vm.stopPrank();

        (bool enVenta, uint256 precio) = ccnft.tokensOnSale(0);
        assertEq(enVenta, true);
        assertEq(precio, 150 * 10 ** 18);
        assertEq(ccnft.listTokensOnSale(0), 0);

        uint256 saldoC1Antes = busd.balanceOf(c1);

        vm.prank(c2);
        ccnft.trade(0);


        assertEq(ccnft.ownerOf(0), c2);
        (enVenta, precio) = ccnft.tokensOnSale(0);
        assertEq(enVenta, false);
        assertEq(precio, 0);


        assertEq(busd.balanceOf(c1), saldoC1Antes + 150 * 10 ** 18);
        assertEq(busd.balanceOf(c2), 1000 * 10 ** 18 - 152 * 10 ** 18);
    }


    function testCannotTradeOwnToken() public {
        configurarTodo();

        vm.startPrank(c1);
        ccnft.buy(VALOR_NFT, 1);
        ccnft.putOnSale(0, 150 * 10 ** 18);

        vm.expectRevert("Buyer is the Seller");
        ccnft.trade(0);
        vm.stopPrank();
    }


    function testClaim() public {
        configurarTodo();

        vm.prank(c1);
        ccnft.buy(VALOR_NFT, 1);


        vm.prank(deployer);
        busd.transfer(funds, 100 * 10 ** 18);
        vm.prank(funds);
        busd.approve(address(ccnft), 1000 * 10 ** 18);

        uint256 saldoAntes = busd.balanceOf(c1);

        uint256[] memory lista = new uint256[](1);
        lista[0] = 0;
        vm.prank(c1);
        ccnft.claim(lista);

        assertEq(ccnft.balanceOf(c1), 0); 
        assertEq(ccnft.totalValue(), 0);
        assertEq(busd.balanceOf(c1), saldoAntes + 105 * 10 ** 18); 
    }

    function testTransferFromIsNotAllowed() public {
        configurarTodo();

        vm.startPrank(c1);
        ccnft.buy(VALOR_NFT, 1);

        vm.expectRevert("Not Allowed");
        ccnft.transferFrom(c1, c2, 0);
        vm.stopPrank();
    }
}
