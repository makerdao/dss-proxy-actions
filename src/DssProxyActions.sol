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

contract ManagerLike {
    function ilks(uint) public view returns (bytes32);
    function urns(uint) public view returns (address);
    function vat() public view returns (address);
    function open(bytes32) public returns (uint);
    function give(uint, address) public;
    function allow(uint, address, uint) public;
    function frob(uint, int, int) public;
    function frob(uint, address, int, int) public;
    function flux(uint, address, uint) public;
    function move(uint, address, uint) public;
    function exit(address, uint, address, uint) public;
    function quit(uint, address) public;
}

contract VatLike {
    function ilks(bytes32) public view returns (uint, uint, uint, uint, uint);
    function dai(address) public view returns (uint);
    function urns(bytes32, address) public view returns (uint, uint);
    function hope(address) public;
    function move(address, address, uint) public;
}

contract GemJoinLike {
    function gem() public returns (GemLike);
    function join(address, uint) public payable;
    function exit(address, uint) public;
}

contract DaiJoinLike {
    function vat() public returns (VatLike);
    function dai() public returns (GemLike);
    function join(address, uint) public payable;
    function exit(address, uint) public;
}

contract HopeLike {
    function hope(address) public;
    function nope(address) public;
}

contract PotLike {
    function chi() public view returns (uint);
    function pie(address) public view returns (uint);
    function drip() public;
    function join(uint) public;
    function exit(uint) public;
}

