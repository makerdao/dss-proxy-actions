// SPDX-License-Identifier: AGPL-3.0-or-later

/// DssProxyActions.sol

// Copyright (C) 2018-2021 Dai Foundation

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

pragma solidity ^0.6.12;

interface GemLike {
    function approve(address, uint256) external;
    function transfer(address, uint256) external;
    function transferFrom(address, address, uint256) external;
    function deposit() external payable;
    function withdraw(uint256) external;
}

interface ManagerLike {
    function cdpCan(address, uint256, address) external view returns (uint256);
    function ilks(uint256) external view returns (bytes32);
    function owns(uint256) external view returns (address);
    function urns(uint256) external view returns (address);
    function vat() external view returns (address);
    function open(bytes32, address) external returns (uint256);
    function give(uint256, address) external;
    function cdpAllow(uint256, address, uint256) external;
    function urnAllow(address, uint256) external;
    function frob(uint256, int256, int256) external;
    function flux(uint256, address, uint256) external;
    function move(uint256, address, uint256) external;
    function exit(address, uint256, address, uint256) external;
    function quit(uint256, address) external;
    function enter(address, uint256) external;
    function shift(uint256, uint256) external;
}

interface VatLike {
    function can(address, address) external view returns (uint256);
    function ilks(bytes32) external view returns (uint256, uint256, uint256, uint256, uint256);
    function dai(address) external view returns (uint256);
    function urns(bytes32, address) external view returns (uint256, uint256);
    function frob(bytes32, address, address, address, int256, int256) external;
    function hope(address) external;
    function move(address, address, uint256) external;
}

interface GemJoinLike {
    function dec() external returns (uint256);
    function gem() external returns (GemLike);
    function join(address, uint256) external payable;
    function exit(address, uint256) external;
}

interface DaiJoinLike {
    function vat() external returns (VatLike);
    function dai() external returns (GemLike);
    function join(address, uint256) external payable;
    function exit(address, uint256) external;
}

interface HopeLike {
    function hope(address) external;
    function nope(address) external;
}

interface EndLike {
    function fix(bytes32) external view returns (uint256);
    function cash(bytes32, uint256) external;
    function free(bytes32) external;
    function pack(uint256) external;
    function skim(bytes32, address) external;
}

interface JugLike {
    function drip(bytes32) external returns (uint256);
}

interface PotLike {
    function pie(address) external view returns (uint256);
    function drip() external returns (uint256);
    function join(uint256) external;
    function exit(uint256) external;
}

interface ProxyRegistryLike {
    function proxies(address) external view returns (address);
    function build(address) external returns (address);
}

interface ProxyLike {
    function owner() external view returns (address);
}

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// WARNING: These functions meant to be used as a a library for a DSProxy. Some are unsafe if you call them directly.
// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

contract Common {
    uint256 constant RAY = 10 ** 27;

    VatLike     immutable public vat;
    DaiJoinLike immutable public daiJoin;
    GemLike     immutable public dai;

    constructor(address daiJoin_) public {
        vat = VatLike(DaiJoinLike(daiJoin_).vat());
        dai = GemLike(DaiJoinLike(daiJoin_).dai());
        daiJoin = DaiJoinLike(daiJoin_);
    }

    function _mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(y == 0 || (z = x * y) / y == x, "DssProxyActions/mul-overflow");
    }

    function daiJoin_join(address urn, uint256 wad) public {
        // Gets DAI from the user's wallet
        dai.transferFrom(msg.sender, address(this), wad);
        // Approves adapter to take the DAI amount
        dai.approve(address(daiJoin), wad);
        // Joins DAI into the vat
        daiJoin.join(urn, wad);
    }
}

