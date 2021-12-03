.model small
.stack 256

data segment

masF dw 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
masS dw 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
masFSize dw 0
masSSize dw 0
buffCX dw 0
str dw 0
col dw 0
enterCol db 'Enter the number of columns: $'
enterStr db 'Enter the number of lines: $'
error db 'Input error!'
indent  db '', 0Dh, 0Ah, '$'

parNum label byte
maxlenNum db 10
actlenNum db ?
fldNum db 10 dup('$')

parCol label byte
maxlenCol db 10
actlenCol db ?
fldCol db 10 dup('$')

parStr label byte
maxlenStr db 10
actlenStr db ?
fldStr db 10 dup('$')

data ends

code segment
assume cs:code, ds:data

outInt2 proc near
    test    ax, ax
    jns  @OutNeg
    mov  cx, ax
    mov     ah, 02h
    mov     dl, '-'
    int     21h
    mov  ax, cx
    neg     ax
@OutNeg:  
    xor     cx, cx
    mov     bx, 10
@OutLoopFirst:
    xor     dx,dx
    div     bx
    push    dx
    inc     cx
    test    ax, ax
    jnz     @OutLoopFirst
    mov     ah, 02h
@OutLoopSec:
    pop     dx
    add     dl, '0'
    int     21h
    loop    @OutLoopSec
    ret
outInt2 endp

enterNum proc near
    mov di, 0           
    mov cx, [bx]                                       
    xor ch, ch
    mov si, 1                                           

    @loopMet:

    push si                                            
    mov si, cx                                         
    cmp cx,1
    je @Signed
    @NoSigned:
    mov ax, [bx+si]
    xor ah, ah   

    cmp al, 30h
    jb @Error
    cmp al, 39h
    ja @Error

    pop si                                             
    sub ax, 30h                                        
    mul si        
    jo @Overflow                       
    add di, ax                                
    mov ax, si                                         
    mov dx, 10
    mul dx                                          
    mov si, ax                       
    loop @loopMet                                      
    
    @return:
    call makeIntend
    ret

    @Signed:
    push dx
    mov dx,[bx+si]
    xor dh,dh
    cmp dl,'-'
    pop dx
    jne @NoSigned
    neg di
    pop si
    jmp @return

    @Error:
    mov error, 1
    pop cx
    jmp @return

    @Overflow:
    mov error, 1
    jmp @return
enterNum endp

fillArray proc near ;заполнение массива
@fillLoop:
    lea dx, parNum
    mov ah, 0Ah
    int 21h
    lea bx, parNum+1    
    mov buffCX, cx                              
    call enterNum
    mov cx, buffCX
    mov [bx], di    ;Переслать DI в элемент массива
    add bx, 2   ;Разместить в BX адрес следующего элемента массива
loop @fillLoop
ret
fillArray endp

makeIntend proc near
    lea dx, indent
    mov ah, 09
    int 21h
    ret
makeIntend endp



start:
    mov ax, data
    mov ds, ax
    jmp @firstTryStr

@errorInputStr:     ;ввод размерности первого массива
    lea dx, error
    mov ah, 09
    int 21h
    call makeIntend
@firstTryStr:
    lea dx, enterStr
    mov ah, 09
    int 21h
    lea dx, parStr
    mov ah, 0Ah
    int 21h
    lea bx, parStr+1                                  
    call enterNum
    cmp di, 5
    ja @errorInputStr
    cmp di, 0
    jbe @errorInputStr
    mov str, di
    jmp @firstTryCol

@errorInputCol:
    lea dx, error
    mov ah, 09
    int 21h
    call makeIntend
@firstTryCol:
    lea dx, enterCol
    mov ah, 09
    int 21h
    lea dx, parCol
    mov ah, 0Ah
    int 21h
    lea bx, parCol+1                                  
    call enterNum
    cmp di, 5
    ja @errorInputCol
    cmp di, 0
    jbe @errorInputCol
    mov col, di

    mov ax, str
    mul col 
    mov masFSize, ax
    call makeIntend
    jmp @firstTryStrS




@errorInputStrS:     ;ввод размерности второго массива
    lea dx, error
    mov ah, 09
    int 21h
    call makeIntend
@firstTryStrS:
    lea dx, enterStr
    mov ah, 09
    int 21h
    lea dx, parStr
    mov ah, 0Ah
    int 21h
    lea bx, parStr+1                                  
    call enterNum
    cmp di, 5
    ja @errorInputStrS
    cmp di, 0
    jbe @errorInputStrS
    mov str, di
    jmp @firstTryColS

@errorInputColS:
    lea dx, error
    mov ah, 09
    int 21h
    call makeIntend
@firstTryColS:
    lea dx, enterCol
    mov ah, 09
    int 21h
    lea dx, parCol
    mov ah, 0Ah
    int 21h
    lea bx, parCol+1                                  
    call enterNum
    cmp di, 5
    ja @errorInputColS
    cmp di, 0
    jbe @errorInputColS
    mov col, di

    mov ax, str
    mul col 
    mov masSSize, ax


lea bx, masF    ;Поместить в BX адрес начала массива mas.
mov cx, masFSize
call fillArray

mov ah, 4ch
int 21h
code ends
end start