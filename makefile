ta:
	clear && forge test -vvv --no-match-test "fork|[fF]uzz"
t:
	clear && forge test -vv --match-contract E2EConditionalOrderTest --match-test "testE2ESettle"