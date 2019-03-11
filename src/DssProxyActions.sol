/// DssProxyActions.sol

// Copyright (C) 2018 Gonzalo Balabasquer <gbalabasquer@gmail.com>
//
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

pragma solidity >=0.5.0;

contract GemLike {
    function approve(address, uint) public;
    function transferFrom(address, address, uint) public;
    function deposit() public payable;
    function withdraw(uint) public;
}

contract CdpManagerLike {
    function ilks(uint) public view returns (bytes32);
    function getUrn(uint) public view returns (bytes32);
    function open(bytes32) public returns (uint);
    function move(uint, address) public;
    function allow(uint, address, bool) public;
    function frob(address, uint, int, int) public;
    function exit(address, uint, address, uint) public;
    function quit(address, uint, bytes32) public;
}

contract VatLike {
    function frob(bytes32, bytes32, bytes32, bytes32, int, int) public;
    function ilks(bytes32) public view returns (uint, uint, uint, uint, uint);
    function dai(bytes32) public view returns (uint);
    function urns(bytes32, bytes32) public view returns (uint, uint);
}

contract GemJoinLike {
    function gem() public returns (GemLike);
    function join(bytes32, uint) public payable;
}

contract DaiJoinLike {
    function dai() public returns (GemLike);
    function join(bytes32, uint) public payable;
}

contract HopeLike {
    function hope(address) public;
    function nope(address) public;
}

