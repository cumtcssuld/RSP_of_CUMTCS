 ;-------------------硬件通道设置OK--------------------------
PORT_A   EQU 280H      ; 8255通道A（负责控制LCD数据写入）
PORT_B   EQU 281H      ; 8255通道B（负责键盘读取）
PORT_C   EQU 282H      ; 8255通道C（负责键盘写入）
PORT_CTL EQU 283H      ; 8255控制
CLK_1    EQU 289H      ; 8254计数器1通道（负责直流电机转动计数）
CLK_CTL  EQU 28BH      ; 8254计数器控制
LS273    EQU 290H      ; 74LS273简单输出接口锁存地址（负责LCD接收信号控制）
PORT_0832 EQU 298H     ; DAC0832数模转换器端口地址（负责控制电机转动）

;-------------------LCD12864控制命令宏OK-----------------------
LCD_CMD_SET MACRO      ; LCD命令设置
    MOV DX,LS273     ; 指向273控制端口
    NOP
    MOV AL,00000000B ; out2置0,out0置0 （LCD W端=0，I端=0）
    OUT DX, AL
    NOP
    MOV AL,00000100B ; out2置1 （LCD E端=1）
    OUT DX, AL
    NOP
    MOV AL,00000000B ; out2置0,（LCD E端=0）
    OUT DX, AL
    NOP
ENDM

;-------------------LCD12864写数据宏OK------------------------
LCD_DATA_SET MACRO     ; LCD写数据
    MOV DX,LS273     ; 指向273控制端口
    MOV AL,00000001B ; out2置0，out0=1 （LCD I端=1）
    OUT DX,AL
    NOP
    MOV AL,00000101B ; out2置1 （LCD E端＝1）
    OUT DX,AL
    NOP
    MOV AL,00000001B ; out2置0,（LCD E端＝0）
    OUT DX,AL
    NOP
ENDM

;----------------------LCD12864显示字符OK---------------------
;------------一行显示INT_N个汉字，INT_N为参数------------------
STRING_SHOW MACRO INT_N
    LOCAL NEXT_WORD
    MOV CL,INT_N
NEXT_WORD:    
    PUSH CX
    MOV AL,WORD_ADDRESS
    MOV DX,PORT_A ;第一次，pa0=0
    OUT DX,AL
    LCD_CMD_SET ; 设定DDRAM地址命令
    MOV AX,[BX]
    PUSH AX
    MOV AL,AH ; 先送汉字编码高位
    MOV DX,PORT_A
    OUT DX,AL
    LCD_DATA_SET ; 输出汉字编码高字节
    POP AX
    MOV DX,PORT_A
    OUT DX, AL
    LCD_DATA_SET ; 输出汉字编码低字节
    INC BX
    INC BX ; 修改显示内码缓冲区指针
    INC BYTE PTR WORD_ADDRESS ; 修改LCD显示端口地址 WORD_ADDRESS是字节单元
    POP CX
    DEC CL
    JNZ NEXT_WORD
ENDM

; ------------------------软延时宏OK-----------------------
DELAY_MACRO MACRO
    LOCAL FOR1
    LOCAL FOR2
    PUSH BX
    PUSH CX
    MOV BX,400H
FOR1: MOV CX,0FFFFH
FOR2: LOOP FOR2
    DEC BX
    JNZ FOR1
    POP CX
    POP BX
ENDM

;-------------------------以下是数据段----------------------------
DATA SEGMENT
;---------------常量表---------------------------
SunFee         DB  10H    ; 白天起步价（10元）
NightFee       DB  12H    ; 夜间起步价（12元）
FeeRate        DB  02H    ; 一公里价格（2元）
FeeTime        DB  01H    ; 等待一分钟价格（1元）
INT16          DB  16     ; 数字16
INT3           DB  3      ; 数字3

;---------------变量表（内部存储不显示）---------------------------
WORD_ADDRESS   DB  00H    ; 存放显示行起始端口地址
SunOrNIght     DB  00H    ; 白天（0）夜间（1）状态

