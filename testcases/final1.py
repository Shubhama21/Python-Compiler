def  factorial(n:int)->int:
    if(n==0):
        return 1
    return n*factorial(n-1)

class IDW:
    def __init__(self,value:int):
        self.value:int = value
    def dis(self):
        print(self.value) 

    
def main():
    print("ARITHMETIC BASIC")
    print("1+2")
    print(1+2)
    print("1-2")
    print(1-2)
    print("2*3")
    print(2*3)
    print("10/3")
    print(10/3)
    print("10//3")
    print(10//3)
    print("10%3")
    print(10%3)
    print("10%2")
    print(10%2)
    print("5**2")
    print(5**2)
    print("5**1")
    print(5**1)
    
    print("RELATIONAL BASIC - INT")
    print("\t==")
    print("1==2")
    print(1==2)
    print("1==1")
    print(1==1)
    print("\t!=")
    print("1!=2")
    print(1!=2)
    print("1!=1")
    print(1!=1)
    print("\t<")
    print("1<2")
    print(1<2)
    print("1<1")
    print(1<1)
    print("1<0")
    print(1<0)
    print("\t<=")
    print("1<=2")
    print(1<=2)
    print("1<=1")
    print(1<=1)
    print("1<=0")
    print(1<=0)
    print("\t>")
    print("1>2")
    print(1>2)
    print("1>1")
    print(1>1)
    print("1>0")
    print(1>0)
    print("\t>=")
    print("1>=2")
    print(1>=2)
    print("1>=1")
    print(1>=1)
    print("1>=0")
    print(1>=0)
    
    print("RELATIONAL BASIC - STRING")
    print("\t==")
    print("b==c")
    print("b"=="c")
    print("b==b")
    print("b"=="b")
    print("\t!=")
    print("b!=c")
    print("b"!="c")
    print("b!=b")
    print("b"!="b")
    print("\t<")
    print("b<c")
    print("b"<"c")
    print("b<b")
    print("b"<"b")
    print("b<a")
    print("b"<"a")
    print("\t<=")
    print("b<=c")
    print("b"<="c")
    print("b<=b")
    print("b"<="b")
    print("b<=a")
    print("b"<="a")
    print("\t>")
    print("b>c")
    print("b">"c")
    print("b>b")
    print("b">"b")
    print("b>a")
    print("b">"a")
    print("\t>=")
    print("b>=c")
    print("b">="c")
    print("b>=b")
    print("b">="b")
    print("b>=a")
    print("b">="a")
    
    print("LOGICAL - BASIC")
    print("\tand")
    print("True and True")
    print(True and True)
    print("False and True")
    print(False and True)
    print("True and False")
    print(True and False)
    print("False and False")
    print(False and False)
    print("\tor")
    print("True or True")
    print(True or True)
    print("False or True")
    print(False or True)
    print("True or False")
    print(True or False)
    print("False or False")
    print(False or False)
    print("\tnot")
    print("not True")
    print(not True)
    print("not False")
    print( not False)
    print(1 << 3)
    print(2 & 4)
    print(2 | 4 )
    print(7^7)
    print(7^8)
    print(1 >> 2)
    print(6 >> 2)
    print(~1)
    a:int = 3
    b:int = 4
    a = b
    print(a)
    a += 3
    print(a)
    a *= 5
    print(a)
    a /= 2
    print(a)
    a//=3
    print(a)
    a|=b
    print(a)
    a **= 3
    print(a)
    b |= 8
    print(b)
    b ^= 8
    print(b)
    b ^= 5
    print(b)
    a &= (a|b)
    print(a)
    a <<=1
    print(a)
    a>>=1
    print(a)
    age:int = 3
    if age >= 18:
        print("Adult")
    elif age >= 12:
        print("teen")
    else:
        print("Child")
    print("iii")
    i:int
    for i in range(5):
        print(i)
    cnt: int = 0
    while cnt < 5:
        print(cnt<<2)
        cnt += 1
    for i in range(8):
        if i%2 == 0:
            print(i)
        else:
            break
            print("x")
    
    fact:int = factorial(5)
    print(fact)
    x:list[int] = [0,3,7,11]
    f:int = x[3]
    print(f)
    f=~(~1)
    print(f)
    
    if (""):
        print("Hi")
    l:IDW = IDW(10)
    l.dis()
    if ("a"):
        print("Hi")
    
    
if __name__ == "main":
    main()
    print("Hello")
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    