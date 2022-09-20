filename = ""
vt_table = []
input_stack = []
symbol_stack = []
step = 0
method = ""

# 手工构造
analyze_table = \
    [[-1, -1, -1, -1, -1, -1, -1, ["block"], -1, -1, -1, -1, -1, -1, -1, -1],
     [-1, -1, -1, -1, -1, -1, -1, ["{", "stmts", "}"], -1, -1, -1, -1, -1, -1, -1, -1],
     [-1, ["stmt", "stmts"], -1, ["stmt", "stmts"], ["stmt", "stmts"], ["stmt", "stmts"], ["stmt", "stmts"], ["stmt", "stmts"], [""], -1, -1, -1, -1, -1, -1],
     [-1, ["id", "=", "expr", ";"], -1, ["if", "(", "boolean", ")", "stmt"], ["while", "(", "boolean", ")", "stmt"], ["do", "stmt", "while", "(", "boolean", ")"], ["break"], ["block"], -1, -1, -1, -1, -1, -1, -1],
     [-1, ["expr", "<", "expr"], ["expr", "<", "expr"], -1, -1, -1, -1, -1, -1, -1, -1, ["expr", "<", "expr"], -1, -1, -1, -1],
     [-1, ["term", "expr1"], ["term", "expr1"], -1, -1, -1, -1, -1, -1, -1, -1, ["term", "expr1"], -1, -1, -1, -1],
     [-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, [""], -1, [""], [""], ["+", "term", "expr1"], -1],
     [-1, ["factor", "term1"], ["factor", "term1"], -1, -1, -1, -1, -1, -1, -1, -1, ["factor", "term1"], -1, -1, -1, -1],
     [-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, [""], -1, [""], [""], [""], ["*", "factor", "term1"]],
     [-1, ["id"], ["num"], -1, -1, -1, -1, -1, -1, -1, -1, ["factor", "(", "expr", ")"], -1, -1, -1, -1]]
table_row = ["program", "block", "stmts", "stmt", "boolean", "expr", "expr1", "term", "term1", "factor"]
table_col = [0, 42, 43, 1, 3, 4, 13, 28, 29, 26, 30, 31, 32, 27, 22, 24]
# 对应 [#, id, "num"（仅限int）, "if", "while", "do", "break", "{", "}", "=", ";", "（", ")", "<", "+", "*"]


def Read():
    global filename
    filename = input("请输入文件名")
    f1 = open(filename + ".txt")
    for line in f1:
        input_stack.append(line.split(',')[:2])


def info():
    global step, symbol_stack, input_stack, method
    print(f'-----Step: {step}-----')
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
    global step, symbol_stack, input_stack, method
    step = 1
    symbol_stack.append("#")
    input_stack.append(["#", "#"])
    method = ""

    symbol_stack.append("program")
    while symbol_stack != ["#"] or input_stack != [["#", "#"]]:
        if symbol_stack[-1] == input_stack[0][1] \
                or symbol_stack[-1] == "id" and int(input_stack[0][0]) == 42\
                or symbol_stack[-1] == "num" and int(input_stack[0][0]) == 43:
            method = "---"
            info()
            symbol_stack.pop(-1)
            input_stack.pop(0)
        elif analyze_table[table_row.index(symbol_stack[-1])][table_col.index(int(input_stack[0][0]))] != -1:
            method = symbol_stack[-1]
            method += " -> "
            right_part = analyze_table[table_row.index(symbol_stack[-1])][table_col.index(int(input_stack[0][0]))]
            for i in right_part:
                if i == "":
                    method += "null"
                else:
                    method += i
                method += " "
            info()
            symbol_stack.pop(-1)
            for i in range(len(right_part)-1, -1, -1):
                if right_part[i] != "":
                    symbol_stack.append(right_part[i])
        else:
            return 0
    method = "Accept!"
    info()
    return 1


if __name__ == "__main__":
    Read()
    print("-----------Step 1 语法分析--------------")
    if analyze():
        print("succeed!该语句有效，所用产生式如上。")
    else:
        print("error!")
    print("LL(1)语法分析结束。")
