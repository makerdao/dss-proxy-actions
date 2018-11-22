pragma solidity ^0.4.24;

import "ds-test/test.sol";

import "./DssProxy.sol";

import {DssDeployTest, CdpLib, CdpRegistry, CdpHandler, DSProxyFactory, DSProxy} from "mcd-cdp-handler/CdpHandler.t.sol";

contract ProxyCalls {
    DSProxy proxy;
    DssProxy proxyLib;

    function open(address) public returns (address) {
        return address(proxy.execute(proxyLib, msg.data));
    }

    function lockETH(address, address, address, address) public payable {
        assert(address(proxy).call.value(msg.value)(bytes4(keccak256("execute(address,bytes)")), proxyLib, uint256(0x40), msg.data.length, msg.data));
    }

    function lockGem(address, address, address, address, bytes32, uint) public {
        proxy.execute(proxyLib, msg.data);
    }

    function freeETH(address, address, address, address, uint) public {
        proxy.execute(proxyLib, msg.data);
    }

    function freeGem(address, address, address, address, bytes32, uint) public {
        proxy.execute(proxyLib, msg.data);
    }

    function draw(address, address, address, address, bytes32, uint) public {
        proxy.execute(proxyLib, msg.data);
    }

    function wipe(address, address, address, address, bytes32, uint) public {
        proxy.execute(proxyLib, msg.data);
    }

    function lockETHAndDraw(address, address, address, address, address, uint) public payable {
        assert(address(proxy).call.value(msg.value)(bytes4(keccak256("execute(address,bytes)")), proxyLib, uint256(0x40), msg.data.length, msg.data));
    }

    function openLockETHAndDraw(address, address, address, address, address, uint) public payable returns (address result) {
        address target = proxy;
        bytes memory calldata = abi.encodeWithSignature("execute(address,bytes)", bytes32(address(proxyLib)), msg.data);
        assembly {
            let succeeded := call(sub(gas, 5000), target, callvalue, add(calldata, 0x20), mload(calldata), 0, 0)
            let size := returndatasize
            let response := mload(0x40)
            mstore(0x40, add(response, and(add(add(size, 0x20), 0x1f), not(0x1f))))
            mstore(response, size)
            returndatacopy(add(response, 0x20), 0, size)

            result := mload(add(response, 0x20))

            switch iszero(succeeded)
            case 1 {
                // throw if delegatecall failed
                revert(add(response, 0x20), size)
            }
        }
    }

    function lockGemAndDraw(address, address, address, address, address, bytes32, uint, uint) public {
        proxy.execute(proxyLib, msg.data);
    }

    function openLockGemAndDraw(address, address, address, address, address, bytes32, uint, uint) public returns (address) {
        return address(proxy.execute(proxyLib, msg.data));
    }

    function wipeAndFreeETH(address, address, address, address, address, uint, uint) public {
        proxy.execute(proxyLib, msg.data);
    }

    function wipeAndFreeGem(address, address, address, address, address, bytes32, uint, uint) public {
        proxy.execute(proxyLib, msg.data);
    }
}

