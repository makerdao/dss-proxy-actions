pragma solidity >=0.5.0;

import "ds-test/test.sol";

import "./DssProxyActions.sol";

import {DssDeployTestBase} from "dss-deploy/DssDeploy.t.base.sol";
import {DssCdpManager} from "dss-cdp-manager/DssCdpManager.sol";
import {DSProxyFactory, DSProxy} from "ds-proxy/proxy.sol";

contract ProxyCalls {
    DSProxy proxy;
    address proxyLib;

    function open(address, bytes32) public returns (uint cdp) {
        bytes memory response = proxy.execute(proxyLib, msg.data);
        assembly {
            cdp := mload(add(response, 0x20))
        }
    }

    function give(address, uint, address) public {
        proxy.execute(proxyLib, msg.data);
    }

    function allow(address, uint, address, bool) public {
        proxy.execute(proxyLib, msg.data);
    }

    function lockETH(address, address, address, uint) public payable {
        (bool success,) = address(proxy).call.value(msg.value)(abi.encodeWithSignature("execute(address,bytes)", proxyLib, msg.data));
        require(success, "");
    }

    function lockGem(address, address, address, uint, uint) public {
        proxy.execute(proxyLib, msg.data);
    }

    function freeETH(address, address, address, uint, uint) public {
        proxy.execute(proxyLib, msg.data);
    }

    function freeGem(address, address, address, uint, uint) public {
        proxy.execute(proxyLib, msg.data);
    }

    function draw(address, address, address, uint, uint) public {
        proxy.execute(proxyLib, msg.data);
    }

    function wipe(address, address, address, uint, uint) public {
        proxy.execute(proxyLib, msg.data);
    }

    function lockETHAndDraw(address, address, address, address, uint, uint) public payable {
        (bool success,) = address(proxy).call.value(msg.value)(abi.encodeWithSignature("execute(address,bytes)", proxyLib, msg.data));
        require(success, "");
    }

    function openLockETHAndDraw(address, address, address, address, bytes32, uint) public payable returns (uint cdp) {
        address payable target = address(proxy);
        bytes memory data = abi.encodeWithSignature("execute(address,bytes)", proxyLib, msg.data);
        assembly {
            let succeeded := call(sub(gas, 5000), target, callvalue, add(data, 0x20), mload(data), 0, 0)
            let size := returndatasize
            let response := mload(0x40)
            mstore(0x40, add(response, and(add(add(size, 0x20), 0x1f), not(0x1f))))
            mstore(response, size)
            returndatacopy(add(response, 0x20), 0, size)

            cdp := mload(add(response, 0x60))

            switch iszero(succeeded)
            case 1 {
                // throw if delegatecall failed
                revert(add(response, 0x20), size)
            }
        }
    }

    function lockGemAndDraw(address, address, address, address, uint, uint, uint) public {
        proxy.execute(proxyLib, msg.data);
    }

    function openLockGemAndDraw(address, address, address, address, bytes32, uint, uint) public returns (uint cdp) {
        bytes memory response = proxy.execute(proxyLib, msg.data);
        assembly {
            cdp := mload(add(response, 0x20))
        }
    }

    function wipeAndFreeETH(address, address, address, address, uint, uint, uint) public {
        proxy.execute(proxyLib, msg.data);
    }

    function wipeAndFreeGem(address, address, address, address, uint, uint, uint) public {
        proxy.execute(proxyLib, msg.data);
    }
}

contract FakeUser {
    function doMove(
        DssCdpManager manager,
        uint cdp,
        address dst
    ) public {
        manager.move(cdp, dst);
    }
}

