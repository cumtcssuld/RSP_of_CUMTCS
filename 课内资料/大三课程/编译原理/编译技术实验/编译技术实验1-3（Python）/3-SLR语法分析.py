filename = ""
vt_table = []
input_stack = []
symbol_stack = []
state_stack = []
step = 0
method = ""
                 #  id num mai whi (  )   {  }    +  -    =    <=  ;
action       = [0, 42, 43, 5, 3, 31, 32, 28, 29, 22, 23, 26, 41, 30]
action_table = [["", "", "", "s2", "", "", "", "", "", "", "", "", "", ""],
                ["acc", "", "", "", "", "", "", "", "", "", "", "", "", ""],
                ["", "", "", "", "", "", "", "s4", "", "", "", "", "", ""],
                ["r1", "", "", "", "", "", "", "", "", "", "", "", "", ""],
                ["", "s10", "", "", "s9", "", "", "", "r4", "", "", "", "", ""],
                ["", "", "", "", "", "", "", "", "s6", "", "", "", "", ""],
                ["r2", "r2", "", "", "r2", "", "", "", "r2", "", "", "", "", ""],
                ["", "s10", "", "", "s9", "", "", "", "r4", "", "", "", "", ""],
                ["", "", "", "", "", "", "", "", "r3", "", "", "", "", ""],
                ["", "", "", "", "", "s11", "", "", "", "", "", "", "", ""],
                ["", "", "", "", "", "", "", "", "", "", "", "s12", "", ""],
                ["", "s18", "s19", "", "", "", "", "", "", "", "", "", "", ""],
                ["", "s18", "s19", "", "", "", "", "", "", "", "", "", "", ""],
                ["", "", "", "", "", "", "", "", "", "", "", "", "s14", ""],
                ["", "s18", "s19", "", "", "", "", "", "", "", "", "", "", ""],
                ["", "", "", "", "", "", "s16", "", "", "", "", "", "", ""],
                ["", "", "", "", "", "", "", "s4", "", "", "", "", "", ""],
                ["", "r7", "", "", "r7", "", "", "", "r7", "", "", "", "", ""],
                ["", "r10", "r10", "", "", "", "r10", "", "", "r10", "r10", "", "r10", "r10"],
                ["", "r11", "r11", "", "", "", "r11", "", "", "r11", "r11", "", "r11", "r11"],
                ["", "", "", "", "", "", "", "", "", "s21", "s23", "", "", ""],
                ["", "s18", "s19", "", "", "", "", "", "", "", "", "", "", ""],
                ["", "", "", "", "", "", "r8", "", "", "", "", "", "r8", "r8"],
                ["", "s18", "s19", "", "", "", "", "", "", "", "", "", "", ""],
                ["", "", "", "", "", "", "r9", "", "", "", "", "", "r9", "r9"],
                ["", "", "", "", "", "", "", "", "", "s21", "s23", "", "", "s26"],
                ["", "r6", "", "", "r6", "", "", "", "r6", "", "", "", "", ""],
                ["", "", "", "", "", "", "", "", "", "", "", "", "", "s28"],
                ["", "r5", "", "", "r5", "", "", "", "r5", "", "", "", "", ""]]
goto = ["prog", "block", "stmts", "stmt", "E", "F"]
goto_table = [[1, 0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0, 0],
              [0, 3, 0, 0, 0, 0],
              [0, 0, 0, 0, 0, 0],
              [0, 0, 5, 7, 0, 0],
              [0, 0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0, 0],
              [0, 0, 8, 7, 0, 0],
              [0, 0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0, 0],
              [0, 0, 0, 0, 13, 20],
              [0, 0, 0, 0, 27, 25],
              [0, 0, 0, 0, 0, 0],
              [0, 0, 0, 0, 15, 20],
              [0, 0, 0, 0, 0, 0],
              [0, 17, 0, 0, 0, 0],
              [0, 0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0, 22],
              [0, 0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0, 24],
              [0, 0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0, 0]]
function = [["prog", "main", "block"],
            ["block", "{", "stmts", "}"],
            ["stmts", "stmt", "stmts"],
            ["stmts"],
            ["stmt", "id", "=", "E", ";"],
            ["stmt", "id", "=", "F", ";"],
            ["stmt", "while", "(", "E", "<=", "E", ")", "block"],
            ["E", "F", "+", "F"],
            ["E", "F", "-", "F"],
            ["F", "id"],
            ["F", "num"]]
function_string = ["prog -> main block",
                   "block -> { stmts }",
                   "stmts -> stmt stmts",
                   "stmts -> @",
                   "stmt -> id = E ;",
                   "stmt -> id = F ;",
                   "stmt -> while ( E <= E ) block",
                   "E -> F + F",
                   "E -> F - F",
                   "F -> id",
                   "F -> num"]


def Read():
    global filename
    filename = input("请输入文件名")
    f1 = open(filename + ".txt")
    for line in f1:
        input_stack.append(line.split(',')[:2])


def info():
    global step, symbol_stack, input_stack, method
    print(f'-----Step: {step}-----')
    print("状态栈：", end='')
    for i in range(len(symbol_stack)):
        print(state_stack[i], end=' ')
    print()
    print("符号栈：", end='')
    for i in range(len(symbol_stack)):
        print(symbol_stack[i], end=' ')
    print()
    print("输入串：", end='')
    for i in range(len(input_stack)):
        print(input_stack[i][1], end=' ')
    print()
    print(f'动作：{method}')
    print()
    step += 1


def analyze():
    global step, state_stack, symbol_stack, input_stack, method
    step = 1
    state_stack.append(0)
    symbol_stack.append("#")
    input_stack.append(["0", "#"])
    method = ""

    while True:
        do = action_table[state_stack[-1]][action.index(int(input_stack[0][0]))]
        if do == "":
            return 0
        elif do[0] == "s":
            method = do + " 移进" + input_stack[0][1] + "，状态转到" + do[1:]
            info()
            state_stack.append(int(do[1:]))
            symbol_stack.append(input_stack[0][1])
            input_stack.pop(0)
        elif do[0] == "r":
            method = do + " 用第" + do[1:] + "个产生式 " + function_string[int(do[1:])-1] + " 进行归约"
            info()
            remove_times = len(function[int(do[1:])-1]) - 1
            for i in range(remove_times):
                state_stack.pop(-1)
                symbol_stack.pop(-1)
            symbol_stack.append(function[int(do[1:])-1][0])
            state_stack.append(goto_table[state_stack[-1]][goto.index(symbol_stack[-1])])
        elif do == "acc":
            method = "Accept!"
            info()
            return 1
        else:
            return 0



if __name__ == "__main__":
    Read()
    print("-----------Step 1 语法分析--------------")
    if analyze():
        print("succeed!该语句有效，所用产生式如上。")
    else:
        print("error!")
    print("SLR语法分析结束。")
