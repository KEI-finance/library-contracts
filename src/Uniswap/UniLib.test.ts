import { UniLibTest, UniLibTest__factory } from '../../../types'
import { ethers } from 'hardhat'
import { BigNumber } from 'ethers'
import { percent } from '~/utils'

describe('UniLib', () => {
  let uniLibTest: UniLibTest
  const decimals = percent(1)

  beforeEach(async () => {
    const [defaultAccount] = await ethers.getSigners()
    const uniLibTestFactory = new UniLibTest__factory(defaultAccount)
    uniLibTest = await uniLibTestFactory.deploy()
  })

  it('should test', async () => {
    const reserve0 = BigNumber.from(10).pow(24).mul(3)
    const reserve1 = BigNumber.from(10).pow(30).mul(9)
    const currentPrice = calculatePrice(reserve0, reserve1)
    const doublePrice = currentPrice.mul(2)
    const halfPrice = currentPrice.div(2)

    const swapToDouble = await uniLibTest.amountsForPrice(
      doublePrice,
      reserve0,
      reserve1,
      decimals,
      percent(0.003)
    )
    const swapToHalf = await uniLibTest.amountsForPrice(
      halfPrice,
      reserve0,
      reserve1,
      decimals,
      percent(0.003)
    )

    console.log(
      calculatePrice(
        reserve0.add(swapToHalf.inA).sub(swapToHalf.outA),
        reserve1.add(swapToHalf.inB).sub(swapToHalf.outB)
      ).toString()
    )
    console.log(halfPrice.toString())
    console.log(currentPrice.toString())
    console.log(doublePrice.toString())
    console.log(
      calculatePrice(
        reserve0.add(swapToDouble.inA).sub(swapToDouble.outA),
        reserve1.add(swapToDouble.inB).sub(swapToDouble.outB)
      ).toString()
    )

    console.log(swapToDouble)
  })

  function calculatePrice(reserve0: BigNumber, reserve1: BigNumber) {
    return reserve1.mul(decimals).div(reserve0)
  }
})
