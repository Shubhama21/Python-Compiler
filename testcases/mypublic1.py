def rev_print(data:list[int]) -> None:
  i:int
  for i in range(5):
    print(data[i])

def lower_bound(arr: list[int], n: int, val: int) -> int:
  l: int = -1
  r: int = n
  while r > l+1:
    m: int = (l+r) >> 1
    print("M")
    print(m)
    if arr[m] < val:
      l = m
    else:
      r = m
  return r

def main():
  data : list[int] = [1, 2, 3, 4, 5]
  x : int = lower_bound(data, 5, 3)
  print(x)
    