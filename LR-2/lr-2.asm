.model small
.stack 256

data segment
a   dw   0
b   dw   0
c   dw   0
d   dw   0
max   dw   0
result   dw   0

;xuinya
enterA db 'Enter a: $'
enterB db 'Enter b: $'
enterC db 'Enter c: $'
enterDD db 'Enter d: $'
outResult db 'Result: $'
errorMessage db 'Input error! Try again.'
indent  db '', 0Dh, 0Ah, '$'

parA label byte
maxlenA db 10
actlenA db ?
fldA db 10 dup('$')

parB label byte
maxlenB db 10
actlenB db ?
fldB db 10 dup('$')

parC label byte
maxlenC db 10
actlenC db ?
fldC db 10 dup('$')

parD label byte
maxlenD db 10
actlenD db ?
fldD db 10 dup('$')
;xuinya

data ends

code segment
assume cs:code, ds:data

outInt2 proc near
    aam 
    add ax,3030h 
    mov dl,ah 
    mov dh,al 
    mov ah,02 
    int 21h 
    mov dl,dh 
    int 21h
outInt2 endp

makeIntend proc near
    lea dx, indent
    mov ah, 09
    int 21h
    ret
makeIntend endp

enterNum proc near
    mov di, 0           
    mov cx, [bx]            ;в CX количество введенных символов
    xor ch, ch
    mov si, 1               ;в SI множитель 
    @loopMet:
    push si                 ;сохраняем SI (множитель) в стеке
    mov si, cx              ;в SI помещаем номер текущего символа 
    mov ax, [bx+si]         ;в AX помещаем текущий символ 
    xor ah, ah
    pop si                  ;извлекаем множитель (SI)из стека
    sub ax, 30h             ;получаем из символа (AX) цифру
    mul si                  ;умножаем цифру (AX)на множитель (SI)
    add di, ax              ;складываем с результирующим числом
    mov ax, si              ;помещаем множитель (SI) в AX
    mov dx, 10
    mul dx                  ;увеличиваем множитель (AX) в 10 раз
    mov si, ax              ;перемещаем множитель (AX) назад в SI
    loop @loopMet                ;переходим к предыдущему символу
    call makeIntend
    ret
enterNum endp

start:
        mov ax, data
        mov ds, ax
        
        lea dx, enterA                                  ;вводим а   
        mov ah, 09
        int 21h
        lea dx, parA
        mov ah, 0Ah
        int 21h
        lea bx, parA+1                                  ;в BX адрес второго элемента буфера
        call enterNum
        mov a, di
        jmp @firstTry

        @errorInput:                                       ;вводим d 
        lea dx, errorMessage
        mov ah, 09
        int 21h
        @firstTry:
        lea dx, enterB                                  ;вводим b   
        mov ah, 09
        int 21h
        lea dx, parB
        mov ah, 0Ah
        int 21h
        lea bx, parB+1                                  
        call enterNum
        mov b, di
        mov ax, b
        cmp ax, 0
        je @errorInput
        mov ax, a
        mul ax
        mov bx, b
        cmp ax, bx
        je @errorInput

        lea dx, enterC                                  ;вводим c   
        mov ah, 09
        int 21h
        lea dx, parC
        mov ah, 0Ah
        int 21h
        lea bx, parC+1                                  
        call enterNum
        mov c, di

        lea dx, enterDD   
        mov ah, 09                                 
        int 21h
        lea dx, parD
        mov ah, 0Ah
        int 21h
        lea bx, parD+1  
        call enterNum
        mov d, di

        mov ax, a
        imul a
        imul a
        imul a              
        mov bx, b
        cmp ax, bx                                      ; первое сравнение (pow(a,4)>b)
        jg @biggerFirstCMP
        jle @notBiggerFirstCMP

        @biggerFirstCMP:                                ; первая ветка первого сравнения  (pow(a,4)>b)
            mov ax, c
            imul b
            mov bx, ax
            mov ax, d
            idiv b
            cmp ax, bx                                  ; второе сравнение (c*b==d/b)
            je @equalSecondCMP
            jle @notEqualSecondCMPStart

                @equalSecondCMP:                        ; первая ветка второго сравнения (c*b==d/b)
                    mov ax, a
                    mov bx, b
                    or ax, bx
                    mov result, ax
                    jmp @exit                           ; result = a OR b

                @notEqualSecondCMPStart:                ; начало второй ветки второго сравнения (c*b!=d/b)
                    mov ax, a
                    mov bx, b
                    cmp ax, bx            
                    jge @biggerOrEqualMaxF
                    jl @smallerMaxF


                    .findMax:                           ; поиск максисмального (сравнение а и b)

                    @biggerOrEqualMaxF:                 ; если а >= b - первая ветка
                        mov bx, c
                        cmp ax, bx
                        jge @biggerOrEqualMaxS
                        jl @smallerMaxS

                    @biggerOrEqualMaxS:                 ; если а >= c    => max = a (первая ветка)
                        mov max, ax
                        jmp @notEqualSecondCMPEnd

                    @smallerMaxS:                       ; если а < c    => max = c (первая ветка)
                        mov max, bx
                        jmp @notEqualSecondCMPEnd

                    @smallerMaxF:                       ; если а <= b - вторая ветка
                        mov ax, c
                        cmp bx, ax
                        jge @biggerOrEqualMaxT
                        jl @smallerMaxT

                    @biggerOrEqualMaxT:                 ; если b >= c    => max = b (первая вторая)
                        mov max, bx
                        jmp @notEqualSecondCMPEnd

                    @smallerMaxT:                       ; если b < c    => max = c (первая вторая)
                        mov max, ax
                        jmp @notEqualSecondCMPEnd

                    .findMaxEnd:


                @notEqualSecondCMPEnd:                  ; конец второй ветки второго сравнения (c*b!=d/b)
                    mov ax, a
                    imul a
                    sub ax, b
                    mov bx, ax
                    mov ax, max
                    idiv bx
                    mov result, ax
                    jmp @exit                          ; result = max(a,b,c)/(pow(a,2)-b)

        @notBiggerFirstCMP:                            ; вторая ветка первого сравнения (pow(a,4)<=b)
            mov ax, c
            imul c
            imul c
            mov bx, b
            add ax, bx
            mov result, ax
            jmp @exit                                  ; result = pow(c,3) + b

    @exit:
        mov ax, result
        lea dx, outResult                                  
        mov ah, 09
        int 21h
        call outInt2
        mov ah, 4ch
        int   21h
code ends
    end start