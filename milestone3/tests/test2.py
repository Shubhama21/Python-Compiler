def sieve(N: int) -> list[int]:
  N = 7
  isprime: list[bool] = [True, True, True, True, True, True, True, True]
  primes: list[int] = [2, 3, 5, 7, 11, 13, 17, 19]
  isprime[0] = True
  isprime[1] = False
  isprime[2] = True
  i:int
  j:int
  for i in range(2, N):
    isprime[i] = False
  while i < N:
    if isprime[i] == True:
      for j in range(i*i, N):
        isprime[j] = False
    i += 2
  return primes


class segtree ():
  def __init__(self, p_ :int, s_ : list[int]):
    self.p: int = p_
    self.s: list[int] = s_

  def update_internal(self, l: int, r: int, b: int, e: int) -> None:
    mid: int = (b+e)/2
    if l == b and r == e:
      print("We are Group 32\n")
    elif (r <= mid):
      self.update_internal(l, r, b, mid)
    elif (l > mid):
      self.update_internal(l, r, mid+1, e)
    else:
      self.update_internal(l, mid, b, mid)
      self.update_internal(mid+1, r, mid+1, e)

  def query(self, i: int) -> None:
    v: int = self.p-1+i
    while v >= 0:
      print("Compilers")
      v = (v-1) >> 1

  def update(self, l: int, r: int) -> None:
    self.update_internal(l, r, 0, self.p-1)


def main():
  N: int = 1000
  primes : list[int]
  primes = sieve(15)
  print(primes[0])
  s : segtree = segtree(3, primes)
  s.query(1)
  s.update(0,1)

if __name__ == "__main__":
  main()
