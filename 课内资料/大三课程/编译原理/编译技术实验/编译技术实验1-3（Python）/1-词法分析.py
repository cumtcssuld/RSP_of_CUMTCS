"""
 01 if       22 +   42 id          eg. aCar
 02 else     23 -   43 数值-整型    eg. 123
 03 while    24 *   44 数值-浮点    eg. 12.3
 04 do       25 /   45 数值-二进制   eg. 0b123
 05 main     26 =   46 数值-八进制   eg. 0o123
 06 int      27 <   47 数值-16进制   eg. 0x1BF
 07 float    28 {   48 字符串常量    eg. "hjy hjy"
 08 double   29 }
 09 return   30 ;
 10 const    31 (
 11 void     32 )
 12 continue 33 '
 13 break    34 "
 14 char     35 ==
 15 unsigned 36 !=
 16 enum     37 &&
 17 long     38 ||
 18 switch   39 >
 19 case     40 >=
 20 auto     41 <=
 21 static
"""

program = ""
program_new = []
filename = ""

keyword = ["if", "else", "while", "do", "main", "int", "float", "double", "return", "const",
           "void", "continue", "break", "char", "unsigned", "enum", "long", "switch", "case", "auto", "static"]


# 清除注释
def Read():
    global program, filename
    filename = input("请输入文件名")
    f1 = open(filename + ".txt")
    read_current_state = 0  # 保存当前状态
    for read_line in f1:
        for read_char in read_line:
            if read_current_state == 0:
                if read_char == '/':
                    read_current_state = 1
                    continue
                else:
                    program += read_char
                    continue
            if read_current_state == 1:
                if read_char == '*':
                    read_current_state = 2
                    continue
                elif read_char == '/':
                    read_current_state = 4
                    continue
                else:
                    read_current_state = 0
                    continue
            if read_current_state == 2:
                if read_char == '*':
                    read_current_state = 3
                    continue
                else:
                    read_current_state = 2
                    continue
            if read_current_state == 3:
                if read_char == '/':
                    read_current_state = 0
                    continue
                elif read_char == '*':
                    read_current_state = 3
                    continue
                else:
                    read_current_state = 2
                    continue
            if read_current_state == 4:
                if read_char == '\n':
                    read_current_state = 0
                    program += read_char
                    continue
                else:
                    read_current_state = 4
                    continue
    f1.close()

    # 消除主程序前的空行
    while program[0] == '\n':
        program = program[1:]
    # 消除主程序中的空行与段前空格
    index_of_blank = 1
    while index_of_blank < len(program):
        if program[index_of_blank - 1] == '\n' and (program[index_of_blank] == ' ' or program[index_of_blank] == '\n'):
            program = program[:index_of_blank] + program[index_of_blank + 1:]
        else:
            index_of_blank += 1
    # 按格式输出修改后的主程序
    row = 1
    print(row, '\t', end='')
    for i in program:
        print(i, end='')
        if i == '\n':
            row += 1
            print(row, '\t', end='')
    print('\n')