Speed          DB  0A0H   ; 速度（A0停止）
Kilometer      DB  00H    ; 总里程（BCD码）      eg 存储18 => 1.8 km
Price          DB  00H    ; 总费用（BCD码）      eg 存储24 => 24 rmb
WaitingTimeSec DB  00H    ; 等待时间（秒，BCD码） eg 存储36 => 36 sec
WaitingTimeMin DB  02H    ; 等待时间（秒，BCD码） eg 存储36 => 02 min
Count          DW  0000H  ; 保存上次计数 IF LESS +10000
CountNow       DW  0000H  ; 保存这次计数

;---------------变量表（外部需要显示）---------------------------
KilometerLCD      DW    2030H,2E30H  ; eg *0.0
SpeedLCD          DW    3030H        ; eg 00
WaitingTimeMinLCD DW    2030H        ; eg *0
WaitingTimeSecLCD DW    3030H        ; eg 00
PriceLCD          DW    3030H        ; eg 00
InitPriceLCD      DW    3030H        ; eg 00

;-------------------LCD12864欢迎界面文字ok------------------------
INIT_WELCOME DW 0BBB6H,0D3ADH,0B3CBH,0D7F8H,0B1BEH,0CBBEH,0B3F6H,0D7E2H
    DW 0CBBEH,0BBFAH,0A1A0H,0BAFAH,0BEFBH,0D2ABH,0A1A0H,0A1A0H
    DW 0B1E0H,0BAC5H,2030H,3631H,3932H,3038H,3120H,0A1A0H
    DW 0BCE0H,0B6BDH,2031H,3839H,3030H,3030H,3030H,3030H
   ;欢迎乘坐本司出租
   ;司机  胡钧耀
   ;编号 06192081
   ;监督 18900000000

;-------------------关机界面文字ok------------------------
STATE_OFF DW 0A1A0H,0A1A0H,0D2D1H,0B9D8H,0BBFAH,0A1A0H,0A1A0H,0A1A0H
;已关机

;-------------------白天设置界面文字ok------------------------
STATE_SUN DW 0B0D7H,0CCECH
;白天

;-------------------夜间设置界面文字ok------------------------
STATE_NIGHT DW 0D2B9H,0BCE4H
;夜间         

; ----------------------------空白行ok--------------------------------
BLANK_LINE DW 0A1A0H,0A1A0H,0A1A0H,0A1A0H,0A1A0H,0A1A0H,0A1A0H,0A1A0H 

; ------------------------键盘扫描码ok-----------------------------
KEYBOARD_DATA DB 77H,7BH,7DH,7EH,0B7H,0BBH,0BDH,0BEH,0D7H,0DBH,0DDH,0DEH,0E7H,0EBH,0EDH,0EEH
;----键盘扫描码表--0---1---2---3---4----5----6----7----8----9----a----b----c----d----e----f    


;----------------支付界面（顾客下车后显示）---------------------
STRING_PAY DW 0D6A7H,0B8B6H
;支付
STRING_YUAN DW 0D4AAH
;元

;----------------运行计价界面（顾客乘车时显示）---------------------
STRING_RUN DW 0C6F0H,0B2BDH,3130H,0D4AAH,0B5A5H,0BCDBH,02032H,0D4AAH
    DW 0C0EFH,0B3CCH,0A1A0H,0A1A0H,0B9ABH,0C0EFH,0A1A0H,0A1A0H
    DW 0CAB1H,0CBD9H,0A1A0H,0A1A0H,6B6DH,2F68H,0A1A0H,0A1A0H
    DW 0B5C8H,0B4FDH,0A1A0H,0B7D6H,0A1A0H,0C3EBH,0A1A0H,0A1A0H
;起步10元单价 2元
;里程 2.3公里
;时速  30km/h
;等待 3分21秒

