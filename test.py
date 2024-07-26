import math

q96 = 2**96
def price_to_sqrtp(p):
    return int(math.sqrt(p) * q96)

def price_to_tick(p):
    return math.floor(math.log(p, 1.0001))


q96 = 2**96
def calc_amount0(liq, pa, pb):
    if pa > pb:
        pa, pb = pb, pa
    return int(liq * q96 * (pb - pa) / pa / pb)


sqrtp_low = price_to_sqrtp(4545)
sqrtp_cur = price_to_sqrtp(5000)
sqrtp_upp = price_to_sqrtp(5500)

def liquidity0(amount, pa, pb):
    if pa > pb:
        pa, pb = pb, pa
    return (amount * (pa * pb) / q96) / (pb - pa)

def liquidity1(amount, pa, pb):
    if pa > pb:
        pa, pb = pb, pa
    return amount * q96 / (pb - pa)

eth = 10**18
amount_eth = 1 * eth
amount_usdc = 5000 * eth

liq0 = liquidity0(amount_eth, sqrtp_cur, sqrtp_upp)
liq1 = liquidity1(amount_usdc, sqrtp_cur, sqrtp_low)
liq = int(min(liq0, liq1))
print(liq)

def calc_amount0(liq, pa, pb):
    if pa > pb:
        pa, pb = pb, pa
    return int(liq * q96 * (pb - pa) / pa / pb)


def calc_amount1(liq, pa, pb):
    if pa > pb:
        pa, pb = pb, pa
    return int(liq * (pb - pa) / q96)

## Swap 1

amount_in = 42 * eth
price_diff = (amount_in * q96) // liq
price_next = sqrtp_cur + price_diff
print("New price:", (price_next / q96) ** 2)
print("New sqrtP:", price_next)
amount_in = calc_amount1(liq, price_next, sqrtp_cur)
amount_out = calc_amount0(liq, price_next, sqrtp_cur)

print("USDC in:", amount_in / eth)
print("ETH out:", amount_out / eth)


## Swap 2
print("\n\n")
amount_in = 0.008396714242162444 * eth

price_next = (liq*sqrtp_cur)/((sqrtp_cur/q96)*amount_in + liq)
# print("->", format((sqrtp_cur/q96)*amount_in + liq,'.0f'))
print("New price:", (price_next / q96) ** 2)
print("New sqrtP:", price_next)
print("Cur sqrtP:", sqrtp_cur) 

# print(liq)
# print((sqrtp_cur/q96)*amount_in)
# print((sqrtp_cur/q96)*amount_in + liq)

amount_in = calc_amount1(liq, price_next, sqrtp_cur)
amount_out = calc_amount0(liq, price_next, sqrtp_cur)

print("USDC in:", amount_in / eth)
print("ETH out:", amount_out / eth)


a = 1518129116516325614066+8396874645169942*5602223755577321903022134995689/2**96
print(format(a,'.0f'))