contract DssProxyTest is DssDeployTest, ProxyCalls {
    CdpRegistry cdpRegistry;
    CdpLib cdpLib;

    function setUp() public {
        super.setUp();
        cdpRegistry = new CdpRegistry();
        cdpLib = new CdpLib();
        DSProxyFactory factory = new DSProxyFactory();
        proxyLib = new DssProxy();
        proxy = factory.build();
    }

    function ink(bytes32 ilk, address urn) public returns (uint inkV) {
        (inkV,) = vat.urns(ilk, bytes32(urn));
    }

    function testDssProxyCreateCDP() public {
        CdpHandler handler = CdpHandler(this.open(cdpRegistry));
        assertEq(handler.owner(), proxy);
        assertTrue(cdpRegistry.inRegistry(handler));
    }

    function testDssProxyLockETH() public {
        deploy();
        uint initialBalance = address(this).balance;
        CdpHandler handler = CdpHandler(this.open(cdpRegistry));
        assertEq(ink("ETH", handler), 0);
        this.lockETH.value(2 ether)(handler, cdpLib, ethJoin, pit);
        assertEq(ink("ETH", handler), 2 ether);
        assertEq(address(this).balance, initialBalance - 2 ether);
    }

    function testDssProxyLockGem() public {
        deploy();
        dgx.mint(5 ether);
        CdpHandler handler = CdpHandler(this.open(cdpRegistry));
        dgx.approve(proxy, 2 ether);
        assertEq(ink("DGX", handler), 0);
        this.lockGem(handler, cdpLib, dgxJoin, pit, "DGX", 2 ether);
        assertEq(ink("DGX", handler), 2 ether);
        assertEq(dgx.balanceOf(this), 3 ether);
    }

    function testDssProxyfreeETH() public {
        deploy();
        uint initialBalance = address(this).balance;
        CdpHandler handler = CdpHandler(this.open(cdpRegistry));
        this.lockETH.value(2 ether)(handler, cdpLib, ethJoin, pit);
        this.freeETH(handler, cdpLib, ethJoin, pit, 1 ether);
        assertEq(ink("ETH", handler), 1 ether);
        assertEq(address(this).balance, initialBalance - 1 ether);
    }

    function testDssProxyfreeGem() public {
        deploy();
        dgx.mint(5 ether);
        CdpHandler handler = CdpHandler(this.open(cdpRegistry));
        dgx.approve(proxy, 2 ether);
        this.lockGem(handler, cdpLib, dgxJoin, pit, "DGX", 2 ether);
        this.freeGem(handler, cdpLib, dgxJoin, pit, "DGX", 1 ether);
        assertEq(ink("DGX", handler), 1 ether);
        assertEq(dgx.balanceOf(this), 4 ether);
    }

    function testDssProxyDraw() public {
        deploy();
        CdpHandler handler = CdpHandler(this.open(cdpRegistry));
        this.lockETH.value(2 ether)(handler, cdpLib, ethJoin, pit);
        assertEq(dai.balanceOf(this), 0);
        this.draw(handler, cdpLib, daiJoin, pit, "ETH", 300 ether);
        assertEq(dai.balanceOf(this), 300 ether);
        (, uint art) = vat.urns("ETH", bytes32(address(handler)));
        assertEq(art, 300 ether);
    }

    function testDssProxyDrawAfterDrip() public {
        deploy();
        this.file(address(drip), bytes32("ETH"), bytes32("tax"), uint(1.05 * 10 ** 27));
        hevm.warp(now + 1);
        drip.drip("ETH");
        CdpHandler handler = CdpHandler(this.open(cdpRegistry));
        this.lockETH.value(2 ether)(handler, cdpLib, ethJoin, pit);
        assertEq(dai.balanceOf(this), 0);
        this.draw(handler, cdpLib, daiJoin, pit, "ETH", 300 ether);
        assertEq(dai.balanceOf(this), 300 ether);
        (, uint art) = vat.urns("ETH", bytes32(address(handler)));
        assertEq(art, mul(300 ether, ONE) / (1.05 * 10 ** 27) + 1); // Extra wei due rounding
    }

    function testDssProxyWipe() public {
        deploy();
        CdpHandler handler = CdpHandler(this.open(cdpRegistry));
        this.lockETH.value(2 ether)(handler, cdpLib, ethJoin, pit);
        this.draw(handler, cdpLib, daiJoin, pit, "ETH", 300 ether);
        dai.approve(proxy, 100 ether);
        this.wipe(handler, cdpLib, daiJoin, pit, "ETH", 100 ether);
        assertEq(dai.balanceOf(this), 200 ether);
    }

    function testDssProxyWipeAfterDrip() public {
        deploy();
        this.file(address(drip), bytes32("ETH"), bytes32("tax"), uint(1.05 * 10 ** 27));
        hevm.warp(now + 1);
        drip.drip("ETH");
        CdpHandler handler = CdpHandler(this.open(cdpRegistry));
        this.lockETH.value(2 ether)(handler, cdpLib, ethJoin, pit);
        this.draw(handler, cdpLib, daiJoin, pit, "ETH", 300 ether);
        dai.approve(proxy, 100 ether);
        this.wipe(handler, cdpLib, daiJoin, pit, "ETH", 100 ether);
        assertEq(dai.balanceOf(this), 200 ether);
        (, uint art) = vat.urns("ETH", bytes32(address(handler)));
        assertEq(art, mul(200 ether, ONE) / (1.05 * 10 ** 27) + 1);
    }

    function testDssProxyWipeAllAfterDrip() public {
        deploy();
        this.file(address(drip), bytes32("ETH"), bytes32("tax"), uint(1.05 * 10 ** 27));
        hevm.warp(now + 1);
        drip.drip("ETH");
        CdpHandler handler = CdpHandler(this.open(cdpRegistry));
        this.lockETH.value(2 ether)(handler, cdpLib, ethJoin, pit);
        this.draw(handler, cdpLib, daiJoin, pit, "ETH", 300 ether);
        dai.approve(proxy, 300 ether);
        this.wipe(handler, cdpLib, daiJoin, pit, "ETH", 300 ether);
        (, uint art) = vat.urns("ETH", bytes32(address(handler)));
        assertEq(art, 0);
    }

    function testDssProxyWipeAllAfterDrip2() public {
        deploy();
        this.file(address(drip), bytes32("ETH"), bytes32("tax"), uint(1.05 * 10 ** 27));
        hevm.warp(now + 1);
        drip.drip("ETH");
        CdpHandler handler = CdpHandler(this.open(cdpRegistry));
        uint times = 30;
        this.lockETH.value(2 ether * times)(handler, cdpLib, ethJoin, pit);
        for (uint i = 0; i < times; i++) {
            this.draw(handler, cdpLib, daiJoin, pit, "ETH", 300 ether);
        }        
        dai.approve(proxy, 300 ether * times);
        this.wipe(handler, cdpLib, daiJoin, pit, "ETH", 300 ether * times);
        (, uint art) = vat.urns("ETH", bytes32(address(handler)));
        assertEq(art, 0);
    }

    function testDssProxyLockETHAndDraw() public {
        deploy();
        CdpHandler handler = CdpHandler(this.open(cdpRegistry));
        uint initialBalance = address(this).balance;
        assertEq(ink("ETH", handler), 0);
        assertEq(dai.balanceOf(this), 0);
        this.lockETHAndDraw.value(2 ether)(handler, cdpLib, ethJoin, daiJoin, pit, 300 ether);
        assertEq(ink("ETH", handler), 2 ether);
        assertEq(dai.balanceOf(this), 300 ether);
        assertEq(address(this).balance, initialBalance - 2 ether);
    }

    function testDssProxyOpenLockETHAndDraw() public {
        deploy();
        uint initialBalance = address(this).balance;
        assertEq(dai.balanceOf(this), 0);
        CdpHandler handler = CdpHandler(this.openLockETHAndDraw.value(2 ether)(cdpRegistry, cdpLib, ethJoin, daiJoin, pit, 300 ether));
        assertEq(ink("ETH", handler), 2 ether);
        assertEq(dai.balanceOf(this), 300 ether);
        assertEq(address(this).balance, initialBalance - 2 ether);
    }

    function testDssProxyLockGemAndDraw() public {
        deploy();
        dgx.mint(5 ether);
        CdpHandler handler = CdpHandler(this.open(cdpRegistry));
        dgx.approve(proxy, 2 ether);
        assertEq(ink("DGX", handler), 0);
        assertEq(dai.balanceOf(this), 0);
        this.lockGemAndDraw(handler, cdpLib, dgxJoin, daiJoin, pit, "DGX", 2 ether, 10 ether);
        assertEq(ink("DGX", handler), 2 ether);
        assertEq(dai.balanceOf(this), 10 ether);
        assertEq(dgx.balanceOf(this), 3 ether);
    }

    function testDssProxyOpenLockGemAndDraw() public {
        deploy();
        dgx.mint(5 ether);
        dgx.approve(proxy, 2 ether);
        assertEq(dai.balanceOf(this), 0);
        CdpHandler handler = CdpHandler(this.openLockGemAndDraw(cdpRegistry, cdpLib, dgxJoin, daiJoin, pit, "DGX", 2 ether, 10 ether));
        assertEq(ink("DGX", handler), 2 ether);
        assertEq(dai.balanceOf(this), 10 ether);
        assertEq(dgx.balanceOf(this), 3 ether);
    }

    function testDssProxyWipeAndFreeETH() public {
        deploy();
        CdpHandler handler = CdpHandler(this.open(cdpRegistry));
        uint initialBalance = address(this).balance;
        this.lockETHAndDraw.value(2 ether)(handler, cdpLib, ethJoin, daiJoin, pit, 300 ether);
        dai.approve(proxy, 250 ether);
        this.wipeAndFreeETH(handler, cdpLib, ethJoin, daiJoin, pit, 1.5 ether, 250 ether);
        assertEq(ink("ETH", handler), 0.5 ether);
        assertEq(dai.balanceOf(this), 50 ether);
        assertEq(address(this).balance, initialBalance - 0.5 ether);
    }

    function testDssProxyWipeAndFreeGem() public {
        deploy();
        dgx.mint(5 ether);
        CdpHandler handler = CdpHandler(this.open(cdpRegistry));
        dgx.approve(proxy, 2 ether);
        this.lockGemAndDraw(handler, cdpLib, dgxJoin, daiJoin, pit, "DGX", 2 ether, 10 ether);
        dai.approve(proxy, 8 ether);
        this.wipeAndFreeGem(handler, cdpLib, dgxJoin, daiJoin, pit, "DGX", 1.5 ether, 8 ether);
        assertEq(ink("DGX", handler), 0.5 ether);
        assertEq(dai.balanceOf(this), 2 ether);
        assertEq(dgx.balanceOf(this), 4.5 ether);
    }
}