contract DssProxyActions {
    uint256 constant ONE = 10 ** 27;

    // Internal functions

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

    function toRad(uint wad) internal pure returns (uint rad) {
        rad = wad * 10 ** 27;
    }

    function _getDrawDart(
        address vat,
        address urn,
        bytes32 ilk,
        uint wad
    ) internal view returns (int dart) {
        // Gets actual rate from the vat
        (, uint rate,,,) = VatLike(vat).ilks(ilk);
        // Gets DAI balance of the urn in the vat
        uint dai = VatLike(vat).dai(urn);

        // If there was already enough DAI in the vat balance, just exits it without adding more debt
        if (dai < mul(wad, ONE)) {
            // Calculates the needed dart so together with the existing dai in the vat is enough to exit wad amount of DAI tokens
            dart = toInt(sub(mul(wad, ONE), dai) / rate);
            // This is neeeded due lack of precision. It might need to sum an extra dart wei (for the given DAI wad amount)
            dart = mul(uint(dart), rate) < mul(wad, ONE) ? dart + 1 : dart;
        }
    }

    function _getWipeDart(
        address vat,
        address urn,
        bytes32 ilk
    ) internal view returns (int dart) {
        // Gets actual rate from the vat
        (, uint rate,,,) = VatLike(vat).ilks(ilk);
        // Gets DAI balance of the urn in the vat
        uint dai = VatLike(vat).dai(urn);
        // Gets actual art value of the urn
        (, uint art) = VatLike(vat).urns(ilk, urn);

        // Uses the whole dai balance in the vat to reduce the debt
        dart = toInt(dai / rate);
        // Checks the calculated dart is not higher than urn.art (total debt), otherwise uses its value
        dart = uint(dart) <= art ? - dart : - toInt(art);
    }

    // Public functions

    function ethJoin_join(address apt, address urn) public payable {
        // Wraps ETH in WETH
        GemJoinLike(apt).gem().deposit.value(msg.value)();
        // Approves adapter to take the WETH amount
        GemJoinLike(apt).gem().approve(address(apt), msg.value);
        // Joins WETH collateral into the vat
        GemJoinLike(apt).join(urn, msg.value);
    }

    function gemJoin_join(address apt, address urn, uint wad) public payable {
        // Gets token from the user's wallet
        GemJoinLike(apt).gem().transferFrom(msg.sender, address(this), wad);
        // Approves adapter to take the token amount
        GemJoinLike(apt).gem().approve(apt, wad);
        // Joins token collateral into the vat
        GemJoinLike(apt).join(urn, wad);
    }

    function daiJoin_join(address apt, address urn, uint wad) public {
        // Gets DAI from the user's wallet
        DaiJoinLike(apt).dai().transferFrom(msg.sender, address(this), wad);
        // Approves adapter to take the DAI amount
        DaiJoinLike(apt).dai().approve(apt, wad);
        // Joins DAI into the vat
        DaiJoinLike(apt).join(urn, wad);
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

    function open(
        address manager,
        bytes32 ilk
    ) public returns (uint cdp) {
        cdp = ManagerLike(manager).open(ilk);
    }

    function give(
        address manager,
        uint cdp,
        address guy
    ) public {
        ManagerLike(manager).give(cdp, guy);
    }

    function allow(
        address manager,
        uint cdp,
        address guy,
        uint ok
    ) public {
        ManagerLike(manager).allow(cdp, guy, ok);
    }

    function flux(
        address manager,
        uint cdp,
        address dst,
        uint wad
    ) public {
        ManagerLike(manager).flux(cdp, dst, wad);
    }

    function move(
        address manager,
        uint cdp,
        address dst,
        uint rad
    ) public {
        ManagerLike(manager).move(cdp, dst, rad);
    }

    function frob(
        address manager,
        uint cdp,
        int dink,
        int dart
    ) public {
        ManagerLike(manager).frob(cdp, dink, dart);
    }

    function frob(
        address manager,
        uint cdp,
        address dst,
        int dink,
        int dart
    ) public {
        ManagerLike(manager).frob(cdp, dst, dink, dart);
    }

    function quit(
        address manager,
        uint cdp,
        address dst
    ) public {
        ManagerLike(manager).quit(cdp, dst);
    }

    function lockETH(
        address manager,
        address ethJoin,
        uint cdp
    ) public payable {
        // Receives ETH amount, converts it to WETH and joins it into the vat
        ethJoin_join(ethJoin, ManagerLike(manager).urns(cdp));
        // Locks WETH amount into the CDP
        frob(manager, cdp, toInt(msg.value), 0);
    }

    function lockGem(
        address manager,
        address gemJoin,
        uint cdp,
        uint wad
    ) public {
        // Takes token amount from user's wallet and joins into the vat
        gemJoin_join(gemJoin, ManagerLike(manager).urns(cdp), wad);
        // Locks token amount into the CDP
        frob(manager, cdp, toInt(wad), 0);
    }

    function freeETH(
        address manager,
        address ethJoin,
        uint cdp,
        uint wad
    ) public {
        // Unlocks WETH amount from the CDP
        frob(manager, cdp, address(this), -toInt(wad), 0);
        // Exits WETH amount to proxy address as a token
        GemJoinLike(ethJoin).exit(address(this), wad);
        // Converts WETH to ETH
        GemJoinLike(ethJoin).gem().withdraw(wad);
        // Sends ETH back to the user's wallet
        msg.sender.transfer(wad);
    }

    function freeGem(
        address manager,
        address gemJoin,
        uint cdp,
        uint wad
    ) public {
        // Unlocks token amount from the CDP
        frob(manager, cdp, address(this), -toInt(wad), 0);
        // Exits token amount to the user's wallet as a token
        GemJoinLike(gemJoin).exit(msg.sender, wad);
    }

    function draw(
        address manager,
        address daiJoin,
        uint cdp,
        uint wad
    ) public {
        address urn = ManagerLike(manager).urns(cdp);
        address vat = ManagerLike(manager).vat();
        // Generates debt in the CDP
        frob(manager, cdp, 0, _getDrawDart(vat, urn, ManagerLike(manager).ilks(cdp), wad));
        // Moves the DAI amount (balance in the vat in rad) to proxy's address
        move(manager, cdp, address(this), toRad(wad));
        // Allows adapter to access to proxy's balance in the vat
        VatLike(vat).hope(daiJoin);
        // Exits DAI to the user's wallet as a token
        DaiJoinLike(daiJoin).exit(msg.sender, wad);
    }

    function wipe(
        address manager,
        address daiJoin,
        uint cdp,
        uint wad
    ) public {
        address urn = ManagerLike(manager).urns(cdp);
        // Joins DAI amount into the vat
        daiJoin_join(daiJoin, urn, wad);
        // Paybacks debt to the CDP
        frob(manager, cdp, 0, _getWipeDart(ManagerLike(manager).vat(), urn, ManagerLike(manager).ilks(cdp)));
    }

    function lockETHAndDraw(
        address manager,
        address ethJoin,
        address daiJoin,
        uint cdp,
        uint wadD
    ) public payable {
        address urn = ManagerLike(manager).urns(cdp);
        address vat = ManagerLike(manager).vat();
        // Receives ETH amount, converts it to WETH and joins it into the vat
        ethJoin_join(ethJoin, urn);
        // Locks WETH amount into the CDP and generates debt
        frob(manager, cdp, toInt(msg.value), _getDrawDart(vat, urn, ManagerLike(manager).ilks(cdp), wadD));
        // Moves the DAI amount (balance in the vat in rad) to proxy's address
        move(manager, cdp, address(this), toRad(wadD));
        // Allows adapter to access to proxy's balance in the vat
        VatLike(vat).hope(daiJoin);
        // Exits DAI to the user's wallet as a token
        DaiJoinLike(daiJoin).exit(msg.sender, wadD);
    }

    function openLockETHAndDraw(
        address manager,
        address ethJoin,
        address daiJoin,
        bytes32 ilk,
        uint wadD
    ) public payable returns (uint cdp) {
        cdp = ManagerLike(manager).open(ilk);
        lockETHAndDraw(manager, ethJoin, daiJoin, cdp, wadD);
    }

    function lockGemAndDraw(
        address manager,
        address gemJoin,
        address daiJoin,
        uint cdp,
        uint wadC,
        uint wadD
    ) public{
        address urn = ManagerLike(manager).urns(cdp);
        address vat = ManagerLike(manager).vat();
        // Takes token amount from user's wallet and joins into the vat
        gemJoin_join(gemJoin, urn, wadC);
        // Locks token amount into the CDP and generates debt
        frob(manager, cdp, toInt(wadC), _getDrawDart(vat, urn, ManagerLike(manager).ilks(cdp), wadD));
        // Moves the DAI amount (balance in the vat in rad) to proxy's address
        move(manager, cdp, address(this), toRad(wadD));
        // Allows adapter to access to proxy's balance in the vat
        VatLike(vat).hope(daiJoin);
        // Exits DAI to the user's wallet as a token
        DaiJoinLike(daiJoin).exit(msg.sender, wadD);
    }

    function openLockGemAndDraw(
        address manager,
        address gemJoin,
        address daiJoin,
        bytes32 ilk,
        uint wadC,
        uint wadD
    ) public returns (uint cdp) {
        cdp = ManagerLike(manager).open(ilk);
        lockGemAndDraw(manager, gemJoin, daiJoin, cdp, wadC, wadD);
    }

    function wipeAndFreeETH(
        address manager,
        address ethJoin,
        address daiJoin,
        uint cdp,
        uint wadC,
        uint wadD
    ) public {
        address urn = ManagerLike(manager).urns(cdp);
        // Joins DAI amount into the vat
        daiJoin_join(daiJoin, urn, wadD);
        // Paybacks debt to the CDP and unlocks WETH amount from it
        frob(manager, cdp, address(this), -toInt(wadC), _getWipeDart(ManagerLike(manager).vat(), urn, ManagerLike(manager).ilks(cdp)));
        // Exits WETH amount to proxy address as a token
        GemJoinLike(ethJoin).exit(address(this), wadC);
        // Converts WETH to ETH
        GemJoinLike(ethJoin).gem().withdraw(wadC);
        // Sends ETH back to the user's wallet
        msg.sender.transfer(wadC);
    }

    function wipeAndFreeGem(
        address manager,
        address gemJoin,
        address daiJoin,
        uint cdp,
        uint wadC,
        uint wadD
    ) public {
        address urn = ManagerLike(manager).urns(cdp);
        // Joins DAI amount into the vat
        daiJoin_join(daiJoin, urn, wadD);
        // Paybacks debt to the CDP and unlocks token amount from it
        frob(manager, cdp, address(this), -toInt(wadC), _getWipeDart(ManagerLike(manager).vat(), urn, ManagerLike(manager).ilks(cdp)));
        // Exits token amount to the user's wallet as a token
        GemJoinLike(gemJoin).exit(msg.sender, wadC);
    }

    function dsrJoin(
        address daiJoin,
        address pot,
        uint wad
    ) public {
        // Joins wad amount to the vat balance
        daiJoin_join(daiJoin, address(this), wad);
        // Approves the pot to take out DAI from the proxy's balance in the vat
        DaiJoinLike(daiJoin).vat().hope(pot);
        // Joins the pie value (equivalent to the DAI wad amount) in the pot
        PotLike(pot).join(mul(wad, ONE) / PotLike(pot).chi());
    }

    function dsrExit(
        address daiJoin,
        address pot,
        uint wad
    ) public {
        // Executes drip to count the savings accumulated until this moment
        PotLike(pot).drip();
        // Calculates the pie value in the pot equivalent to the DAI wad amount
        uint pie = mul(wad, ONE) / PotLike(pot).chi();
        // Exits DAI from the pot
        PotLike(pot).exit(pie);
        // Checks the actual balance of DAI in the vat after the pot exit
        uint bal = DaiJoinLike(daiJoin).vat().dai(address(this));
        // It is necessary to check if due rounding the exact wad amount can be exited by the adapter.
        // Otherwise it will do the maximum DAI balance in the vat
        DaiJoinLike(daiJoin).exit(
            msg.sender,
            bal >= mul(wad, ONE) ? wad : bal / ONE
        );
    }

    function dsrExitAll(
        address daiJoin,
        address pot
    ) public {
        // Executes drip to count the savings accumulated until this moment
        PotLike(pot).drip();
        // Gets the total pie belonging to the proxy address
        uint pie = PotLike(pot).pie(address(this));
        // Exits DAI from the pot
        PotLike(pot).exit(pie);
        // Exits the DAI amount corresponding to the value of pie
        DaiJoinLike(daiJoin).exit(msg.sender, mul(PotLike(pot).chi(), pie) / ONE);
    }
}