;----------------扫码支付（本人微信支付二维码）ok---------------------
QR_CODE DB 00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H
DB 00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H
DB 00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H
DB 00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H
DB 00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H
DB 00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H
DB 00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H
DB 00H,07H,0F3H,38H,0CBH,0DFH,0C0H,00H,00H,04H,16H,0B6H,4AH,10H,40H,00H
DB 00H,05H,0D0H,2EH,61H,97H,40H,00H,00H,05H,0D3H,0A4H,0D3H,97H,40H,00H
DB 00H,05H,0D2H,9DH,0D6H,0D7H,40H,00H,00H,04H,15H,57H,66H,90H,40H,00H
DB 00H,07H,0F5H,55H,55H,5FH,0C0H,00H,00H,00H,04H,0BCH,96H,40H,00H,00H
DB 00H,00H,79H,6AH,8BH,18H,80H,00H,00H,07H,0A5H,66H,43H,8EH,80H,00H
DB 00H,05H,0F0H,0CFH,0CBH,0DH,40H,00H,00H,06H,6DH,0D6H,80H,91H,00H,00H
DB 00H,04H,0BDH,2CH,30H,19H,0C0H,00H,00H,07H,0E0H,0D0H,0FH,98H,40H,00H
DB 00H,01H,15H,27H,05H,02H,80H,00H,00H,01H,4FH,0A4H,0AH,2AH,40H,00H
DB 00H,04H,0D9H,0C7H,0EH,0DH,40H,00H,00H,03H,67H,0A1H,0C2H,26H,40H,00H
DB 00H,00H,0D8H,01H,0FH,0BH,00H,00H,00H,02H,0EBH,81H,0E4H,0A8H,0C0H,00H
DB 00H,00H,0FCH,40H,22H,5EH,00H,00H,00H,04H,84H,0A1H,0E7H,0CAH,40H,00H
DB 00H,02H,51H,80H,03H,4EH,0C0H,00H,00H,00H,0AAH,0D9H,04H,7AH,40H,00H
DB 00H,06H,55H,0C2H,0BFH,31H,0C0H,00H,00H,07H,65H,5EH,16H,0BAH,0C0H,00H
DB 00H,01H,0BAH,41H,5AH,25H,00H,00H,00H,01H,2EH,35H,69H,18H,0C0H,00H
DB 00H,07H,75H,2BH,0A1H,7FH,0C0H,00H,00H,00H,06H,54H,0BH,46H,00H,00H
DB 00H,07H,0F4H,73H,69H,54H,00H,00H,00H,04H,14H,0DFH,0FCH,45H,0C0H,00H
DB 00H,05H,0D5H,16H,51H,7FH,0C0H,00H,00H,05H,0D3H,19H,4FH,46H,0C0H,00H
DB 00H,05H,0D1H,0AFH,0D2H,7AH,80H,00H,00H,04H,12H,0D0H,0FDH,41H,40H,00H
DB 00H,07H,0F0H,03H,0D0H,0B7H,0C0H,00H,00H,00H,00H,00H,00H,00H,00H,00H
DB 00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H
DB 00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H
DB 00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H
DB 00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H
DB 00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H
DB 00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H
DATA      ENDS

;-----------------------暂存栈ok---------------------
STACKS    SEGMENT
          DB 2560 DUP(?)
STACKS    ENDS

;---------------------------主函数-------------------------
CODE SEGMENT
    ASSUME CS:CODE,DS:DATA,SS:STACKS,ES:DATA

START:
;========================环境清零，初始化======================

    MOV WORD_ADDRESS,00H
    MOV SunOrNIght,00H
    MOV HaveOrNot,00H
    MOV WaitOrNOt,00H
    MOV Speed,0A0H
    MOV Kilometer,00H
    MOV Price,00H
    MOV WaitingTimeMin,00H
    MOV WaitingTimeSec,00H
    MOV Count,0000H
    MOV CountNow,0000H

    MOV AX, DATA
    MOV DS, AX
    MOV DX, PORT_CTL
    MOV AL, 10000010B    ; 8255初始化，A口输出，B口输入，C口输出
    OUT DX, AL
    CALL CLEAR
    CALL LCD_DISP_INIT   ; LCD清屏，显示欢迎界面                                                                                                                                        
    
DO_MAIN:
    CALL KEYBROAD
; ===============主界面仅允许进入开关机、载客、设置================
    CMP BX,0000H ; 按键0，开关机
    JZ ON_OFF
    CMP BX,0001H ; 按键1，载客
    JZ ON_PERSON
    CMP BX,0003H ; 按键3，设置
    JZ SETTING
    JMP DO_MAIN  ; 按其他按键无效，重返DO_MAIN继续读取按键

ON_OFF:
    CALL LCD_DISP_OFF
    JMP START
    
ON_PERSON:
    CALL LCD_DISP_ON_PERSON
    JMP START

