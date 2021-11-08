// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.6.12;

import "ds-test/test.sol";

import "./DssProxyActions.sol";

import {DssDeployTestBase, GemJoin, Flipper} from "dss-deploy/DssDeploy.t.base.sol";
import {DGD} from "dss-gem-joins/tokens/DGD.sol";
import {GemJoin3} from "dss-gem-joins/join-3.sol";
import {GemJoin4} from "dss-gem-joins/join-4.sol";
import {DSValue} from "ds-value/value.sol";
import {DssCdpManager} from "dss-cdp-manager/DssCdpManager.sol";
import {GetCdps} from "dss-cdp-manager/GetCdps.sol";
import {ProxyRegistry, DSProxyFactory, DSProxy} from "proxy-registry/ProxyRegistry.sol";
import {WETH9_} from "ds-weth/weth9.sol";

contract ProxyCalls {
    DSProxy proxy;
    address dssProxyActions;
    address dssProxyActionsEnd;
    address dssProxyActionsDsr;

    function transfer(address, address, uint256) public {
        proxy.execute(dssProxyActions, msg.data);
    }

    function open(bytes32, address) public returns (uint256 cdp) {
        bytes memory response = proxy.execute(dssProxyActions, msg.data);
        assembly {
            cdp := mload(add(response, 0x20))
        }
    }

    function give(uint256, address) public {
        proxy.execute(dssProxyActions, msg.data);
    }

    function giveToProxy(address, uint256, address) public {
        proxy.execute(dssProxyActions, msg.data);
    }

    function cdpAllow(uint256, address, uint256) public {
        proxy.execute(dssProxyActions, msg.data);
    }

    function urnAllow(address, uint256) public {
        proxy.execute(dssProxyActions, msg.data);
    }

    function hope(address, address) public {
        proxy.execute(dssProxyActions, msg.data);
    }

    function nope(address, address) public {
        proxy.execute(dssProxyActions, msg.data);
    }

    function flux(uint256, address, uint256) public {
        proxy.execute(dssProxyActions, msg.data);
    }

    function move(uint256, address, uint256) public {
        proxy.execute(dssProxyActions, msg.data);
    }

    function frob(uint256, int256, int256) public {
        proxy.execute(dssProxyActions, msg.data);
    }

    function quit(uint256, address) public {
        proxy.execute(dssProxyActions, msg.data);
    }

    function enter(address, uint256) public {
        proxy.execute(dssProxyActions, msg.data);
    }

    function shift(uint256, uint256) public {
        proxy.execute(dssProxyActions, msg.data);
    }

    function lockETH(address, uint256) public payable {
        (bool success,) = address(proxy).call{value: msg.value}(abi.encodeWithSignature("execute(address,bytes)", dssProxyActions, msg.data));
        require(success, "");
    }

    function safeLockETH(address, uint256, address) public payable {
        (bool success,) = address(proxy).call{value: msg.value}(abi.encodeWithSignature("execute(address,bytes)", dssProxyActions, msg.data));
        require(success, "");
    }

    function lockGem(address, uint256, uint256) public {
        proxy.execute(dssProxyActions, msg.data);
    }

    function safeLockGem(address, uint256, uint256, address) public {
        proxy.execute(dssProxyActions, msg.data);
    }

    function freeETH(address, uint256, uint256) public {
        proxy.execute(dssProxyActions, msg.data);
    }

    function freeGem(address, uint256, uint256) public {
        proxy.execute(dssProxyActions, msg.data);
    }

    function exitETH(address, uint256, uint256) public {
        proxy.execute(dssProxyActions, msg.data);
    }

    function exitGem(address, uint256, uint256) public {
        proxy.execute(dssProxyActions, msg.data);
    }

    function draw(address, address, uint256, uint256) public {
        proxy.execute(dssProxyActions, msg.data);
    }

    function wipe(address, uint256, uint256) public {
        proxy.execute(dssProxyActions, msg.data);
    }

    function wipeAll(address, uint256) public {
        proxy.execute(dssProxyActions, msg.data);
    }

    function safeWipe(address, uint256, uint256, address) public {
        proxy.execute(dssProxyActions, msg.data);
    }

    function safeWipeAll(address, uint256, address) public {
        proxy.execute(dssProxyActions, msg.data);
    }

    function lockETHAndDraw(address, address, address, uint256, uint256) public payable {
        (bool success,) = address(proxy).call{value: msg.value}(abi.encodeWithSignature("execute(address,bytes)", dssProxyActions, msg.data));
        require(success, "");
    }

    function openLockETHAndDraw(address, address, address, bytes32, uint256) public payable returns (uint256 cdp) {
        address payable target = address(proxy);
        bytes memory data = abi.encodeWithSignature("execute(address,bytes)", dssProxyActions, msg.data);
        assembly {
            let succeeded := call(sub(gas(), 5000), target, callvalue(), add(data, 0x20), mload(data), 0, 0)
            let size := returndatasize()
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

    function lockGemAndDraw(address, address, address, uint256, uint256, uint256) public {
        proxy.execute(dssProxyActions, msg.data);
    }

    function openLockGemAndDraw(address, address, address, bytes32, uint256, uint256) public returns (uint256 cdp) {
        bytes memory response = proxy.execute(dssProxyActions, msg.data);
        assembly {
            cdp := mload(add(response, 0x20))
        }
    }

    function wipeAndFreeETH(address, address, uint256, uint256, uint256) public {
        proxy.execute(dssProxyActions, msg.data);
    }

    function wipeAllAndFreeETH(address, address, uint256, uint256) public {
        proxy.execute(dssProxyActions, msg.data);
    }

    function wipeAndFreeGem(address, address, uint256, uint256, uint256) public {
        proxy.execute(dssProxyActions, msg.data);
    }

    function wipeAllAndFreeGem(address, address, uint256, uint256) public {
        proxy.execute(dssProxyActions, msg.data);
    }

    function end_freeETH(address a, address b, uint256 c) public {
        proxy.execute(dssProxyActionsEnd, abi.encodeWithSignature("freeETH(address,address,uint256)", a, b, c));
    }

    function end_freeGem(address a, address b, uint256 c) public {
        proxy.execute(dssProxyActionsEnd, abi.encodeWithSignature("freeGem(address,address,uint256)", a, b, c));
    }

    function end_pack(address a, address b, uint256 c) public {
        proxy.execute(dssProxyActionsEnd, abi.encodeWithSignature("pack(address,address,uint256)", a, b, c));
    }

    function end_cashETH(address a, address b, bytes32 c, uint256 d) public {
        proxy.execute(dssProxyActionsEnd, abi.encodeWithSignature("cashETH(address,address,bytes32,uint256)", a, b, c, d));
    }

    function end_cashGem(address a, address b, bytes32 c, uint256 d) public {
        proxy.execute(dssProxyActionsEnd, abi.encodeWithSignature("cashGem(address,address,bytes32,uint256)", a, b, c, d));
    }

    function dsr_join(address a, address b, uint256 c) public {
        proxy.execute(dssProxyActionsDsr, abi.encodeWithSignature("join(address,address,uint256)", a, b, c));
    }

    function dsr_exit(address a, address b, uint256 c) public {
        proxy.execute(dssProxyActionsDsr, abi.encodeWithSignature("exit(address,address,uint256)", a, b, c));
    }

    function dsr_exitAll(address a, address b) public {
        proxy.execute(dssProxyActionsDsr, abi.encodeWithSignature("exitAll(address,address)", a, b));
    }
}

contract FakeUser {
    function doGive(
        DssCdpManager manager,
        uint256 cdp,
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
    Flipper dgdFlip;
    ProxyRegistry registry;
    WETH9_ realWeth;

    function setUp() public override {
        super.setUp();
        deployKeepAuth();

        // Create a real WETH token and replace it with a new adapter in the vat
        realWeth = new WETH9_();
        this.deny(address(vat), address(ethJoin));
        ethJoin = new GemJoin(address(vat), "ETH", address(realWeth));
        this.rely(address(vat), address(ethJoin));

        // Add a token collateral
        dgd = new DGD(1000 * 10 ** 9);
        dgdJoin = new GemJoin3(address(vat), "DGD", address(dgd), 9);
        pipDGD = new DSValue();
        dssDeploy.deployCollateralFlip("DGD", address(dgdJoin), address(pipDGD));
        (dgdFlip,,) = dssDeploy.ilks("DGD");
        pipDGD.poke(bytes32(uint256(50 ether))); // Price 50 DAI = 1 DGD (in precision 18)
        this.file(address(spotter), "DGD", "mat", uint256(1500000000 ether)); // Liquidation ratio 150%
        this.file(address(vat), bytes32("DGD"), bytes32("line"), uint256(10000 * 10 ** 45));
        spotter.poke("DGD");
        (,,uint256 spot,,) = vat.ilks("DGD");
        assertEq(spot, 50 * RAY * RAY / 1500000000 ether);

        manager = new DssCdpManager(address(vat));
        DSProxyFactory factory = new DSProxyFactory();
        registry = new ProxyRegistry(address(factory));
        dssProxyActions = address(new DssProxyActions(address(vat), address(manager)));
        dssProxyActionsEnd = address(new DssProxyActionsEnd(address(vat), address(manager)));
        dssProxyActionsDsr = address(new DssProxyActionsDsr(address(vat)));
        proxy = DSProxy(registry.build());
    }

    function ink(bytes32 ilk, address urn) public view returns (uint256 inkV) {
        (inkV,) = vat.urns(ilk, urn);
    }

    function art(bytes32 ilk, address urn) public view returns (uint256 artV) {
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
        uint256 cdp = this.open("ETH", address(proxy));
        assertEq(cdp, 1);
        assertEq(manager.owns(cdp), address(proxy));
    }

    function testGiveCDP() public {
        uint256 cdp = this.open("ETH", address(proxy));
        this.give(cdp, address(123));
        assertEq(manager.owns(cdp), address(123));
    }

    function testGiveCDPToProxy() public {
        uint256 cdp = this.open("ETH", address(proxy));
        address userProxy = registry.build(address(123));
        this.giveToProxy(address(registry), cdp, address(123));
        assertEq(manager.owns(cdp), userProxy);
    }

    function testGiveCDPToNewProxy() public {
        uint256 cdp = this.open("ETH", address(proxy));
        assertEq(address(registry.proxies(address(123))), address(0));
        this.giveToProxy(address(registry), cdp, address(123));
        DSProxy userProxy = registry.proxies(address(123));
        assertTrue(address(userProxy) != address(0));
        assertEq(userProxy.owner(), address(123));
        assertEq(manager.owns(cdp), address(userProxy));
    }

    function testFailGiveCDPToNewContractProxy() public {
        uint256 cdp = this.open("ETH", address(proxy));
        FakeUser user = new FakeUser();
        assertEq(address(registry.proxies(address(user))), address(0));
        this.giveToProxy(address(registry), cdp, address(user)); // Fails as user is a contract and not a regular address
    }

    function testGiveCDPAllowedUser() public {
        uint256 cdp = this.open("ETH", address(proxy));
        FakeUser user = new FakeUser();
        this.cdpAllow(cdp, address(user), 1);
        user.doGive(manager, cdp, address(123));
        assertEq(manager.owns(cdp), address(123));
    }

    function testAllowUrn() public {
        assertEq(manager.urnCan(address(proxy), address(123)), 0);
        this.urnAllow(address(123), 1);
        assertEq(manager.urnCan(address(proxy), address(123)), 1);
        this.urnAllow(address(123), 0);
        assertEq(manager.urnCan(address(proxy), address(123)), 0);
    }

    function testFlux() public {
        uint256 cdp = this.open("ETH", address(proxy));

        assertEq(dai.balanceOf(address(this)), 0);
        realWeth.deposit{value: 1 ether}();
        realWeth.approve(address(ethJoin), uint256(-1));
        ethJoin.join(manager.urns(cdp), 1 ether);
        assertEq(vat.gem("ETH", address(this)), 0);
        assertEq(vat.gem("ETH", manager.urns(cdp)), 1 ether);

        this.flux(cdp, address(this), 0.75 ether);

        assertEq(vat.gem("ETH", address(this)), 0.75 ether);
        assertEq(vat.gem("ETH", manager.urns(cdp)), 0.25 ether);
    }

    function testFrob() public {
        uint256 cdp = this.open("ETH", address(proxy));

        assertEq(dai.balanceOf(address(this)), 0);
        realWeth.deposit{value: 1 ether}();
        realWeth.approve(address(ethJoin), uint256(-1));
        ethJoin.join(manager.urns(cdp), 1 ether);

        this.frob(cdp, 0.5 ether, 60 ether);
        assertEq(vat.gem("ETH", manager.urns(cdp)), 0.5 ether);
        assertEq(vat.dai(manager.urns(cdp)), mul(RAY, 60 ether));
        assertEq(vat.dai(address(this)), 0);

        this.move(cdp, address(this), mul(RAY, 60 ether));
        assertEq(vat.dai(manager.urns(cdp)), 0);
        assertEq(vat.dai(address(this)), mul(RAY, 60 ether));

        vat.hope(address(daiJoin));
        daiJoin.exit(address(this), 60 ether);
        assertEq(dai.balanceOf(address(this)), 60 ether);
    }

    function testLockETH() public {
        uint256 initialBalance = address(this).balance;
        uint256 cdp = this.open("ETH", address(proxy));
        assertEq(ink("ETH", manager.urns(cdp)), 0);
        this.lockETH{value: 2 ether}(address(ethJoin), cdp);
        assertEq(ink("ETH", manager.urns(cdp)), 2 ether);
        assertEq(address(this).balance, initialBalance - 2 ether);
    }

    function testSafeLockETH() public {
        uint256 initialBalance = address(this).balance;
        uint256 cdp = this.open("ETH", address(proxy));
        assertEq(ink("ETH", manager.urns(cdp)), 0);
        this.safeLockETH{value: 2 ether}(address(ethJoin), cdp, address(proxy));
        assertEq(ink("ETH", manager.urns(cdp)), 2 ether);
        assertEq(address(this).balance, initialBalance - 2 ether);
    }

    function testLockETHOtherCDPOwner() public {
        uint256 initialBalance = address(this).balance;
        uint256 cdp = this.open("ETH", address(proxy));
        this.give(cdp, address(123));
        assertEq(ink("ETH", manager.urns(cdp)), 0);
        this.lockETH{value: 2 ether}(address(ethJoin), cdp);
        assertEq(ink("ETH", manager.urns(cdp)), 2 ether);
        assertEq(address(this).balance, initialBalance - 2 ether);
    }

    function testFailSafeLockETHOtherCDPOwner() public {
        uint256 cdp = this.open("ETH", address(proxy));
        this.give(cdp, address(123));
        this.safeLockETH{value: 2 ether}(address(ethJoin), cdp, address(321));
    }

    function testLockGem() public {
        col.mint(5 ether);
        uint256 cdp = this.open("COL", address(proxy));
        col.approve(address(proxy), 2 ether);
        assertEq(ink("COL", manager.urns(cdp)), 0);
        this.lockGem(address(colJoin), cdp, 2 ether);
        assertEq(ink("COL", manager.urns(cdp)), 2 ether);
        assertEq(col.balanceOf(address(this)), 3 ether);
    }

    function testSafeLockGem() public {
        col.mint(5 ether);
        uint256 cdp = this.open("COL", address(proxy));
        col.approve(address(proxy), 2 ether);
        assertEq(ink("COL", manager.urns(cdp)), 0);
        this.safeLockGem(address(colJoin), cdp, 2 ether, address(proxy));
        assertEq(ink("COL", manager.urns(cdp)), 2 ether);
        assertEq(col.balanceOf(address(this)), 3 ether);
    }

    function testLockGemDGD() public {
        uint256 cdp = this.open("DGD", address(proxy));
        dgd.approve(address(proxy), 2 * 10 ** 9);
        assertEq(ink("DGD", manager.urns(cdp)), 0);
        uint256 prevBalance = dgd.balanceOf(address(this));
        this.lockGem(address(dgdJoin), cdp, 2 * 10 ** 9);
        assertEq(ink("DGD", manager.urns(cdp)),  2 ether);
        assertEq(dgd.balanceOf(address(this)), prevBalance - 2 * 10 ** 9);
    }

    function testLockGemOtherCDPOwner() public {
        col.mint(5 ether);
        uint256 cdp = this.open("COL", address(proxy));
        this.give(cdp, address(123));
        col.approve(address(proxy), 2 ether);
        assertEq(ink("COL", manager.urns(cdp)), 0);
        this.lockGem(address(colJoin), cdp, 2 ether);
        assertEq(ink("COL", manager.urns(cdp)), 2 ether);
        assertEq(col.balanceOf(address(this)), 3 ether);
    }

    function testFailSafeLockGemOtherCDPOwner() public {
        col.mint(5 ether);
        uint256 cdp = this.open("COL", address(proxy));
        this.give(cdp, address(123));
        col.approve(address(proxy), 2 ether);
        this.safeLockGem(address(colJoin), cdp, 2 ether, address(321));
    }

    function testFreeETH() public {
        uint256 initialBalance = address(this).balance;
        uint256 cdp = this.open("ETH", address(proxy));
        this.lockETH{value: 2 ether}(address(ethJoin), cdp);
        this.freeETH(address(ethJoin), cdp, 1 ether);
        assertEq(ink("ETH", manager.urns(cdp)), 1 ether);
        assertEq(address(this).balance, initialBalance - 1 ether);
    }

    function testFreeGem() public {
        col.mint(5 ether);
        uint256 cdp = this.open("COL", address(proxy));
        col.approve(address(proxy), 2 ether);
        this.lockGem(address(colJoin), cdp, 2 ether);
        this.freeGem(address(colJoin), cdp, 1 ether);
        assertEq(ink("COL", manager.urns(cdp)), 1 ether);
        assertEq(col.balanceOf(address(this)), 4 ether);
    }

    function testFreeGemDGD() public {
        uint256 cdp = this.open("DGD", address(proxy));
        dgd.approve(address(proxy), 2 * 10 ** 9);
        assertEq(ink("DGD", manager.urns(cdp)), 0);
        uint256 prevBalance = dgd.balanceOf(address(this));
        this.lockGem(address(dgdJoin), cdp, 2 * 10 ** 9);
        this.freeGem(address(dgdJoin), cdp, 1 * 10 ** 9);
        assertEq(ink("DGD", manager.urns(cdp)),  1 ether);
        assertEq(dgd.balanceOf(address(this)), prevBalance - 1 * 10 ** 9);
    }

    function testDraw() public {
        uint256 cdp = this.open("ETH", address(proxy));
        this.lockETH{value: 2 ether}(address(ethJoin), cdp);
        assertEq(dai.balanceOf(address(this)), 0);
        this.draw(address(jug), address(daiJoin), cdp, 300 ether);
        assertEq(dai.balanceOf(address(this)), 300 ether);
        assertEq(art("ETH", manager.urns(cdp)), 300 ether);
    }

    function testDrawAfterDrip() public {
        this.file(address(jug), bytes32("ETH"), bytes32("duty"), uint256(1.05 * 10 ** 27));
        hevm.warp(now + 1);
        jug.drip("ETH"); // This is actually not necessary as `draw` will also call drip
        uint256 cdp = this.open("ETH", address(proxy));
        this.lockETH{value: 2 ether}(address(ethJoin), cdp);
        assertEq(dai.balanceOf(address(this)), 0);
        this.draw(address(jug), address(daiJoin), cdp, 300 ether);
        assertEq(dai.balanceOf(address(this)), 300 ether);
        assertEq(art("ETH", manager.urns(cdp)), mul(300 ether, RAY) / (1.05 * 10 ** 27) + 1); // Extra wei due rounding
    }

    function testWipe() public {
        uint256 cdp = this.open("ETH", address(proxy));
        this.lockETH{value: 2 ether}(address(ethJoin), cdp);
        this.draw(address(jug), address(daiJoin), cdp, 300 ether);
        dai.approve(address(proxy), 100 ether);
        this.wipe(address(daiJoin), cdp, 100 ether);
        assertEq(dai.balanceOf(address(this)), 200 ether);
        assertEq(art("ETH", manager.urns(cdp)), 200 ether);
    }

    function testWipeAll() public {
        uint256 cdp = this.open("ETH", address(proxy));
        this.lockETH{value: 2 ether}(address(ethJoin), cdp);
        this.draw(address(jug), address(daiJoin), cdp, 300 ether);
        dai.approve(address(proxy), 300 ether);
        this.wipeAll(address(daiJoin), cdp);
        assertEq(dai.balanceOf(address(this)), 0);
        assertEq(art("ETH", manager.urns(cdp)), 0);
    }

    function testSafeWipe() public {
        uint256 cdp = this.open("ETH", address(proxy));
        this.lockETH{value: 2 ether}(address(ethJoin), cdp);
        this.draw(address(jug), address(daiJoin), cdp, 300 ether);
        dai.approve(address(proxy), 100 ether);
        this.safeWipe(address(daiJoin), cdp, 100 ether, address(proxy));
        assertEq(dai.balanceOf(address(this)), 200 ether);
        assertEq(art("ETH", manager.urns(cdp)), 200 ether);
    }

    function testSafeWipeAll() public {
        uint256 cdp = this.open("ETH", address(proxy));
        this.lockETH{value: 2 ether}(address(ethJoin), cdp);
        this.draw(address(jug), address(daiJoin), cdp, 300 ether);
        dai.approve(address(proxy), 300 ether);
        this.safeWipeAll(address(daiJoin), cdp, address(proxy));
        assertEq(dai.balanceOf(address(this)), 0);
        assertEq(art("ETH", manager.urns(cdp)), 0);
    }

    function testWipeOtherCDPOwner() public {
        uint256 cdp = this.open("ETH", address(proxy));
        this.lockETH{value: 2 ether}(address(ethJoin), cdp);
        this.draw(address(jug), address(daiJoin), cdp, 300 ether);
        dai.approve(address(proxy), 100 ether);
        this.give(cdp, address(123));
        this.wipe(address(daiJoin), cdp, 100 ether);
        assertEq(dai.balanceOf(address(this)), 200 ether);
        assertEq(art("ETH", manager.urns(cdp)), 200 ether);
    }

    function testFailSafeWipeOtherCDPOwner() public {
        uint256 cdp = this.open("ETH", address(proxy));
        this.lockETH{value: 2 ether}(address(ethJoin), cdp);
        this.draw(address(jug), address(daiJoin), cdp, 300 ether);
        dai.approve(address(proxy), 100 ether);
        this.give(cdp, address(123));
        this.safeWipe(address(daiJoin), cdp, 100 ether, address(321));
    }

    function testFailSafeWipeAllOtherCDPOwner() public {
        uint256 cdp = this.open("ETH", address(proxy));
        this.lockETH{value: 2 ether}(address(ethJoin), cdp);
        this.draw(address(jug), address(daiJoin), cdp, 300 ether);
        dai.approve(address(proxy), 300 ether);
        this.give(cdp, address(123));
        this.safeWipeAll(address(daiJoin), cdp, address(321));
    }

    function testWipeAfterDrip() public {
        this.file(address(jug), bytes32("ETH"), bytes32("duty"), uint256(1.05 * 10 ** 27));
        hevm.warp(now + 1);
        jug.drip("ETH");
        uint256 cdp = this.open("ETH", address(proxy));
        this.lockETH{value: 2 ether}(address(ethJoin), cdp);
        this.draw(address(jug), address(daiJoin), cdp, 300 ether);
        dai.approve(address(proxy), 100 ether);
        this.wipe(address(daiJoin), cdp, 100 ether);
        assertEq(dai.balanceOf(address(this)), 200 ether);
        assertEq(art("ETH", manager.urns(cdp)), mul(200 ether, RAY) / (1.05 * 10 ** 27) + 1);
    }

    function testWipeAllAfterDrip() public {
        this.file(address(jug), bytes32("ETH"), bytes32("duty"), uint256(1.05 * 10 ** 27));
        hevm.warp(now + 1);
        jug.drip("ETH");
        uint256 cdp = this.open("ETH", address(proxy));
        this.lockETH{value: 2 ether}(address(ethJoin), cdp);
        this.draw(address(jug), address(daiJoin), cdp, 300 ether);
        dai.approve(address(proxy), 300 ether);
        this.wipe(address(daiJoin), cdp, 300 ether);
        assertEq(art("ETH", manager.urns(cdp)), 0);
    }

    function testWipeAllAfterDrip2() public {
        this.file(address(jug), bytes32("ETH"), bytes32("duty"), uint256(1.05 * 10 ** 27));
        hevm.warp(now + 1);
        jug.drip("ETH"); // This is actually not necessary as `draw` will also call drip
        uint256 cdp = this.open("ETH", address(proxy));
        uint256 times = 30;
        this.lockETH{value: 2 ether * times}(address(ethJoin), cdp);
        for (uint256 i = 0; i < times; i++) {
            this.draw(address(jug), address(daiJoin), cdp, 300 ether);
        }
        dai.approve(address(proxy), 300 ether * times);
        this.wipe(address(daiJoin), cdp, 300 ether * times);
        assertEq(art("ETH", manager.urns(cdp)), 0);
    }

    function testLockETHAndDraw() public {
        uint256 cdp = this.open("ETH", address(proxy));
        uint256 initialBalance = address(this).balance;
        assertEq(ink("ETH", manager.urns(cdp)), 0);
        assertEq(dai.balanceOf(address(this)), 0);
        this.lockETHAndDraw{value: 2 ether}(address(jug), address(ethJoin), address(daiJoin), cdp, 300 ether);
        assertEq(ink("ETH", manager.urns(cdp)), 2 ether);
        assertEq(dai.balanceOf(address(this)), 300 ether);
        assertEq(address(this).balance, initialBalance - 2 ether);
    }

    function testOpenLockETHAndDraw() public {
        uint256 initialBalance = address(this).balance;
        assertEq(dai.balanceOf(address(this)), 0);
        uint256 cdp = this.openLockETHAndDraw{value: 2 ether}(address(jug), address(ethJoin), address(daiJoin), "ETH", 300 ether);
        assertEq(ink("ETH", manager.urns(cdp)), 2 ether);
        assertEq(dai.balanceOf(address(this)), 300 ether);
        assertEq(address(this).balance, initialBalance - 2 ether);
    }

    function testLockGemAndDraw() public {
        col.mint(5 ether);
        uint256 cdp = this.open("COL", address(proxy));
        col.approve(address(proxy), 2 ether);
        assertEq(ink("COL", manager.urns(cdp)), 0);
        assertEq(dai.balanceOf(address(this)), 0);
        this.lockGemAndDraw(address(jug), address(colJoin), address(daiJoin), cdp, 2 ether, 10 ether);
        assertEq(ink("COL", manager.urns(cdp)), 2 ether);
        assertEq(dai.balanceOf(address(this)), 10 ether);
        assertEq(col.balanceOf(address(this)), 3 ether);
    }

    function testLockGemDGDAndDraw() public {
        uint256 cdp = this.open("DGD", address(proxy));
        dgd.approve(address(proxy), 3 * 10 ** 9);
        assertEq(ink("DGD", manager.urns(cdp)), 0);
        uint256 prevBalance = dgd.balanceOf(address(this));
        this.lockGemAndDraw(address(jug), address(dgdJoin), address(daiJoin), cdp, 3 * 10 ** 9, 50 ether);
        assertEq(ink("DGD", manager.urns(cdp)), 3 ether);
        assertEq(dai.balanceOf(address(this)), 50 ether);
        assertEq(dgd.balanceOf(address(this)), prevBalance - 3 * 10 ** 9);
    }

    function testOpenLockGemAndDraw() public {
        col.mint(5 ether);
        col.approve(address(proxy), 2 ether);
        assertEq(dai.balanceOf(address(this)), 0);
        uint256 cdp = this.openLockGemAndDraw(address(jug), address(colJoin), address(daiJoin), "COL", 2 ether, 10 ether);
        assertEq(ink("COL", manager.urns(cdp)), 2 ether);
        assertEq(dai.balanceOf(address(this)), 10 ether);
        assertEq(col.balanceOf(address(this)), 3 ether);
    }

    function testWipeAndFreeETH() public {
        uint256 cdp = this.open("ETH", address(proxy));
        uint256 initialBalance = address(this).balance;
        this.lockETHAndDraw{value: 2 ether}(address(jug), address(ethJoin), address(daiJoin), cdp, 300 ether);
        dai.approve(address(proxy), 250 ether);
        this.wipeAndFreeETH(address(ethJoin), address(daiJoin), cdp, 1.5 ether, 250 ether);
        assertEq(ink("ETH", manager.urns(cdp)), 0.5 ether);
        assertEq(art("ETH", manager.urns(cdp)), 50 ether);
        assertEq(dai.balanceOf(address(this)), 50 ether);
        assertEq(address(this).balance, initialBalance - 0.5 ether);
    }

    function testWipeAllAndFreeETH() public {
        uint256 cdp = this.open("ETH", address(proxy));
        uint256 initialBalance = address(this).balance;
        this.lockETHAndDraw{value: 2 ether}(address(jug), address(ethJoin), address(daiJoin), cdp, 300 ether);
        dai.approve(address(proxy), 300 ether);
        this.wipeAllAndFreeETH(address(ethJoin), address(daiJoin), cdp, 1.5 ether);
        assertEq(ink("ETH", manager.urns(cdp)), 0.5 ether);
        assertEq(art("ETH", manager.urns(cdp)), 0);
        assertEq(dai.balanceOf(address(this)), 0);
        assertEq(address(this).balance, initialBalance - 0.5 ether);
    }

    function testWipeAndFreeGem() public {
        col.mint(5 ether);
        uint256 cdp = this.open("COL", address(proxy));
        col.approve(address(proxy), 2 ether);
        this.lockGemAndDraw(address(jug), address(colJoin), address(daiJoin), cdp, 2 ether, 10 ether);
        dai.approve(address(proxy), 8 ether);
        this.wipeAndFreeGem(address(colJoin), address(daiJoin), cdp, 1.5 ether, 8 ether);
        assertEq(ink("COL", manager.urns(cdp)), 0.5 ether);
        assertEq(art("COL", manager.urns(cdp)), 2 ether);
        assertEq(dai.balanceOf(address(this)), 2 ether);
        assertEq(col.balanceOf(address(this)), 4.5 ether);
    }

    function testWipeAllAndFreeGem() public {
        col.mint(5 ether);
        uint256 cdp = this.open("COL", address(proxy));
        col.approve(address(proxy), 2 ether);
        this.lockGemAndDraw(address(jug), address(colJoin), address(daiJoin), cdp, 2 ether, 10 ether);
        dai.approve(address(proxy), 10 ether);
        this.wipeAllAndFreeGem(address(colJoin), address(daiJoin), cdp, 1.5 ether);
        assertEq(ink("COL", manager.urns(cdp)), 0.5 ether);
        assertEq(art("COL", manager.urns(cdp)), 0);
        assertEq(dai.balanceOf(address(this)), 0);
        assertEq(col.balanceOf(address(this)), 4.5 ether);
    }

    function testWipeAndFreeGemDGDAndDraw() public {
        uint256 cdp = this.open("DGD", address(proxy));
        dgd.approve(address(proxy), 3 * 10 ** 9);
        assertEq(ink("DGD", manager.urns(cdp)), 0);
        uint256 prevBalance = dgd.balanceOf(address(this));
        this.lockGemAndDraw(address(jug), address(dgdJoin), address(daiJoin), cdp, 3 * 10 ** 9, 50 ether);
        dai.approve(address(proxy), 25 ether);
        this.wipeAndFreeGem(address(dgdJoin), address(daiJoin), cdp, 1 * 10 ** 9, 25 ether);
        assertEq(ink("DGD", manager.urns(cdp)), 2 ether);
        assertEq(dai.balanceOf(address(this)), 25 ether);
        assertEq(dgd.balanceOf(address(this)), prevBalance - 2 * 10 ** 9);
    }

    function testPreventHigherDaiOnWipe() public {
        uint256 cdp = this.open("ETH", address(proxy));
        this.lockETHAndDraw{value: 2 ether}(address(jug), address(ethJoin), address(daiJoin), cdp, 300 ether);

        realWeth.deposit{value: 2 ether}();
        realWeth.approve(address(ethJoin), 2 ether);
        ethJoin.join(address(this), 2 ether);
        vat.frob("ETH", address(this), address(this), address(this), 1 ether, 150 ether);
        vat.move(address(this), manager.urns(cdp), 150 ether);

        dai.approve(address(proxy), 300 ether);
        this.wipe(address(daiJoin), cdp, 300 ether);
    }

    function testHopeNope() public {
        assertEq(vat.can(address(proxy), address(123)), 0);
        this.hope(address(vat), address(123));
        assertEq(vat.can(address(proxy), address(123)), 1);
        this.nope(address(vat), address(123));
        assertEq(vat.can(address(proxy), address(123)), 0);
    }

    function testQuit() public {
        uint256 cdp = this.open("ETH", address(proxy));
        this.lockETHAndDraw{value: 1 ether}(address(jug), address(ethJoin), address(daiJoin), cdp, 50 ether);

        assertEq(ink("ETH", manager.urns(cdp)), 1 ether);
        assertEq(art("ETH", manager.urns(cdp)), 50 ether);
        assertEq(ink("ETH", address(proxy)), 0);
        assertEq(art("ETH", address(proxy)), 0);

        this.hope(address(vat), address(manager));
        this.quit(cdp, address(proxy));

        assertEq(ink("ETH", manager.urns(cdp)), 0);
        assertEq(art("ETH", manager.urns(cdp)), 0);
        assertEq(ink("ETH", address(proxy)), 1 ether);
        assertEq(art("ETH", address(proxy)), 50 ether);
    }

    function testEnter() public {
        realWeth.deposit{value: 1 ether}();
        realWeth.approve(address(ethJoin), 1 ether);
        ethJoin.join(address(this), 1 ether);
        vat.frob("ETH", address(this), address(this), address(this), 1 ether, 50 ether);
        uint256 cdp = this.open("ETH", address(proxy));

        assertEq(ink("ETH", manager.urns(cdp)), 0);
        assertEq(art("ETH", manager.urns(cdp)), 0);
        assertEq(ink("ETH", address(this)), 1 ether);
        assertEq(art("ETH", address(this)), 50 ether);

        vat.hope(address(manager));
        manager.urnAllow(address(proxy), 1);
        this.enter(address(this), cdp);

        assertEq(ink("ETH", manager.urns(cdp)), 1 ether);
        assertEq(art("ETH", manager.urns(cdp)), 50 ether);
        assertEq(ink("ETH", address(this)), 0);
        assertEq(art("ETH", address(this)), 0);
    }

    function testShift() public {
        uint256 cdpSrc = this.open("ETH", address(proxy));
        this.lockETHAndDraw{value: 1 ether}(address(jug), address(ethJoin), address(daiJoin), cdpSrc, 50 ether);

        uint256 cdpDst = this.open("ETH", address(proxy));

        assertEq(ink("ETH", manager.urns(cdpSrc)), 1 ether);
        assertEq(art("ETH", manager.urns(cdpSrc)), 50 ether);
        assertEq(ink("ETH", manager.urns(cdpDst)), 0);
        assertEq(art("ETH", manager.urns(cdpDst)), 0);

        this.shift(cdpSrc, cdpDst);

        assertEq(ink("ETH", manager.urns(cdpSrc)), 0);
        assertEq(art("ETH", manager.urns(cdpSrc)), 0);
        assertEq(ink("ETH", manager.urns(cdpDst)), 1 ether);
        assertEq(art("ETH", manager.urns(cdpDst)), 50 ether);
    }

    function _flipETH() internal returns (uint256 cdp) {
        this.file(address(cat), "ETH", "dunk", rad(200 ether)); // 200 units of DAI per batch
        this.file(address(cat), "box", rad(1000 ether)); // 1000 units of DAI max
        this.file(address(cat), "ETH", "chop", WAD);

        cdp = this.open("ETH", address(proxy));
        this.lockETHAndDraw{value: 1 ether}(address(jug), address(ethJoin), address(daiJoin), cdp, 200 ether); // Maximun DAI generated
        pipETH.poke(bytes32(uint256(300 * 10 ** 18 - 1))); // Force liquidation
        spotter.poke("ETH");
        uint256 batchId = cat.bite("ETH", manager.urns(cdp));

        realWeth.deposit{value: 10 ether}();
        realWeth.transfer(address(user1), 10 ether);
        user1.doWethJoin(address(realWeth), address(ethJoin), address(user1), 10 ether);
        user1.doFrob(address(vat), "ETH", address(user1), address(user1), address(user1), 10 ether, 1000 ether);

        realWeth.deposit{value: 10 ether}();
        realWeth.transfer(address(user2), 10 ether);
        user2.doWethJoin(address(realWeth), address(ethJoin), address(user2), 10 ether);
        user2.doFrob(address(vat), "ETH", address(user2), address(user2), address(user2), 10 ether, 1000 ether);

        user1.doHope(address(vat), address(ethFlip));
        user2.doHope(address(vat), address(ethFlip));

        user1.doTend(address(ethFlip), batchId, 1 ether, rad(200 ether));

        user2.doDent(address(ethFlip), batchId, 0.7 ether, rad(200 ether));
    }

    function testExitETHAfterFlip() public {
        uint256 cdp = _flipETH();
        assertEq(vat.gem("ETH", manager.urns(cdp)), 0.3 ether);
        uint256 prevBalance = address(this).balance;
        this.exitETH(address(ethJoin), cdp, 0.3 ether);
        assertEq(vat.gem("ETH", manager.urns(cdp)), 0);
        assertEq(address(this).balance, prevBalance + 0.3 ether);
    }

    function testExitGemAfterFlip() public {
        this.file(address(cat), "COL", "dunk", rad(40 ether)); // 100 units of DAI per batch
        this.file(address(cat), "box", rad(1000 ether)); // 1000 units of DAI max
        this.file(address(cat), "COL", "chop", WAD);

        col.mint(1 ether);
        uint256 cdp = this.open("COL", address(proxy));
        col.approve(address(proxy), 1 ether);
        this.lockGemAndDraw(address(jug), address(colJoin), address(daiJoin), cdp, 1 ether, 40 ether);

        pipCOL.poke(bytes32(uint256(40 * 10 ** 18))); // Force liquidation
        spotter.poke("COL");
        uint256 batchId = cat.bite("COL", manager.urns(cdp));

        realWeth.deposit{value: 10 ether}();
        realWeth.transfer(address(user1), 10 ether);
        user1.doWethJoin(address(realWeth), address(ethJoin), address(user1), 10 ether);
        user1.doFrob(address(vat), "ETH", address(user1), address(user1), address(user1), 10 ether, 1000 ether);

        realWeth.deposit{value: 10 ether}();
        realWeth.transfer(address(user2), 10 ether);
        user2.doWethJoin(address(realWeth), address(ethJoin), address(user2), 10 ether);
        user2.doFrob(address(vat), "ETH", address(user2), address(user2), address(user2), 10 ether, 1000 ether);

        user1.doHope(address(vat), address(colFlip));
        user2.doHope(address(vat), address(colFlip));

        user1.doTend(address(colFlip), batchId, 1 ether, rad(40 ether));

        user2.doDent(address(colFlip), batchId, 0.7 ether, rad(40 ether));
        assertEq(vat.gem("COL", manager.urns(cdp)), 0.3 ether);
        assertEq(col.balanceOf(address(this)), 0);
        this.exitGem(address(colJoin), cdp, 0.3 ether);
        assertEq(vat.gem("COL", manager.urns(cdp)), 0);
        assertEq(col.balanceOf(address(this)), 0.3 ether);
    }

    function testExitDGDAfterFlip() public {
        this.file(address(cat), "DGD", "dunk", rad(30 ether)); // 30 units of DAI per batch
        this.file(address(cat), "box", rad(1000 ether)); // 1000 units of DAI max
        this.file(address(cat), "DGD", "chop", WAD);

        uint256 cdp = this.open("DGD", address(proxy));
        dgd.approve(address(proxy), 1 * 10 ** 9);
        this.lockGemAndDraw(address(jug), address(dgdJoin), address(daiJoin), cdp, 1 * 10 ** 9, 30 ether);

        pipDGD.poke(bytes32(uint256(40 * 10 ** 18))); // Force liquidation
        spotter.poke("DGD");
        uint256 batchId = cat.bite("DGD", manager.urns(cdp));

        realWeth.deposit{value: 10 ether}();
        realWeth.transfer(address(user1), 10 ether);
        user1.doWethJoin(address(realWeth), address(ethJoin), address(user1), 10 ether);
        user1.doFrob(address(vat), "ETH", address(user1), address(user1), address(user1), 10 ether, 1000 ether);

        realWeth.deposit{value: 10 ether}();
        realWeth.transfer(address(user2), 10 ether);
        user2.doWethJoin(address(realWeth), address(ethJoin), address(user2), 10 ether);
        user2.doFrob(address(vat), "ETH", address(user2), address(user2), address(user2), 10 ether, 1000 ether);

        user1.doHope(address(vat), address(dgdFlip));
        user2.doHope(address(vat), address(dgdFlip));

        user1.doTend(address(dgdFlip), batchId, 1 ether, rad(30 ether));

        user2.doDent(address(dgdFlip), batchId, 0.7 ether, rad(30 ether));
        assertEq(vat.gem("DGD", manager.urns(cdp)), 0.3 ether);
        uint256 prevBalance = dgd.balanceOf(address(this));
        this.exitGem(address(dgdJoin), cdp, 0.3 * 10 ** 9);
        assertEq(vat.gem("DGD", manager.urns(cdp)), 0);
        assertEq(dgd.balanceOf(address(this)), prevBalance + 0.3 * 10 ** 9);
    }

    function testLockBackAfterFlip() public {
        uint256 cdp = _flipETH();
        (uint256 inkV,) = vat.urns("ETH", manager.urns(cdp));
        assertEq(inkV, 0);
        assertEq(vat.gem("ETH", manager.urns(cdp)), 0.3 ether);
        this.frob(cdp, 0.3 ether, 0);
        (inkV,) = vat.urns("ETH", manager.urns(cdp));
        assertEq(inkV, 0.3 ether);
        assertEq(vat.gem("ETH", manager.urns(cdp)), 0);
    }

    function testEnd() public {
        uint256 cdp = this.openLockETHAndDraw{value: 2 ether}(address(jug), address(ethJoin), address(daiJoin), "ETH", 300 ether);
        col.mint(1 ether);
        col.approve(address(proxy), 1 ether);
        uint256 cdp2 = this.openLockGemAndDraw(address(jug), address(colJoin), address(daiJoin), "COL", 1 ether, 5 ether);
        dgd.approve(address(proxy), 1 * 10 ** 9);
        uint256 cdp3 = this.openLockGemAndDraw(address(jug), address(dgdJoin), address(daiJoin), "DGD", 1 * 10 ** 9, 5 ether);

        this.cage(address(end));
        end.cage("ETH");
        end.cage("COL");
        end.cage("DGD");

        (uint256 inkV, uint256 artV) = vat.urns("ETH", manager.urns(cdp));
        assertEq(inkV, 2 ether);
        assertEq(artV, 300 ether);

        (inkV, artV) = vat.urns("COL", manager.urns(cdp2));
        assertEq(inkV, 1 ether);
        assertEq(artV, 5 ether);

        (inkV, artV) = vat.urns("DGD", manager.urns(cdp3));
        assertEq(inkV, 1 ether);
        assertEq(artV, 5 ether);

        uint256 prevBalanceETH = address(this).balance;
        this.end_freeETH(address(ethJoin), address(end), cdp);
        (inkV, artV) = vat.urns("ETH", manager.urns(cdp));
        assertEq(inkV, 0);
        assertEq(artV, 0);
        uint256 remainInkVal = 2 ether - 300 * end.tag("ETH") / 10 ** 9; // 2 ETH (deposited) - 300 DAI debt * ETH cage price
        assertEq(address(this).balance, prevBalanceETH + remainInkVal);

        uint256 prevBalanceCol = col.balanceOf(address(this));
        this.end_freeGem(address(colJoin), address(end), cdp2);
        (inkV, artV) = vat.urns("COL", manager.urns(cdp2));
        assertEq(inkV, 0);
        assertEq(artV, 0);
        remainInkVal = 1 ether - 5 * end.tag("COL") / 10 ** 9; // 1 COL (deposited) - 5 DAI debt * COL cage price
        assertEq(col.balanceOf(address(this)), prevBalanceCol + remainInkVal);

        uint256 prevBalanceDGD = dgd.balanceOf(address(this));
        this.end_freeGem(address(dgdJoin), address(end), cdp3);
        (inkV, artV) = vat.urns("DGD", manager.urns(cdp3));
        assertEq(inkV, 0);
        assertEq(artV, 0);
        remainInkVal = (1 ether - 5 * end.tag("DGD") / 10 ** 9) / 10 ** 9; // 1 DGD (deposited) - 5 DAI debt * DGD cage price
        assertEq(dgd.balanceOf(address(this)), prevBalanceDGD + remainInkVal);

        end.thaw();

        end.flow("ETH");
        end.flow("COL");
        end.flow("DGD");

        dai.approve(address(proxy), 310 ether);
        this.end_pack(address(daiJoin), address(end), 310 ether);

        this.end_cashETH(address(ethJoin), address(end), "ETH", 310 ether);
        this.end_cashGem(address(colJoin), address(end), "COL", 310 ether);
        this.end_cashGem(address(dgdJoin), address(end), "DGD", 310 ether);

        assertEq(address(this).balance, prevBalanceETH + 2 ether - 1); // (-1 rounding)
        assertEq(col.balanceOf(address(this)), prevBalanceCol + 1 ether - 1); // (-1 rounding)
        assertEq(dgd.balanceOf(address(this)), prevBalanceDGD + 1 * 10 ** 9 - 1); // (-1 rounding)
    }

    function testDSRSimpleCase() public {
        this.file(address(pot), "dsr", uint256(1.05 * 10 ** 27)); // 5% per second
        uint256 initialTime = 0; // Initial time set to 0 to avoid any intial rounding
        hevm.warp(initialTime);
        uint256 cdp = this.open("ETH", address(proxy));
        this.lockETHAndDraw{value: 1 ether}(address(jug), address(ethJoin), address(daiJoin), cdp, 50 ether);
        dai.approve(address(proxy), 50 ether);
        assertEq(dai.balanceOf(address(this)), 50 ether);
        assertEq(pot.pie(address(this)), 0 ether);
        this.nope(address(vat), address(daiJoin)); // Remove vat permission for daiJoin to test it is correctly re-activate in exit
        this.dsr_join(address(daiJoin), address(pot), 50 ether);
        assertEq(dai.balanceOf(address(this)), 0 ether);
        assertEq(pot.pie(address(proxy)) * pot.chi(), 50 ether * RAY);
        hevm.warp(initialTime + 1); // Moved 1 second
        pot.drip();
        assertEq(pot.pie(address(proxy)) * pot.chi(), 52.5 ether * RAY); // Now the equivalent DAI amount is 2.5 DAI extra
        this.dsr_exit(address(daiJoin), address(pot), 52.5 ether);
        assertEq(dai.balanceOf(address(this)), 52.5 ether);
        assertEq(pot.pie(address(proxy)), 0);
    }

    function testDSRRounding() public {
        this.file(address(pot), "dsr", uint256(1.05 * 10 ** 27));
        uint256 initialTime = 1; // Initial time set to 1 this way some the pie will not be the same than the initial DAI wad amount
        hevm.warp(initialTime);
        uint256 cdp = this.open("ETH", address(proxy));
        this.lockETHAndDraw{value: 1 ether}(address(jug), address(ethJoin), address(daiJoin), cdp, 50 ether);
        dai.approve(address(proxy), 50 ether);
        assertEq(dai.balanceOf(address(this)), 50 ether);
        assertEq(pot.pie(address(this)), 0 ether);
        this.nope(address(vat), address(daiJoin)); // Remove vat permission for daiJoin to test it is correctly re-activate in exit
        this.dsr_join(address(daiJoin), address(pot), 50 ether);
        assertEq(dai.balanceOf(address(this)), 0 ether);
        // Due rounding the DAI equivalent is not the same than initial wad amount
        assertEq(pot.pie(address(proxy)) * pot.chi(), 49999999999999999999350000000000000000000000000);
        hevm.warp(initialTime + 1);
        pot.drip(); // Just necessary to check in this test the updated value of chi
        assertEq(pot.pie(address(proxy)) * pot.chi(), 52499999999999999999317500000000000000000000000);
        this.dsr_exit(address(daiJoin), address(pot), 52.5 ether);
        assertEq(dai.balanceOf(address(this)), 52499999999999999999);
        assertEq(pot.pie(address(proxy)), 0);
    }

    function testDSRRounding2() public {
        this.file(address(pot), "dsr", uint256(1.03434234324 * 10 ** 27));
        uint256 initialTime = 1;
        hevm.warp(initialTime);
        uint256 cdp = this.open("ETH", address(proxy));
        this.lockETHAndDraw{value: 1 ether}(address(jug), address(ethJoin), address(daiJoin), cdp, 50 ether);
        dai.approve(address(proxy), 50 ether);
        assertEq(dai.balanceOf(address(this)), 50 ether);
        assertEq(pot.pie(address(this)), 0 ether);
        this.nope(address(vat), address(daiJoin)); // Remove vat permission for daiJoin to test it is correctly re-activate in exit
        this.dsr_join(address(daiJoin), address(pot), 50 ether);
        assertEq(pot.pie(address(proxy)) * pot.chi(), 49999999999999999999993075745400000000000000000);
        assertEq(vat.dai(address(proxy)), mul(50 ether, RAY) - 49999999999999999999993075745400000000000000000);
        this.dsr_exit(address(daiJoin), address(pot), 50 ether);
        // In this case we get the full 50 DAI back as we also use (for the exit) the dust that remained in the proxy DAI balance in the vat
        // The proxy function tries to return the wad amount if there is enough balance to do it
        assertEq(dai.balanceOf(address(this)), 50 ether);
    }

    function testDSRExitAll() public {
        this.file(address(pot), "dsr", uint256(1.03434234324 * 10 ** 27));
        uint256 initialTime = 1;
        hevm.warp(initialTime);
        uint256 cdp = this.open("ETH", address(proxy));
        this.lockETHAndDraw{value: 1 ether}(address(jug), address(ethJoin), address(daiJoin), cdp, 50 ether);
        this.nope(address(vat), address(daiJoin)); // Remove vat permission for daiJoin to test it is correctly re-activate in exitAll
        dai.approve(address(proxy), 50 ether);
        this.dsr_join(address(daiJoin), address(pot), 50 ether);
        this.dsr_exitAll(address(daiJoin), address(pot));
        // In this case we get 49.999 DAI back as the returned amount is based purely in the pie amount
        assertEq(dai.balanceOf(address(this)), 49999999999999999999);
    }

    receive() external payable {}
}
