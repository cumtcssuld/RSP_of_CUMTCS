filename = ""
vt_table = []
read_vt_index = 0
error_flag = 0
step = 1
stack = []
method = ""


def info():
    global step, stack, method, stack
    print(f'-----Step: {step}-----')
    print("识别串：=>", end='')
    for i in range(len(stack)):
        print(stack[i], end=' ')
    print()
    print(f'动作：{method}')
    print()
    step += 1


def Read():
    global filename
    filename = input("请输入文件名")
    f1 = open(filename + ".txt")
    for line in f1:
        vt_table.append(line.split(',')[:2])


def match(vt):
    global read_vt_index, error_flag
    if error_flag:
        return
    if vt != vt_table[read_vt_index][1]:
        error()
        print(f'当前出现的{vt_table[read_vt_index][1]}与需要的{vt}不匹配')
        return
    read_vt_index += 1


def program():
    global error_flag, method, stack
    if error_flag:
        return
    method = "program\t-->\tblock"
    info()
    index = len(stack) - stack[::-1].index("program") - 1
    stack = stack[:index] + ["block"] + stack[index+1:]
    block()


def block():
    global error_flag, method, stack
    if error_flag:
        return
    method = "block\t-->\t{stmts}"
    info()
    index = len(stack) - stack[::-1].index("block") - 1
    stack = stack[:index] + ["{", "stmts", "}"] + stack[index+1:]
    match("{")
    stmts()
    match("}")


def stmts():
    global read_vt_index, error_flag, method, stack
    if error_flag:
        return
    if vt_table[read_vt_index][1] == '}':
        method = "stmts\t-->\tnull"
        info()
        index = len(stack) - stack[::-1].index("stmts") - 1
        stack = stack[:index] + stack[index + 1:]
        return
    method = "stmts\t-->\tstmt stmts"
    info()
    index = len(stack) - stack[::-1].index("stmts") - 1
    stack = stack[:index] + ["stmt", "stmts"] + stack[index+1:]
    stmt()
    stmts()


def stmt():
    global read_vt_index, error_flag, method, stack
    if error_flag:
        return
    if int(vt_table[read_vt_index][0]) == 42:  # id
        method = "stmt\t-->\tid = expr;"
        info()
        index = len(stack) - stack[::-1].index("stmt") - 1
        stack = stack[:index] + ["id", "=", "expr", ";"] + stack[index + 1:]
        read_vt_index += 1
        match("=")
        expr()
        match(";")
    elif vt_table[read_vt_index][1] == "if":
        read_vt_index += 1
        match("(")
        boolean()
        match(")")
        stmt()
        if vt_table[read_vt_index][1] == "else":
            method = "stmt\t-->\tif (boolean) stmt else stmt"
            info()
            index = len(stack) - stack[::-1].index("stmt") - 1
            stack = stack[:index] + ["if", "(", "boolean", ")", "stmt", "else", "stmt"] + stack[index + 1:]
            match("else")
            stmt()
            return
        method = "stmt\t-->\tif (boolean) stmt"
        info()
        index = len(stack) - stack[::-1].index("stmt") - 1
        stack = stack[:index] + ["if", "(", "boolean", ")", "stmt"] + stack[index + 1:]
    elif vt_table[read_vt_index][1] == "while":
        method = "stmt\t-->\twhile (boolean) stmt"
        info()
        index = len(stack) - stack[::-1].index("stmt") - 1
        stack = stack[:index] + ["while", "(", "boolean", ")", "stmt"] + stack[index + 1:]
        read_vt_index += 1
        match("(")
        boolean()
        match(")")
        stmt()
    elif vt_table[read_vt_index][1] == "do":
        method = "stmt\t-->\tdo stmt while (boolean)"
        info()
        index = len(stack) - stack[::-1].index("stmt") - 1
        stack = stack[:index] + ["do", "stmt", "while", "(", "boolean", ")"] + stack[index + 1:]
        read_vt_index += 1
        stmt()
        match("while")
        match("(")
        boolean()
        match(")")
    elif vt_table[read_vt_index][1] == "break":
        method = "stmt\t-->\tbreak"
        info()
        index = len(stack) - stack[::-1].index("stmt") - 1
        stack = stack[:index] + ["break"] + stack[index + 1:]
        read_vt_index += 1
    else:
        method = "stmt\t-->\tblock"
        info()
        index = len(stack) - stack[::-1].index("stmt") - 1
        stack = stack[:index] + ["block"] + stack[index + 1:]
        block()


