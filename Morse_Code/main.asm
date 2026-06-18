; proto type of functions I used in this code.
GetStdHandle proto
WriteConsoleA proto
ReadConsoleA proto
SetConsoleMode proto
GetConsoleMode proto

; define the constant
STD_OUTPUT_HANDLE = -11
STD_INPUT_HANDLE  = -10


.data
; Morse code for A-Z
    mA  BYTE ".-  ",    0    
    mB  BYTE "-...",    0
    mC  BYTE "-.-.",    0
    mD  BYTE "-.. ",    0
    mE  BYTE ".   ",    0
    mF  BYTE "..-.",    0
    mG  BYTE "--. ",    0
    mH  BYTE "....",    0
    mI  BYTE "..  ",    0
    mJ  BYTE ".---",    0
    mK  BYTE "-.- ",    0
    mL  BYTE ".-..",    0
    mM  BYTE "--  ",    0
    mN  BYTE "-.  ",    0
    mO  BYTE "--- ",    0
    mP  BYTE ".--.",    0
    mQ  BYTE "--.-",    0
    mR  BYTE ".-. ",    0
    mS  BYTE "... ",    0
    mT  BYTE "-   ",    0
    mU  BYTE "..- ",    0
    mV  BYTE "...-",    0
    mW  BYTE ".-- ",    0
    mX  BYTE "-..-",    0
    mY  BYTE "-.--",    0
    mZ  BYTE "--..",    0

    ; pointer table A-Z
    morseTable  QWORD   OFFSET mA, OFFSET mB, OFFSET mC, OFFSET mD, OFFSET mE, OFFSET mF, OFFSET mG, OFFSET mH, OFFSET mI, OFFSET mJ, OFFSET mK, OFFSET mL, OFFSET mM, OFFSET mN, OFFSET mO, OFFSET mP, OFFSET mQ, OFFSET mR, OFFSET mS, OFFSET mT, OFFSET mU, OFFSET mV, OFFSET mW, OFFSET mX, OFFSET mY, OFFSET mZ
    
    ; Variables to store the data
    plaint_text_data db 256 dup(0)
	length_of_data_already_read dd 0
    print_info_message db "Enter the plain text: ", 0
    print_format db "%s", 0
	consoleMode dd 1

.data?
writtin db ?


.code

print_it proc
	
    ; call the Handle function with the output mode 
	mov r10, rcx
	mov rcx, STD_OUTPUT_HANDLE
	sub rsp, 40
	call GetStdHandle
	add rsp, 40

    ; call The write function to write in the console
	mov rcx, rax
	mov rdx, r10
	lea r9, writtin
	push 0
	sub rsp, 32
	call WriteConsoleA
	add rsp, 40
	ret
print_it endp

read_it proc
    push    r12
    sub     rsp, 40                          

    ; call the Handle function with the output mode 
    mov     ecx, STD_INPUT_HANDLE                        
    call    GetStdHandle
    mov     r12, rax                         

    ; --- GetConsoleMode ---
    mov     rcx, r12
    lea     rdx, consoleMode
    call    GetConsoleMode

    ; --- SetConsoleMode ---
    mov     rcx, r12
    mov     edx, 7h                          
    call    SetConsoleMode 

    ; --- ReadConsoleA ---
    mov     rcx, r12                         ; hConsoleInput
    lea     rdx, plaint_text_data            ; lpBuffer
    mov     r8d, 255                         ; nNumberOfCharsToRead
    lea     r9,  length_of_data_already_read ; lpNumberOfCharsRead
    mov     byte ptr [rdx + rax], 0            ; pInputControl = NULL (5th arg)
    call    ReadConsoleA

    add     rsp, 40
    pop     r12
    ret
read_it endp

main proc
	; prologue
	push rbp
	mov rbp, rsp
	sub rsp, 32
	
    ; Print info message to indicate the user to enter data
    lea rcx, print_info_message
	mov r8d, sizeof print_info_message
	call print_it

    ; read the data
	call read_it

    ; store the pointer pointing on data in r12 reg
    lea     r12, [plaint_text_data]

each_element:
    ; get each byte (char)
    mov     al, byte ptr [r12]   

    ; compare it with the end of each string \r
    cmp     al, 0Dh            
    
    ; if it reaches, end the loop
    je      done

    ; sub the charachter from 'A' to get the index of array already stores the morse code to each char
    sub     al, 41h         ; al - 65

    
    mov     bl, 5           ; (asscii of in-char - 65) * 5 + rcx (head)
    mul     bl             
    
    ; store the output in rbx regs
    movzx   rbx, ax        

    mov rcx, morseTable
    add rcx, rbx             ; each +5 is an element 0, 5, 10
	mov r8d, 4
	call print_it

    ; mov to the next byte (the next char)
    inc     r12
    jmp     each_element

done:
    ; when the loop end 
    mov     r12, 0

    ; apilogue
    xor eax, eax
    mov rsp, rbp
    pop rbp
       
    ; end of the main function
    ret
main endp

end

