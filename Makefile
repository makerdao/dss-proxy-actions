build	:; DAPP_BUILD_OPTIMIZE=1 DAPP_BUILD_OPTIMIZE_RUNS=200 forge build --use solc:0.6.12
clean	:; forge clean
test	:; ./test.sh $(match)
