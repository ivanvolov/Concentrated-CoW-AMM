ta:
	clear && forge test -vvv --no-match-test "fork|[fF]uzz"

t1:
	clear && forge test -vvv --match-contract V3MathLibTest --match-test "test_uniswapV3_math_swap_sqrt_price"
t2:
	clear && forge test -vvv --match-contract V3MathLibTest --match-test "test_uniswapV3_math_swap_sqrt_price_out_of_range"


t3:
	clear && forge test -vv --match-contract ValidateOrderHash
t4:
	clear && forge test -vv --match-contract ValidateOrderHash --match-test "testReturnsMagicValueIfTradeable"





t5:
	clear && forge test -vvv --match-contract V3OracleTest --fork-url https://eth-mainnet.g.alchemy.com/v2/38A3rlBUZpErpHxQnoZlEhpRHSu4a7VB --fork-block-number 19955703