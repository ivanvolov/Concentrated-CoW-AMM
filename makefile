ta:
	clear && forge test -vvv --no-match-test "fork|[fF]uzz"
t:
	clear && forge test -vvv --match-contract DeterministicDeployment --match-test "testDifferentOwnersCanDeployAMMWithSameParameters"