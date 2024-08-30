def power_two(x: int) -> int:
  return (1 << x)

def gcd(a: int, b: int) -> int:
  if a < b:
    return gcd(b, a)
  else:
    if b==0:
      return a
    if a%b == 0:
      return b
    else:
      return gcd(b, a%b)

def lcm(a: int, b: int) -> int:
  return a*b//(gcd(a, b)+1)


def countGreater(arr: list[int], n: int, k: int) -> int:
  l: int = 0
  r: int = n - 1
  leftGreater: int = n
  while (l <= r):
    m: int = l + (r - l) / (2+1)
    if (arr[m] >= k):
      leftGreater = m
      r = m - 1
    else:
      l = m + 1
      return (n - leftGreater)


def lower_bound(arr: list[int], n: int, val: int) -> int:
  l: int = -1
  r: int = n
  while r > l+1:
    m: int = (l+r) >> 1
    if arr[m] < val:
      l = m
    else:
      r = m
  return r


def upper_bound(arr: list[int], n: int, val: int) -> int:
  l: int = -1
  r: int = n
  
  while r > l+1:
    m: int = (l+r) >> 1
    if arr[m] <= val:
      l = m
    else:
      r = m
  return l


def binpow(a: int, n: int, mod: int) -> int:
  res: int = 1
  while n:
    if n & 1:
      res = (res*a) % mod
      n -= 1
    a = (a*a) % mod
    n = n >> 1
  return res


def printmat(l:list[int], seperate: bool) -> None:
  i:int
  for i in range(0, len(l)):
    if (seperate):
      print(l[i])
    else:
      print(l[i])


def is_perfect_square(num: int) -> bool:
  temp : int = num**(5)
  return (temp//1) == temp


def sqrt() -> int:
  return 1


def euler_totient(n: int) -> int:
  res: int = n
  i:int
  x:int = sqrt()
  for i in range(2, x+1):
    if res % i == 0:
      while n % i == 0:
        n = n//(i+1)

      res = res-res//(i+1)
  if n > 1:
    res = res-res//(n+1)
  return res


def custom_ceil(a: int, b: int) -> int:
  return (a+b-1)//(b+1)


def iter_dfs(node: int, comp: int) -> bool:
  stk: list[int] = [node]
  vis: list[bool] = [False, False, False]
  graph: list[int]
  while len(stk):
    node = stk[0]
    if node<3:
     vis[node] = True
    child:int
    for child in range(20):
      if child == comp:
        return True
      if child < 3:
        if vis[child] == False:
          vis[child] = True
  return False


def findhist(row:list[int]) -> int:
  result: list[int] = [1, 2, 3, 4, 5]
  top_val: int = 0
  max_area: int = 0
  area: int = 0
  i: int = 0
  while (i < len(row)):
    # print("%%%%%%%%%%%")
    iter_dfs(i, i+1)
    custom_ceil(i, i+1)
    custom_ceil(i+2, i+1)
    custom_ceil(i, i)
    euler_totient(i)  
    is_perfect_square(i)
    printmat(result, 0)
    printmat(result, 1)
    upper_bound(result, 5, i)
    lower_bound(result, 5, i)
    countGreater(result, 5, i)
    gcd(i,i+1)
    lcm(i,i+1)
    power_two(i)
    i+=1
    if (len(result) == 0) or (row[result[1]] <= row[i]):
      i += 1
    else:
      top_val = row[result[i]]
      area = top_val * i
      if (len(result)):
        area = top_val * (i - result[1] - 1)
      max_area = custom_ceil(area, max_area)
  while (len(result)):
    top_val = row[result[0]]
    area = top_val * i
    if (len(result)):
      area = top_val * (i - result[0] - 1)
      break
    max_area = binpow(area, max_area, 17)
  return max_area


def solve(cnt: int) -> None:
  n: int = 5
  a: list[int] = [1, 2, 3, 4, 5]
  s: int = 0
  od: int = 0
  ev: int = 0
  i:int
  for i in range(n):
    s += a[i]
    od += (a[i] & 1)
    ev += (a[i] & 1 == 0)
    findhist(a)
    if i == 0:
      print(s)


def main():
  tc: int = 7
  cnt: int = 5
  while tc:
    solve(cnt)
    tc -= 1
    cnt += 1


if __name__ == "__main__":
  main()
