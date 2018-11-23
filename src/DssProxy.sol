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
    function dai(bytes32) public view returns (uint);
}

contract GemJoinLike {
    function gem() public returns(GemLike);
}

contract DaiAJoinLike {
    function dai() public returns(GemLike);
}

contract DssProxy {
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
        address handler,
        address pit,
        bytes32 ilk,
        uint wad
    ) internal view returns (int dart) {
        (, uint rate) = PitLike(pit).vat().ilks(ilk);
        uint dai = PitLike(pit).vat().dai(bytes32(handler));

        if (dai < mul(wad, ONE)) {
            // If there was already enough DAI generated but not extracted as token, ignore this statement and do the exit directly
            // Otherwise generate the missing necessart part
            dart = int(sub(mul(wad, ONE), dai) / rate);
            dart = int(mul(uint(dart), rate) < mul(wad, ONE) ? dart + 1 : dart); // This is neeeded due lack of precision of dart value
        }
    }

    function _getWipeDart(
        address handler,
        address pit,
        bytes32 ilk
    ) internal view returns (int dart) {
        uint dai = PitLike(pit).vat().dai(bytes32(handler));
        (, uint rate) = PitLike(pit).vat().ilks(ilk);
        // Decrease the whole allocated dai balance: dai / rate
        dart = - int(dai / rate);
    }

    // Public methods

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
        bytes memory calldata = abi.encodeWithSignature(
            "ethJoin_join(address,bytes32)",
            bytes32(ethJoin),
            bytes32(handler)
        );
        require(
            address(handler).call.value(msg.value)(
                bytes4(keccak256("execute(address,bytes)")),
                cdpLib,
                uint256(0x40),
                calldata.length,
                calldata
            ),
            "Call failed"
        );

        CdpHandlerLike(handler).execute(
            cdpLib,
            abi.encodeWithSignature(
                "frob(address,bytes32,int256,int256)",
                bytes32(pit),
                bytes32("ETH"),
                _getLockDink(pit, "ETH", msg.value),
                int(0)
            )
        );
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
        CdpHandlerLike(handler).execute(
            cdpLib,
            abi.encodeWithSignature(
                "gemJoin_join(address,bytes32,uint256)",
                bytes32(gemJoin),
                bytes32(handler),
                wad
            )
        );

        CdpHandlerLike(handler).execute(
            cdpLib,
            abi.encodeWithSignature(
                "frob(address,bytes32,int256,int256)",
                bytes32(pit),
                bytes32(ilk),
                _getLockDink(pit, ilk, wad),
                int(0)
            )
        );
    } 

    function freeETH(
        address handler,
        address cdpLib,
        address ethJoin,
        address pit,
        uint wad
    ) public {
        CdpHandlerLike(handler).execute(
            cdpLib,
            abi.encodeWithSignature(
                "frob(address,bytes32,int256,int256)",
                bytes32(pit),
                bytes32("ETH"),
                _getFreeDink(pit, "ETH", wad),
                0
            )
        );

        CdpHandlerLike(handler).execute(
            cdpLib,
            abi.encodeWithSignature(
                "ethJoin_exit(address,address,uint256)",
                bytes32(ethJoin),
                bytes32(msg.sender),
                wad
            )
        );
    }

    function freeGem(
        address handler,
        address cdpLib,
        address gemJoin,
        address pit,
        bytes32 ilk,
        uint wad
    ) public {
        CdpHandlerLike(handler).execute(
            cdpLib,
            abi.encodeWithSignature(
                "frob(address,bytes32,int256,int256)",
                bytes32(pit),
                ilk,
                _getFreeDink(pit, ilk, wad),
                0
            )
        );

        CdpHandlerLike(handler).execute(
            cdpLib,
            abi.encodeWithSignature(
                "gemJoin_exit(address,address,uint256)",
                bytes32(gemJoin),
                bytes32(msg.sender),
                wad
            )
        );
    }

    function draw(
        address handler,
        address cdpLib,
        address daiJoin,
        address pit,
        bytes32 ilk,
        uint wad
    ) public {
        CdpHandlerLike(handler).execute(
            cdpLib,
            abi.encodeWithSignature(
                "frob(address,bytes32,int256,int256)",
                bytes32(pit), ilk,
                0,
                _getDrawDart(handler, pit, ilk, wad)
            )
        );

        CdpHandlerLike(handler).execute(
            cdpLib,
            abi.encodeWithSignature(
                "daiJoin_exit(address,address,uint256)",
                bytes32(daiJoin),
                bytes32(msg.sender),
                wad
            )
        );
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
        CdpHandlerLike(handler).execute(
            cdpLib,
            abi.encodeWithSignature(
                "daiJoin_join(address,bytes32,uint256)",
                bytes32(daiJoin),
                bytes32(handler),
                wad
            )
        );

        CdpHandlerLike(handler).execute(
            cdpLib,
            abi.encodeWithSignature(
                "frob(address,bytes32,int256,int256)",
                bytes32(pit),
                ilk,
                0,
                _getWipeDart(handler, pit, ilk)
            )
        );
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
        address gemJoin,
        address daiJoin,
        address pit,
        bytes32 ilk,
        uint wadC,
        uint wadD
    ) public payable {
        lockGem(handler, cdpLib, gemJoin, pit, ilk, wadC);
        draw(handler, cdpLib, daiJoin, pit, ilk, wadD);
    }

    function openLockGemAndDraw(
        address cdpRegistry,
        address cdpLib,
        address gemJoin,
        address daiJoin,
        address pit,
        bytes32 ilk,
        uint wadC,
        uint wadD
    ) public returns (address handler) {
        handler = open(cdpRegistry);
        lockGemAndDraw(handler, cdpLib, gemJoin, daiJoin, pit, ilk, wadC, wadD);
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
