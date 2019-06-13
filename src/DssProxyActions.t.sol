pragma solidity >=0.5.0;

import "ds-test/test.sol";

import "./DssProxyActions.sol";

import {DssDeployTestBase} from "dss-deploy/DssDeploy.t.base.sol";
import {Token5} from "dss-deploy/token5.sol";
import {GemJoin3} from "dss-deploy/join.sol";
import {DSValue} from "ds-value/value.sol";
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

    function allow(address, uint, address, uint) public {
        proxy.execute(proxyLib, msg.data);
    }

    function hope(address, address) public {
        proxy.execute(proxyLib, msg.data);
    }

    function nope(address, address) public {
        proxy.execute(proxyLib, msg.data);
    }

    function flux(address, uint, address, uint) public {
        proxy.execute(proxyLib, msg.data);
    }

    function move(address, uint, address, uint) public {
        proxy.execute(proxyLib, msg.data);
    }

    function frob(address, uint, int, int) public {
        proxy.execute(proxyLib, msg.data);
    }

    function frob(address, uint, address, int, int) public {
        proxy.execute(proxyLib, msg.data);
    }

    function quit(address, uint, address) public {
        proxy.execute(proxyLib, msg.data);
    }

    function lockETH(address, address, uint) public payable {
        (bool success,) = address(proxy).call.value(msg.value)(abi.encodeWithSignature("execute(address,bytes)", proxyLib, msg.data));
        require(success, "");
    }

    function lockGem(address, address, uint, uint) public {
        proxy.execute(proxyLib, msg.data);
    }

    function freeETH(address, address, uint, uint) public {
        proxy.execute(proxyLib, msg.data);
    }

    function freeGem(address, address, uint, uint) public {
        proxy.execute(proxyLib, msg.data);
    }

    function draw(address, address, uint, uint) public {
        proxy.execute(proxyLib, msg.data);
    }

    function wipe(address, address, uint, uint) public {
        proxy.execute(proxyLib, msg.data);
    }

    function lockETHAndDraw(address, address, address, uint, uint) public payable {
        (bool success,) = address(proxy).call.value(msg.value)(abi.encodeWithSignature("execute(address,bytes)", proxyLib, msg.data));
        require(success, "");
    }

    function openLockETHAndDraw(address, address, address, bytes32, uint) public payable returns (uint cdp) {
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

    function lockGemAndDraw(address, address, address, uint, uint, uint) public {
        proxy.execute(proxyLib, msg.data);
    }

    function openLockGemAndDraw(address, address, address, bytes32, uint, uint) public returns (uint cdp) {
        bytes memory response = proxy.execute(proxyLib, msg.data);
        assembly {
            cdp := mload(add(response, 0x20))
        }
    }

    function wipeAndFreeETH(address, address, address, uint, uint, uint) public {
        proxy.execute(proxyLib, msg.data);
    }

    function wipeAndFreeGem(address, address, address, uint, uint, uint) public {
        proxy.execute(proxyLib, msg.data);
    }

    function dsrJoin(address, address, uint) public {
        proxy.execute(proxyLib, msg.data);
    }

    function dsrExit(address, address, uint) public {
        proxy.execute(proxyLib, msg.data);
    }

    function dsrExitAll(address, address) public {
        proxy.execute(proxyLib, msg.data);
    }
}

contract FakeUser {
    function doGive(
        DssCdpManager manager,
        uint cdp,
        address dst
    ) public {
        manager.give(cdp, dst);
    }
}

