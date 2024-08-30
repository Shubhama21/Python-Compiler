def input() -> int:
  return 1

def main():
  t: int
  t = input()
  tests:int
  for tests in range(t):
    n: int = input()
    cnt: int = 0
    A:int
    B:int
    ca:int
    cb:int
    pa:int
    pb:int

    i:int
    for i in range(63):
      if (n >> i) & 1:
        cnt += 1 
    if cnt & 1:
      print("Second")
      A = 10;B = 20
 
      while A != 0 and B != 0:
        print("Inside Whhile lop")
        ca = 0; cb =0
        pa=0;  pb= 0 
        for i in range(63):
          if (A >> i) & 1:
            ca += 1
            pa = i
          if (B >> i) & 1:
            cb += 1
            pb = i 
        if ca & 1:
          print("Compilers1")
          A = 0
          B = 0
        else:
          print("Compilers2")
          A = 0
          B = 0
    else:
      print("First")
      p: int = 0
 
      for i in range(63):
        if (n >> i) & 1:
          p = i
 
      print("Compilers3")
      A = 10
      B = 20
 
      while A != 0 and B != 0:
 
        for i in range(63):
          if (A >> i) & 1:
            ca += 1
            pa = i
          if (B >> i) & 1:
            cb += 1
            pb = i
 
        if ca & 1:
          print("Compilers4")
          A = 0
          B = 0
        else:
          print("Compilers5")
          A = 0
          B = 0 
 
if __name__ == "__main__":
  main()
  