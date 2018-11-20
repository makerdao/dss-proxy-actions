# dss-proxy
Initial version of the proxy functions to be used via ds-proxy. These functions are based on mcd-cdp-handler as CDP owner.

https://github.com/makerdao/dss-proxy

`open`: creates a new handler

`give`: sets owner of a handler, it could also create a new authority for it - TBD

`lockETH`: deposits ETH in adapter and executes `frob` increasing locked collateral

`lockGem`: deposits ERC20 Collateral in adapter and executes `frob` increasing locked collateral

`freeETH`: executes `frob` decreasing locked collateral and withdraws ETH from adapter

`freeGem`: executes `frob` decreasing locked collateral and withdraws ERC20 Collateral from adapter

`draw`: executes `frob` increasing debt and exits token (minting it) from DAI adapter

`wipe`: joins token to the DAI adapter (burns it) and executes `frob` for decreasing debt

`lockETHAndDraw`: combines `lockETH` and `draw`

`openLockETHAndDraw`: combines `open`, `lockETH` and `draw`

`lockGemAndDraw`: combines `lockGem` and `draw`

`openLockGemAndDraw`: combines `open`, `lockGem` and `draw`

`wipeAndFreeETH`: combines `wipe` and `freeETH`

`wipeAndFreeGem`: combines `wipe` and `freeGem`
