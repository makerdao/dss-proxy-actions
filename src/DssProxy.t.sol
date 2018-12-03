pragma solidity >=0.5.0;

import "ds-test/test.sol";

import "./DssProxy.sol";

import {DssDeployTest, CdpLib, CdpRegistry, CdpHandler, DSProxyFactory, DSProxy} from "mcd-cdp-handler/CdpHandler.t.sol";

contract ProxyCalls {
    DSProxy proxy;
    address proxyLib;

    function open(address) public returns (address payable addr) {
        bytes memory response = proxy.execute(proxyLib, msg.data);
        assembly {
            addr := mload(add(response, 0x20))
        }
    }

    function lockETH(address, address, address, address) public payable {
        (bool success,) = address(proxy).call.value(msg.value)(abi.encodeWithSignature("execute(address,bytes)", proxyLib, msg.data));
        require(success, "");
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
        (bool success,) = address(proxy).call.value(msg.value)(abi.encodeWithSignature("execute(address,bytes)", proxyLib, msg.data));
        require(success, "");
    }

    function openLockETHAndDraw(address, address, address, address, address, uint) public payable returns (address payable addr) {
        address payable target = address(proxy);
        bytes memory data = abi.encodeWithSignature("execute(address,bytes)", proxyLib, msg.data);
        assembly {
            let succeeded := call(sub(gas, 5000), target, callvalue, add(data, 0x20), mload(data), 0, 0)
            let size := returndatasize
            let response := mload(0x40)
            mstore(0x40, add(response, and(add(add(size, 0x20), 0x1f), not(0x1f))))
            mstore(response, size)
            returndatacopy(add(response, 0x20), 0, size)

            addr := mload(add(response, 0x60))

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

    function openLockGemAndDraw(address, address, address, address, address, bytes32, uint, uint) public returns (address payable addr) {
        bytes memory response = proxy.execute(proxyLib, msg.data);
        assembly {
            addr := mload(add(response, 0x20))
        }
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
        proxyLib = address(new DssProxy());
        proxy = DSProxy(factory.build());
    }

    function ink(bytes32 ilk, bytes32 urn) public view returns (uint inkV) {
        (inkV,) = vat.urns(ilk, urn);
    }

    function testDssProxyCreateCDP() public {
        CdpHandler handler = CdpHandler(this.open(address(cdpRegistry)));
        assertEq(handler.owner(), address(proxy));
        assertTrue(cdpRegistry.inRegistry(address(handler)));
    }

    function testDssProxyLockETH() public {
        deploy();
        uint initialBalance = address(this).balance;
        CdpHandler handler = CdpHandler(this.open(address(cdpRegistry)));
        assertEq(ink("ETH", bytes32(bytes20(address(handler)))), 0);
        this.lockETH.value(2 ether)(address(handler), address(cdpLib), address(ethJoin), address(pit));
        assertEq(ink("ETH", bytes32(bytes20(address(handler)))), 2 ether);
        assertEq(address(this).balance, initialBalance - 2 ether);
    }

    function testDssProxyLockGem() public {
        deploy();
        dgx.mint(5 ether);
        CdpHandler handler = CdpHandler(this.open(address(cdpRegistry)));
        dgx.approve(address(proxy), 2 ether);
        assertEq(ink("DGX", bytes32(bytes20(address(handler)))), 0);
        this.lockGem(address(handler), address(cdpLib), address(dgxJoin), address(pit), "DGX", 2 ether);
        assertEq(ink("DGX", bytes32(bytes20(address(handler)))), 2 ether);
        assertEq(dgx.balanceOf(address(this)), 3 ether);
    }

    function testDssProxyfreeETH() public {
        deploy();
        uint initialBalance = address(this).balance;
        CdpHandler handler = CdpHandler(this.open(address(cdpRegistry)));
        this.lockETH.value(2 ether)(address(handler), address(cdpLib), address(ethJoin), address(pit));
        this.freeETH(address(handler), address(cdpLib), address(ethJoin), address(pit), 1 ether);
        assertEq(ink("ETH", bytes32(bytes20(address(handler)))), 1 ether);
        assertEq(address(this).balance, initialBalance - 1 ether);
    }

    function testDssProxyfreeGem() public {
        deploy();
        dgx.mint(5 ether);
        CdpHandler handler = CdpHandler(this.open(address(cdpRegistry)));
        dgx.approve(address(proxy), 2 ether);
        this.lockGem(address(handler), address(cdpLib), address(dgxJoin), address(pit), "DGX", 2 ether);
        this.freeGem(address(handler), address(cdpLib), address(dgxJoin), address(pit), "DGX", 1 ether);
        assertEq(ink("DGX", bytes32(bytes20(address(handler)))), 1 ether);
        assertEq(dgx.balanceOf(address(this)), 4 ether);
    }

    function testDssProxyDraw() public {
        deploy();
        CdpHandler handler = CdpHandler(this.open(address(cdpRegistry)));
        this.lockETH.value(2 ether)(address(handler), address(cdpLib), address(ethJoin), address(pit));
        assertEq(dai.balanceOf(address(this)), 0);
        this.draw(address(handler), address(cdpLib), address(daiJoin), address(pit), "ETH", 300 ether);
        assertEq(dai.balanceOf(address(this)), 300 ether);
        (, uint art) = vat.urns("ETH", bytes32(bytes20(address(handler))));
        assertEq(art, 300 ether);
    }

    function testDssProxyDrawAfterDrip() public {
        deploy();
        this.file(address(drip), bytes32("ETH"), bytes32("tax"), uint(1.05 * 10 ** 27));
        hevm.warp(now + 1);
        drip.drip("ETH");
        CdpHandler handler = CdpHandler(this.open(address(cdpRegistry)));
        this.lockETH.value(2 ether)(address(handler), address(cdpLib), address(ethJoin), address(pit));
        assertEq(dai.balanceOf(address(this)), 0);
        this.draw(address(handler), address(cdpLib), address(daiJoin), address(pit), "ETH", 300 ether);
        assertEq(dai.balanceOf(address(this)), 300 ether);
        (, uint art) = vat.urns("ETH", bytes32(bytes20(address(handler))));
        assertEq(art, mul(300 ether, ONE) / (1.05 * 10 ** 27) + 1); // Extra wei due rounding
    }

    function testDssProxyWipe() public {
        deploy();
        CdpHandler handler = CdpHandler(this.open(address(cdpRegistry)));
        this.lockETH.value(2 ether)(address(handler), address(cdpLib), address(ethJoin), address(pit));
        this.draw(address(handler), address(cdpLib), address(daiJoin), address(pit), "ETH", 300 ether);
        dai.approve(address(proxy), 100 ether);
        this.wipe(address(handler), address(cdpLib), address(daiJoin), address(pit), "ETH", 100 ether);
        assertEq(dai.balanceOf(address(this)), 200 ether);
    }

    function testDssProxyWipeAfterDrip() public {
        deploy();
        this.file(address(drip), bytes32("ETH"), bytes32("tax"), uint(1.05 * 10 ** 27));
        hevm.warp(now + 1);
        drip.drip("ETH");
        CdpHandler handler = CdpHandler(this.open(address(cdpRegistry)));
        this.lockETH.value(2 ether)(address(handler), address(cdpLib), address(ethJoin), address(pit));
        this.draw(address(handler), address(cdpLib), address(daiJoin), address(pit), "ETH", 300 ether);
        dai.approve(address(proxy), 100 ether);
        this.wipe(address(handler), address(cdpLib), address(daiJoin), address(pit), "ETH", 100 ether);
        assertEq(dai.balanceOf(address(this)), 200 ether);
        (, uint art) = vat.urns("ETH", bytes32(bytes20(address(handler))));
        assertEq(art, mul(200 ether, ONE) / (1.05 * 10 ** 27) + 1);
    }

    function testDssProxyWipeAllAfterDrip() public {
        deploy();
        this.file(address(drip), bytes32("ETH"), bytes32("tax"), uint(1.05 * 10 ** 27));
        hevm.warp(now + 1);
        drip.drip("ETH");
        CdpHandler handler = CdpHandler(this.open(address(cdpRegistry)));
        this.lockETH.value(2 ether)(address(handler), address(cdpLib), address(ethJoin), address(pit));
        this.draw(address(handler), address(cdpLib), address(daiJoin), address(pit), "ETH", 300 ether);
        dai.approve(address(proxy), 300 ether);
        this.wipe(address(handler), address(cdpLib), address(daiJoin), address(pit), "ETH", 300 ether);
        (, uint art) = vat.urns("ETH", bytes32(bytes20(address(handler))));
        assertEq(art, 0);
    }

    function testDssProxyWipeAllAfterDrip2() public {
        deploy();
        this.file(address(drip), bytes32("ETH"), bytes32("tax"), uint(1.05 * 10 ** 27));
        hevm.warp(now + 1);
        drip.drip("ETH");
        CdpHandler handler = CdpHandler(this.open(address(cdpRegistry)));
        uint times = 30;
        this.lockETH.value(2 ether * times)(address(handler), address(cdpLib), address(ethJoin), address(pit));
        for (uint i = 0; i < times; i++) {
            this.draw(address(handler), address(cdpLib), address(daiJoin), address(pit), "ETH", 300 ether);
        }        
        dai.approve(address(proxy), 300 ether * times);
        this.wipe(address(handler), address(cdpLib), address(daiJoin), address(pit), "ETH", 300 ether * times);
        (, uint art) = vat.urns("ETH", bytes32(bytes20(address(handler))));
        assertEq(art, 0);
    }

    function testDssProxyLockETHAndDraw() public {
        deploy();
        CdpHandler handler = CdpHandler(this.open(address(cdpRegistry)));
        uint initialBalance = address(this).balance;
        assertEq(ink("ETH", bytes32(bytes20(address(handler)))), 0);
        assertEq(dai.balanceOf(address(this)), 0);
        this.lockETHAndDraw.value(2 ether)(address(handler), address(cdpLib), address(ethJoin), address(daiJoin), address(pit), 300 ether);
        assertEq(ink("ETH", bytes32(bytes20(address(handler)))), 2 ether);
        assertEq(dai.balanceOf(address(this)), 300 ether);
        assertEq(address(this).balance, initialBalance - 2 ether);
    }

    function testDssProxyOpenLockETHAndDraw() public {
        deploy();
        uint initialBalance = address(this).balance;
        assertEq(dai.balanceOf(address(this)), 0);
        CdpHandler handler = CdpHandler(this.openLockETHAndDraw.value(2 ether)(address(cdpRegistry), address(cdpLib), address(ethJoin), address(daiJoin), address(pit), 300 ether));
        assertEq(ink("ETH", bytes32(bytes20(address(handler)))), 2 ether);
        assertEq(dai.balanceOf(address(this)), 300 ether);
        assertEq(address(this).balance, initialBalance - 2 ether);
    }

    function testDssProxyLockGemAndDraw() public {
        deploy();
        dgx.mint(5 ether);
        CdpHandler handler = CdpHandler(this.open(address(cdpRegistry)));
        dgx.approve(address(proxy), 2 ether);
        assertEq(ink("DGX", bytes32(bytes20(address(handler)))), 0);
        assertEq(dai.balanceOf(address(this)), 0);
        this.lockGemAndDraw(address(handler), address(cdpLib), address(dgxJoin), address(daiJoin), address(pit), "DGX", 2 ether, 10 ether);
        assertEq(ink("DGX", bytes32(bytes20(address(handler)))), 2 ether);
        assertEq(dai.balanceOf(address(this)), 10 ether);
        assertEq(dgx.balanceOf(address(this)), 3 ether);
    }

    function testDssProxyOpenLockGemAndDraw() public {
        deploy();
        dgx.mint(5 ether);
        dgx.approve(address(proxy), 2 ether);
        assertEq(dai.balanceOf(address(this)), 0);
        CdpHandler handler = CdpHandler(this.openLockGemAndDraw(address(cdpRegistry), address(cdpLib), address(dgxJoin), address(daiJoin), address(pit), "DGX", 2 ether, 10 ether));
        assertEq(ink("DGX", bytes32(bytes20(address(handler)))), 2 ether);
        assertEq(dai.balanceOf(address(this)), 10 ether);
        assertEq(dgx.balanceOf(address(this)), 3 ether);
    }

    function testDssProxyWipeAndFreeETH() public {
        deploy();
        CdpHandler handler = CdpHandler(this.open(address(cdpRegistry)));
        uint initialBalance = address(this).balance;
        this.lockETHAndDraw.value(2 ether)(address(handler), address(cdpLib), address(ethJoin), address(daiJoin), address(pit), 300 ether);
        dai.approve(address(proxy), 250 ether);
        this.wipeAndFreeETH(address(handler), address(cdpLib), address(ethJoin), address(daiJoin), address(pit), 1.5 ether, 250 ether);
        assertEq(ink("ETH", bytes32(bytes20(address(handler)))), 0.5 ether);
        assertEq(dai.balanceOf(address(this)), 50 ether);
        assertEq(address(this).balance, initialBalance - 0.5 ether);
    }

    function testDssProxyWipeAndFreeGem() public {
        deploy();
        dgx.mint(5 ether);
        CdpHandler handler = CdpHandler(this.open(address(cdpRegistry)));
        dgx.approve(address(proxy), 2 ether);
        this.lockGemAndDraw(address(handler), address(cdpLib), address(dgxJoin), address(daiJoin), address(pit), "DGX", 2 ether, 10 ether);
        dai.approve(address(proxy), 8 ether);
        this.wipeAndFreeGem(address(handler), address(cdpLib), address(dgxJoin), address(daiJoin), address(pit), "DGX", 1.5 ether, 8 ether);
        assertEq(ink("DGX", bytes32(bytes20(address(handler)))), 0.5 ether);
        assertEq(dai.balanceOf(address(this)), 2 ether);
        assertEq(dgx.balanceOf(address(this)), 4.5 ether);
    }
}