contract DssProxyActions is Common {
    JugLike             immutable public jug;
    ProxyRegistryLike   immutable public registry;
    ManagerLike         immutable public manager;

    constructor(address daiJoin_, address jug_, address registry_, address manager_) public Common(daiJoin_) {
        jug = JugLike(jug_);
        registry = ProxyRegistryLike(registry_);
        manager = ManagerLike(manager_);
    }

    function _divup(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x != 0 ? ((x - 1) / y) + 1 : 0;
    }

    function _toInt256(uint256 x) internal pure returns (int256 y) {
        y = int256(x);
        require(y >= 0, "DssProxyActions/int-overflow");
    }

    function _toRad(uint256 wad) internal pure returns (uint256 rad) {
        rad = _mul(wad, 10 ** 27);
    }

    function _convertTo18(address gemJoin, uint256 amt) internal returns (uint256 wad) {
        // For those collaterals that have less than 18 decimals precision we need to do the conversion before passing to frob function
        // Adapters will automatically handle the difference of precision
        wad = _mul(
            amt,
            10 ** (18 - GemJoinLike(gemJoin).dec())
        );
    }

    function _getDrawDart(
        address urn,
        bytes32 ilk,
        uint256 wad
    ) internal returns (int256 dart) {
        // Updates stability fee rate
        uint256 rate = jug.drip(ilk);
        // Gets DAI balance of the urn in the vat
        uint256 dai = vat.dai(urn);
        // If there was already enough DAI in the vat balance, just exits it without adding more debt
        uint256 rad = _mul(wad, RAY);
        if (dai < rad) {
            dart = _toInt256(_divup(rad - dai, rate)); // safe since dai < rad
        }
    }

    function _getWipeDart(
        uint256 dai,
        address urn,
        bytes32 ilk
    ) internal view returns (int256 dart) {
        // Gets actual rate from the vat
        (, uint256 rate,,,) = vat.ilks(ilk);
        // Gets actual art value of the urn
        (, uint256 art) = vat.urns(ilk, urn);
        // Uses the whole dai balance in the vat to reduce the debt
        dart = _toInt256(dai / rate);
        // Checks the calculated dart is not higher than urn.art (total debt), otherwise uses its value
        dart = uint256(dart) <= art ? - dart : - _toInt256(art);
    }

    function _getWipeAllWad(
        address usr,
        address urn,
        bytes32 ilk
    ) internal view returns (uint256 wad) {
        // Gets actual rate from the vat
        (, uint256 rate,,,) = vat.ilks(ilk);
        // Gets actual art value of the urn
        (, uint256 art) = vat.urns(ilk, urn);
        // Gets DAI balance of the urn in the vat
        uint256 dai = vat.dai(usr);
        uint256 debt = _mul(art, rate);
        // If there was already enough DAI in the vat balance, no need to join more
        if (debt > dai) {
            // Return the amount of DAI needed to join to cover remaining debt
            wad = _divup(debt - dai, RAY); // safe since debt > dai
        }
    }

    function transfer(address gem, address dst, uint256 amt) external {
        GemLike(gem).transfer(dst, amt);
    }

    function ethJoin_join(address ethJoin, address urn) public payable {
        GemLike gem = GemJoinLike(ethJoin).gem();
        // Wraps ETH in WETH
        gem.deposit{value: msg.value}();
        // Approves adapter to take the WETH amount
        gem.approve(ethJoin, msg.value);
        // Joins WETH collateral into the vat
        GemJoinLike(ethJoin).join(urn, msg.value);
    }

    function gemJoin_join(address gemJoin, address urn, uint256 amt) public {
        GemLike gem = GemJoinLike(gemJoin).gem();
        // Gets token from the user's wallet
        gem.transferFrom(msg.sender, address(this), amt);
        // Approves adapter to take the token amount
        gem.approve(gemJoin, amt);
        // Joins token collateral into the vat
        GemJoinLike(gemJoin).join(urn, amt);
    }

    function hope(
        address addr,
        address usr
    ) external {
        HopeLike(addr).hope(usr);
    }

    function nope(
        address addr,
        address usr
    ) external {
        HopeLike(addr).nope(usr);
    }

    function open(
        bytes32 ilk,
        address usr
    ) external returns (uint256 cdp) {
        cdp = manager.open(ilk, usr);
    }

    function give(
        uint256 cdp,
        address usr
    ) external {
        manager.give(cdp, usr);
    }

    function giveToProxy(
        uint256 cdp,
        address dst
    ) external {
        // Gets actual proxy address
        address proxy = registry.proxies(dst);
        // Checks if the proxy address already existed and dst address is still the owner
        if (proxy == address(0) || ProxyLike(proxy).owner() != dst) {
            uint256 csize;
            assembly {
                csize := extcodesize(dst)
            }
            // We want to avoid creating a proxy for a contract address that might not be able to handle proxies, then losing the CDP
            require(csize == 0, "DssProxyActions/dst-is-a-contract");
            // Creates the proxy for the dst address
            proxy = registry.build(dst);
        }
        // Transfers CDP to the dst proxy
        manager.give(cdp, proxy);
    }

    function cdpAllow(
        uint256 cdp,
        address usr,
        uint256 ok
    ) external {
        manager.cdpAllow(cdp, usr, ok);
    }

    function urnAllow(
        address usr,
        uint256 ok
    ) external {
        manager.urnAllow(usr, ok);
    }

    function flux(
        uint256 cdp,
        address dst,
        uint256 wad
    ) external {
        manager.flux(cdp, dst, wad);
    }

    function move(
        uint256 cdp,
        address dst,
        uint256 rad
    ) external {
        manager.move(cdp, dst, rad);
    }

    function frob(
        uint256 cdp,
        int256 dink,
        int256 dart
    ) external {
        manager.frob(cdp, dink, dart);
    }

    function quit(
        uint256 cdp,
        address dst
    ) external {
        manager.quit(cdp, dst);
    }

    function enter(
        address src,
        uint256 cdp
    ) external {
        manager.enter(src, cdp);
    }

    function shift(
        uint256 cdpSrc,
        uint256 cdpOrg
    ) external {
        manager.shift(cdpSrc, cdpOrg);
    }

    function lockETH(
        address ethJoin,
        uint256 cdp
    ) public payable {
        // Receives ETH amount, converts it to WETH and joins it into the vat
        ethJoin_join(ethJoin, address(this));
        // Locks WETH amount into the CDP
        vat.frob(
            manager.ilks(cdp),
            manager.urns(cdp),
            address(this),
            address(this),
            _toInt256(msg.value),
            0
        );
    }

    function safeLockETH(
        address ethJoin,
        uint256 cdp,
        address owner
    ) external payable {
        require(manager.owns(cdp) == owner, "DssProxyActions/owner-missmatch");
        lockETH(ethJoin, cdp);
    }

    function lockGem(
        address gemJoin,
        uint256 cdp,
        uint256 amt
    ) public {
        // Takes token amount from user's wallet and joins into the vat
        gemJoin_join(gemJoin, address(this), amt);
        // Locks token amount into the CDP
        vat.frob(
            manager.ilks(cdp),
            manager.urns(cdp),
            address(this),
            address(this),
            _toInt256(_convertTo18(gemJoin, amt)),
            0
        );
    }

    function safeLockGem(
        address gemJoin,
        uint256 cdp,
        uint256 amt,
        address owner
    ) external {
        require(manager.owns(cdp) == owner, "DssProxyActions/owner-missmatch");
        lockGem(gemJoin, cdp, amt);
    }

    function freeETH(
        address ethJoin,
        uint256 cdp,
        uint256 wad
    ) external {
        // Unlocks WETH amount from the CDP
        manager.frob(cdp, -_toInt256(wad), 0);
        // Moves the amount from the CDP urn to proxy's address
        manager.flux(cdp, address(this), wad);
        // Exits WETH amount to proxy address as a token
        GemJoinLike(ethJoin).exit(address(this), wad);
        // Converts WETH to ETH
        GemJoinLike(ethJoin).gem().withdraw(wad);
        // Sends ETH back to the user's wallet
        msg.sender.transfer(wad);
    }

    function freeGem(
        address gemJoin,
        uint256 cdp,
        uint256 amt
    ) external {
        uint256 wad = _convertTo18(gemJoin, amt);
        // Unlocks token amount from the CDP
        manager.frob(cdp, -_toInt256(wad), 0);
        // Moves the amount from the CDP urn to proxy's address
        manager.flux(cdp, address(this), wad);
        // Exits token amount to the user's wallet as a token
        GemJoinLike(gemJoin).exit(msg.sender, amt);
    }

    function exitETH(
        address ethJoin,
        uint256 cdp,
        uint256 wad
    ) external {
        // Moves the amount from the CDP urn to proxy's address
        manager.flux(cdp, address(this), wad);
        // Exits WETH amount to proxy address as a token
        GemJoinLike(ethJoin).exit(address(this), wad);
        // Converts WETH to ETH
        GemJoinLike(ethJoin).gem().withdraw(wad);
        // Sends ETH back to the user's wallet
        msg.sender.transfer(wad);
    }

    function exitGem(
        address gemJoin,
        uint256 cdp,
        uint256 amt
    ) external {
        // Moves the amount from the CDP urn to proxy's address
        manager.flux(cdp, address(this), _convertTo18(gemJoin, amt));
        // Exits token amount to the user's wallet as a token
        GemJoinLike(gemJoin).exit(msg.sender, amt);
    }

    function draw(
        uint256 cdp,
        uint256 wad
    ) external {
        // Generates debt in the CDP
        manager.frob(
            cdp,
            0,
            _getDrawDart(
                manager.urns(cdp),
                manager.ilks(cdp),
                wad
            )
        );
        // Moves the DAI amount (balance in the vat in rad) to proxy's address
        manager.move(cdp, address(this), _toRad(wad));
        // Allows adapter to access to proxy's DAI balance in the vat
        if (vat.can(address(this), address(daiJoin)) == 0) {
            vat.hope(address(daiJoin));
        }
        // Exits DAI to the user's wallet as a token
        daiJoin.exit(msg.sender, wad);
    }

    function wipe(
        uint256 cdp,
        uint256 wad
    ) public {
        address urn = manager.urns(cdp);
        bytes32 ilk = manager.ilks(cdp);
        address own = manager.owns(cdp);
        if (own == address(this) || manager.cdpCan(own, cdp, address(this)) == 1) {
            // Joins DAI amount into the vat
            daiJoin_join(urn, wad);
            // Paybacks debt to the CDP
            manager.frob(cdp, 0, _getWipeDart(vat.dai(urn), urn, ilk));
        } else {
             // Joins DAI amount into the vat
            daiJoin_join(address(this), wad);
            // Paybacks debt to the CDP
            vat.frob(
                ilk,
                urn,
                address(this),
                address(this),
                0,
                _getWipeDart(wad * RAY, urn, ilk)
            );
        }
    }

    function safeWipe(
        uint256 cdp,
        uint256 wad,
        address owner
    ) external {
        require(manager.owns(cdp) == owner, "DssProxyActions/owner-missmatch");
        wipe(cdp, wad);
    }

    function wipeAll(
        uint256 cdp
    ) public {
        address urn = manager.urns(cdp);
        bytes32 ilk = manager.ilks(cdp);
        address own = manager.owns(cdp);
        (, uint256 art) = vat.urns(ilk, urn);
        if (own == address(this) || manager.cdpCan(own, cdp, address(this)) == 1) {
            // Joins DAI amount into the vat
            daiJoin_join(urn, _getWipeAllWad(urn, urn, ilk));
            // Paybacks debt to the CDP
            manager.frob(cdp, 0, -_toInt256(art));
        } else {
            // Joins DAI amount into the vat
            daiJoin_join(address(this), _getWipeAllWad(address(this), urn, ilk));
            // Paybacks debt to the CDP
            vat.frob(
                ilk,
                urn,
                address(this),
                address(this),
                0,
                -_toInt256(art)
            );
        }
    }

    function safeWipeAll(
        uint256 cdp,
        address owner
    ) external {
        require(manager.owns(cdp) == owner, "DssProxyActions/owner-missmatch");
        wipeAll(cdp);
    }

    function lockETHAndDraw(
        address ethJoin,
        uint256 cdp,
        uint256 wadD
    ) public payable {
        address urn = manager.urns(cdp);
        // Receives ETH amount, converts it to WETH and joins it into the vat
        ethJoin_join(ethJoin, urn);
        // Locks WETH amount into the CDP and generates debt
        manager.frob(
            cdp,
            _toInt256(msg.value),
            _getDrawDart(
                urn,
                manager.ilks(cdp),
                wadD
            )
        );
        // Moves the DAI amount (balance in the vat in rad) to proxy's address
        manager.move(cdp, address(this), _toRad(wadD));
        // Allows adapter to access to proxy's DAI balance in the vat
        if (vat.can(address(this), address(daiJoin)) == 0) {
            vat.hope(address(daiJoin));
        }
        // Exits DAI to the user's wallet as a token
        daiJoin.exit(msg.sender, wadD);
    }

    function openLockETHAndDraw(
        address ethJoin,
        bytes32 ilk,
        uint256 wadD
    ) external payable returns (uint256 cdp) {
        cdp = manager.open(ilk, address(this));
        lockETHAndDraw(ethJoin, cdp, wadD);
    }

    function lockGemAndDraw(
        address gemJoin,
        uint256 cdp,
        uint256 amtC,
        uint256 wadD
    ) public {
        address urn = manager.urns(cdp);
        bytes32 ilk = manager.ilks(cdp);
        // Takes token amount from user's wallet and joins into the vat
        gemJoin_join(gemJoin, urn, amtC);
        // Locks token amount into the CDP and generates debt
        manager.frob(
            cdp,
            _toInt256(_convertTo18(gemJoin, amtC)),
            _getDrawDart(
                urn,
                ilk,
                wadD
            )
        );
        // Moves the DAI amount (balance in the vat in rad) to proxy's address
        manager.move(cdp, address(this), _toRad(wadD));
        // Allows adapter to access to proxy's DAI balance in the vat
        if (vat.can(address(this), address(daiJoin)) == 0) {
            vat.hope(address(daiJoin));
        }
        // Exits DAI to the user's wallet as a token
        daiJoin.exit(msg.sender, wadD);
    }

    function openLockGemAndDraw(
        address gemJoin,
        bytes32 ilk,
        uint256 amtC,
        uint256 wadD
    ) external returns (uint256 cdp) {
        cdp = manager.open(ilk, address(this));
        lockGemAndDraw(gemJoin, cdp, amtC, wadD);
    }

    function wipeAndFreeETH(
        address ethJoin,
        uint256 cdp,
        uint256 wadC,
        uint256 wadD
    ) external {
        address urn = manager.urns(cdp);
        // Joins DAI amount into the vat
        daiJoin_join(urn, wadD);
        // Paybacks debt to the CDP and unlocks WETH amount from it
        manager.frob(
            cdp,
            -_toInt256(wadC),
            _getWipeDart(vat.dai(urn), urn, manager.ilks(cdp))
        );
        // Moves the amount from the CDP urn to proxy's address
        manager.flux(cdp, address(this), wadC);
        // Exits WETH amount to proxy address as a token
        GemJoinLike(ethJoin).exit(address(this), wadC);
        // Converts WETH to ETH
        GemJoinLike(ethJoin).gem().withdraw(wadC);
        // Sends ETH back to the user's wallet
        msg.sender.transfer(wadC);
    }

    function wipeAllAndFreeETH(
        address ethJoin,
        uint256 cdp,
        uint256 wadC
    ) external {
        address urn = manager.urns(cdp);
        bytes32 ilk = manager.ilks(cdp);
        (, uint256 art) = vat.urns(ilk, urn);
        // Joins DAI amount into the vat
        daiJoin_join(urn, _getWipeAllWad(urn, urn, ilk));
        // Paybacks debt to the CDP and unlocks WETH amount from it
        manager.frob(
            cdp,
            -_toInt256(wadC),
            -_toInt256(art)
        );
        // Moves the amount from the CDP urn to proxy's address
        manager.flux(cdp, address(this), wadC);
        // Exits WETH amount to proxy address as a token
        GemJoinLike(ethJoin).exit(address(this), wadC);
        // Converts WETH to ETH
        GemJoinLike(ethJoin).gem().withdraw(wadC);
        // Sends ETH back to the user's wallet
        msg.sender.transfer(wadC);
    }

    function wipeAndFreeGem(
        address gemJoin,
        uint256 cdp,
        uint256 amtC,
        uint256 wadD
    ) external {
        address urn = manager.urns(cdp);
        // Joins DAI amount into the vat
        daiJoin_join(urn, wadD);
        uint256 wadC = _convertTo18(gemJoin, amtC);
        // Paybacks debt to the CDP and unlocks token amount from it
        manager.frob(
            cdp,
            -_toInt256(wadC),
            _getWipeDart(vat.dai(urn), urn, manager.ilks(cdp))
        );
        // Moves the amount from the CDP urn to proxy's address
        manager.flux(cdp, address(this), wadC);
        // Exits token amount to the user's wallet as a token
        GemJoinLike(gemJoin).exit(msg.sender, amtC);
    }

    function wipeAllAndFreeGem(
        address gemJoin,
        uint256 cdp,
        uint256 amtC
    ) external {
        address urn = manager.urns(cdp);
        bytes32 ilk = manager.ilks(cdp);
        (, uint256 art) = vat.urns(ilk, urn);
        // Joins DAI amount into the vat
        daiJoin_join(urn, _getWipeAllWad(urn, urn, ilk));
        uint256 wadC = _convertTo18(gemJoin, amtC);
        // Paybacks debt to the CDP and unlocks token amount from it
        manager.frob(
            cdp,
            -_toInt256(wadC),
            -_toInt256(art)
        );
        // Moves the amount from the CDP urn to proxy's address
        manager.flux(cdp, address(this), wadC);
        // Exits token amount to the user's wallet as a token
        GemJoinLike(gemJoin).exit(msg.sender, amtC);
    }
}

