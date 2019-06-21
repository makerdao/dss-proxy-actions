# dss-proxy-actions
Proxy functions to be used via ds-proxy. These functions are based on `dss-cdp-manager` as CDP registry.

https://github.com/makerdao/dss-proxy-actions

`open(address manager, bytes32 ilk)`: creates an `UrnHandler` (`cdp`) for the caller (for a specific `ilk`) and allows to manage it via the internal registry of the `manager`.

`give(address manager, uint cdp, address guy)`: transfers the ownership of the `cdp` in the `manager` registry to `guy` address.

`allow(address manager, uint cdp, address guy, uint ok)`: allows/denies `guy` address to manage the `cdp`.

`flux(address manager, uint cdp, address dst, uint wad)`: moves `wad` amount of collateral from the `cdp` address to `dst` address.

`move(address manager, uint cdp, address dst, uint rad)`: moves `rad` amount of DAI from the `cdp` address to `dst` address.

`frob(address manager, uint cdp, int dink, int dart)`: executes `frob` for `cdp` address assigning the collateral freed and/or DAI drawn to the same address.

`frob(address manager, uint cdp, address dst, int dink, int dart)`: executes `frob` for `cdp` address assigning the collateral freed or DAI drawn to `dst` address.

`quit(address manager, uint cdp, address dst)`: moves the `cdp` collateral balance and debt to `dst` address.

`lockETH(address manager, address ethJoin, uint cdp)`: deposits ETH in adapter and executes `frob` for `cdp` increasing the locked value.

`lockGem(address manager, address gemJoin, uint cdp, uint wad)`: deposits `wad` amount of collateral in adapter and executes `frob` for `cdp` increasing the locked value.

`freeETH(address manager, address ethJoin, uint cdp, uint wad)`: executes `frob` for `cdp` decreasing locked collateral and withdraws `wad` amount of ETH from `ethJoin` adapter.

`freeGem(address manager, address gemJoin, uint cdp, uint wad)`: executes `frob` for `cdp` decreasing locked collateral and withdraws `wad` amount of collateral from `gemJoin` adapter.

`draw(address manager, address daiJoin, uint cdp, uint wad)`: executes `frob` for `cdp` increasing debt and exits `wad` amount of DAI token (minting it) from `daiJoin` adapter.

`wipe(address manager, address daiJoin, uint cdp, uint wad)`: joins `wad` amount of DAI token to the `daiJoin` adapter (burning it) and executes `frob` for `cdp` for decreasing debt.

`lockETHAndDraw(address manager, address ethJoin, address daiJoin, uint cdp, uint wadD)`: combines `lockETH` and `draw`.

`openLockETHAndDraw(address manager, address ethJoin, address daiJoin, bytes32 ilk, uint wadD)`: combines `open`, `lockETH` and `draw`.

`lockGemAndDraw(address manager, address gemJoin, address daiJoin, uint cdp, uint wadC, uint wadD)`: combines `lockGem` and `draw`.

`openLockGemAndDraw(address manager, address gemJoin, address daiJoin, bytes32 ilk, uint wadC, uint wadD)`: combines `open`, `lockGem` and `draw`.

`wipeAndFreeETH(address manager, address ethJoin, address daiJoin, uint cdp, uint wadC, uint wadD)`: combines `wipe` and `freeETH`.

`wipeAndFreeGem(address manager, address gemJoin, address daiJoin, uint cdp, uint wadC, uint wadD)`: combines `wipe` and `freeGem`.

`dsrJoin(address daiJoin, address pot, uint wad)`: joins `wad` amount of DAI token to the `daiJoin` adapter (burning it) and moves the balance to the `pot` for DAI Saving Rates.

`dsrExit(address daiJoin, address pot, uint wad)`: retrieves `wad` amount of DAI from the `pot` and exits DAI token from the `daiJoin` Adapter (minting it).

`dsrExitAll(address daiJoin, address pot)`: same than `dsrExit` but all the available amount.
