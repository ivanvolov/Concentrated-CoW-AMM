// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

import {BaseComposableCoWTest} from "lib/composable-cow/test/ComposableCoW.base.t.sol";

import {CConstantProduct, GPv2Order, IERC20} from "src/CConstantProduct.sol";
import {UniswapV3PriceOracle} from "src/oracles/UniswapV3PriceOracle.sol";
import {ISettlement} from "src/interfaces/ISettlement.sol";
import {V3MathLib} from "src/libraries/V3MathLib.sol";

abstract contract CConstantProductTestHarness is BaseComposableCoWTest {
    using GPv2Order for GPv2Order.Data;

    struct SignatureData {
        GPv2Order.Data order;
        bytes32 orderHash;
        CConstantProduct.TradingParams tradingParams;
        bytes signature;
    }

    address internal vaultRelayer = makeAddr("vault relayer");
    address private USDC = makeAddr("USDC");
    address private WETH = makeAddr("WETH");
    address private DEFAULT_PAIR = makeAddr("default USDC/WETH pair");
    address private DEFAULT_RECEIVER = makeAddr("default receiver");
    address private DEFAULT_SOLUTION_SETTLER = makeAddr("settlement contract");
    bytes32 private DEFAULT_APPDATA = keccak256(bytes("unit test"));
    bytes32 private DEFAULT_COMMITMENT = keccak256(bytes("order hash"));
    bytes32 private DEFAULT_DOMAIN_SEPARATOR =
        keccak256(bytes("domain separator hash"));

    address private DEFAULT_POOL_ADDRESS =
        makeAddr("default USDC/WETH pool address");
    uint160 DEFAULT_SQRT_PRICE_CURRENT_X96 = uint160(1); //TODO: change it;
    uint160 DEFAULT_SQRT_PRICE_AX96 = uint160(1); //TODO: change it;
    uint160 DEFAULT_SQRT_PRICE_BX96 = uint160(1); //TODO: change it;

    ISettlement internal solutionSettler =
        ISettlement(DEFAULT_SOLUTION_SETTLER);
    CConstantProduct internal constantProduct;
    UniswapV3PriceOracle internal uniswapV2PriceOracle;

    function setUp() public virtual override(BaseComposableCoWTest) {
        super.setUp();
        address constantProductAddress = vm.computeCreateAddress(
            address(this),
            vm.getNonce(address(this))
        );
        setUpSolutionSettler();
        setUpAmmDeployment(constantProductAddress);
        constantProduct = new CConstantProduct(
            solutionSettler,
            IERC20(USDC),
            IERC20(WETH)
        );
        uniswapV2PriceOracle = new UniswapV3PriceOracle();
    }

    function setUpSolutionSettler() internal {
        vm.mockCall(
            DEFAULT_SOLUTION_SETTLER,
            abi.encodeCall(ISettlement.domainSeparator, ()),
            abi.encode(DEFAULT_DOMAIN_SEPARATOR)
        );
        vm.mockCall(
            DEFAULT_SOLUTION_SETTLER,
            abi.encodeCall(ISettlement.vaultRelayer, ()),
            abi.encode(vaultRelayer)
        );
        vm.mockCallRevert(
            DEFAULT_SOLUTION_SETTLER,
            hex"",
            abi.encode("Called unexpected function on mock settlement contract")
        );
    }

    function setUpDefaultPair() internal {
        //TODO: set up token0 and token1 for the pool to check in oracle
    }

    function getDefaultTradingParams()
        internal
        view
        returns (CConstantProduct.TradingParams memory)
    {
        return
            CConstantProduct.TradingParams(
                0,
                uniswapV2PriceOracle,
                abi.encode(DEFAULT_POOL_ADDRESS),
                DEFAULT_APPDATA,
                DEFAULT_SQRT_PRICE_CURRENT_X96,
                DEFAULT_SQRT_PRICE_AX96,
                DEFAULT_SQRT_PRICE_BX96
            );
    }

    function setUpDefaultTradingParams()
        internal
        returns (CConstantProduct.TradingParams memory)
    {
        setUpDefaultPair();
        return getDefaultTradingParams();
    }

    function setUpDefaultCommitment() internal {
        vm.prank(address(solutionSettler));
        constantProduct.commit(DEFAULT_COMMITMENT);
    }

    function setUpDefaultReserves(address owner) internal {
        setUpDefaultWithReserves(owner, 1337, 1337);
    }

    function setUpDefaultWithReserves(
        address owner,
        uint256 amount0,
        uint256 amount1
    ) internal {
        CConstantProduct.TradingParams
            memory defaultTradingParams = setUpDefaultTradingParams();
        UniswapV3PriceOracle.Data memory oracleData = abi.decode(
            defaultTradingParams.priceOracleData,
            (UniswapV3PriceOracle.Data)
        );

        (address _token0, address _token1) = V3MathLib.getTokensFromPool(
            address(oracleData.pool)
        );

        vm.mockCall(
            _token0,
            abi.encodeCall(IERC20.balanceOf, (owner)),
            abi.encode(amount0)
        );
        vm.mockCall(
            _token1,
            abi.encodeCall(IERC20.balanceOf, (owner)),
            abi.encode(amount1)
        );
    }

    function setUpDefaultReferencePairReserves(
        uint256 amount0,
        uint256 amount1
    ) public {
        //TODO: do it for e2e only
    }

    function defaultSignatureAndHashes()
        internal
        view
        returns (SignatureData memory out)
    {
        CConstantProduct.TradingParams
            memory tradingParams = getDefaultTradingParams();
        GPv2Order.Data memory order = getDefaultOrder();
        bytes32 orderHash = order.hash(solutionSettler.domainSeparator());
        bytes memory signature = abi.encode(order, tradingParams);
        out = SignatureData(order, orderHash, tradingParams, signature);
    }

    // This function calls `getTradeableOrder` and immediately checks that the
    // order is valid for the default commitment.
    function checkedGetTradeableOrder(
        CConstantProduct.TradingParams memory tradingParams
    ) internal view returns (GPv2Order.Data memory order) {
        order = constantProduct.getTradeableOrder(tradingParams);
        constantProduct.verify(tradingParams, order);
    }

    function getDefaultOrder() internal view returns (GPv2Order.Data memory) {
        CConstantProduct.TradingParams
            memory tradingParams = getDefaultTradingParams();

        return
            GPv2Order.Data(
                IERC20(USDC), // IERC20 sellToken;
                IERC20(WETH), // IERC20 buyToken;
                GPv2Order.RECEIVER_SAME_AS_OWNER, // address receiver;
                0, // uint256 sellAmount;
                0, // uint256 buyAmount;
                uint32(block.timestamp) +
                    constantProduct.MAX_ORDER_DURATION() /
                    2, // uint32 validTo;
                tradingParams.appData, // bytes32 appData;
                0, // uint256 feeAmount;
                GPv2Order.KIND_SELL, // bytes32 kind;
                true, // bool partiallyFillable;
                GPv2Order.BALANCE_ERC20, // bytes32 sellTokenBalance;
                GPv2Order.BALANCE_ERC20 // bytes32 buyTokenBalance;
            );
    }

    function setUpAmmDeployment(address constantProductAddress) internal {
        setUpTokenForDeployment(
            IERC20(USDC),
            constantProductAddress,
            address(this)
        );
        setUpTokenForDeployment(
            IERC20(WETH),
            constantProductAddress,
            address(this)
        );
    }

    function setUpTokenForDeployment(
        IERC20 token,
        address constantProductAddress,
        address owner
    ) internal {
        mockSafeApprove(
            token,
            constantProductAddress,
            solutionSettler.vaultRelayer()
        );
        mockSafeApprove(token, constantProductAddress, owner);
    }

    function mockSafeApprove(
        IERC20 token,
        address owner,
        address spender
    ) internal {
        mockZeroAllowance(token, owner, spender);
        mockApprove(token, spender);
    }

    function mockApprove(IERC20 token, address spender) internal {
        vm.mockCall(
            address(token),
            abi.encodeCall(IERC20.approve, (spender, type(uint256).max)),
            abi.encode(true)
        );
    }

    function mockZeroAllowance(
        IERC20 token,
        address owner,
        address spender
    ) internal {
        vm.mockCall(
            address(token),
            abi.encodeCall(IERC20.allowance, (owner, spender)),
            abi.encode(0)
        );
    }
}