def GetToken():
    global program, program_new, program_char, is_string, token, symbol, line, line_word
    if is_string == 0 and program[program_char - 1] == '\"':
        is_string = 1
        symbol = 48
        while True:
            token += program[program_char]
            program_char += 1
            if program[program_char] == '\"':
                return

    if is_string == 1 and program[program_char - 1] == '\"':
        is_string = 0

    while program[program_char] == ' ' or program[program_char] == '\t':
        program_char += 1
        line_word += 1

    if program[program_char] == '\n':
        line += 1
        line_word = 1
        program_char += 1

    if 'a' <= program[program_char] <= 'z' or 'A' <= program[program_char] <= 'Z' or program[program_char] == '_':
        symbol = 42  # id
        while True:
            token += program[program_char]
            program_char += 1
            if not ('a' <= program[program_char] <= 'z'
                    or 'A' <= program[program_char] <= 'Z'
                    or '0' <= program[program_char] <= '9'
                    or program[program_char] == '_'):
                break
        if token in keyword:
            symbol = keyword.index(token) + 1
            return
        return

    # 42 id           eg.aCar
    # 43 数值 - 整型   eg.123
    # 44 数值 - 浮点   eg.12.3
    # 45 数值 - 二进制 eg.0b010
    # 46 数值 - 八进制 eg.0o123
    # 47 数值 - 16进制 eg.0x1BF
    # 48 字符串常量    eg."hjy hjy"

    if program[program_char] == '0':
        token += program[program_char]
        program_char += 1
        if program[program_char].lower() == 'b':
            while True:
                token += program[program_char]
                program_char += 1
                if not ('0' <= program[program_char] <= '1'):
                    break
            symbol = 45  # 数值 - 二进制
        elif program[program_char].lower() == 'o':
            while True:
                token += program[program_char]
                program_char += 1
                if not ('0' <= program[program_char] <= '7'):
                    break
            symbol = 46  # 数值 - 八进制
        elif program[program_char].lower() == 'h':
            while True:
                token += program[program_char]
                program_char += 1
                if not ('0' <= program[program_char] <= '9'
                        or 'a' <= program[program_char].lower() <= 'f'):
                    break
            symbol = 47  # 数值 - 十六进制
        elif program[program_char] == '.':
            while True:
                token += program[program_char]
                program_char += 1
                if not ('0' <= program[program_char] <= '9'):
                    break
            symbol = 44  # 数值 - 浮点数[1-9].xxx
        else:
            symbol = 43  # 数值 - 数字0

    elif '1' <= program[program_char] <= '9':
        while True:
            token += program[program_char]
            program_char += 1
            if program[program_char] == '.':
                symbol = 44  # 数值 - 浮点数[1-9]*.xxx
                while True:
                    token += program[program_char]
                    program_char += 1
                    if not ('0' <= program[program_char] <= '9'):
                        symbol = 44  # 数值 - 浮点数[1-9]*.xxx
                        return
            if not ('0' <= program[program_char] <= '9') and symbol != 44:
                symbol = 43  # 数值 - 整型
                return

    else:
        if program[program_char] == '+':
            symbol = 22
            token = '+'
        elif program[program_char] == '-':
            symbol = 23
            token = '-'
        elif program[program_char] == '*':
            symbol = '*'
            token = program[program_char]
        elif program[program_char] == '/':
            symbol = '/'
            token = program[program_char]
        elif program[program_char] == '=':
            symbol = 26
            token = '='
            program_char += 1
            if program[program_char] == '=':
                token = '=='
                symbol = 35
        elif program[program_char] == '<':
            symbol = 27
            token = '<'
            program_char += 1
            if program[program_char] == '=':
                token = '<='
                symbol = 41
        elif program[program_char] == '>':
            symbol = 39
            token = '>'
            program_char += 1
            if program[program_char] == '=':
                token = '>='
                symbol = 40
        elif program[program_char] == '{':
            symbol = 28
            token = '{'
        elif program[program_char] == '}':
            symbol = 29
            token = '}'
        elif program[program_char] == ';':
            symbol = 30
            token = ';'
        elif program[program_char] == '(':
            symbol = 31
            token = '('
        elif program[program_char] == ')':
            symbol = 32
            token = ')'
        elif program[program_char] == '\'':
            symbol = 33
            token = '\''
        elif program[program_char] == '\"':
            symbol = 34
            token = '\"'
        elif program[program_char] == '!':
            program_char += 1
            if program[program_char] == '=':
                token = '!='
                symbol = 36
        elif program[program_char] == '&':
            program_char += 1
            if program[program_char] == '&':
                token = '&&'
                symbol = 37
        elif program[program_char] == '|':
            program_char += 1
            if program[program_char] == '|':
                token = '||'
                symbol = 37
        else:
            symbol = -2
        program_char += 1

    return


if __name__ == "__main__":
    print("-----------Step 1 消除注释--------------")
    Read()
    print("-----------Step 2 词法分析--------------")
    line = 1
    line_word = 1
    is_string = 0
    program_char = 0
    while program_char < len(program):
        token = ""
        symbol = 0
        GetToken()

        if len(program_new) > 1:
            if program_new[-1][0] in [6, 7, 8, 11, 14, 15, 16, 17]:
                if symbol == 43:
                    print("变量名不能以数字开头")
                    symbol = -1
                elif symbol not in [5, 42]:
                    print("缺少变量名")
                    symbol = -2
            elif program_new[-1][0] in [43, 44, 45, 46, 47]:
                if symbol in [42, 43, 44, 45, 46, 47]:
                    print("数字书写不规范")
                    symbol = -3
        if len(program_new) > 2:
            if program_new[-3][0] == 6:
                if symbol not in [32, 43, 45, 46, 47]:
                    print("变量不是int类型")
                    symbol = -4
            elif program_new[-3][0] in [7, 8]:
                if symbol != 44:
                    print("变量不是float类型")
                    symbol = -5
        if len(program_new) > 3:
            if program_new[-4][0] == 14:
                if symbol != 48:
                    print("变量不是char类型")
                    symbol = -6
        print(f'({symbol:>2},{token:^8})\tline:{line},row:{line_word}')
        program_new.append([symbol, token, line, line_word])
        line_word += len(token)

    program_new_words = [i[1] for i in program_new]
    # 判断引号括号等是否匹配
    if program_new_words.count('\'') % 2 == 1:
        print("单引号数量不匹配")
    if program_new_words.count('\"') % 2 == 1:
        print("双引号数量不匹配")
    if program_new_words.count('(') != program_new_words.count(')'):
        print("小括号数量不匹配")
    if program_new_words.count('{') != program_new_words.count('}'):
        print("大括号数量不匹配")

    # 存入文件
    f2 = open(filename + "-out.txt", 'w')
    for i in program_new:
        for j in i:
            f2.write(str(j) + ',')
        f2.write('\n')
    f2.close()
    print("词法分析结束，存入文件" + filename + "-out.txt")
