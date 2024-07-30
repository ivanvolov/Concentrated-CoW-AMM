ta:
	forge test -vvv --no-match-test "fork|[fF]uzz"
t:
	forge test -vvv --match-contract V3MathLibTest
t1:
	forge test -vvv --match-contract V3MathLibTest --match-test test_uniswapV3_math_tick_and_prices
t2:
	forge test -vvv --match-contract ValidateUniswapMath --match-test testReturnedTradeValues