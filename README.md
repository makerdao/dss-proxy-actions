# dss-proxy-actions
![Build Status](https://github.com/makerdao/dss-proxy-actions/actions/workflows/.github/workflows/tests.yaml/badge.svg?branch=master)

Proxy functions to be used via ds-proxy. These functions are based on `dss-cdp-manager` as CDP registry.

https://github.com/makerdao/dss-proxy-actions

## DssProxyActions

`open(address manager, bytes32 ilk, address usr)`: creates an `UrnHandler` (`cdp`) for the address `usr` (for a specific `ilk`) and allows to manage it via the internal registry of the `manager`.

`give(address manager, uint cdp, address usr)`: transfers the ownership of `cdp` to `usr` address in the `manager` registry.

`giveToProxy(address proxyRegistry, address manager, uint cdp, address usr)`: transfers the ownership of `cdp` to the proxy of `usr` address (via `proxyRegistry`) in the `manager` registry.

`cdpAllow(address manager, uint cdp, address usr, uint ok)`: allows/denies `usr` address to manage the `cdp`.

`urnAllow(address manager, address usr, uint ok)`: allows/denies `usr` address to manage the `msg.sender` address as `dst` for `quit`.

`flux(address manager, uint cdp, address dst, uint wad)`: moves `wad` amount of collateral from `cdp` address to `dst` address.

`move(address manager, uint cdp, address dst, uint rad)`: moves `rad` amount of DAI from `cdp` address to `dst` address.

`frob(address manager, uint cdp, int dink, int dart)`: executes `frob` to `cdp` address assigning the collateral freed and/or DAI drawn to the same address.

`quit(address manager, uint cdp, address dst)`: moves `cdp` collateral balance and debt to `dst` address.

`enter(address manager, address src, uint cdp)`: moves `src` collateral balance and debt to `cdp`.

`shift(address manager, uint cdpSrc, uint cdpDst)`: moves `cdpSrc` collateral balance and debt to `cdpDst`.

`lockETH(address manager, address ethJoin, uint cdp)`: deposits `msg.value` amount of ETH in `ethJoin` adapter and executes `frob` to `cdp` increasing the locked value.

`safeLockETH(address manager, address ethJoin, uint cdp, address owner)`: same than `lockETH` but requiring `owner == cdp owner`.

`lockGem(address manager, address gemJoin, uint cdp, uint wad, bool transferFrom)`: deposits `wad` amount of collateral in `gemJoin` adapter and executes `frob` to `cdp` increasing the locked value. Gets funds from `msg.sender` if `transferFrom == true`.

`safeLockGem(address manager, address gemJoin, uint cdp, uint wad, bool transferFrom, address owner)`: same than `lockGem` but requiring `owner == cdp owner`.

`freeETH(address manager, address ethJoin, uint cdp, uint wad)`: executes `frob` to `cdp` decreasing locked collateral and withdraws `wad` amount of ETH from `ethJoin` adapter.

`freeGem(address manager, address gemJoin, uint cdp, uint wad)`: executes `frob` to `cdp` decreasing locked collateral and withdraws `wad` amount of collateral from `gemJoin` adapter.

`draw(address manager, address jug, address daiJoin, uint cdp, uint wad)`: updates collateral fee rate, executes `frob` to `cdp` increasing debt and exits `wad` amount of DAI token (minting it) from `daiJoin` adapter.

`wipe(address manager, address daiJoin, uint cdp, uint wad)`: joins `wad` amount of DAI token to `daiJoin` adapter (burning it) and executes `frob` to `cdp` for decreasing debt.

`safeWipe(address manager, address daiJoin, uint cdp, uint wad, address owner)`: same than `wipe` but requiring `owner == cdp owner`.

`wipeAll(address manager, address daiJoin, uint cdp)`: joins all the necessary amount of DAI token to `daiJoin` adapter (burning it) and executes `frob` to `cdp` setting the debt to zero.

`safeWipeAll(address manager, address daiJoin, uint cdp, address owner)`: same than `wipeAll` but requiring `owner == cdp owner`.

`lockETHAndDraw(address manager, address jug, address ethJoin, address daiJoin, uint cdp, uint wadD)`: combines `lockETH` and `draw`.

`openLockETHAndDraw(address manager, address jug, address ethJoin, address daiJoin, bytes32 ilk, uint wadD)`: combines `open`, `lockETH` and `draw`.

`lockGemAndDraw(address manager, address jug, address gemJoin, address daiJoin, uint cdp, uint wadC, uint wadD, bool transferFrom)`: combines `lockGem` and `draw`.

`openLockGemAndDraw(address manager, address jug, address gemJoin, address daiJoin, bytes32 ilk, uint wadC, uint wadD, bool transferFrom)`: combines `open`, `lockGem` and `draw`.

`wipeAndFreeETH(address manager, address ethJoin, address daiJoin, uint cdp, uint wadC, uint wadD)`: combines `wipe` and `freeETH`.

`wipeAllAndFreeETH(address manager, address ethJoin, address daiJoin, uint cdp, uint wadC)`: combines `wipeAll` and `freeETH`.

`wipeAndFreeGem(address manager, address gemJoin, address daiJoin, uint cdp, uint wadC, uint wadD)`: combines `wipe` and `freeGem`.

`wipeAllAndFreeGem(address manager, address gemJoin, address daiJoin, uint cdp, uint wadC)`: combines `wipeAll` and `freeGem`.

`openLockGNTAndDraw(address manager, address jug, address gntJoin, address daiJoin, bytes32 ilk, uint wadC, uint wadD)`: like `openLockGemAndDraw` but specially for GNT token.

## DssProxyActionsFlip

`exitETH(address manager, address ethJoin, uint cdp, uint wad)`: exits `wad` amount of ETH from `ethJoin` adapter (received in the `cdp` urn after the liquidation auction is over).

`exitGem(address manager, address gemJoin, uint cdp, uint wad)`: exits `wad` amount of collateral from `gemJoin` adapter (received in the `cdp` urn after the liquidation auction is over).

## DssProxyActionsEnd

`freeETH(address manager, address ethJoin, address end, uint cdp)`: after system is caged, recovers remaining ETH from `cdp` (pays remaining debt if exists).

`freeGem(address manager, address gemJoin, address end, uint cdp)`: after system is caged, recovers remaining token from `cdp` (pays remaining debt if exists).

`pack(address daiJoin, address end, uint wad)`: after system is caged, packs `wad` amount of DAI to be ready for cashing.

`cashETH(address ethJoin, address end, bytes32 ilk, uint wad)`: after system is caged, cashes `wad` amount of previously packed DAI and returns the equivalent in ETH.

`cashGem(address gemJoin, address end, bytes32 ilk, uint wad)`: after system is caged, cashes `wad` amount of previously packed DAI and returns the equivalent in token.

## DssProxyActionsDsr

`join(address daiJoin, address pot, uint wad)`: joins `wad` amount of DAI token to `daiJoin` adapter (burning it) and moves balance to `pot` for DAI Saving Rates.

`exit(address daiJoin, address pot, uint wad)`: retrieves `wad` amount of DAI from `pot` and exits DAI token from `daiJoin` adapter (minting it).

`exitAll(address daiJoin, address pot)`: same than `exit` but all the available amount.