contract DssProxyActionsTest is DssDeployTestBase, ProxyCalls {
    DssCdpManager manager;

    function setUp() public {
        super.setUp();
        manager = new DssCdpManager();
        DSProxyFactory factory = new DSProxyFactory();
        proxyLib = address(new DssProxyActions());
        proxy = DSProxy(factory.build());
        deploy();
    }

    function ink(bytes32 ilk, bytes32 urn) public view returns (uint inkV) {
        (inkV,) = vat.urns(ilk, urn);
    }

    function testCreateCDP() public {
        uint cdp = this.open(address(manager), "ETH");
        assertEq(cdp, 1);
        assertEq(manager.lads(cdp), address(proxy));
    }

    function testGiveCDP() public {
        uint cdp = this.open(address(manager), "ETH");
        this.give(address(manager), cdp, address(123));
        assertEq(manager.lads(cdp), address(123));
    }

    function testGiveCDPAllowedUser() public {
        uint cdp = this.open(address(manager), "ETH");
        FakeUser user = new FakeUser();
        this.allow(address(manager), cdp, address(user), true);
        user.doMove(manager, cdp, address(123));
        assertEq(manager.lads(cdp), address(123));
    }

    function testLockETH() public {
        uint initialBalance = address(this).balance;
        uint cdp = this.open(address(manager), "ETH");
        assertEq(ink("ETH", manager.getUrn(cdp)), 0);
        this.lockETH.value(2 ether)(address(manager), address(ethJoin), address(vat), cdp);
        assertEq(ink("ETH", manager.getUrn(cdp)), 2 ether);
        emit log_named_uint("vat.gem", vat.gem("ETH", manager.getUrn(cdp)));
        assertEq(address(this).balance, initialBalance - 2 ether);
    }

    function testLockGem() public {
        dgx.mint(5 ether);
        uint cdp = this.open(address(manager), "DGX");
        dgx.approve(address(proxy), 2 ether);
        assertEq(ink("DGX", manager.getUrn(cdp)), 0);
        this.lockGem(address(manager), address(dgxJoin), address(vat), cdp, 2 ether);
        assertEq(ink("DGX", manager.getUrn(cdp)), 2 ether);
        assertEq(dgx.balanceOf(address(this)), 3 ether);
    }

    function testfreeETH() public {
        uint initialBalance = address(this).balance;
        uint cdp = this.open(address(manager), "ETH");
        this.lockETH.value(2 ether)(address(manager), address(ethJoin), address(vat), cdp);
        this.freeETH(address(manager), address(ethJoin), address(vat), cdp, 1 ether);
        assertEq(ink("ETH", manager.getUrn(cdp)), 1 ether);
        assertEq(address(this).balance, initialBalance - 1 ether);
    }

    function testfreeGem() public {
        dgx.mint(5 ether);
        uint cdp = this.open(address(manager), "DGX");
        dgx.approve(address(proxy), 2 ether);
        this.lockGem(address(manager), address(dgxJoin), address(vat), cdp, 2 ether);
        this.freeGem(address(manager), address(dgxJoin), address(vat), cdp, 1 ether);
        assertEq(ink("DGX", manager.getUrn(cdp)), 1 ether);
        assertEq(dgx.balanceOf(address(this)), 4 ether);
    }

    function testDraw() public {
        uint cdp = this.open(address(manager), "ETH");
        this.lockETH.value(2 ether)(address(manager), address(ethJoin), address(vat), cdp);
        assertEq(dai.balanceOf(address(this)), 0);
        this.draw(address(manager), address(daiJoin), address(vat), cdp, 300 ether);
        assertEq(dai.balanceOf(address(this)), 300 ether);
        (, uint art) = vat.urns("ETH", manager.getUrn(cdp));
        assertEq(art, 300 ether);
    }

    function testDrawAfterDrip() public {
        this.file(address(jug), bytes32("ETH"), bytes32("tax"), uint(1.05 * 10 ** 27));
        hevm.warp(now + 1);
        jug.drip("ETH");
        uint cdp = this.open(address(manager), "ETH");
        this.lockETH.value(2 ether)(address(manager), address(ethJoin), address(vat), cdp);
        assertEq(dai.balanceOf(address(this)), 0);
        this.draw(address(manager), address(daiJoin), address(vat), cdp, 300 ether);
        assertEq(dai.balanceOf(address(this)), 300 ether);
        (, uint art) = vat.urns("ETH", manager.getUrn(cdp));
        assertEq(art, mul(300 ether, ONE) / (1.05 * 10 ** 27) + 1); // Extra wei due rounding
    }

    function testWipe() public {
        uint cdp = this.open(address(manager), "ETH");
        this.lockETH.value(2 ether)(address(manager), address(ethJoin), address(vat), cdp);
        this.draw(address(manager), address(daiJoin), address(vat), cdp, 300 ether);
        dai.approve(address(proxy), 100 ether);
        this.wipe(address(manager), address(daiJoin), address(vat), cdp, 100 ether);
        assertEq(dai.balanceOf(address(this)), 200 ether);
        (, uint art) = vat.urns("ETH", manager.getUrn(cdp));
        assertEq(art, 200 ether);
    }

    function testWipeAfterDrip() public {
        this.file(address(jug), bytes32("ETH"), bytes32("tax"), uint(1.05 * 10 ** 27));
        hevm.warp(now + 1);
        jug.drip("ETH");
        uint cdp = this.open(address(manager), "ETH");
        this.lockETH.value(2 ether)(address(manager), address(ethJoin), address(vat), cdp);
        this.draw(address(manager), address(daiJoin), address(vat), cdp, 300 ether);
        dai.approve(address(proxy), 100 ether);
        this.wipe(address(manager), address(daiJoin), address(vat), cdp, 100 ether);
        assertEq(dai.balanceOf(address(this)), 200 ether);
        (, uint art) = vat.urns("ETH", manager.getUrn(cdp));
        assertEq(art, mul(200 ether, ONE) / (1.05 * 10 ** 27) + 1);
    }

    function testWipeAllAfterDrip() public {
        this.file(address(jug), bytes32("ETH"), bytes32("tax"), uint(1.05 * 10 ** 27));
        hevm.warp(now + 1);
        jug.drip("ETH");
        uint cdp = this.open(address(manager), "ETH");
        this.lockETH.value(2 ether)(address(manager), address(ethJoin), address(vat), cdp);
        this.draw(address(manager), address(daiJoin), address(vat), cdp, 300 ether);
        dai.approve(address(proxy), 300 ether);
        this.wipe(address(manager), address(daiJoin), address(vat), cdp, 300 ether);
        (, uint art) = vat.urns("ETH", manager.getUrn(cdp));
        assertEq(art, 0);
    }

    function testWipeAllAfterDrip2() public {
        this.file(address(jug), bytes32("ETH"), bytes32("tax"), uint(1.05 * 10 ** 27));
        hevm.warp(now + 1);
        jug.drip("ETH");
        uint cdp = this.open(address(manager), "ETH");
        uint times = 30;
        this.lockETH.value(2 ether * times)(address(manager), address(ethJoin), address(vat), cdp);
        for (uint i = 0; i < times; i++) {
            this.draw(address(manager), address(daiJoin), address(vat), cdp, 300 ether);
        }
        dai.approve(address(proxy), 300 ether * times);
        this.wipe(address(manager), address(daiJoin), address(vat), cdp, 300 ether * times);
        (, uint art) = vat.urns("ETH", manager.getUrn(cdp));
        assertEq(art, 0);
    }

    function testLockETHAndDraw() public {
        uint cdp = this.open(address(manager), "ETH");
        uint initialBalance = address(this).balance;
        assertEq(ink("ETH", manager.getUrn(cdp)), 0);
        assertEq(dai.balanceOf(address(this)), 0);
        this.lockETHAndDraw.value(2 ether)(address(manager), address(ethJoin), address(daiJoin), address(vat), cdp, 300 ether);
        assertEq(ink("ETH", manager.getUrn(cdp)), 2 ether);
        assertEq(dai.balanceOf(address(this)), 300 ether);
        assertEq(address(this).balance, initialBalance - 2 ether);
    }

    function testOpenLockETHAndDraw() public {
        uint initialBalance = address(this).balance;
        assertEq(dai.balanceOf(address(this)), 0);
        uint cdp = this.openLockETHAndDraw.value(2 ether)(address(manager), address(ethJoin), address(daiJoin), address(vat), "ETH", 300 ether);
        assertEq(ink("ETH", manager.getUrn(cdp)), 2 ether);
        assertEq(dai.balanceOf(address(this)), 300 ether);
        assertEq(address(this).balance, initialBalance - 2 ether);
    }

    function testLockGemAndDraw() public {
        dgx.mint(5 ether);
        uint cdp = this.open(address(manager), "DGX");
        dgx.approve(address(proxy), 2 ether);
        assertEq(ink("DGX", manager.getUrn(cdp)), 0);
        assertEq(dai.balanceOf(address(this)), 0);
        this.lockGemAndDraw(address(manager), address(dgxJoin), address(daiJoin), address(vat), cdp, 2 ether, 10 ether);
        assertEq(ink("DGX", manager.getUrn(cdp)), 2 ether);
        assertEq(dai.balanceOf(address(this)), 10 ether);
        assertEq(dgx.balanceOf(address(this)), 3 ether);
    }

    function testOpenLockGemAndDraw() public {
        dgx.mint(5 ether);
        dgx.approve(address(proxy), 2 ether);
        assertEq(dai.balanceOf(address(this)), 0);
        uint cdp = this.openLockGemAndDraw(address(manager), address(dgxJoin), address(daiJoin), address(vat), "DGX", 2 ether, 10 ether);
        assertEq(ink("DGX", manager.getUrn(cdp)), 2 ether);
        assertEq(dai.balanceOf(address(this)), 10 ether);
        assertEq(dgx.balanceOf(address(this)), 3 ether);
    }

    function testWipeAndFreeETH() public {
        uint cdp = this.open(address(manager), "ETH");
        uint initialBalance = address(this).balance;
        this.lockETHAndDraw.value(2 ether)(address(manager), address(ethJoin), address(daiJoin), address(vat), cdp, 300 ether);
        dai.approve(address(proxy), 250 ether);
        this.wipeAndFreeETH(address(manager), address(ethJoin), address(daiJoin), address(vat), cdp, 1.5 ether, 250 ether);
        assertEq(ink("ETH", manager.getUrn(cdp)), 0.5 ether);
        assertEq(dai.balanceOf(address(this)), 50 ether);
        assertEq(address(this).balance, initialBalance - 0.5 ether);
    }

    function testWipeAndFreeGem() public {
        dgx.mint(5 ether);
        uint cdp = this.open(address(manager), "DGX");
        dgx.approve(address(proxy), 2 ether);
        this.lockGemAndDraw(address(manager), address(dgxJoin), address(daiJoin), address(vat), cdp, 2 ether, 10 ether);
        dai.approve(address(proxy), 8 ether);
        this.wipeAndFreeGem(address(manager), address(dgxJoin), address(daiJoin), address(vat), cdp, 1.5 ether, 8 ether);
        assertEq(ink("DGX", manager.getUrn(cdp)), 0.5 ether);
        assertEq(dai.balanceOf(address(this)), 2 ether);
        assertEq(dgx.balanceOf(address(this)), 4.5 ether);
    }

    function testPreventHigherDaiOnWipe() public {
        uint cdp = this.open(address(manager), "ETH");
        this.lockETHAndDraw.value(2 ether)(address(manager), address(ethJoin), address(daiJoin), address(vat), cdp, 300 ether);

        weth.deposit.value(2 ether)();
        weth.approve(address(ethJoin), 2 ether);
        ethJoin.join(bytes32(bytes20(address(this))), 2 ether);
        vat.frob("ETH", bytes32(bytes20(address(this))), bytes32(bytes20(address(this))), bytes32(bytes20(address(this))), 1 ether, 150 ether);
        daiMove.move(bytes32(bytes20(address(this))), manager.getUrn(cdp), 150 ether);

        dai.approve(address(proxy), 300 ether);
        this.wipe(address(manager), address(daiJoin), address(vat), cdp, 300 ether);
    }
}
