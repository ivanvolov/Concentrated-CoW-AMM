ta:
	clear && forge test -vv --no-match-test "fork|[fF]uzz"
tal:
	clear && forge test -vvvv --no-match-test "fork|[fF]uzz"
t:
	clear && forge test -vv --match-test "testNewAMMHasExpectedTokens"
tl:
	clear && forge test -vvvv --match-test "testNewAMMHasExpectedTokens"