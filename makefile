ta:
	forge test -vvv --no-match-test "fork|[fF]uzz"
t:
	forge test -vvv --match-contract V3MathLibTest
t1:
	forge test -vvv --match-contract V3MathLibTest --match-test test_uniswapV3_math_swap_amount0
t2:
	forge test -vvv --match-contract V3MathLibTest --match-test test_uniswapV3_math_swap_sqrt_price
t3:
	forge test -vvv --match-contract ValidateUniswapV3Math --match-test testReturnedTradeValues
t4:
	forge test -vvv --match-contract V3OracleTest --fork-url https://eth-mainnet.g.alchemy.com/v2/38A3rlBUZpErpHxQnoZlEhpRHSu4a7VB --fork-block-number 19955703