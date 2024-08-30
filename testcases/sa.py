
def complex_calc(a:int, b:int, c:int)->int:
  return a*b*(c-1)
#def str_add(a: str, b: str)->str:
 # return a+b
def main():
  x:int = 2
  y:float = 2.99
  z:float = 1.23
  a:str = 'abc'
  b:str = 'def'
  #c:str =  str_add(a, b)
  res: float = complex_calc(x, y, z)
  print(res)
 # print(c)


if __name__ == "__main__":
  main()
