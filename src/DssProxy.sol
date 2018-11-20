pragma solidity ^0.4.24;

contract GemLike {
    function approve(address, uint) public;
    function transferFrom(address, address, uint) public;
}

contract CdpHandlerLike {
    function setOwner(address) public;
    function execute(address, bytes) public returns (bytes32);
}

contract CdpRegistryLike {
    function create() public returns (address);
}

contract PitLike {
    function vat() public view returns (VatLike); 
}

contract VatLike {
    function ilks(bytes32) public view returns (uint, uint);
}

contract GemJoinLike {
    function gem() public returns(GemLike);
}

contract DaiAJoinLike {
    function dai() public returns(GemLike);
}

contract DssProxy {
    function open(
        address cdpRegistry
    ) public returns (address handler) {
        handler = CdpRegistryLike(cdpRegistry).create();
    }

    function give(
        address handler,
        address guy
    ) public {
        CdpHandlerLike(handler).setOwner(guy);
    }

    function lockETH(
        address handler,
        address cdpLib,
        address ethJoin,
        address pit
    ) public payable {
        bytes memory calldata = abi.encodeWithSignature("ethJoin_join(address,bytes32)", bytes32(ethJoin), bytes32(handler));
        assert(
            address(handler).call.value(msg.value)(bytes4(keccak256("execute(address,bytes)")), cdpLib, uint256(0x40), calldata.length, calldata)
        );

        (uint take,) = PitLike(pit).vat().ilks("ETH");
        calldata = abi.encodeWithSignature("frob(address,bytes32,int256,int256)", bytes32(pit), bytes32("ETH"), int(msg.value * 10 ** 27 / take), int(0));
        CdpHandlerLike(handler).execute(cdpLib, calldata);
    }

    function lockGem(
        address handler,
        address cdpLib,
        address gemJoin,
        address pit,
        bytes32 ilk,
        uint wad
    ) public {
        GemJoinLike(gemJoin).gem().transferFrom(msg.sender, this, wad);
        GemJoinLike(gemJoin).gem().approve(handler, wad);
        bytes memory calldata = abi.encodeWithSignature("gemJoin_join(address,bytes32,uint256)", bytes32(gemJoin), bytes32(handler), wad);
        CdpHandlerLike(handler).execute(cdpLib, calldata);

        (uint take,) = PitLike(pit).vat().ilks(ilk);
        calldata = abi.encodeWithSignature("frob(address,bytes32,int256,int256)", bytes32(pit), bytes32(ilk), int(wad * 10 ** 27 / take), int(0));
        CdpHandlerLike(handler).execute(cdpLib, calldata);
    } 

    function freeETH(
        address handler,
        address cdpLib,
        address ethJoin,
        address pit,
        uint wad
    ) public {
        (uint take,) = PitLike(pit).vat().ilks("ETH");
        bytes memory calldata = abi.encodeWithSignature("frob(address,bytes32,int256,int256)", bytes32(pit), bytes32("ETH"), -int(wad * 10 ** 27 / take), 0);
        CdpHandlerLike(handler).execute(cdpLib, calldata);
        
        calldata = abi.encodeWithSignature("ethJoin_exit(address,address,uint256)", bytes32(ethJoin), bytes32(msg.sender), wad);
        CdpHandlerLike(handler).execute(cdpLib, calldata);
    }

    function freeGem(
        address handler,
        address cdpLib,
        address gemJoin,
        address pit,
        bytes32 ilk,
        uint wad
    ) public {
        (uint take,) = PitLike(pit).vat().ilks(ilk);
        bytes memory calldata = abi.encodeWithSignature("frob(address,bytes32,int256,int256)", bytes32(pit), ilk, -int(wad * 10 ** 27 / take), 0);
        CdpHandlerLike(handler).execute(cdpLib, calldata);
        
        calldata = abi.encodeWithSignature("gemJoin_exit(address,address,uint256)", bytes32(gemJoin), bytes32(msg.sender), wad);
        CdpHandlerLike(handler).execute(cdpLib, calldata);
    }

    function draw(
        address handler,
        address cdpLib,
        address daiJoin,
        address pit,
        bytes32 ilk,
        uint wad
    ) public {
        (, uint rate) = PitLike(pit).vat().ilks(ilk);
        bytes memory calldata = abi.encodeWithSignature("frob(address,bytes32,int256,int256)", bytes32(pit), ilk, 0, int(wad * 10 ** 27 / rate));
        CdpHandlerLike(handler).execute(cdpLib, calldata);

        calldata = abi.encodeWithSignature("daiJoin_exit(address,address,uint256)", bytes32(daiJoin), bytes32(msg.sender), wad);
        CdpHandlerLike(handler).execute(cdpLib, calldata);
    }

    function wipe(
        address handler,
        address cdpLib,
        address daiJoin,
        address pit,
        bytes32 ilk,
        uint wad
    ) public {
        DaiAJoinLike(daiJoin).dai().transferFrom(msg.sender, this, wad);
        DaiAJoinLike(daiJoin).dai().approve(handler, wad);
        bytes memory calldata = abi.encodeWithSignature("daiJoin_join(address,bytes32,uint256)", bytes32(daiJoin), bytes32(handler), wad);
        CdpHandlerLike(handler).execute(cdpLib, calldata);
        
        (, uint rate) = PitLike(pit).vat().ilks(ilk);
        calldata = abi.encodeWithSignature("frob(address,bytes32,int256,int256)", bytes32(pit), ilk, 0, -int(wad * 10 ** 27 / rate));
        CdpHandlerLike(handler).execute(cdpLib, calldata);
    }

    function lockETHAndDraw(
        address handler,
        address cdpLib,
        address ethJoin,
        address daiJoin,
        address pit,
        uint wadD
    ) public payable {
        lockETH(handler, cdpLib, ethJoin, pit);
        draw(handler, cdpLib, daiJoin, pit, "ETH", wadD);
    }

    function openLockETHAndDraw(
        address cdpRegistry,
        address cdpLib,
        address ethJoin,
        address daiJoin,
        address pit,
        uint wadD
    ) public payable returns (address handler) {
        handler = open(cdpRegistry);
        lockETHAndDraw(handler, cdpLib, ethJoin, daiJoin, pit, wadD);
    }

    function lockGemAndDraw(
        address handler,
        address cdpLib,
        address ethJoin,
        address daiJoin,
        address pit,
        bytes32 ilk,
        uint wadC,
        uint wadD
    ) public payable {
        lockGem(handler, cdpLib, ethJoin, pit, ilk, wadC);
        draw(handler, cdpLib, daiJoin, pit, ilk, wadD);
    }

    function openLockGemAndDraw(
        address cdpRegistry,
        address cdpLib,
        address ethJoin,
        address daiJoin,
        address pit,
        bytes32 ilk,
        uint wadC,
        uint wadD
    ) public returns (address handler) {
        handler = open(cdpRegistry);
        lockGemAndDraw(handler, cdpLib, ethJoin, daiJoin, pit, ilk, wadC, wadD);
    }

    function wipeAndFreeETH(
        address handler,
        address cdpLib,
        address ethJoin,
        address daiJoin,
        address pit,
        uint wadC,
        uint wadD
    ) public payable {
        wipe(handler, cdpLib, daiJoin, pit, "ETH", wadD);
        freeETH(handler, cdpLib, ethJoin, pit, wadC);
    }

    function wipeAndFreeGem(
        address handler,
        address cdpLib,
        address gemJoin,
        address daiJoin,
        address pit,
        bytes32 ilk,
        uint wadC,
        uint wadD
    ) public payable {
        wipe(handler, cdpLib, daiJoin, pit, ilk, wadD);
        freeGem(handler, cdpLib, gemJoin, pit, ilk, wadC);
    }
}