SETTING:
    CALL LCD_DISP_SETTING
    JMP START
    
; =======================键盘MAIN===================
KEYBROAD PROC
    MOV DX,PORT_C
    MOV AL,00H
    OUT DX,AL
    MOV DX,PORT_B
    IN AL,DX         ; 再查列，看按键是否仍被压着
    AND AL,0FH
    CMP AL,0FH
WAIT_OPEN:           ; 查看所有键是否松开
    IN AL,DX
    AND AL,0FH
    CMP AL,0FH
    JNE WAIT_OPEN    ; 各键均松开，查列是否有0
WAIT_PRES:
    IN AL,DX
    AND AL,0FH       ; 只查低四位
    CMP AL,0FH
    JE WAIT_PRES     ; 延时20ms，消抖动
    MOV CX,16EAH
DELAY1:LOOP DELAY1   ; CX为0，跳出循环
    IN AL,DX         ; 再查列，看按键是否仍被压着
    AND AL,0FH
    CMP AL,0FH
    JE WAIT_PRES     ; 键仍被按下，确定哪一个键被按下
    MOV AL,0FEH
    MOV CL,AL
NEXT_ROW:
    MOV DX,PORT_C
    OUT DX,AL        ; 向一行输出低电平
    MOV DX,PORT_B
    IN AL,DX         ; 读入B口状态
    AND AL,0FH       ; 只检测低四位，即列值
    CMP AL,0FH       ; 是否均为1，若是，则此行无按键按下
    JNE ENCODE       ; 否，此行有按键按下，转去编码
    ROL CL,1         ; 均为1，转去下行
    MOV AL,CL
    JMP NEXT_ROW     ; 查看下一行
ENCODE:
    MOV BX,000FH
    IN AL,DX
NEXT_TRY:
    CMP AL,KEYBOARD_DATA[BX] ; 读入的行列值是否与表中的值相等
    JE FINISH_MAIN_KEYBROAD
    DEC BX
    JNS NEXT_TRY ; 非负，继续检查
FINISH_MAIN_KEYBROAD:
    RET
KEYBROAD ENDP

;=======================键盘FOR PERSON========================
KEYBROAD_FOR_PERSON PROC
    MOV DX,PORT_C
    MOV AL,00H
    OUT DX,AL
    MOV DX,PORT_B
    IN AL,DX                ; 再查列，看按键是否仍被压着
    AND AL,0FH
    CMP AL,0FH
    JE DO_NOTHING           ; 没有按下就直接结束     
    MOV AL,0FEH             ; 键仍被按下，确定哪一个键被按下
    MOV CL,AL
NEXT_ROW_FOR_PERSON:
    MOV DX,PORT_C
    OUT DX,AL               ; 向一行输出低电平
    MOV DX,PORT_B
    IN AL,DX                ; 读入B口状态
    AND AL,0FH              ; 只检测低四位，即列值
    CMP AL,0FH              ; 是否均为1，若是，则此行无按键按下
    JNE ENCODE_FOR_PERSON   ; 否，此行有按键按下，转去编码
    ROL CL,1                ; 均为1，转去下行
    MOV AL,CL
    JMP NEXT_ROW_FOR_PERSON ; 查看下一行
ENCODE_FOR_PERSON:
    MOV BX,000FH
    IN AL,DX
NEXT_TRY_FOR_PERSON:
    CMP AL,KEYBOARD_DATA[BX] ; 读入的行列值是否与表中的值相等
    JE FINISH_FOR_PERSON
    DEC BX
    JNS NEXT_TRY_FOR_PERSON  ; 非负，继续检查
DO_NOTHING:
    MOV BX,00FFH
FINISH_FOR_PERSON:
    RET
KEYBROAD_FOR_PERSON ENDP

;======================LCD清屏函数====================
CLEAR PROC
    MOV AL,00000001B        ; 清除控制字    
    MOV DX,PORT_A
    OUT DX,AL 
    LCD_CMD_SET             ; 启动LCD执行命令
    RET
CLEAR ENDP

