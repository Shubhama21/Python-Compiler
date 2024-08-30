def compute_min() -> int:
  data: list[int] = [-2, 3, 3, 14, 0, 9, 11, 0, -9, 1]
  min_value: int = None
  i: int = 0
  n: int = len(data)
  for i in range(n):
    if not min_value:
      min_value = data[i]
    elif data[i] < min_value:
      min_value = data[i]
  return min_value


def compute_avg() -> int:
  data: list[int] = [-2, 3, 3, 14, 0, 9, 11, 0, -9, 1]
  avg_value: int = None
  sum: int = 0
  i: int = 0
  n: int = len(data)
  for i in range(n):
    sum += data[i]
  return sum / len(data)


def main():
  min_value: int = compute_min()
  print("Minimum value: ")
  print(min_value)
  avg_value: int = compute_avg()
  print("Average value: ")
  print(avg_value)


if __name__ == "__main__":
  main()
