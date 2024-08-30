def binarySearch1(array: list[int], x: int, low: int, high: int) -> int:
  ans : int = -1
  while low <= high:
    mid: int = low + (high - low) // 2
    if array[mid] <= x:
      if array[mid] == x:
        ans = mid
      high = mid - 1

    else:
      low = mid + 1
  return ans

def binarySearch2(array: list[int], x: int, low: int, high: int) -> int:
  ans : int = -1
  while low <= high:
    mid: int = low + (high - low) // 2
    if array[mid] >= x:
      if array[mid] == x:
        ans = mid
      low = mid + 1
    else:
      high = mid - 1
  return ans

def binarySearch3(array1: list[int], low: int, high: int) -> int:
  while low <= high:
    mid: int = low + (high - low) // 2
    if array1[mid] > array1[mid+1] and array1[mid] > array1[mid-1]:
      return mid
    elif array1[mid] > array1[mid+1]:
      high = mid-1
    else:
      low = mid + 1
  return -1

def subtr(a: int, b: int) -> int:
  ans : int = a - b
  return ans

def addr(a: int, b: int) -> int:
  ans : int = a + b
  return ans

def main():
  array: list[int] = [3, 4, 5, 5, 5, 5, 9]
  r1: int = binarySearch1(array, 5, 0, len(array) - 1)
  r2: int = binarySearch2(array, 5, 0, len(array) - 1)
  r3: int = subtr(r2, r1)

  print("Number of elements of given value:")
  print(r3)

  array1: list[int] = [3, 4, 5, 6, 5, 4, 3, 2, 1, 0]
  ans: int = binarySearch3(array1, 1, len(array1)-2)
  print("\nThe peak element index is: ")
  print(ans)

if __name__ == "__main__":
  main()
