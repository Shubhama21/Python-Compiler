def data_types_stress_testing():
    
    # INT
    decint1 : int = 0
    decint2 : int = 0_0
    decint3 : int = 1_2_3_0_4_5_6_7_8_9
    binint1 : int = 0b_0_1_0_1
    binint2 : int = 0B_0_1_0_1
    octint1 : int = 0o_1_2_3_4_5_6_7_0
    octint2 : int = 0O_1_2_3_4_5_6_7_0
    hexint1 : int = 0x_1_2_3_4_5_6_7_0_9_a_A_b_B_c_C_d_D_e_E_f_F
    hexint2 : int = 0X_1_2_3_4_5_6_7_0_9_a_A_b_B_c_C_d_D_e_E_f_F

    # FLOAT

    # STRING

    # BOOL
    bool1 : bool  = True
    bool2 : bool = False
    
# def list_stress_testing():
    
def control_flow_stress_testing():
    if True:
        print("1")
    elif True:
        print("2")
    elif False:
        print("3")
    else:
        print("4")
        
    while True:
        print("1")
        if True:
            continue
        else:
            break
        
        
    
def operators_stress_testing():
    ans1 : int = 1 + 2 - 3 * 4 // 6 % 7 ** 8
    ans1_1 : bool = 17 == 18
    ans1_2 : bool = 19 != 20
    ans1_3 : bool = 21 > 22
    ans1_4 : bool = 23 < 24
    ans1_5 : bool = 25 <= 26
    ans1_6 : bool = 27 >= 28
    ans2 : float = 9 / 10
    ans3 : bool = True and False or not True
    ans4 : int = 11 & 12 | 13 ^ ~14 << 15 >> 16
    ans5 : int = 0
    ans5 += ans1
    ans5 -= ans1
    ans5 *= ans1
    ans2 /= ans1
    ans5 //= ans1
    ans5 %= ans1
    ans5 **= ans1
    ans5 &= ans1
    ans5 |= ans1
    ans5 ^= ans1
    ans5 <<= ans1
    ans5 >>= ans1

def string_test() -> int:   #kuch bhi
    str: string = "rnfiusnfr \r \n \t \a \f\v\b\\'\"\042 \
    ";
    str2 = ''' """" \
        \\\\ tbt '''
    
def main():
    operators_stress_testing()

if __name__ == "__main__":
  main()
