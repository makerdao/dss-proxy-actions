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
}

contract CdpManagerLike {
    function open() public returns (bytes12);
    function give(bytes12, address) public;
    function allow(bytes12, address, bool) public;
    function getUrn(bytes12) public view returns (bytes32);
    function frob(address, bytes12, bytes32, int, int) public;
    function exit(address, bytes12, address, uint) public;
}

contract PitLike {
    function vat() public view returns (VatLike); 
}

contract VatLike {
    function ilks(bytes32) public view returns (uint, uint);
    function dai(bytes32) public view returns (uint);
}

contract ETHJoinLike {
    function join(bytes32) public payable;
}

contract GemJoinLike {
    function gem() public returns (GemLike);
    function join(bytes32, uint) public payable;
}

contract DaiJoinLike {
    function dai() public returns (GemLike);
    function join(bytes32, uint) public payable;
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

    function _getLockDink(
        address pit,
        bytes32 ilk,
        uint wad
    ) internal view returns (int dink) {
        (uint take,) = PitLike(pit).vat().ilks(ilk);
        dink = int(mul(wad, ONE) / take);
    }

    function _getFreeDink(
        address pit,
        bytes32 ilk,
        uint wad
    ) internal view returns (int dink) {
        (uint take,) = PitLike(pit).vat().ilks(ilk);
        dink = - int(mul(wad, ONE) / take);
    }

    function _getDrawDart(
        address pit,
        bytes32 urn,
        bytes32 ilk,
        uint wad
    ) internal view returns (int dart) {
        (, uint rate) = PitLike(pit).vat().ilks(ilk);
        uint dai = PitLike(pit).vat().dai(urn);

        if (dai < mul(wad, ONE)) {
            // If there was already enough DAI generated but not extracted as token, ignore this statement and do the exit directly
            // Otherwise generate the missing necessart part
            dart = int(sub(mul(wad, ONE), dai) / rate);
            dart = int(mul(uint(dart), rate) < mul(wad, ONE) ? dart + 1 : dart); // This is neeeded due lack of precision of dart value
        }
    }

    function _getWipeDart(
        address pit,
        bytes32 urn,
        bytes32 ilk
    ) internal view returns (int dart) {
        uint dai = PitLike(pit).vat().dai(urn);
        (, uint rate) = PitLike(pit).vat().ilks(ilk);
        // Decrease the whole allocated dai balance: dai / rate
        dart = - int(dai / rate);
    }

    // Public methods
    function ethJoin_join(address apt, bytes32 urn) public payable {
        ETHJoinLike(apt).join.value(msg.value)(urn);
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

    function open(
        address cdpManager
    ) public returns (bytes12 cdp) {
        cdp = CdpManagerLike(cdpManager).open();
    }

    function give(
        address cdpManager,
        bytes12 cdp,
        address guy
    ) public {
        CdpManagerLike(cdpManager).give(cdp, guy);
    }

    function allow(
        address cdpManager,
        bytes12 cdp,
        address guy,
        bool ok
    ) public {
        CdpManagerLike(cdpManager).allow(cdp, guy, ok);
    }

    function lockETH(
        address cdpManager,
        address ethJoin,
        address pit,
        bytes12 cdp
    ) public payable {
        ethJoin_join(ethJoin, CdpManagerLike(cdpManager).getUrn(cdp));
        CdpManagerLike(cdpManager).frob(pit, cdp, "ETH", _getLockDink(pit, "ETH", msg.value), 0);
    }

    function lockGem(
        address cdpManager,
        address gemJoin,
        address pit,
        bytes12 cdp,
        bytes32 ilk,
        uint wad
    ) public {
        gemJoin_join(gemJoin, CdpManagerLike(cdpManager).getUrn(cdp), wad);
        CdpManagerLike(cdpManager).frob(pit, cdp, ilk, _getLockDink(pit, ilk, wad), 0);
    }

    function freeETH(
        address cdpManager,
        address ethJoin,
        address pit,
        bytes12 cdp,
        uint wad
    ) public {
        CdpManagerLike(cdpManager).frob(pit, cdp, "ETH", _getFreeDink(pit, "ETH", wad), 0);
        CdpManagerLike(cdpManager).exit(ethJoin, cdp, msg.sender, wad);
    }

    function freeGem(
        address cdpManager,
        address gemJoin,
        address pit,
        bytes12 cdp,
        bytes32 ilk,
        uint wad
    ) public {
        CdpManagerLike(cdpManager).frob(pit, cdp, ilk, _getFreeDink(pit, ilk, wad), 0);
        CdpManagerLike(cdpManager).exit(gemJoin, cdp, msg.sender, wad);
    }

    function draw(
        address cdpManager,
        address daiJoin,
        address pit,
        bytes12 cdp,
        bytes32 ilk,
        uint wad
    ) public {
        CdpManagerLike(cdpManager).frob(pit, cdp, ilk, 0, _getDrawDart(pit, CdpManagerLike(cdpManager).getUrn(cdp), ilk, wad));
        CdpManagerLike(cdpManager).exit(daiJoin, cdp, msg.sender, wad);
    }

    function wipe(
        address cdpManager,
        address daiJoin,
        address pit,
        bytes12 cdp,
        bytes32 ilk,
        uint wad
    ) public {
        bytes32 urn = CdpManagerLike(cdpManager).getUrn(cdp);
        daiJoin_join(daiJoin, urn, wad);
        CdpManagerLike(cdpManager).frob(pit, cdp, ilk, 0, _getWipeDart(pit, urn, ilk));
    }

    function lockETHAndDraw(
        address cdpManager,
        address ethJoin,
        address daiJoin,
        address pit,
        bytes12 cdp,
        uint wadD
    ) public payable {
        bytes32 urn = CdpManagerLike(cdpManager).getUrn(cdp);
        ethJoin_join(ethJoin, urn);
        CdpManagerLike(cdpManager).frob(pit, cdp, "ETH", _getLockDink(pit, "ETH", msg.value), _getDrawDart(pit, urn, "ETH", wadD));
        CdpManagerLike(cdpManager).exit(daiJoin, cdp, msg.sender, wadD);
    }

    function openLockETHAndDraw(
        address cdpManager,
        address ethJoin,
        address daiJoin,
        address pit,
        uint wadD
    ) public payable returns (bytes12 cdp) {
        cdp = CdpManagerLike(cdpManager).open();
        lockETHAndDraw(cdpManager, ethJoin, daiJoin, pit, cdp, wadD);
    }

    function lockGemAndDraw(
        address cdpManager,
        address gemJoin,
        address daiJoin,
        address pit,
        bytes12 cdp,
        bytes32 ilk,
        uint wadC,
        uint wadD
    ) public{
        bytes32 urn = CdpManagerLike(cdpManager).getUrn(cdp);
        gemJoin_join(gemJoin, urn, wadC);
        CdpManagerLike(cdpManager).frob(pit, cdp, ilk, _getLockDink(pit, ilk, wadC), _getDrawDart(pit, urn, ilk, wadD));
        CdpManagerLike(cdpManager).exit(daiJoin, cdp, msg.sender, wadD);
    }

    function openLockGemAndDraw(
        address cdpManager,
        address gemJoin,
        address daiJoin,
        address pit,
        bytes32 ilk,
        uint wadC,
        uint wadD
    ) public returns (bytes12 cdp) {
        cdp = CdpManagerLike(cdpManager).open();
        lockGemAndDraw(cdpManager, gemJoin, daiJoin, pit, cdp, ilk, wadC, wadD);
    }

    function wipeAndFreeETH(
        address cdpManager,
        address ethJoin,
        address daiJoin,
        address pit,
        bytes12 cdp,
        uint wadC,
        uint wadD
    ) public {
        bytes32 urn = CdpManagerLike(cdpManager).getUrn(cdp);
        daiJoin_join(daiJoin, urn, wadD);
        CdpManagerLike(cdpManager).frob(pit, cdp, "ETH", _getFreeDink(pit, "ETH", wadC), _getWipeDart(pit, urn, "ETH"));
        CdpManagerLike(cdpManager).exit(ethJoin, cdp, msg.sender, wadC);
    }

    function wipeAndFreeGem(
        address cdpManager,
        address gemJoin,
        address daiJoin,
        address pit,
        bytes12 cdp,
        bytes32 ilk,
        uint wadC,
        uint wadD
    ) public {
        bytes32 urn = CdpManagerLike(cdpManager).getUrn(cdp);
        daiJoin_join(daiJoin, urn, wadD);
        CdpManagerLike(cdpManager).frob(pit, cdp, ilk, _getFreeDink(pit, ilk, wadC), _getWipeDart(pit, urn, ilk));
        CdpManagerLike(cdpManager).exit(gemJoin, cdp, msg.sender, wadC);
    }
}
