ta:
	clear && forge test -vvv --no-match-test "fork|[fF]uzz"
t:
	clear && forge test -vvvv --match-contract CCConstantProduct --match-test "testDefaultDoesNotRevert"
t2:
	clear && forge test -vvvv --match-contract CCConstantProduct --match-test "testReturnedTradeValues"