;==================LCD初始化欢迎函数=================
LCD_DISP_INIT PROC
    CALL CLEAR
    MOV AX, DATA
    LEA BX, INIT_WELCOME           ; 加载欢迎界面
    MOV BYTE PTR WORD_ADDRESS, 80H ; 第一行起始端口地址
    STRING_SHOW 8
    MOV BYTE PTR WORD_ADDRESS, 90H ; 第二行起始端口地址
    STRING_SHOW 8
    MOV BYTE PTR WORD_ADDRESS, 88H ; 第三行起始端口地址
    STRING_SHOW 8
    MOV BYTE PTR WORD_ADDRESS, 98H ; 第4行起始端口地址
    STRING_SHOW 8
    
    CMP SunOrNIght,00H
    JNZ DO_NIGHT
DO_SUN:
    MOV AH,00H
    MOV AL,SunFee                 ; 10 BCD => 3130H
    JMP FINISH_SUN_OR_NIGHT
DO_NIGHT:
    MOV AH,00H
    MOV AL,NightFee               ; 12 BCD => 3132H
FINISH_SUN_OR_NIGHT:
    DIV INT16                     ; AL = 01H, AH = 00H
    XCHG AH,AL                    ; AX = 0100H
    ADD AH,30H
    ADD AL,30H                    ; AX = 3130H
    LEA BX,InitPriceLCD
    MOV [BX],AX
    RET
LCD_DISP_INIT ENDP

;======================LCD_DISP_OFF函数=================
LCD_DISP_OFF PROC
    CALL CLEAR
    MOV AX,DATA
    LEA BX, STATE_OFF              ; 加载OFF界面
    MOV BYTE PTR WORD_ADDRESS, 90H ; 第2行起始端口地址
    STRING_SHOW 8
    LEA BX, BLANK_LINE             ; 加载OFF界面
    MOV BYTE PTR WORD_ADDRESS, 98H ; 第4行起始端口地址
    STRING_SHOW 8
    CALL KEYBROAD                  ; 按任意键开机
    RET
LCD_DISP_OFF ENDP

;-----------------------LCD_DISP_ON_PERSON函数----------------------
LCD_DISP_ON_PERSON PROC
    CALL BUZZ
    CALL CLEAR
    CALL MOTOR_INIT
    
    ;8254通道1初始化
    MOV AL,01110101B  ; 通道1，先低后高，方式2，BCD计数,N=10000
    MOV DX,CLK_CTL
    OUT DX,AL
    MOV DX,CLK_1
    MOV AL,99H
    OUT DX,AL
    MOV AL,99H
    OUT DX,AL

    MOV AX,DATA
    LEA BX,STRING_RUN              ; 加载界面
    MOV BYTE PTR WORD_ADDRESS, 80H ; 第一行起始端口地址
    STRING_SHOW 8
    MOV BYTE PTR WORD_ADDRESS, 90H ; 第二行起始端口地址
    STRING_SHOW 8
    MOV BYTE PTR WORD_ADDRESS, 88H ; 第三行起始端口地址
    STRING_SHOW 8
    MOV BYTE PTR WORD_ADDRESS, 98H ; 第4行起始端口地址
    STRING_SHOW 8

    LEA BX,InitPriceLCD             
    MOV BYTE PTR WORD_ADDRESS, 82H
    STRING_SHOW 1

UPDATE_INFO:
    CALL READ_MOTOR_INFO
    CALL WRITE_RUN_INFO
DO_PERSON:
    CALL KEYBROAD_FOR_PERSON
; ----------LCD_DISP_ON_PERSON界面仅允许进入下客、加速、减速-----------------
    CMP BX,0001H ; 下客
    JZ PAY
    CMP BX,0000H ; STOP/GO
    JZ STOP_GO
    CMP BX,0002H ; FAST
    JZ FAST
    CMP BX,0003H ; SLOW
    JZ SLOW
    JMP UPDATE_INFO

PAY:
    CALL CLEAR
    CALL DRAW_PAY_INFO
    JMP START

STOP_GO:
    CALL MOTOR_STOP
    JMP UPDATE_INFO

FAST:
    CALL MOTOR_INC
    JMP UPDATE_INFO

SLOW:
    CALL MOTOR_DEC
    JMP UPDATE_INFO
    RET
LCD_DISP_ON_PERSON ENDP