contract DssProxyActionsTest is DssDeployTestBase, ProxyCalls {
    DssCdpManager manager;

    GemJoin3 col5Join;
    Token5 col5;
    DSValue pipCOL5;

    function setUp() public {
        super.setUp();
        deployKeepAuth();

        // Add a token collateral
        col5 = new Token5(1000 * 10 ** 9);
        col5Join = new GemJoin3(address(vat), "COL5", address(col5));
        pipCOL5 = new DSValue();
        dssDeploy.deployCollateral("COL5", address(col5Join), address(pipCOL5));
        pipCOL5.poke(bytes32(uint(50 ether))); // Price 50 DAI = 1 COL5 (in precision 18)
        this.file(address(spotter), "COL5", "mat", uint(1500000000 ether)); // Liquidation ratio 150%
        this.file(address(vat), bytes32("COL5"), bytes32("line"), uint(10000 * 10 ** 45));
        spotter.poke("COL5");
        (,,uint spot,,) = vat.ilks("COL5");
        assertEq(spot, 50 * ONE * ONE / 1500000000 ether);

        manager = new DssCdpManager(address(vat));
        DSProxyFactory factory = new DSProxyFactory();
        proxyLib = address(new DssProxyActions());
        proxy = DSProxy(factory.build());
    }

    function ink(bytes32 ilk, address urn) public view returns (uint inkV) {
        (inkV,) = vat.urns(ilk, urn);
    }

    function art(bytes32 ilk, address urn) public view returns (uint artV) {
        (,artV) = vat.urns(ilk, urn);
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
        this.allow(address(manager), cdp, address(user), 1);
        user.doGive(manager, cdp, address(123));
        assertEq(manager.lads(cdp), address(123));
    }

    function testFlux() public {
        uint cdp = this.open(address(manager), "ETH");

        assertEq(dai.balanceOf(address(this)), 0);
        weth.deposit.value(1 ether)();
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(manager.urns(cdp), 1 ether);
        assertEq(vat.gem("ETH", address(this)), 0);
        assertEq(vat.gem("ETH", manager.urns(cdp)), 1 ether);

        this.flux(address(manager), cdp, address(this), 0.75 ether);

        assertEq(vat.gem("ETH", address(this)), 0.75 ether);
        assertEq(vat.gem("ETH", manager.urns(cdp)), 0.25 ether);
    }

    function testFrob() public {
        uint cdp = this.open(address(manager), "ETH");

        assertEq(dai.balanceOf(address(this)), 0);
        weth.deposit.value(1 ether)();
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(manager.urns(cdp), 1 ether);

        this.frob(address(manager), cdp, 0.5 ether, 60 ether);
        assertEq(vat.gem("ETH", manager.urns(cdp)), 0.5 ether);
        assertEq(vat.dai(manager.urns(cdp)), mul(ONE, 60 ether));
        assertEq(vat.dai(address(this)), 0);

        this.move(address(manager), cdp, address(this), mul(ONE, 60 ether));
        assertEq(vat.dai(manager.urns(cdp)), 0);
        assertEq(vat.dai(address(this)), mul(ONE, 60 ether));

        vat.hope(address(daiJoin));
        daiJoin.exit(address(this), 60 ether);
        assertEq(dai.balanceOf(address(this)), 60 ether);
    }

    function testFrobDaiOtherDst() public {
        uint cdp = this.open(address(manager), "ETH");

        weth.deposit.value(1 ether)();
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(manager.urns(cdp), 1 ether);

        assertEq(vat.dai(manager.urns(cdp)), 0);
        assertEq(vat.dai(address(this)), 0);

        this.frob(address(manager), cdp, address(this), 0.5 ether, 60 ether);
        assertEq(vat.dai(manager.urns(cdp)), 0);
        assertEq(vat.dai(address(this)), mul(ONE, 60 ether));
    }

    function testFrobGemOtherDst() public {
        uint cdp = this.open(address(manager), "ETH");

        weth.deposit.value(1 ether)();
        weth.approve(address(ethJoin), uint(-1));
        ethJoin.join(manager.urns(cdp), 1 ether);

        assertEq(vat.gem("ETH", manager.urns(cdp)), 1 ether);
        assertEq(vat.gem("ETH", address(this)), 0);

        this.frob(address(manager), cdp, 0.5 ether, 60 ether);
        assertEq(vat.gem("ETH", manager.urns(cdp)), 0.5 ether);
        assertEq(vat.gem("ETH", address(this)), 0);

        this.frob(address(manager), cdp, address(this), -int(0.5 ether), -int(60 ether));
        assertEq(vat.gem("ETH", manager.urns(cdp)), 0.5 ether);
        assertEq(vat.gem("ETH", address(this)), 0.5 ether);
    }

    function testLockETH() public {
        uint initialBalance = address(this).balance;
        uint cdp = this.open(address(manager), "ETH");
        assertEq(ink("ETH", manager.urns(cdp)), 0);
        this.lockETH.value(2 ether)(address(manager), address(ethJoin), cdp);
        assertEq(ink("ETH", manager.urns(cdp)), 2 ether);
        assertEq(address(this).balance, initialBalance - 2 ether);
    }

    function testLockETHOtherCDPOwner() public {
        uint initialBalance = address(this).balance;
        uint cdp = this.open(address(manager), "ETH");
        this.give(address(manager), cdp, address(123));
        assertEq(ink("ETH", manager.urns(cdp)), 0);
        this.lockETH.value(2 ether)(address(manager), address(ethJoin), cdp);
        assertEq(ink("ETH", manager.urns(cdp)), 2 ether);
        assertEq(address(this).balance, initialBalance - 2 ether);
    }

    function testLockGem() public {
        col.mint(5 ether);
        uint cdp = this.open(address(manager), "COL");
        col.approve(address(proxy), 2 ether);
        assertEq(ink("COL", manager.urns(cdp)), 0);
        this.lockGem(address(manager), address(colJoin), cdp, 2 ether);
        assertEq(ink("COL", manager.urns(cdp)), 2 ether);
        assertEq(col.balanceOf(address(this)), 3 ether);
    }

    function testLockGemCol5() public {
        uint cdp = this.open(address(manager), "COL5");
        col5.approve(address(proxy), 2 * 10 ** 9);
        assertEq(ink("COL5", manager.urns(cdp)), 0);
        uint prevBalance = col5.balanceOf(address(this));
        this.lockGem(address(manager), address(col5Join), cdp, 2 * 10 ** 9);
        assertEq(ink("COL5", manager.urns(cdp)),  2 ether);
        assertEq(col5.balanceOf(address(this)), prevBalance - 2 * 10 ** 9);
    }

    function testLockGemOtherCDPOwner() public {
        col.mint(5 ether);
        uint cdp = this.open(address(manager), "COL");
        this.give(address(manager), cdp, address(123));
        col.approve(address(proxy), 2 ether);
        assertEq(ink("COL", manager.urns(cdp)), 0);
        this.lockGem(address(manager), address(colJoin), cdp, 2 ether);
        assertEq(ink("COL", manager.urns(cdp)), 2 ether);
        assertEq(col.balanceOf(address(this)), 3 ether);
    }

    function testFreeETH() public {
        uint initialBalance = address(this).balance;
        uint cdp = this.open(address(manager), "ETH");
        this.lockETH.value(2 ether)(address(manager), address(ethJoin), cdp);
        this.freeETH(address(manager), address(ethJoin), cdp, 1 ether);
        assertEq(ink("ETH", manager.urns(cdp)), 1 ether);
        assertEq(address(this).balance, initialBalance - 1 ether);
    }

    function testFreeGem() public {
        col.mint(5 ether);
        uint cdp = this.open(address(manager), "COL");
        col.approve(address(proxy), 2 ether);
        this.lockGem(address(manager), address(colJoin), cdp, 2 ether);
        this.freeGem(address(manager), address(colJoin), cdp, 1 ether);
        assertEq(ink("COL", manager.urns(cdp)), 1 ether);
        assertEq(col.balanceOf(address(this)), 4 ether);
    }

    function testFreeGemCol5() public {
        uint cdp = this.open(address(manager), "COL5");
        col5.approve(address(proxy), 2 * 10 ** 9);
        assertEq(ink("COL5", manager.urns(cdp)), 0);
        uint prevBalance = col5.balanceOf(address(this));
        this.lockGem(address(manager), address(col5Join), cdp, 2 * 10 ** 9);
        this.freeGem(address(manager), address(col5Join), cdp, 1 * 10 ** 9);
        assertEq(ink("COL5", manager.urns(cdp)),  1 ether);
        assertEq(col5.balanceOf(address(this)), prevBalance - 1 * 10 ** 9);
    }

    function testDraw() public {
        uint cdp = this.open(address(manager), "ETH");
        this.lockETH.value(2 ether)(address(manager), address(ethJoin), cdp);
        assertEq(dai.balanceOf(address(this)), 0);
        this.draw(address(manager), address(daiJoin), cdp, 300 ether);
        assertEq(dai.balanceOf(address(this)), 300 ether);
        assertEq(art("ETH", manager.urns(cdp)), 300 ether);
    }

    function testDrawAfterDrip() public {
        this.file(address(jug), bytes32("ETH"), bytes32("duty"), uint(1.05 * 10 ** 27));
        hevm.warp(now + 1);
        jug.drip("ETH");
        uint cdp = this.open(address(manager), "ETH");
        this.lockETH.value(2 ether)(address(manager), address(ethJoin), cdp);
        assertEq(dai.balanceOf(address(this)), 0);
        this.draw(address(manager), address(daiJoin), cdp, 300 ether);
        assertEq(dai.balanceOf(address(this)), 300 ether);
        assertEq(art("ETH", manager.urns(cdp)), mul(300 ether, ONE) / (1.05 * 10 ** 27) + 1); // Extra wei due rounding
    }

    function testWipe() public {
        uint cdp = this.open(address(manager), "ETH");
        this.lockETH.value(2 ether)(address(manager), address(ethJoin), cdp);
        this.draw(address(manager), address(daiJoin), cdp, 300 ether);
        dai.approve(address(proxy), 100 ether);
        this.wipe(address(manager), address(daiJoin), cdp, 100 ether);
        assertEq(dai.balanceOf(address(this)), 200 ether);
        assertEq(art("ETH", manager.urns(cdp)), 200 ether);
    }

    function testWipeOtherCDPOwner() public {
        uint cdp = this.open(address(manager), "ETH");
        this.lockETH.value(2 ether)(address(manager), address(ethJoin), cdp);
        this.draw(address(manager), address(daiJoin), cdp, 300 ether);
        dai.approve(address(proxy), 100 ether);
        this.give(address(manager), cdp, address(123));
        this.wipe(address(manager), address(daiJoin), cdp, 100 ether);
        assertEq(dai.balanceOf(address(this)), 200 ether);
        assertEq(art("ETH", manager.urns(cdp)), 200 ether);
    }

    function testWipeAfterDrip() public {
        this.file(address(jug), bytes32("ETH"), bytes32("duty"), uint(1.05 * 10 ** 27));
        hevm.warp(now + 1);
        jug.drip("ETH");
        uint cdp = this.open(address(manager), "ETH");
        this.lockETH.value(2 ether)(address(manager), address(ethJoin), cdp);
        this.draw(address(manager), address(daiJoin), cdp, 300 ether);
        dai.approve(address(proxy), 100 ether);
        this.wipe(address(manager), address(daiJoin), cdp, 100 ether);
        assertEq(dai.balanceOf(address(this)), 200 ether);
        assertEq(art("ETH", manager.urns(cdp)), mul(200 ether, ONE) / (1.05 * 10 ** 27) + 1);
    }

    function testWipeAllAfterDrip() public {
        this.file(address(jug), bytes32("ETH"), bytes32("duty"), uint(1.05 * 10 ** 27));
        hevm.warp(now + 1);
        jug.drip("ETH");
        uint cdp = this.open(address(manager), "ETH");
        this.lockETH.value(2 ether)(address(manager), address(ethJoin), cdp);
        this.draw(address(manager), address(daiJoin), cdp, 300 ether);
        dai.approve(address(proxy), 300 ether);
        this.wipe(address(manager), address(daiJoin), cdp, 300 ether);
        assertEq(art("ETH", manager.urns(cdp)), 0);
    }

    function testWipeAllAfterDrip2() public {
        this.file(address(jug), bytes32("ETH"), bytes32("duty"), uint(1.05 * 10 ** 27));
        hevm.warp(now + 1);
        jug.drip("ETH");
        uint cdp = this.open(address(manager), "ETH");
        uint times = 30;
        this.lockETH.value(2 ether * times)(address(manager), address(ethJoin), cdp);
        for (uint i = 0; i < times; i++) {
            this.draw(address(manager), address(daiJoin), cdp, 300 ether);
        }
        dai.approve(address(proxy), 300 ether * times);
        this.wipe(address(manager), address(daiJoin), cdp, 300 ether * times);
        assertEq(art("ETH", manager.urns(cdp)), 0);
    }

    function testLockETHAndDraw() public {
        uint cdp = this.open(address(manager), "ETH");
        uint initialBalance = address(this).balance;
        assertEq(ink("ETH", manager.urns(cdp)), 0);
        assertEq(dai.balanceOf(address(this)), 0);
        this.lockETHAndDraw.value(2 ether)(address(manager), address(ethJoin), address(daiJoin), cdp, 300 ether);
        assertEq(ink("ETH", manager.urns(cdp)), 2 ether);
        assertEq(dai.balanceOf(address(this)), 300 ether);
        assertEq(address(this).balance, initialBalance - 2 ether);
    }

    function testOpenLockETHAndDraw() public {
        uint initialBalance = address(this).balance;
        assertEq(dai.balanceOf(address(this)), 0);
        uint cdp = this.openLockETHAndDraw.value(2 ether)(address(manager), address(ethJoin), address(daiJoin), "ETH", 300 ether);
        assertEq(ink("ETH", manager.urns(cdp)), 2 ether);
        assertEq(dai.balanceOf(address(this)), 300 ether);
        assertEq(address(this).balance, initialBalance - 2 ether);
    }

    function testLockGemAndDraw() public {
        col.mint(5 ether);
        uint cdp = this.open(address(manager), "COL");
        col.approve(address(proxy), 2 ether);
        assertEq(ink("COL", manager.urns(cdp)), 0);
        assertEq(dai.balanceOf(address(this)), 0);
        this.lockGemAndDraw(address(manager), address(colJoin), address(daiJoin), cdp, 2 ether, 10 ether);
        assertEq(ink("COL", manager.urns(cdp)), 2 ether);
        assertEq(dai.balanceOf(address(this)), 10 ether);
        assertEq(col.balanceOf(address(this)), 3 ether);
    }

    function testLockGemCol5AndDraw() public {
        uint cdp = this.open(address(manager), "COL5");
        col5.approve(address(proxy), 3 * 10 ** 9);
        assertEq(ink("COL5", manager.urns(cdp)), 0);
        uint prevBalance = col5.balanceOf(address(this));
        this.lockGemAndDraw(address(manager), address(col5Join), address(daiJoin), cdp, 3 * 10 ** 9, 50 ether);
        assertEq(ink("COL5", manager.urns(cdp)), 3 ether);
        assertEq(dai.balanceOf(address(this)), 50 ether);
        assertEq(col5.balanceOf(address(this)), prevBalance - 3 * 10 ** 9);
    }

    function testOpenLockGemAndDraw() public {
        col.mint(5 ether);
        col.approve(address(proxy), 2 ether);
        assertEq(dai.balanceOf(address(this)), 0);
        uint cdp = this.openLockGemAndDraw(address(manager), address(colJoin), address(daiJoin), "COL", 2 ether, 10 ether);
        assertEq(ink("COL", manager.urns(cdp)), 2 ether);
        assertEq(dai.balanceOf(address(this)), 10 ether);
        assertEq(col.balanceOf(address(this)), 3 ether);
    }

    function testWipeAndFreeETH() public {
        uint cdp = this.open(address(manager), "ETH");
        uint initialBalance = address(this).balance;
        this.lockETHAndDraw.value(2 ether)(address(manager), address(ethJoin), address(daiJoin), cdp, 300 ether);
        dai.approve(address(proxy), 250 ether);
        this.wipeAndFreeETH(address(manager), address(ethJoin), address(daiJoin), cdp, 1.5 ether, 250 ether);
        assertEq(ink("ETH", manager.urns(cdp)), 0.5 ether);
        assertEq(dai.balanceOf(address(this)), 50 ether);
        assertEq(address(this).balance, initialBalance - 0.5 ether);
    }

    function testWipeAndFreeGem() public {
        col.mint(5 ether);
        uint cdp = this.open(address(manager), "COL");
        col.approve(address(proxy), 2 ether);
        this.lockGemAndDraw(address(manager), address(colJoin), address(daiJoin), cdp, 2 ether, 10 ether);
        dai.approve(address(proxy), 8 ether);
        this.wipeAndFreeGem(address(manager), address(colJoin), address(daiJoin), cdp, 1.5 ether, 8 ether);
        assertEq(ink("COL", manager.urns(cdp)), 0.5 ether);
        assertEq(dai.balanceOf(address(this)), 2 ether);
        assertEq(col.balanceOf(address(this)), 4.5 ether);
    }

    function testWipeAndFreeGemCol5AndDraw() public {
        uint cdp = this.open(address(manager), "COL5");
        col5.approve(address(proxy), 3 * 10 ** 9);
        assertEq(ink("COL5", manager.urns(cdp)), 0);
        uint prevBalance = col5.balanceOf(address(this));
        this.lockGemAndDraw(address(manager), address(col5Join), address(daiJoin), cdp, 3 * 10 ** 9, 50 ether);
        dai.approve(address(proxy), 25 ether);
        this.wipeAndFreeGem(address(manager), address(col5Join), address(daiJoin), cdp, 1 * 10 ** 9, 25 ether);
        assertEq(ink("COL5", manager.urns(cdp)), 2 ether);
        assertEq(dai.balanceOf(address(this)), 25 ether);
        assertEq(col5.balanceOf(address(this)), prevBalance - 2 * 10 ** 9);
    }

    function testPreventHigherDaiOnWipe() public {
        uint cdp = this.open(address(manager), "ETH");
        this.lockETHAndDraw.value(2 ether)(address(manager), address(ethJoin), address(daiJoin), cdp, 300 ether);

        weth.deposit.value(2 ether)();
        weth.approve(address(ethJoin), 2 ether);
        ethJoin.join(address(this), 2 ether);
        vat.frob("ETH", address(this), address(this), address(this), 1 ether, 150 ether);
        vat.move(address(this), manager.urns(cdp), 150 ether);

        dai.approve(address(proxy), 300 ether);
        this.wipe(address(manager), address(daiJoin), cdp, 300 ether);
    }

    function testHopeNope() public {
        assertEq(vat.can(address(proxy), address(123)), 0);
        this.hope(address(vat), address(123));
        assertEq(vat.can(address(proxy), address(123)), 1);
        this.nope(address(vat), address(123));
        assertEq(vat.can(address(proxy), address(123)), 0);
    }

    function testQuit() public {
        uint cdp = this.open(address(manager), "ETH");
        this.lockETHAndDraw.value(1 ether)(address(manager), address(ethJoin), address(daiJoin), cdp, 50 ether);

        assertEq(ink("ETH", manager.urns(cdp)), 1 ether);
        assertEq(art("ETH", manager.urns(cdp)), 50 ether);
        assertEq(ink("ETH", address(proxy)), 0);
        assertEq(art("ETH", address(proxy)), 0);

        this.hope(address(vat), address(manager));
        this.quit(address(manager), cdp, address(proxy));

        assertEq(ink("ETH", manager.urns(cdp)), 0);
        assertEq(art("ETH", manager.urns(cdp)), 0);
        assertEq(ink("ETH", address(proxy)), 1 ether);
        assertEq(art("ETH", address(proxy)), 50 ether);
    }

    function testDSRSimpleCase() public {
        this.file(address(pot), "dsr", uint(1.05 * 10 ** 27)); // 5% per second
        uint initialTime = 0; // Initial time set to 0 to avoid any intial rounding
        hevm.warp(initialTime);
        pot.drip(); // It doesn't do anything as time didn't move
        uint cdp = this.open(address(manager), "ETH");
        this.lockETHAndDraw.value(1 ether)(address(manager), address(ethJoin), address(daiJoin), cdp, 50 ether);
        dai.approve(address(proxy), 50 ether);
        assertEq(dai.balanceOf(address(this)), 50 ether);
        assertEq(pot.pie(address(this)), 0 ether);
        this.dsrJoin(address(daiJoin), address(pot), 50 ether);
        assertEq(dai.balanceOf(address(this)), 0 ether);
        assertEq(pot.pie(address(proxy)) * pot.chi(), 50 ether * ONE);
        hevm.warp(initialTime + 1); // Moved 1 second
        pot.drip();
        assertEq(pot.pie(address(proxy)) * pot.chi(), 52.5 ether * ONE); // Now the equivalent DAI amount is 2.5 DAI extra
        this.dsrExit(address(daiJoin), address(pot), 52.5 ether);
        assertEq(dai.balanceOf(address(this)), 52.5 ether);
        assertEq(pot.pie(address(proxy)), 0);
    }

    function testDSRRounding() public {
        this.file(address(pot), "dsr", uint(1.05 * 10 ** 27));
        uint initialTime = 1; // Initial time set to 1 this way some the pie will not be the same than the initial DAI wad amount
        hevm.warp(initialTime);
        pot.drip();
        uint cdp = this.open(address(manager), "ETH");
        this.lockETHAndDraw.value(1 ether)(address(manager), address(ethJoin), address(daiJoin), cdp, 50 ether);
        dai.approve(address(proxy), 50 ether);
        assertEq(dai.balanceOf(address(this)), 50 ether);
        assertEq(pot.pie(address(this)), 0 ether);
        this.dsrJoin(address(daiJoin), address(pot), 50 ether);
        assertEq(dai.balanceOf(address(this)), 0 ether);
        // Due rounding the DAI equivalent is not the same than initial wad amount
        assertEq(pot.pie(address(proxy)) * pot.chi(), 49999999999999999999350000000000000000000000000);
        hevm.warp(initialTime + 1);
        pot.drip();
        assertEq(pot.pie(address(proxy)) * pot.chi(), 52499999999999999999317500000000000000000000000);
        this.dsrExit(address(daiJoin), address(pot), 52.5 ether);
        assertEq(dai.balanceOf(address(this)), 52499999999999999999);
        assertEq(pot.pie(address(proxy)), 0);
    }

    function testDSRRounding2() public {
        this.file(address(pot), "dsr", uint(1.03434234324 * 10 ** 27));
        uint initialTime = 1;
        hevm.warp(initialTime);
        pot.drip();
        uint cdp = this.open(address(manager), "ETH");
        this.lockETHAndDraw.value(1 ether)(address(manager), address(ethJoin), address(daiJoin), cdp, 50 ether);
        dai.approve(address(proxy), 50 ether);
        assertEq(dai.balanceOf(address(this)), 50 ether);
        assertEq(pot.pie(address(this)), 0 ether);
        this.dsrJoin(address(daiJoin), address(pot), 50 ether);
        assertEq(pot.pie(address(proxy)) * pot.chi(), 49999999999999999999993075745400000000000000000);
        assertEq(vat.dai(address(proxy)), mul(50 ether, ONE) - 49999999999999999999993075745400000000000000000);
        this.dsrExit(address(daiJoin), address(pot), 50 ether);
        // In this case we get the full 50 DAI back as we also use (for the exit) the dust that remained in the proxy DAI balance in the vat
        // The proxy function tries to return the wad amount if there is enough balance to do it
        assertEq(dai.balanceOf(address(this)), 50 ether);
    }

    function testDSRExitAll() public {
        this.file(address(pot), "dsr", uint(1.03434234324 * 10 ** 27));
        uint initialTime = 1;
        hevm.warp(initialTime);
        pot.drip();
        uint cdp = this.open(address(manager), "ETH");
        this.lockETHAndDraw.value(1 ether)(address(manager), address(ethJoin), address(daiJoin), cdp, 50 ether);
        dai.approve(address(proxy), 50 ether);
        this.dsrJoin(address(daiJoin), address(pot), 50 ether);
        this.dsrExitAll(address(daiJoin), address(pot));
        // In this case we get 49.999 DAI back as the returned amount is based purely in the pie amount
        assertEq(dai.balanceOf(address(this)), 49999999999999999999);
    }
}
