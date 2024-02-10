// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.8.0;

import "@openzeppelin/contracts/utils/math/Math.sol";

import "../util/Pricing.sol";
import "../util/Percent.sol";

import "./Uniswap.sol";

library UniLib {
    using Math for uint256;
    using Percent for uint256;

    // **** SWAP ****
    // requires the initial amount to have already been sent to the first pair
    function swap(address factory, uint256[] memory amounts, address[] memory path, address _to) internal {
        for (uint256 i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0,) = UniswapV2Library.sortTokens(input, output);
            uint256 amountOut = amounts[i + 1];
            (uint256 amount0Out, uint256 amount1Out) =
                input == token0 ? (uint256(0), amountOut) : (amountOut, uint256(0));
            address to = i < path.length - 2 ? UniswapV2Library.pairFor(factory, output, path[i + 2]) : _to;
            IUniswapV2Pair(UniswapV2Library.pairFor(factory, input, output)).swap(
                amount0Out, amount1Out, to, new bytes(0)
            );
        }
    }

    // A = token reserve | reserve0
    // B = backing reserve | reserve1
    // P = price
    // C = B.A dot product
    // P == B'/A'
    // A' == C/B'

    // P' == B'/(C/B')
    // P'.(C/B') == B'
    // P'.C == B'^2
    // B' == SQRT(P'.C)
    // price of A in terms of B
    function swapToPrice(uint256 priceA, uint256 reserveA, uint256 reserveB, uint256 decimals, uint256 buffer)
        internal
        pure
        returns (uint256 inA, uint256 inB, uint256 outA, uint256 outB)
    {
        uint256 newReserveB = Math.sqrt((reserveA * reserveB * priceA) / decimals);
        if (newReserveB > reserveB) {
            // increase the required1 amount by a factory of 0.5%
            newReserveB = newReserveB.inversePercent(buffer);
            inB = newReserveB - reserveB;
            outA = UniswapV2Library.getAmountOut(inB, reserveB, reserveA);
        } else if (newReserveB < reserveB) {
            // reduce the required1 amount by a factory of 0.5%
            newReserveB = newReserveB.applyPercent(Percent.BASE_PERCENT - buffer); // allow for the pool fee of 0.3%
            outB = reserveB - newReserveB;
            inA = UniswapV2Library.getAmountIn(outB, reserveA, reserveB);
        }
    }

    // here we want to quote the liquidity using the base price and number of tokens to use.
    // this will give us how many tokens and assets to put into the lp pool, whilst maintaining base price
    // and increasing the total liquidity
    function getUsableTokens(uint256 floorPrice, uint256 totalTokens, uint256 tokenReserve, uint256 assetReserveBASE)
        internal
        pure
        returns (uint256 resultTokens)
    {
        // d = Pricing.DECIMALS
        // p = floorPrice
        // t = totalTokens
        // tR = tokenReserve
        // aR = assetReserve

        // tR' = new tokenReserve
        // aR' = new assetReserve

        uint256 totalBase = Pricing.tokensToBase(floorPrice, totalTokens);

        // x should go to pool
        // y should go to treasury

        // x = (resultTokens * assetReserveBASE) / tokenReserve
        // y = (resultTokens * floorPrice) / decimals

        // x + y == totalBase / 2
        // (resultTokens * assetReserveBASE) / tokenReserve + (resultTokens * floorPrice) / decimals == totalBase / 2
        // resultTokens.(assetReserveBASE/tokenReserve + floorPrice/decimals) == totalBase / 2
        // resultTokens == totalBase / 2.(assetReserveBASE/tokenReserve + floorPrice/decimals)
        // resultTokens == totalBase.decimals / 2.(assetReserveBASE.decimals/tokenReserve + floorPrice)
        // resultTokens == totalBase.decimals.tokenReserve / 2.(assetReserveBASE.decimals + floorPrice.tokenReserve)

        // numerator = totalBase.decimals.tokenReserve
        uint256 numerator = (totalBase * Pricing.DECIMALS * tokenReserve);
        // denominator = 2.(assetReserve.decimals + floorPrice.tokenReserve)
        uint256 denominator = 2 * (assetReserveBASE * Pricing.DECIMALS + floorPrice * tokenReserve);

        // resultTokens to use in the quote
        return numerator / denominator;
    }
}
