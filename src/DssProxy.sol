pragma solidity >=0.5.0;

contract GemLike {
    function approve(address, uint) public;
    function transferFrom(address, address, uint) public;
}

contract CdpHandlerLike {
    function setOwner(address) public;
    function execute(address, bytes memory) public returns (bytes32);
}

contract CdpRegistryLike {
    function build() public returns (address payable);
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

contract DaiJoinLike {
    function dai() public returns(GemLike);
}

contract DssProxy {
    uint256 constant ONE = 10 ** 27;

    // Public methods
    function open(
        address cdpRegistry
    ) public returns (address payable handler) {
        handler = CdpRegistryLike(cdpRegistry).build();
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
        (bool success,) = address(handler).call.value(msg.value)(
            abi.encodeWithSignature(
                "execute(address,bytes)",
                cdpLib,
                abi.encodeWithSignature(
                    "lockETH(address,address)",
                    bytes32(uint(address(ethJoin))),
                    bytes32(uint(address(pit)))
                )
            )
        );
        require(success, "Call failed");
    }

    function lockGem(
        address handler,
        address cdpLib,
        address gemJoin,
        address pit,
        bytes32 ilk,
        uint wad
    ) public {
        GemJoinLike(gemJoin).gem().transferFrom(msg.sender, address(this), wad);
        GemJoinLike(gemJoin).gem().approve(handler, wad);
        CdpHandlerLike(handler).execute(
            cdpLib,
            abi.encodeWithSignature(
                "lockGem(address,address,bytes32,uint256)",
                bytes32(uint(address(gemJoin))),
                bytes32(uint(address(pit))),
                ilk,
                bytes32(wad)
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
                "freeETH(address,address,address,uint256)",
                bytes32(uint(address(ethJoin))),
                bytes32(uint(address(pit))),
                bytes32(uint(msg.sender)),
                bytes32(wad)
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
                "freeGem(address,address,bytes32,address,uint256)",
                bytes32(uint(address(gemJoin))),
                bytes32(uint(address(pit))),
                ilk,
                bytes32(uint(msg.sender)),
                bytes32(wad)
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
                "draw(address,address,bytes32,address,uint256)",
                bytes32(uint(address(daiJoin))),
                bytes32(uint(address(pit))),
                ilk,
                bytes32(uint(msg.sender)),
                bytes32(wad)
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
        DaiJoinLike(daiJoin).dai().transferFrom(msg.sender, address(this), wad);
        DaiJoinLike(daiJoin).dai().approve(handler, wad);
        CdpHandlerLike(handler).execute(
            cdpLib,
            abi.encodeWithSignature(
                "wipe(address,address,bytes32,uint256)",
                bytes32(uint(address(daiJoin))),
                bytes32(uint(address(pit))),
                ilk,
                bytes32(wad)
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
        (bool success,) = address(handler).call.value(msg.value)(
            abi.encodeWithSignature(
                "execute(address,bytes)",
                cdpLib,
                abi.encodeWithSignature(
                    "lockETHAndDraw(address,address,address,address,uint256)",
                    bytes32(uint(address(ethJoin))),
                    bytes32(uint(address(daiJoin))),
                    bytes32(uint(address(pit))),
                    bytes32(uint(msg.sender)),
                    bytes32(wadD)
                )
            )
        );
        require(success, "Call failed");
    }

    function openLockETHAndDraw(
        address cdpRegistry,
        address cdpLib,
        address ethJoin,
        address daiJoin,
        address pit,
        uint wadD
    ) public payable returns (address payable handler) {
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
    ) public {
        GemJoinLike(gemJoin).gem().transferFrom(msg.sender, address(this), wadC);
        GemJoinLike(gemJoin).gem().approve(handler, wadC);
        CdpHandlerLike(handler).execute(
            cdpLib,
            abi.encodeWithSignature(
                "lockGemAndDraw(address,address,address,bytes32,address,uint256,uint256)",
                bytes32(uint(address(gemJoin))),
                bytes32(uint(address(daiJoin))),
                bytes32(uint(address(pit))),
                ilk,
                bytes32(uint(msg.sender)),
                bytes32(wadC),
                bytes32(wadD)
            )
        );
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
    ) public returns (address payable handler) {
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
    ) public {
        DaiJoinLike(daiJoin).dai().transferFrom(msg.sender, address(this), wadD);
        DaiJoinLike(daiJoin).dai().approve(handler, wadD);
        CdpHandlerLike(handler).execute(
            cdpLib,
            abi.encodeWithSignature(
                "wipeAndFreeETH(address,address,address,address,uint256,uint256)",
                bytes32(uint(address(ethJoin))),
                bytes32(uint(address(daiJoin))),
                bytes32(uint(address(pit))),
                bytes32(uint(msg.sender)),
                bytes32(wadC),
                bytes32(wadD)
            )
        );
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
    ) public {
        DaiJoinLike(daiJoin).dai().transferFrom(msg.sender, address(this), wadD);
        DaiJoinLike(daiJoin).dai().approve(handler, wadD);
        CdpHandlerLike(handler).execute(
            cdpLib,
            abi.encodeWithSignature(
                "wipeAndFreeGem(address,address,address,bytes32,address,uint256,uint256)",
                bytes32(uint(address(gemJoin))),
                bytes32(uint(address(daiJoin))),
                bytes32(uint(address(pit))),
                ilk,
                bytes32(uint(msg.sender)),
                bytes32(wadC),
                bytes32(wadD)
            )
        );
    }
}
