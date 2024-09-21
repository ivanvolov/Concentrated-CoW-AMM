ta:
	clear && forge test -vvv --no-match-test "fork|[fF]uzz"
t:
	clear && forge test -vv --match-contract CMathLibTest --match-test "test"
tl:
	clear && forge test -vvvv --match-contract CMathLibTest --match-test "test"