ta:
	clear && forge test -vvv --no-match-test "fork|[fF]uzz"
t:
	clear && forge test -vvv --match-contract ValidateOrderParametersTest --match-test test