;---------------------LCD_DISP_SETTING函数-----------------------
; -------------------白天（0）夜间（1）状态-----------------------
LCD_DISP_SETTING PROC
    CALL CLEAR
    CMP SunOrNIght,00H
    JZ BECOME_NIGHT
BECOME_SUN:
    MOV SunOrNIght,00H
    MOV AX,DATA
    LEA BX,STATE_SUN                ; 加载OFF界面
    JMP FINISH_SETTING
BECOME_NIGHT:
    MOV SunOrNIght,01H
    MOV AX,DATA
    LEA BX,STATE_NIGHT              ; 加载OFF界面
FINISH_SETTING:
    MOV BYTE PTR WORD_ADDRESS, 93H  ; 第2行起始端口地址
    STRING_SHOW 2
    LEA BX,BLANK_LINE               ; 加载OFF界面
    MOV BYTE PTR WORD_ADDRESS, 98H  ; 第4行起始端口地址
    STRING_SHOW 8

    CALL DELAY_MACRO
    RET
LCD_DISP_SETTING ENDP


;----------------------LCD画二维码以及付钱界面函数---------------------------
DRAW_PAY_INFO PROC
    MOV DX,PORT_A
    MOV AL,00110100B ; 扩充功能设定 绘图显示 OFF
    OUT DX,AL
    LCD_CMD_SET        ; 启动LCD执行命令
    LEA BX,QR_CODE

    ;上半部分
    MOV CL,0   ;计数一直到CL = 32

LOOP1:
    MOV CH,0   ;计数一直到CH = 4
LOOP2:
    MOV AL,80H 
    ADD AL,CL 
    MOV DX,PORT_A
    OUT DX,AL
    LCD_CMD_SET

    MOV AL,80H
    ADD AL,4
    ADD AL,CH
    MOV DX,PORT_A
    OUT DX,AL
    LCD_CMD_SET

    MOV AL,[BX]
    MOV DX,PORT_A
    OUT DX,AL
    LCD_DATA_SET
    INC BX

    MOV AL,[BX]
    MOV DX,PORT_A
    OUT DX,AL
    LCD_DATA_SET
    INC BX

    INC CH
    CMP CH,4
    JNZ LOOP2
    
    INC CL
    CMP CL,32
    JNZ LOOP1

    ;下半部分
    MOV CL,0
LOOP3:
    MOV CH,0
LOOP4:
    MOV AL,80H
    ADD AL,CL
    MOV DX,PORT_A
    OUT DX,AL
    LCD_CMD_SET

    MOV AL,88H
    ADD AL,4
    ADD AL,CH
    MOV DX,PORT_A
    OUT DX,AL
    LCD_CMD_SET

    MOV AL,[BX]
    MOV DX,PORT_A
    OUT DX,AL
    LCD_DATA_SET
    INC BX

    MOV AL,[BX]
    MOV DX,PORT_A
    OUT DX,AL
    LCD_DATA_SET
    INC BX

    INC CH
    CMP CH,4
    JNZ LOOP4
    
    INC CL
    CMP CL,32
    JNZ LOOP3
    

    ;上半部分
    MOV CL,0
LOOP5:
    MOV CH,0
LOOP6:
    MOV AL,80H
    ADD AL,CL
    MOV DX,PORT_A
    OUT DX,AL
    LCD_CMD_SET

    MOV AL,80H
    ADD AL,CH
    MOV DX,PORT_A
    OUT DX,AL
    LCD_CMD_SET

    MOV AL,00H
    MOV DX,PORT_A
    OUT DX,AL
    LCD_DATA_SET
    INC BX

    MOV AL,00H
    MOV DX,PORT_A
    OUT DX,AL
    LCD_DATA_SET
    INC BX

    INC CH
    CMP CH,4
    JNZ LOOP6
    
    INC CL
    CMP CL,32
    JNZ LOOP5

    ;下半部分
    MOV CL,0
LOOP7:
    MOV CH,0