contract DssProxyActionsEnd is Common {
    ManagerLike immutable public manager;

    constructor(address daiJoin_, address manager_) public Common(daiJoin_) {
        manager = ManagerLike(manager_);
    }

    function _free(
        address end,
        uint256 cdp
    ) internal returns (uint256 ink) {
        bytes32 ilk = manager.ilks(cdp);
        address urn = manager.urns(cdp);
        uint256 art;
        (ink, art) = vat.urns(ilk, urn);
        // If CDP still has debt, it needs to be paid
        if (art > 0) {
            EndLike(end).skim(ilk, urn);
            (ink,) = vat.urns(ilk, urn);
        }
        // Approves the manager to transfer the position to proxy's address in the vat
        if (vat.can(address(this), address(manager)) == 0) {
            vat.hope(address(manager));
        }
        // Transfers position from CDP to the proxy address
        manager.quit(cdp, address(this));
        // Frees the position and recovers the collateral in the vat registry
        EndLike(end).free(ilk);
    }

    function freeETH(
        address ethJoin,
        address end,
        uint256 cdp
    ) external {
        uint256 wad = _free(end, cdp);
        // Exits WETH amount to proxy address as a token
        GemJoinLike(ethJoin).exit(address(this), wad);
        // Converts WETH to ETH
        GemJoinLike(ethJoin).gem().withdraw(wad);
        // Sends ETH back to the user's wallet
        msg.sender.transfer(wad);
    }

    function freeGem(
        address gemJoin,
        address end,
        uint256 cdp
    ) external {
        // Exits token amount to the user's wallet as a token
        GemJoinLike(gemJoin).exit(
            msg.sender,
            _free(end, cdp) / 10 ** (18 - GemJoinLike(gemJoin).dec())
        );
    }

    function pack(
        address end,
        uint256 wad
    ) external {
        daiJoin_join(address(this), wad);
        // Approves the end to take out DAI from the proxy's balance in the vat
        if (vat.can(address(this), address(end)) == 0) {
            vat.hope(end);
        }
        EndLike(end).pack(wad);
    }

    function cashETH(
        address ethJoin,
        address end,
        bytes32 ilk,
        uint256 wad
    ) external {
        EndLike(end).cash(ilk, wad);
        uint256 wadC = _mul(wad, EndLike(end).fix(ilk)) / RAY;
        // Exits WETH amount to proxy address as a token
        GemJoinLike(ethJoin).exit(address(this), wadC);
        // Converts WETH to ETH
        GemJoinLike(ethJoin).gem().withdraw(wadC);
        // Sends ETH back to the user's wallet
        msg.sender.transfer(wadC);
    }

    function cashGem(
        address gemJoin,
        address end,
        bytes32 ilk,
        uint256 wad
    ) external {
        EndLike(end).cash(ilk, wad);
        // Exits token amount to the user's wallet as a token
        GemJoinLike(gemJoin).exit(
            msg.sender,
            _mul(wad, EndLike(end).fix(ilk)) / RAY / 10 ** (18 - GemJoinLike(gemJoin).dec())
        );
    }
}

