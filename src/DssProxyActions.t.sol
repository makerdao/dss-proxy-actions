pragma solidity >=0.5.0;

import "ds-test/test.sol";

import "./DssProxyActions.sol";

import {DssDeployTestBase} from "dss-deploy/DssDeploy.t.base.sol";
import {DGD, GNT} from "dss-deploy/tokens.sol";
import {GemJoin3, GemJoin4} from "dss-deploy/join.sol";
import {DSValue} from "ds-value/value.sol";
import {DssCdpManager} from "dss-cdp-manager/DssCdpManager.sol";
import {GetCdps} from "dss-cdp-manager/GetCdps.sol";
import {ProxyRegistry, DSProxyFactory, DSProxy} from "proxy-registry/ProxyRegistry.sol";

contract ProxyCalls {
    DSProxy proxy;
    address proxyLib;

    function transfer(address, address, uint256) public {
        proxy.execute(proxyLib, msg.data);
    }

    function open(address, bytes32) public returns (uint cdp) {
        bytes memory response = proxy.execute(proxyLib, msg.data);
        assembly {
            cdp := mload(add(response, 0x20))
        }
    }

    function give(address, uint, address) public {
        proxy.execute(proxyLib, msg.data);
    }

    function giveToProxy(address, address, uint, address) public {
        proxy.execute(proxyLib, msg.data);
    }

    function cdpAllow(address, uint, address, uint) public {
        proxy.execute(proxyLib, msg.data);
    }

    function urnAllow(address, address, uint) public {
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

    function safeLockETH(address, address, uint) public payable {
        (bool success,) = address(proxy).call.value(msg.value)(abi.encodeWithSignature("execute(address,bytes)", proxyLib, msg.data));
        require(success, "");
    }

    function lockGem(address, address, uint, uint, bool) public {
        proxy.execute(proxyLib, msg.data);
    }

    function safeLockGem(address, address, uint, uint, bool) public {
        proxy.execute(proxyLib, msg.data);
    }

    function makeGemBag(address) public returns (address bag) {
        address payable target = address(proxy);
        bytes memory data = abi.encodeWithSignature("execute(address,bytes)", proxyLib, msg.data);
        assembly {
            let succeeded := call(sub(gas, 5000), target, callvalue, add(data, 0x20), mload(data), 0, 0)
            let size := returndatasize
            let response := mload(0x40)
            mstore(0x40, add(response, and(add(add(size, 0x20), 0x1f), not(0x1f))))
            mstore(response, size)
            returndatacopy(add(response, 0x20), 0, size)

            bag := mload(add(response, 0x60))

            switch iszero(succeeded)
            case 1 {
                // throw if delegatecall failed
                revert(add(response, 0x20), size)
            }
        }
    }

    function freeETH(address, address, uint, uint) public {
        proxy.execute(proxyLib, msg.data);
    }

    function freeGem(address, address, uint, uint) public {
        proxy.execute(proxyLib, msg.data);
    }

    function draw(address, address, address, uint, uint) public {
        proxy.execute(proxyLib, msg.data);
    }

    function wipe(address, address, uint, uint) public {
        proxy.execute(proxyLib, msg.data);
    }

    function wipeAll(address, address, uint) public {
        proxy.execute(proxyLib, msg.data);
    }

    function safeWipe(address, address, uint, uint) public {
        proxy.execute(proxyLib, msg.data);
    }

    function safeWipeAll(address, address, uint) public {
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

    function lockGemAndDraw(address, address, address, address, uint, uint, uint, bool) public {
        proxy.execute(proxyLib, msg.data);
    }

    function openLockGemAndDraw(address, address, address, address, bytes32, uint, uint, bool) public returns (uint cdp) {
        bytes memory response = proxy.execute(proxyLib, msg.data);
        assembly {
            cdp := mload(add(response, 0x20))
        }
    }

    function openLockGNTAndDraw(address, address, address, address, bytes32, uint, uint) public returns (address bag, uint cdp) {
        bytes memory response = proxy.execute(proxyLib, msg.data);
        assembly {
            bag := mload(add(response, 0x20))
            cdp := mload(add(response, 0x40))
        }
    }

    function wipeAndFreeETH(address, address, address, uint, uint, uint) public {
        proxy.execute(proxyLib, msg.data);
    }

    function wipeAllAndFreeETH(address, address, address, uint, uint) public {
        proxy.execute(proxyLib, msg.data);
    }

    function wipeAndFreeGem(address, address, address, uint, uint, uint) public {
        proxy.execute(proxyLib, msg.data);
    }

    function wipeAllAndFreeGem(address, address, address, uint, uint) public {
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

    GemJoin3 dgdJoin;
    DGD dgd;
    DSValue pipDGD;
    GemJoin4 gntJoin;
    GNT gnt;
    DSValue pipGNT;
    ProxyRegistry registry;

    function setUp() public {
        super.setUp();
        deployKeepAuth();

        // Add a token collateral
        dgd = new DGD(1000 * 10 ** 9);
        dgdJoin = new GemJoin3(address(vat), "DGD", address(dgd), 9);
        pipDGD = new DSValue();
        dssDeploy.deployCollateral("DGD", address(dgdJoin), address(pipDGD));
        pipDGD.poke(bytes32(uint(50 ether))); // Price 50 DAI = 1 DGD (in precision 18)
        this.file(address(spotter), "DGD", "mat", uint(1500000000 ether)); // Liquidation ratio 150%
        this.file(address(vat), bytes32("DGD"), bytes32("line"), uint(10000 * 10 ** 45));
        spotter.poke("DGD");
        (,,uint spot,,) = vat.ilks("DGD");
        assertEq(spot, 50 * ONE * ONE / 1500000000 ether);

        gnt = new GNT(1000000 ether);
        gntJoin = new GemJoin4(address(vat), "GNT", address(gnt));
        pipGNT = new DSValue();
        dssDeploy.deployCollateral("GNT", address(gntJoin), address(pipGNT));
        pipGNT.poke(bytes32(uint(100 ether))); // Price 100 DAI = 1 GNT
        this.file(address(spotter), "GNT", "mat", uint(1500000000 ether)); // Liquidation ratio 150%
        this.file(address(vat), bytes32("GNT"), bytes32("line"), uint(10000 * 10 ** 45));
        spotter.poke("GNT");
        (,, spot,,) = vat.ilks("GNT");
        assertEq(spot, 100 * ONE * ONE / 1500000000 ether);

        manager = new DssCdpManager(address(vat));
        DSProxyFactory factory = new DSProxyFactory();
        registry = new ProxyRegistry(address(factory));
        proxyLib = address(new DssProxyActions());
        proxy = DSProxy(registry.build());
    }

    function ink(bytes32 ilk, address urn) public view returns (uint inkV) {
        (inkV,) = vat.urns(ilk, urn);
    }

    function art(bytes32 ilk, address urn) public view returns (uint artV) {
        (,artV) = vat.urns(ilk, urn);
    }

    function testTransfer() public {
        col.mint(10);
        col.transfer(address(proxy), 10);
        assertEq(col.balanceOf(address(proxy)), 10);
        assertEq(col.balanceOf(address(123)), 0);
        this.transfer(address(col), address(123), 4);
        assertEq(col.balanceOf(address(proxy)), 6);
        assertEq(col.balanceOf(address(123)), 4);
    }

    function testCreateCDP() public {
        uint cdp = this.open(address(manager), "ETH");
        assertEq(cdp, 1);
        assertEq(manager.owns(cdp), address(proxy));
    }

    function testGiveCDP() public {
        uint cdp = this.open(address(manager), "ETH");
        this.give(address(manager), cdp, address(123));
        assertEq(manager.owns(cdp), address(123));
    }

    function testGiveCDPToProxy() public {
        uint cdp = this.open(address(manager), "ETH");
        address userProxy = registry.build(address(123));
        this.giveToProxy(address(registry), address(manager), cdp, address(123));
        assertEq(manager.owns(cdp), userProxy);
    }

    function testGiveCDPToNewProxy() public {
        uint cdp = this.open(address(manager), "ETH");
        assertEq(address(registry.proxies(address(123))), address(0));
        this.giveToProxy(address(registry), address(manager), cdp, address(123));
        DSProxy userProxy = registry.proxies(address(123));
        assertTrue(address(userProxy) != address(0));
        assertEq(userProxy.owner(), address(123));
        assertEq(manager.owns(cdp), address(userProxy));
    }

    function testFailGiveCDPToNewContractProxy() public {
        uint cdp = this.open(address(manager), "ETH");
        FakeUser user = new FakeUser();
        assertEq(address(registry.proxies(address(user))), address(0));
        this.giveToProxy(address(registry), address(manager), cdp, address(user)); // Fails as user is a contract and not a regular address
    }

    function testGiveCDPAllowedUser() public {
        uint cdp = this.open(address(manager), "ETH");
        FakeUser user = new FakeUser();
        this.cdpAllow(address(manager), cdp, address(user), 1);
        user.doGive(manager, cdp, address(123));
        assertEq(manager.owns(cdp), address(123));
    }

    function testAllowUrn() public {
        assertEq(manager.urnCan(address(proxy), address(123)), 0);
        this.urnAllow(address(manager), address(123), 1);
        assertEq(manager.urnCan(address(proxy), address(123)), 1);
        this.urnAllow(address(manager), address(123), 0);
        assertEq(manager.urnCan(address(proxy), address(123)), 0);
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

    function testSafeLockETH() public {
        uint initialBalance = address(this).balance;
        uint cdp = this.open(address(manager), "ETH");
        assertEq(ink("ETH", manager.urns(cdp)), 0);
        this.safeLockETH.value(2 ether)(address(manager), address(ethJoin), cdp);
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

    function testFailSafeLockETHOtherCDPOwner() public {
        uint cdp = this.open(address(manager), "ETH");
        this.give(address(manager), cdp, address(123));
        this.safeLockETH.value(2 ether)(address(manager), address(ethJoin), cdp);
    }

    function testLockGem() public {
        col.mint(5 ether);
        uint cdp = this.open(address(manager), "COL");
        col.approve(address(proxy), 2 ether);
        assertEq(ink("COL", manager.urns(cdp)), 0);
        this.lockGem(address(manager), address(colJoin), cdp, 2 ether, true);
        assertEq(ink("COL", manager.urns(cdp)), 2 ether);
        assertEq(col.balanceOf(address(this)), 3 ether);
    }

    function testSafeLockGem() public {
        col.mint(5 ether);
        uint cdp = this.open(address(manager), "COL");
        col.approve(address(proxy), 2 ether);
        assertEq(ink("COL", manager.urns(cdp)), 0);
        this.safeLockGem(address(manager), address(colJoin), cdp, 2 ether, true);
        assertEq(ink("COL", manager.urns(cdp)), 2 ether);
        assertEq(col.balanceOf(address(this)), 3 ether);
    }

    function testLockGemDGD() public {
        uint cdp = this.open(address(manager), "DGD");
        dgd.approve(address(proxy), 2 * 10 ** 9);
        assertEq(ink("DGD", manager.urns(cdp)), 0);
        uint prevBalance = dgd.balanceOf(address(this));
        this.lockGem(address(manager), address(dgdJoin), cdp, 2 * 10 ** 9, true);
        assertEq(ink("DGD", manager.urns(cdp)),  2 ether);
        assertEq(dgd.balanceOf(address(this)), prevBalance - 2 * 10 ** 9);
    }

    function testLockGemGNT() public {
        uint cdp = this.open(address(manager), "GNT");
        assertEq(ink("GNT", manager.urns(cdp)), 0);
        uint prevBalance = gnt.balanceOf(address(this));
        address bag = this.makeGemBag(address(gntJoin));
        assertEq(gnt.balanceOf(bag), 0);
        gnt.transfer(bag, 2 ether);
        assertEq(gnt.balanceOf(address(this)), prevBalance - 2 ether);
        assertEq(gnt.balanceOf(bag), 2 ether);
        this.lockGem(address(manager), address(gntJoin), cdp, 2 ether, false);
        assertEq(ink("GNT", manager.urns(cdp)),  2 ether);
        assertEq(gnt.balanceOf(bag), 0);
    }

    function testLockGemOtherCDPOwner() public {
        col.mint(5 ether);
        uint cdp = this.open(address(manager), "COL");
        this.give(address(manager), cdp, address(123));
        col.approve(address(proxy), 2 ether);
        assertEq(ink("COL", manager.urns(cdp)), 0);
        this.lockGem(address(manager), address(colJoin), cdp, 2 ether, true);
        assertEq(ink("COL", manager.urns(cdp)), 2 ether);
        assertEq(col.balanceOf(address(this)), 3 ether);
    }

    function testFailSafeLockGemOtherCDPOwner() public {
        col.mint(5 ether);
        uint cdp = this.open(address(manager), "COL");
        this.give(address(manager), cdp, address(123));
        col.approve(address(proxy), 2 ether);
        this.safeLockGem(address(manager), address(colJoin), cdp, 2 ether, true);
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
        this.lockGem(address(manager), address(colJoin), cdp, 2 ether, true);
        this.freeGem(address(manager), address(colJoin), cdp, 1 ether);
        assertEq(ink("COL", manager.urns(cdp)), 1 ether);
        assertEq(col.balanceOf(address(this)), 4 ether);
    }

    function testFreeGemDGD() public {
        uint cdp = this.open(address(manager), "DGD");
        dgd.approve(address(proxy), 2 * 10 ** 9);
        assertEq(ink("DGD", manager.urns(cdp)), 0);
        uint prevBalance = dgd.balanceOf(address(this));
        this.lockGem(address(manager), address(dgdJoin), cdp, 2 * 10 ** 9, true);
        this.freeGem(address(manager), address(dgdJoin), cdp, 1 * 10 ** 9);
        assertEq(ink("DGD", manager.urns(cdp)),  1 ether);
        assertEq(dgd.balanceOf(address(this)), prevBalance - 1 * 10 ** 9);
    }

    function testFreeGemGNT() public {
        uint cdp = this.open(address(manager), "GNT");
        assertEq(ink("GNT", manager.urns(cdp)), 0);
        uint prevBalance = gnt.balanceOf(address(this));
        address bag = this.makeGemBag(address(gntJoin));
        gnt.transfer(bag, 2 ether);
        this.lockGem(address(manager), address(gntJoin), cdp, 2 ether, false);
        this.freeGem(address(manager), address(gntJoin), cdp, 1 ether);
        assertEq(ink("GNT", manager.urns(cdp)),  1 ether);
        assertEq(gnt.balanceOf(address(this)), prevBalance - 1 ether);
    }

    function testDraw() public {
        uint cdp = this.open(address(manager), "ETH");
        this.lockETH.value(2 ether)(address(manager), address(ethJoin), cdp);
        assertEq(dai.balanceOf(address(this)), 0);
        this.draw(address(manager), address(jug), address(daiJoin), cdp, 300 ether);
        assertEq(dai.balanceOf(address(this)), 300 ether);
        assertEq(art("ETH", manager.urns(cdp)), 300 ether);
    }

    function testDrawAfterDrip() public {
        this.file(address(jug), bytes32("ETH"), bytes32("duty"), uint(1.05 * 10 ** 27));
        hevm.warp(now + 1);
        jug.drip("ETH"); // This is actually not necessary as `draw` will also call drip
        uint cdp = this.open(address(manager), "ETH");
        this.lockETH.value(2 ether)(address(manager), address(ethJoin), cdp);
        assertEq(dai.balanceOf(address(this)), 0);
        this.draw(address(manager), address(jug), address(daiJoin), cdp, 300 ether);
        assertEq(dai.balanceOf(address(this)), 300 ether);
        assertEq(art("ETH", manager.urns(cdp)), mul(300 ether, ONE) / (1.05 * 10 ** 27) + 1); // Extra wei due rounding
    }

    function testWipe() public {
        uint cdp = this.open(address(manager), "ETH");
        this.lockETH.value(2 ether)(address(manager), address(ethJoin), cdp);
        this.draw(address(manager), address(jug), address(daiJoin), cdp, 300 ether);
        dai.approve(address(proxy), 100 ether);
        this.wipe(address(manager), address(daiJoin), cdp, 100 ether);
        assertEq(dai.balanceOf(address(this)), 200 ether);
        assertEq(art("ETH", manager.urns(cdp)), 200 ether);
    }

    function testWipeAll() public {
        uint cdp = this.open(address(manager), "ETH");
        this.lockETH.value(2 ether)(address(manager), address(ethJoin), cdp);
        this.draw(address(manager), address(jug), address(daiJoin), cdp, 300 ether);
        dai.approve(address(proxy), 300 ether);
        this.wipeAll(address(manager), address(daiJoin), cdp);
        assertEq(dai.balanceOf(address(this)), 0);
        assertEq(art("ETH", manager.urns(cdp)), 0);
    }

    function testSafeWipe() public {
        uint cdp = this.open(address(manager), "ETH");
        this.lockETH.value(2 ether)(address(manager), address(ethJoin), cdp);
        this.draw(address(manager), address(jug), address(daiJoin), cdp, 300 ether);
        dai.approve(address(proxy), 100 ether);
        this.safeWipe(address(manager), address(daiJoin), cdp, 100 ether);
        assertEq(dai.balanceOf(address(this)), 200 ether);
        assertEq(art("ETH", manager.urns(cdp)), 200 ether);
    }

    function testSafeWipeAll() public {
        uint cdp = this.open(address(manager), "ETH");
        this.lockETH.value(2 ether)(address(manager), address(ethJoin), cdp);
        this.draw(address(manager), address(jug), address(daiJoin), cdp, 300 ether);
        dai.approve(address(proxy), 300 ether);
        this.safeWipeAll(address(manager), address(daiJoin), cdp);
        assertEq(dai.balanceOf(address(this)), 0);
        assertEq(art("ETH", manager.urns(cdp)), 0);
    }

    function testWipeOtherCDPOwner() public {
        uint cdp = this.open(address(manager), "ETH");
        this.lockETH.value(2 ether)(address(manager), address(ethJoin), cdp);
        this.draw(address(manager), address(jug), address(daiJoin), cdp, 300 ether);
        dai.approve(address(proxy), 100 ether);
        this.give(address(manager), cdp, address(123));
        this.wipe(address(manager), address(daiJoin), cdp, 100 ether);
        assertEq(dai.balanceOf(address(this)), 200 ether);
        assertEq(art("ETH", manager.urns(cdp)), 200 ether);
    }

    function testFailSafeWipeOtherCDPOwner() public {
        uint cdp = this.open(address(manager), "ETH");
        this.lockETH.value(2 ether)(address(manager), address(ethJoin), cdp);
        this.draw(address(manager), address(jug), address(daiJoin), cdp, 300 ether);
        dai.approve(address(proxy), 100 ether);
        this.give(address(manager), cdp, address(123));
        this.safeWipe(address(manager), address(daiJoin), cdp, 100 ether);
    }

    function testFailSafeWipeAllOtherCDPOwner() public {
        uint cdp = this.open(address(manager), "ETH");
        this.lockETH.value(2 ether)(address(manager), address(ethJoin), cdp);
        this.draw(address(manager), address(jug), address(daiJoin), cdp, 300 ether);
        dai.approve(address(proxy), 300 ether);
        this.give(address(manager), cdp, address(123));
        this.safeWipeAll(address(manager), address(daiJoin), cdp);
    }

    function testWipeAfterDrip() public {
        this.file(address(jug), bytes32("ETH"), bytes32("duty"), uint(1.05 * 10 ** 27));
        hevm.warp(now + 1);
        jug.drip("ETH");
        uint cdp = this.open(address(manager), "ETH");
        this.lockETH.value(2 ether)(address(manager), address(ethJoin), cdp);
        this.draw(address(manager), address(jug), address(daiJoin), cdp, 300 ether);
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
        this.draw(address(manager), address(jug), address(daiJoin), cdp, 300 ether);
        dai.approve(address(proxy), 300 ether);
        this.safeWipe(address(manager), address(daiJoin), cdp, 300 ether);
        assertEq(art("ETH", manager.urns(cdp)), 0);
    }

    function testWipeAllAfterDrip2() public {
        this.file(address(jug), bytes32("ETH"), bytes32("duty"), uint(1.05 * 10 ** 27));
        hevm.warp(now + 1);
        jug.drip("ETH"); // This is actually not necessary as `draw` will also call drip
        uint cdp = this.open(address(manager), "ETH");
        uint times = 30;
        this.lockETH.value(2 ether * times)(address(manager), address(ethJoin), cdp);
        for (uint i = 0; i < times; i++) {
            this.draw(address(manager), address(jug), address(daiJoin), cdp, 300 ether);
        }
        dai.approve(address(proxy), 300 ether * times);
        this.safeWipe(address(manager), address(daiJoin), cdp, 300 ether * times);
        assertEq(art("ETH", manager.urns(cdp)), 0);
    }

    function testLockETHAndDraw() public {
        uint cdp = this.open(address(manager), "ETH");
        uint initialBalance = address(this).balance;
        assertEq(ink("ETH", manager.urns(cdp)), 0);
        assertEq(dai.balanceOf(address(this)), 0);
        this.lockETHAndDraw.value(2 ether)(address(manager), address(jug), address(ethJoin), address(daiJoin), cdp, 300 ether);
        assertEq(ink("ETH", manager.urns(cdp)), 2 ether);
        assertEq(dai.balanceOf(address(this)), 300 ether);
        assertEq(address(this).balance, initialBalance - 2 ether);
    }

    function testOpenLockETHAndDraw() public {
        uint initialBalance = address(this).balance;
        assertEq(dai.balanceOf(address(this)), 0);
        uint cdp = this.openLockETHAndDraw.value(2 ether)(address(manager), address(jug), address(ethJoin), address(daiJoin), "ETH", 300 ether);
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
        this.lockGemAndDraw(address(manager), address(jug), address(colJoin), address(daiJoin), cdp, 2 ether, 10 ether, true);
        assertEq(ink("COL", manager.urns(cdp)), 2 ether);
        assertEq(dai.balanceOf(address(this)), 10 ether);
        assertEq(col.balanceOf(address(this)), 3 ether);
    }

    function testLockGemDGDAndDraw() public {
        uint cdp = this.open(address(manager), "DGD");
        dgd.approve(address(proxy), 3 * 10 ** 9);
        assertEq(ink("DGD", manager.urns(cdp)), 0);
        uint prevBalance = dgd.balanceOf(address(this));
        this.lockGemAndDraw(address(manager), address(jug), address(dgdJoin), address(daiJoin), cdp, 3 * 10 ** 9, 50 ether, true);
        assertEq(ink("DGD", manager.urns(cdp)), 3 ether);
        assertEq(dai.balanceOf(address(this)), 50 ether);
        assertEq(dgd.balanceOf(address(this)), prevBalance - 3 * 10 ** 9);
    }

    function testLockGemGNTAndDraw() public {
        uint cdp = this.open(address(manager), "GNT");
        assertEq(ink("GNT", manager.urns(cdp)), 0);
        uint prevBalance = gnt.balanceOf(address(this));
        address bag = this.makeGemBag(address(gntJoin));
        gnt.transfer(bag, 3 ether);
        this.lockGemAndDraw(address(manager), address(jug), address(gntJoin), address(daiJoin), cdp, 3 ether, 50 ether, false);
        assertEq(ink("GNT", manager.urns(cdp)), 3 ether);
        assertEq(dai.balanceOf(address(this)), 50 ether);
        assertEq(gnt.balanceOf(address(this)), prevBalance - 3 ether);
    }

    function testOpenLockGemAndDraw() public {
        col.mint(5 ether);
        col.approve(address(proxy), 2 ether);
        assertEq(dai.balanceOf(address(this)), 0);
        uint cdp = this.openLockGemAndDraw(address(manager), address(jug), address(colJoin), address(daiJoin), "COL", 2 ether, 10 ether, true);
        assertEq(ink("COL", manager.urns(cdp)), 2 ether);
        assertEq(dai.balanceOf(address(this)), 10 ether);
        assertEq(col.balanceOf(address(this)), 3 ether);
    }

    function testOpenLockGemGNTAndDraw() public {
        assertEq(dai.balanceOf(address(this)), 0);
        address bag = this.makeGemBag(address(gntJoin));
        assertEq(address(bag), gntJoin.bags(address(proxy)));
        gnt.transfer(bag, 2 ether);
        uint cdp = this.openLockGemAndDraw(address(manager), address(jug), address(gntJoin), address(daiJoin), "GNT", 2 ether, 10 ether, false);
        assertEq(ink("GNT", manager.urns(cdp)), 2 ether);
        assertEq(dai.balanceOf(address(this)), 10 ether);
    }

    function testOpenLockGemGNTAndDrawSafe() public {
        assertEq(dai.balanceOf(address(this)), 0);
        gnt.transfer(address(proxy), 2 ether);
        (address bag, uint cdp) = this.openLockGNTAndDraw(address(manager), address(jug), address(gntJoin), address(daiJoin), "GNT", 2 ether, 10 ether);
        assertEq(address(bag), gntJoin.bags(address(proxy)));
        assertEq(ink("GNT", manager.urns(cdp)), 2 ether);
        assertEq(dai.balanceOf(address(this)), 10 ether);
    }

    function testOpenLockGemGNTAndDrawSafeTwice() public {
        assertEq(dai.balanceOf(address(this)), 0);
        gnt.transfer(address(proxy), 4 ether);
        (address bag, uint cdp) = this.openLockGNTAndDraw(address(manager), address(jug), address(gntJoin), address(daiJoin), "GNT", 2 ether, 10 ether);
        (address bag2, uint cdp2) = this.openLockGNTAndDraw(address(manager), address(jug), address(gntJoin), address(daiJoin), "GNT", 2 ether, 10 ether);
        assertEq(address(bag), gntJoin.bags(address(proxy)));
        assertEq(address(bag), address(bag2));
        assertEq(ink("GNT", manager.urns(cdp)), 2 ether);
        assertEq(ink("GNT", manager.urns(cdp2)), 2 ether);
        assertEq(dai.balanceOf(address(this)), 20 ether);
    }

    function testWipeAndFreeETH() public {
        uint cdp = this.open(address(manager), "ETH");
        uint initialBalance = address(this).balance;
        this.lockETHAndDraw.value(2 ether)(address(manager), address(jug), address(ethJoin), address(daiJoin), cdp, 300 ether);
        dai.approve(address(proxy), 250 ether);
        this.wipeAndFreeETH(address(manager), address(ethJoin), address(daiJoin), cdp, 1.5 ether, 250 ether);
        assertEq(ink("ETH", manager.urns(cdp)), 0.5 ether);
        assertEq(art("ETH", manager.urns(cdp)), 50 ether);
        assertEq(dai.balanceOf(address(this)), 50 ether);
        assertEq(address(this).balance, initialBalance - 0.5 ether);
    }

    function testWipeAllAndFreeETH() public {
        uint cdp = this.open(address(manager), "ETH");
        uint initialBalance = address(this).balance;
        this.lockETHAndDraw.value(2 ether)(address(manager), address(jug), address(ethJoin), address(daiJoin), cdp, 300 ether);
        dai.approve(address(proxy), 300 ether);
        this.wipeAllAndFreeETH(address(manager), address(ethJoin), address(daiJoin), cdp, 1.5 ether);
        assertEq(ink("ETH", manager.urns(cdp)), 0.5 ether);
        assertEq(art("ETH", manager.urns(cdp)), 0);
        assertEq(dai.balanceOf(address(this)), 0);
        assertEq(address(this).balance, initialBalance - 0.5 ether);
    }

    function testWipeAndFreeGem() public {
        col.mint(5 ether);
        uint cdp = this.open(address(manager), "COL");
        col.approve(address(proxy), 2 ether);
        this.lockGemAndDraw(address(manager), address(jug), address(colJoin), address(daiJoin), cdp, 2 ether, 10 ether, true);
        dai.approve(address(proxy), 8 ether);
        this.wipeAndFreeGem(address(manager), address(colJoin), address(daiJoin), cdp, 1.5 ether, 8 ether);
        assertEq(ink("COL", manager.urns(cdp)), 0.5 ether);
        assertEq(art("COL", manager.urns(cdp)), 2 ether);
        assertEq(dai.balanceOf(address(this)), 2 ether);
        assertEq(col.balanceOf(address(this)), 4.5 ether);
    }

    function testWipeAllAndFreeGem() public {
        col.mint(5 ether);
        uint cdp = this.open(address(manager), "COL");
        col.approve(address(proxy), 2 ether);
        this.lockGemAndDraw(address(manager), address(jug), address(colJoin), address(daiJoin), cdp, 2 ether, 10 ether, true);
        dai.approve(address(proxy), 10 ether);
        this.wipeAllAndFreeGem(address(manager), address(colJoin), address(daiJoin), cdp, 1.5 ether);
        assertEq(ink("COL", manager.urns(cdp)), 0.5 ether);
        assertEq(art("COL", manager.urns(cdp)), 0);
        assertEq(dai.balanceOf(address(this)), 0);
        assertEq(col.balanceOf(address(this)), 4.5 ether);
    }

    function testWipeAndFreeGemDGDAndDraw() public {
        uint cdp = this.open(address(manager), "DGD");
        dgd.approve(address(proxy), 3 * 10 ** 9);
        assertEq(ink("DGD", manager.urns(cdp)), 0);
        uint prevBalance = dgd.balanceOf(address(this));
        this.lockGemAndDraw(address(manager), address(jug), address(dgdJoin), address(daiJoin), cdp, 3 * 10 ** 9, 50 ether, true);
        dai.approve(address(proxy), 25 ether);
        this.wipeAndFreeGem(address(manager), address(dgdJoin), address(daiJoin), cdp, 1 * 10 ** 9, 25 ether);
        assertEq(ink("DGD", manager.urns(cdp)), 2 ether);
        assertEq(dai.balanceOf(address(this)), 25 ether);
        assertEq(dgd.balanceOf(address(this)), prevBalance - 2 * 10 ** 9);
    }

    function testPreventHigherDaiOnWipe() public {
        uint cdp = this.open(address(manager), "ETH");
        this.lockETHAndDraw.value(2 ether)(address(manager), address(jug), address(ethJoin), address(daiJoin), cdp, 300 ether);

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
        this.lockETHAndDraw.value(1 ether)(address(manager), address(jug), address(ethJoin), address(daiJoin), cdp, 50 ether);

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
        uint cdp = this.open(address(manager), "ETH");
        this.lockETHAndDraw.value(1 ether)(address(manager), address(jug), address(ethJoin), address(daiJoin), cdp, 50 ether);
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
        uint cdp = this.open(address(manager), "ETH");
        this.lockETHAndDraw.value(1 ether)(address(manager), address(jug), address(ethJoin), address(daiJoin), cdp, 50 ether);
        dai.approve(address(proxy), 50 ether);
        assertEq(dai.balanceOf(address(this)), 50 ether);
        assertEq(pot.pie(address(this)), 0 ether);
        this.dsrJoin(address(daiJoin), address(pot), 50 ether);
        assertEq(dai.balanceOf(address(this)), 0 ether);
        // Due rounding the DAI equivalent is not the same than initial wad amount
        assertEq(pot.pie(address(proxy)) * pot.chi(), 49999999999999999999350000000000000000000000000);
        hevm.warp(initialTime + 1);
        pot.drip(); // Just necessary to check in this test the updated value of chi
        assertEq(pot.pie(address(proxy)) * pot.chi(), 52499999999999999999317500000000000000000000000);
        this.dsrExit(address(daiJoin), address(pot), 52.5 ether);
        assertEq(dai.balanceOf(address(this)), 52499999999999999999);
        assertEq(pot.pie(address(proxy)), 0);
    }

    function testDSRRounding2() public {
        this.file(address(pot), "dsr", uint(1.03434234324 * 10 ** 27));
        uint initialTime = 1;
        hevm.warp(initialTime);
        uint cdp = this.open(address(manager), "ETH");
        this.lockETHAndDraw.value(1 ether)(address(manager), address(jug), address(ethJoin), address(daiJoin), cdp, 50 ether);
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
        uint cdp = this.open(address(manager), "ETH");
        this.lockETHAndDraw.value(1 ether)(address(manager), address(jug), address(ethJoin), address(daiJoin), cdp, 50 ether);
        dai.approve(address(proxy), 50 ether);
        this.dsrJoin(address(daiJoin), address(pot), 50 ether);
        this.dsrExitAll(address(daiJoin), address(pot));
        // In this case we get 49.999 DAI back as the returned amount is based purely in the pie amount
        assertEq(dai.balanceOf(address(this)), 49999999999999999999);
    }
}
