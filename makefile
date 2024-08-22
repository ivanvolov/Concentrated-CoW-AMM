ta:
	clear && forge test -vvv --no-match-test "fork|[fF]uzz"
t1:
	clear && forge test -vv --match-contract ValidateAmmMath --match-test "testExactAmountsInOut"
t2:
	clear && forge test -vvvv --match-contract CCConstantProduct --match-test "testReturnedTradeValues"