contract DssProxyActions {
    uint256 constant ONE = 10 ** 27;

    // Internal methods
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "mul-overflow");
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "sub-overflow");
    }

    function toInt(uint x) internal pure returns (int y) {
        y = int(x);
        require(y >= 0, "int-overflow");
    }

    function _getDrawDart(
        address vat,
        bytes32 urn,
        bytes32 ilk,
        uint wad
    ) internal view returns (int dart) {
        (, uint rate,,,) = VatLike(vat).ilks(ilk);
        uint dai = VatLike(vat).dai(urn);

        if (dai < mul(wad, ONE)) {
            // If there was already enough DAI generated but not extracted as token, ignore this statement and do the exit directly
            // Otherwise generate the missing necessary part
            dart = toInt(sub(mul(wad, ONE), dai) / rate);
            dart = mul(uint(dart), rate) < mul(wad, ONE) ? dart + 1 : dart; // This is neeeded due lack of precision of dart value
        }
    }

    function _getWipeDart(
        address vat,
        bytes32 urn,
        bytes32 ilk
    ) internal view returns (int dart) {
        uint dai = VatLike(vat).dai(urn);
        (, uint rate,,,) = VatLike(vat).ilks(ilk);

        (, uint art) = VatLike(vat).urns(ilk, urn);

        // Decrease the whole allocated dai balance: dai / rate
        dart = toInt(dai / rate);
        // We need to check the calculated dart is not higher than urn.art
        dart = uint(dart) <= art ? - dart : - toInt(art);
    }

    // Public methods
    function ethJoin_join(address apt, bytes32 urn) public payable {
        GemJoinLike(apt).gem().deposit.value(msg.value)();
        GemJoinLike(apt).gem().approve(address(apt), msg.value);
        GemJoinLike(apt).join(urn, msg.value);
    }

    function gemJoin_join(address apt, bytes32 urn, uint wad) public payable {
        GemJoinLike(apt).gem().transferFrom(msg.sender, address(this), wad);
        GemJoinLike(apt).gem().approve(apt, wad);
        GemJoinLike(apt).join(urn, wad);
    }

    function daiJoin_join(address apt, bytes32 urn, uint wad) public {
        DaiJoinLike(apt).dai().transferFrom(msg.sender, address(this), wad);
        DaiJoinLike(apt).dai().approve(apt, wad);
        DaiJoinLike(apt).join(urn, wad);
    }

    function frob(
        address vat,
        bytes32 i,
        bytes32 u,
        bytes32 v,
        bytes32 w,
        int dink,
        int dart
    ) public {
        VatLike(vat).frob(i, u, v, w, dink, dart);
    }

    function open(
        address cdpManager,
        bytes32 ilk
    ) public returns (uint cdp) {
        cdp = CdpManagerLike(cdpManager).open(ilk);
    }

    function give(
        address cdpManager,
        uint cdp,
        address guy
    ) public {
        CdpManagerLike(cdpManager).move(cdp, guy);
    }

    function allow(
        address cdpManager,
        uint cdp,
        address guy,
        bool ok
    ) public {
        CdpManagerLike(cdpManager).allow(cdp, guy, ok);
    }

    function hope(
        address obj,
        address guy
    ) public {
        HopeLike(obj).hope(guy);
    }

    function nope(
        address obj,
        address guy
    ) public {
        HopeLike(obj).nope(guy);
    }

    function quit(
        address cdpManager,
        address vat,
        uint cdp,
        bytes32 dst
    ) public {
        CdpManagerLike(cdpManager).quit(vat, cdp, dst);
    }

    function lockETH(
        address cdpManager,
        address ethJoin,
        address vat,
        uint cdp
    ) public payable {
        ethJoin_join(ethJoin, CdpManagerLike(cdpManager).getUrn(cdp));
        CdpManagerLike(cdpManager).frob(vat, cdp, toInt(msg.value), 0);
    }

    function lockGem(
        address cdpManager,
        address gemJoin,
        address vat,
        uint cdp,
        uint wad
    ) public {
        gemJoin_join(gemJoin, CdpManagerLike(cdpManager).getUrn(cdp), wad);
        CdpManagerLike(cdpManager).frob(vat, cdp, toInt(wad), 0);
    }

    function freeETH(
        address cdpManager,
        address ethJoin,
        address vat,
        uint cdp,
        uint wad
    ) public {
        CdpManagerLike(cdpManager).frob(vat, cdp, -toInt(wad), 0);
        CdpManagerLike(cdpManager).exit(ethJoin, cdp, address(this), wad);
        GemJoinLike(ethJoin).gem().withdraw(wad);
        msg.sender.transfer(wad);
    }

    function freeGem(
        address cdpManager,
        address gemJoin,
        address vat,
        uint cdp,
        uint wad
    ) public {
        CdpManagerLike(cdpManager).frob(vat, cdp, -toInt(wad), 0);
        CdpManagerLike(cdpManager).exit(gemJoin, cdp, msg.sender, wad);
    }

    function draw(
        address cdpManager,
        address daiJoin,
        address vat,
        uint cdp,
        uint wad
    ) public {
        CdpManagerLike(cdpManager).frob(vat, cdp, 0, _getDrawDart(vat, CdpManagerLike(cdpManager).getUrn(cdp), CdpManagerLike(cdpManager).ilks(cdp), wad));
        CdpManagerLike(cdpManager).exit(daiJoin, cdp, msg.sender, wad);
    }

    function wipe(
        address cdpManager,
        address daiJoin,
        address vat,
        uint cdp,
        uint wad
    ) public {
        bytes32 urn = CdpManagerLike(cdpManager).getUrn(cdp);
        daiJoin_join(daiJoin, urn, wad);
        CdpManagerLike(cdpManager).frob(vat, cdp, 0, _getWipeDart(vat, urn, CdpManagerLike(cdpManager).ilks(cdp)));
    }

    function lockETHAndDraw(
        address cdpManager,
        address ethJoin,
        address daiJoin,
        address vat,
        uint cdp,
        uint wadD
    ) public payable {
        bytes32 urn = CdpManagerLike(cdpManager).getUrn(cdp);
        ethJoin_join(ethJoin, urn);
        CdpManagerLike(cdpManager).frob(vat, cdp, toInt(msg.value), _getDrawDart(vat, urn, CdpManagerLike(cdpManager).ilks(cdp), wadD));
        CdpManagerLike(cdpManager).exit(daiJoin, cdp, msg.sender, wadD);
    }

    function openLockETHAndDraw(
        address cdpManager,
        address ethJoin,
        address daiJoin,
        address vat,
        bytes32 ilk,
        uint wadD
    ) public payable returns (uint cdp) {
        cdp = CdpManagerLike(cdpManager).open(ilk);
        lockETHAndDraw(cdpManager, ethJoin, daiJoin, vat, cdp, wadD);
    }

    function lockGemAndDraw(
        address cdpManager,
        address gemJoin,
        address daiJoin,
        address vat,
        uint cdp,
        uint wadC,
        uint wadD
    ) public{
        bytes32 urn = CdpManagerLike(cdpManager).getUrn(cdp);
        gemJoin_join(gemJoin, urn, wadC);
        CdpManagerLike(cdpManager).frob(vat, cdp, toInt(wadC), _getDrawDart(vat, urn, CdpManagerLike(cdpManager).ilks(cdp), wadD));
        CdpManagerLike(cdpManager).exit(daiJoin, cdp, msg.sender, wadD);
    }

    function openLockGemAndDraw(
        address cdpManager,
        address gemJoin,
        address daiJoin,
        address vat,
        bytes32 ilk,
        uint wadC,
        uint wadD
    ) public returns (uint cdp) {
        cdp = CdpManagerLike(cdpManager).open(ilk);
        lockGemAndDraw(cdpManager, gemJoin, daiJoin, vat, cdp, wadC, wadD);
    }

    function wipeAndFreeETH(
        address cdpManager,
        address ethJoin,
        address daiJoin,
        address vat,
        uint cdp,
        uint wadC,
        uint wadD
    ) public {
        bytes32 urn = CdpManagerLike(cdpManager).getUrn(cdp);
        daiJoin_join(daiJoin, urn, wadD);
        CdpManagerLike(cdpManager).frob(vat, cdp, -toInt(wadC), _getWipeDart(vat, urn, CdpManagerLike(cdpManager).ilks(cdp)));
        CdpManagerLike(cdpManager).exit(ethJoin, cdp, address(this), wadC);
        GemJoinLike(ethJoin).gem().withdraw(wadC);
        msg.sender.transfer(wadC);
    }

    function wipeAndFreeGem(
        address cdpManager,
        address gemJoin,
        address daiJoin,
        address vat,
        uint cdp,
        uint wadC,
        uint wadD
    ) public {
        bytes32 urn = CdpManagerLike(cdpManager).getUrn(cdp);
        daiJoin_join(daiJoin, urn, wadD);
        CdpManagerLike(cdpManager).frob(vat, cdp, -toInt(wadC), _getWipeDart(vat, urn, CdpManagerLike(cdpManager).ilks(cdp)));
        CdpManagerLike(cdpManager).exit(gemJoin, cdp, msg.sender, wadC);
    }
}