def boolean():
    global read_vt_index, error_flag, method, stack
    if error_flag:
        return

    # if int(vt_table[read_vt_index][0]) in [42,43]:  # id num
    #
    if vt_table[read_vt_index+1][1] == "<":
        method = "boolean\t-->\texpr < expr"
        info()
        index = len(stack) - stack[::-1].index("boolean") - 1
        stack = stack[:index] + ["expr", "<", "expr"] + stack[index + 1:]
        expr()
        read_vt_index += 1
    elif vt_table[read_vt_index+1][1] == "<=":
        method = "boolean\t-->\texpr <= expr"
        info()
        index = len(stack) - stack[::-1].index("boolean") - 1
        stack = stack[:index] + ["expr", "<=", "expr"] + stack[index + 1:]
        expr()
        read_vt_index += 1
    elif vt_table[read_vt_index+1][1] == ">":
        method = "boolean\t-->\texpr > expr"
        info()
        index = len(stack) - stack[::-1].index("boolean") - 1
        stack = stack[:index] + ["expr", ">", "expr"] + stack[index + 1:]
        expr()
        read_vt_index += 1
    elif vt_table[read_vt_index+1][1] == ">=":
        method = "boolean\t-->\texpr >= expr"
        info()
        index = len(stack) - stack[::-1].index("boolean") - 1
        stack = stack[:index] + ["expr", ">=", "expr"] + stack[index + 1:]
        expr()
        read_vt_index += 1
    else:
        method = "boolean\t-->\texpr"
        info()
        index = len(stack) - stack[::-1].index("boolean") - 1
        stack = stack[:index] + ["expr"] + stack[index + 1:]
    expr()  # 这里是跟以上情况都合并了


def expr():
    global read_vt_index, error_flag, method, stack
    if error_flag:
        return
    method = "expr\t-->\tterm expr1"
    info()
    index = len(stack) - stack[::-1].index("expr") - 1
    stack = stack[:index] + ["term", "expr1"] + stack[index + 1:]
    term()
    expr1()


def expr1():
    global read_vt_index, error_flag, method, stack
    if error_flag:
        return
    if vt_table[read_vt_index][1] == "+":
        method = "expr1\t-->\t + term expr1"
        info()
        index = len(stack) - stack[::-1].index("expr1") - 1
        stack = stack[:index] + ["+", "term", "expr1"] + stack[index + 1:]
        read_vt_index += 1
        term()
        expr1()
    elif vt_table[read_vt_index][1] == "-":
        method = "expr1\t-->\t - term expr1"
        info()
        index = len(stack) - stack[::-1].index("expr1") - 1
        stack = stack[:index] + ["-", "term", "expr1"] + stack[index + 1:]
        read_vt_index += 1
        term()
        expr1()
    else:
        method = "expr1\t-->\tnull"
        info()
        index = len(stack) - stack[::-1].index("expr1") - 1
        stack = stack[:index] + stack[index + 1:]


def term():
    global read_vt_index, error_flag, method, stack
    if error_flag:
        return
    method = "term\t-->\tfactor term1"
    info()
    index = len(stack) - stack[::-1].index("term") - 1
    stack = stack[:index] + ["factor", "term1"] + stack[index + 1:]
    factor()
    term1()


def term1():
    global read_vt_index, error_flag, method, stack
    if error_flag:
        return
    if vt_table[read_vt_index][1] == "*":
        method = "term1\t-->\t * factor term1"
        info()
        index = len(stack) - stack[::-1].index("term1") - 1
        stack = stack[:index] + ["*", "factor", "term1"] + stack[index + 1:]
        read_vt_index += 1
        factor()
        term1()
    elif vt_table[read_vt_index][1] == "/":
        method = "term1\t-->\t / factor term1"
        info()
        index = len(stack) - stack[::-1].index("term1") - 1
        stack = stack[:index] + ["/", "factor", "term1"] + stack[index + 1:]
        read_vt_index += 1
        factor()
        term1()
    else:
        method = "term1\t-->\tnull"
        info()
        index = len(stack) - stack[::-1].index("term1") - 1
        stack = stack[:index] + stack[index + 1:]


def factor():
    global read_vt_index, error_flag, method, stack
    if error_flag:
        return
    if vt_table[read_vt_index][1] == "(":
        method = "factor\t-->\t(expr)"
        info()
        index = len(stack) - stack[::-1].index("factor") - 1
        stack = stack[:index] + ["(", "expr", ")"] + stack[index + 1:]
        read_vt_index += 1
        expr()
        match(")")
    elif int(vt_table[read_vt_index][0]) in [43, 44, 45, 46, 47]:  # number
        method = "factor\t-->\tnum"
        info()
        index = len(stack) - stack[::-1].index("factor") - 1
        stack = stack[:index] + ["num"] + stack[index + 1:]
        read_vt_index += 1
    elif int(vt_table[read_vt_index][0]) == 42:  # id
        method = "factor\t-->\tid"
        info()
        index = len(stack) - stack[::-1].index("factor") - 1
        stack = stack[:index] + ["id"] + stack[index + 1:]
        read_vt_index += 1
    else:
        error()


def error():
    global error_flag
    error_flag = 1
    print("出错！")


if __name__ == "__main__":
    Read()
    print("-----------Step 1 语法分析--------------")
    stack.append("program")
    program()
    print("递归下降语法分析结束。")