LOOP8:
    MOV AL,80H
    ADD AL,CL
    MOV DX,PORT_A
    OUT DX,AL
    LCD_CMD_SET

    MOV AL,88H
    ADD AL,CH
    MOV DX,PORT_A
    OUT DX,AL
    LCD_CMD_SET

    MOV AL,00H
    MOV DX,PORT_A
    OUT DX,AL
    LCD_DATA_SET
    INC BX

    MOV AL,00H
    MOV DX,PORT_A
    OUT DX,AL
    LCD_DATA_SET
    INC BX

    INC CH
    CMP CH,4
    JNZ LOOP8
    
    INC CL
    CMP CL,32
    JNZ LOOP7
    
    MOV DX,PORT_A
    MOV AL,00110110B   ;扩充功能设定 绘图显示 ON
    OUT DX,AL
    LCD_CMD_SET

    MOV DX,PORT_A
    MOV AL,00110000B  ;恢复
    OUT DX,AL
    LCD_CMD_SET

    ;写文字的
    MOV AX,DATA
    LEA BX,STRING_PAY
    MOV BYTE PTR WORD_ADDRESS, 91H
    STRING_SHOW 2
    LEA BX,STRING_YUAN
    MOV BYTE PTR WORD_ADDRESS, 8AH
    STRING_SHOW 1
    
    LEA BX,Kilometer
    MOV AH,00H
    MOV AL,[BX]       ; AX = 00 18
    DIV INT16         ; AX = 08 01
    MOV AH,00H
    MUL FeeRate       ; AX = 00 02
    AAM
    ADD Price,AL
    DAA

    LEA BX,WaitingTimeMin
    MOV AH,00H
    MOV AL,[BX]
    ADD Price,AL
    DAA
    
    LEA BX,SunFee
    MOV AH,00H
    MOV AL,[BX]
    ADD Price,AL
    DAA

    MOV AH,00H
    MOV AL,Price               ; 09 => *9 => 2039 | 29 => 3239   
    DIV INT16                  ; AL = 02H, AH = 09H
    XCHG AH,AL                 ; AX = 0209H
    CMP AH,00H
    JZ SET_BLANK
    ADD AH,10H
SET_BLANK:
    ADD AH,20H
    ADD AL,30H                 ; AX = 2039 3239
    LEA BX,PriceLCD
    MOV [BX],AX

    LEA BX,PriceLCD                 
    MOV BYTE PTR WORD_ADDRESS, 89H
    STRING_SHOW 1

    CALL KEYBROAD
    RET
DRAW_PAY_INFO ENDP


; -----------------出租车电机初始化运转函数-------------------
MOTOR_INIT PROC
    MOV Speed,0A0H
    MOV AL,Speed     ; 这里是A0H，无转动
    MOV DX,PORT_0832
    OUT DX,AL
    ret
MOTOR_INIT ENDP


; -----------------写入运行里程价格等函数-------------------
;---------------变量表（外部需要显示）---------------------------
;KilometerLCD      DW    2030H,2E30H ; eg *0.0
;SpeedLCD          DW    3030H       ; eg 00
;WaitingTimeMinLCD DW    2030H       ; eg *0
;WaitingTimeSecLCD DW    3030H       ; eg 00
;起步10元单价 2元
;里程 2.3公里
;时速  30km/h
;等待 3分21秒
WRITE_RUN_INFO PROC
    MOV AX, DATA
    LEA BX, KilometerLCD
    MOV BYTE PTR WORD_ADDRESS, 92H ; 第一行起始端口地址
    STRING_SHOW 2

    LEA BX, SpeedLCD
    MOV BYTE PTR WORD_ADDRESS, 8BH ; 第一行起始端口地址
    STRING_SHOW 1
    
    ret
WRITE_RUN_INFO ENDP

; -----------------读取车轮运转次数转换函数-------------------
READ_MOTOR_INFO PROC
    DELAY_MACRO
    MOV AL,01000000B
    MOV DX,CLK_CTL
    OUT DX,AL
    MOV DX,CLK_1
    IN AL,DX
    MOV AH,AL
    IN AL,DX
    XCHG AH,AL
    
    MOV CountNow,AX
    CMP AX,Count
    JBE PASS_ADD
    ADD Count,1000H
    DAA
PASS_ADD:
    LEA BX,Count
    MOV AL,[BX+1]
    LEA BX,CountNow
    MOV AH,[BX+1]
    SUB AL,AH
    DAS