contract DssProxyActionsDsr is Common {
    PotLike immutable public pot;

    constructor(address daiJoin_, address pot_) public Common(daiJoin_) {
        pot = PotLike(pot_);
    }

    function join(
        uint256 wad
    ) external {
        // Joins wad amount to the vat balance
        daiJoin_join(address(this), wad);
        // Approves the pot to take out DAI from the proxy's balance in the vat
        if (vat.can(address(this), address(pot)) == 0) {
            vat.hope(address(pot));
        }
        // Joins the pie value (equivalent to the DAI wad amount) in the pot
        pot.join(_mul(wad, RAY) / pot.drip());
    }

    function exit(
        uint256 wad
    ) external {
        // Exits wad DAI from the pot (calculating the input value)
        pot.exit(_mul(wad, RAY) / pot.drip());
        // Checks the actual balance of DAI in the vat after the pot exit
        uint256 bal = vat.dai(address(this));
        // Allows adapter to access to proxy's DAI balance in the vat
        if (vat.can(address(this), address(daiJoin)) == 0) {
            vat.hope(address(daiJoin));
        }
        // It is necessary to check if due rounding the exact wad amount can be exited by the adapter.
        // Otherwise it will do the maximum DAI balance in the vat
        daiJoin.exit(
            msg.sender,
            bal >= _mul(wad, RAY) ? wad : bal / RAY
        );
    }

    function exitAll() external {
        // Executes drip to count the savings accumulated until this moment
        uint256 chi = pot.drip();
        // Gets the total pie belonging to the proxy address
        uint256 pie = pot.pie(address(this));
        // Exits DAI from the pot
        pot.exit(pie);
        // Allows adapter to access to proxy's DAI balance in the vat
        if (vat.can(address(this), address(daiJoin)) == 0) {
            vat.hope(address(daiJoin));
        }
        // Exits the DAI amount corresponding to the value of pie
        daiJoin.exit(msg.sender, _mul(chi, pie) / RAY);
    }
}
