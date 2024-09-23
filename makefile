ta:
	clear && forge test -vv --no-match-test "fork|[fF]uzz"
tal:
	clear && forge test -vvvv --no-match-test "fork|[fF]uzz"
t:
	clear && forge test -vv --match-contract ValidateUniswapV3Math --match-test "test"
tl:
	clear && forge test -vvvv --match-contract ValidateUniswapV3Math --match-test "test"