KILO_ADD:
    ADD Kilometer,AL           ; 来自上面sub al(count),ah(count_now)
    DAA
    MOV AH,00H
    MOV AL,Kilometer           ; 82 BCD => *8.2H  => 2038 2E32
    DIV INT16                  ; AL = 08H, AH = 02H
    MOV AH,00H
    DIV INT3
    XCHG AH,AL                 ; AX = 0802H
    ADD AH,30H
    ADD AL,30H                 ; AX = 3832H
    LEA BX,KilometerLCD
    MOV [BX],AH
    MOV AH,20H
    MOV [BX+1],AH
    MOV [BX+2],AL
    MOV AL,2EH
    MOV [BX+3],AL             ; WaitingTimeMinLCD = 20 AH 2E AL = 20 38 2E 32 => *8.2 


    MOV AL,Speed               ; C0 BCD => C0-A0 = 20 => 32 00
    SUB AL,A0H                 ; AL = 20
    DAS
    MOV AH,00H
    DIV INT16                  ; AH = 00 AL = 02
    XCHG AH,AL                 ; AH = 02 AL = 00
    ADD AH,30H
    DAA
    LEA BX,SpeedLCD
    MOV [BX],AH
    MOV [BX+1],AL
    ret
READ_MOTOR_INFO ENDP

; -----------------出租车电机加速函数-------------------
MOTOR_INC PROC
    CMP Speed,0E0H
    JZ PASS_INC
    ADD Speed,10H
    MOV AL,Speed      ; 速度+10   A0 B0 C0 E0 D0
    MOV DX,PORT_0832
    OUT DX,AL
PASS_INC:
    ret
MOTOR_INC ENDP

; -----------------出租车电机减速函数-------------------
MOTOR_DEC PROC
    CMP Speed,0C0H
    JZ PASS_DEC
    SUB Speed,10H
    MOV AL,Speed      ; 速度-10   A0 B0 C0 E0 D0
    MOV DX,PORT_0832
    OUT DX,AL
PASS_DEC: 
    ret
MOTOR_DEC ENDP

; -----------------出租车电机STOP函数-------------------
MOTOR_STOP PROC
TIMEING_ADD:
    CALL MOTOR_INIT
    ADD WaitingTimeSec,1H
    DAA
    CMP WaitingTimeSec,60H
    JNZ NOT_SECOND_INC
    MOV WaitingTimeSec,00H
    ADD WaitingTimeSec,1H
    DAA
NOT_SECOND_INC:
    MOV AH,00H
    MOV AL,WaitingTimeSec      ; 16 BCD => 3136H
    DIV INT16                  ; AL = 01H, AH = 06H
    XCHG AH,AL                 ; AX = 0106H
    CMP AH,00H
    JNZ SET_BLANK1
    ADD AH,10H
SET_BLANK1:
    ADD AH,20H
    ADD AL,30H                 
    LEA BX,WaitingTimeSecLCD
    MOV [BX],AX
    JMP FINISH_READ

    ADD AL,30H
    ADD AH,30H                 ; AX = 3136H
    LEA BX,WaitingTimeSecLCD
    MOV [BX],AX

    MOV AH,00H
    MOV AL,WaitingTimeMin      ; 06 BCD => 2036H    16 BCD => 3136H
    DIV INT16                  ; AL = 01H, AH = 06H
    XCHG AH,AL                 ; AX = 0106H
    CMP AH,00H
    JNZ NOT_SET_BLANK2
    ADD AH,20H
NOT_SET_BLANK2:
    ADD AH,10H
    ADD AL,30H                 ; AX = 2036H 3136H
    LEA BX,WaitingTimeMinLCD
    MOV [BX],AX


    LEA BX, WaitingTimeMinLCD
    MOV BYTE PTR WORD_ADDRESS, 9AH ; 第一行起始端口地址
    STRING_SHOW 1
    
    LEA BX, WaitingTimeSecLCD
    MOV BYTE PTR WORD_ADDRESS, 9CH ; 第一行起始端口地址
    STRING_SHOW 1

    CALL DELAY_MACRO
    CALL KEYBROAD
    CMP BX,0002H
    JZ FINISH_TIMING_ADD
    
    JMP TIMEING_ADD

FINISH_TIMING:
    ret
MOTOR_STOP ENDP


CODE ENDS
    END START
