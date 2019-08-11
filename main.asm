;Anthony Bravo 

LOCALS
.MODEL tiny
.386

;Ouput file is saved as "OUTPUT.TXT" 

.DATA
    inputfile db "output.txt", 0
    outputfile db "output.txt", 0  
    inhandle dw ?
    outhandle dw ?
    character db ' '


.CODE
org 100h


main PROC
    ;Create new File 
    mov dx, offset inputfile
    mov ah, 3dh
    mov al, 1 ;---
    int 21h
    mov inhandle, ax 

    ;Creating output File ---
    mov dx, offset outputfile
    mov ah, 3ch
    sub cx, cx
    int 21h
    mov outhandle, ax

    Start:
    mov dx, offset outputfile
    mov ah, 41h
    int 21h

    ;Creating output File ---
    mov dx, offset outputfile
    mov ah, 3ch
    sub cx, cx
    int 21h
    mov outhandle, ax

    ;Sets video mode to (80x25) and clears the screen
    mov ah, 0
    mov al, 3h; --
    int 10h

    ;Sets the background color to gray 
    mov ax, 0600h
    mov bh, 70h
    mov cx, 0
    mov dx, 184fh
    int 10h 

    call drawlines
    call instructions

    ;Displays the name Text Editor & Anthony Bravo
    mov al, 1
    mov bh, 0
    mov bl, 70h
    mov cx, txt0 - offset msg0
    mov dl, 25
    mov dh, 1
    mov bp, offset msg0
    mov ah, 13h
    int 10h
    jmp txt0
    msg0 db "Text Editor By Anthony Bravo"
    txt0:  

    ;Sets cursor to initial position
    mov ah, 2  
    mov dl, 10 ; colum
    mov dh, 4  ;row
    mov bh, 0           
    int 10h  

    ;keyboard buffer
    mov ah, 0
    mov cl, al          
    int 16h 
    
    mov si, 0
    mov di, 0
    
    ;Move cursor using keyboard -------------

    WHILE:
    ;Comparing if escape key was pressed
    cmp al, 1Bh    
    je ENDWHILE 
    cmp al, 13
    je  Enter_pressed
    cmp al, 08h
    je Del_Pressed

    continue4:
    ;Compare function 
    cmp al, 0            
    jne ELSE1 
    call Stores_Value 
    jmp NEXT   

    ELSE1:  
    mov dx, 0
    mov ah, 2            
    mov dl, al        
    int 21h  
    ;al has the character typed 

    ;Write to file
    mov si, offset character
    mov [si], al
    mov ah, 40h 
    lea dx, [si]
    mov cx, 1
    mov bx, outhandle
    int 21h 

    NEXT:
    call Validate  
    continue1:  
    mov ah, 0        
    int 16h
    jmp WHILE

    ENDWHILE:
    mov ah, 5Ch
    int 21h

    Validate:
    ;Get current position
    mov ah, 3
    mov bh, 0 
    int 10h
    cmp dl, 43
    je next_Row 
    ret

    next_Row:
    mov ah, 2
    mov dl, 10 ; colum
    Inc dh ; row
    mov bh, 0           
    int 10h  
    jmp continue1

    F1_Pressed:
    mov si, 1
    jmp evaluate1

    F2_Pressed:
    mov si, 0
    mov di, 0
    jmp evaluate2

    F3_Pressed:
    jmp Start

    Del_Pressed:

        call moveCursorLeft
        mov  ah, 02h
        mov  dl, ''
        int  21h                        
        call moveCursorLeft

        ;Get current position
         mov ah, 3
        mov bh, 0 
        int 10h
        cmp dl, 10
        jne continue4

        mov ah, 2
        mov dl, 42 ; colum
        dec dh ; row
        mov bh, 0           
        int 10h 
    
    jmp continue4

    Stores_Value:
        push ax 

        ;Check if we want to navigate or draw boxes
        cmp ah, 3Bh
        je F1_Pressed
        cmp ah, 3Dh
        je F3_Pressed
        evaluate1:
        cmp si, 1
        je Boxes
        jmp Navigate


        Boxes:
            ;Check if we want to exit draw boxes
            cmp ah, 3Ch
            je F2_Pressed
            evaluate2: 
            cmp si, 0
            je Navigate

            ;Locates position of cursor 
            mov ah, 3            
            mov bh, 0          
            int 10h            
            pop ax  

            ;Drawing Boxes using cursor
            ;Scanning Codes for arrows on keyboard
            cmp ah, 48h           
            je Arrow_Up_Draw     
            cmp ah, 4Bh          
            je Arrow_Left_Draw   
            cmp ah, 4Dh           
            je Arrow_Right_Draw    
            cmp ah, 50h         
            je Arrow_Down_Draw
            jmp Exit_   


            Arrow_Up_Draw:
            call Vertical_Line_Up
            call writeToFile
            mov ah, 3  
            int 10h
            Dec dl
            cmp dh, 4 
            jne UP_Draw        
            mov dh, 20 
            jmp RUN_Draw

            Arrow_Down_Draw:
            call Vertical_Line_Down
            call writeToFile
            mov ah, 3  
            int 10h
            Dec dl
            cmp dh, 20
            jne Down_Draw
            mov dh, 4  
            jmp RUN_Draw

            Arrow_Left_Draw:
            call Horizontal_Line_Left
            call writeToFile
            mov ah, 3  
            int 10h
            Dec dl
            cmp dl, 10        
            jne Left_Draw     
            mov dl, 42 
            jmp RUN_Draw

            Arrow_Right_Draw:
            call Horizontal_Line_Right
            call writeToFile
            mov ah, 3  
            int 10h
            Dec dl
            cmp dl, 42     
            jne Right_Draw 
            mov dl, 10
            jmp RUN_Draw

            Left_Draw:
            SUB dl,1          
            jmp RUN_Draw 

            Right_Draw:
            ADD dl,1        
            jmp RUN_Draw 

            Up_Draw: 
            SUB dh, 1
            jmp RUN_Draw

            Down_Draw:
            ADD dh, 1
            jmp RUN_Draw 

            RUN_Draw:
            mov ah, 2          
            int 10h  

            jmp Exit_ 



        Navigate:

            ;Locates position of cursor 
            mov ah, 3            
            mov bh, 0          
            int 10h            
            pop ax    

            ;Scanning Codes for arrows on keyboard
            cmp ah, 48h           
            je Arrow_Up     
            cmp ah, 4Bh          
            je Arrow_Left     
            cmp ah, 4Dh           
            je Arrow_Right    
            cmp ah, 50h         
            je Arrow_Down 
            jmp Exit_            

            Arrow_Up:
            mov ah, 3  
            int 10h
            cmp dh, 4 
            jne UP        
            mov dh, 20 
            jmp RUN 

            Arrow_Down:
            mov ah, 3  
            int 10h
            cmp dh, 20
            jne Down 
            mov dh, 4                 
            jmp RUN    

            Arrow_Left:
            mov ah, 3  
            int 10h
            cmp dl, 10        
            jne Left      
            mov dl, 42          
            jmp RUN        

            Arrow_Right:
            mov ah, 3  
            int 10h
            cmp dl, 42     
            jne Right       
            mov dl, 10         
            jmp RUN 

            Left:
            SUB dl,1          
            jmp RUN     

            Right:
            ADD dl,1        
            jmp RUN   

            Up: 
            SUB dh, 1
            jmp RUN

            Down:
            ADD dh, 1
            jmp RUN    

            RUN:
            mov ah, 2          
            int 10h  

        Exit_:
        ret 

    ;------------------------

    
    ;End Program
    mov ax, 4c00h
    mov al, 0
    int 21h


    ;---------------------------------
    drawlines:
         ;Sets line drawing
        LINE MACRO row, col
        mov ah, 2
        mov dh, row
        mov dl, col
        mov bh, 0
        int 10h

        ;six lines are drawn
        mov ah, 9
        mov bh, 0
        mov bl, 1h
        mov cx, 36
        int 10h
        ENDM

        ;position for 3 lines
        LINE 3,8
        LINE 21,8

        ;cursor for 1st line
        mov dh, 21
        VERTICAL_1:
        mov ah, 2
        mov dh, dh
        mov dl, 8
        mov bh, 0
        int 10h
        add dh, -1

        ;Draw line
        mov ah, 9
        mov bh, 0
        mov bl, 1h
        mov cx, 01
        int 10h
        cmp dh, 3
        JGE VERTICAL_1
        

        ;cursor for 10th line
        mov dh, 21
        VERTICAL_10:
        mov ah, 2
        mov dh, dh
        mov dl, 44
        mov bh, 0
        int 10h
        add dh, -1

        ;Draw 10th line
        mov ah, 9
        mov bh, 0
        mov bl, 1h
        mov cx, 01
        int 10h
        cmp dh, 3
        JGE VERTICAL_10
        ret

    instructions:
        ;Show instructions
        mov bh, 0
        mov bl, 0Fh
        mov cx, txt39 - offset msg39
        mov dl, 48
        mov dh, 5
        mov bp, offset msg39
        mov ah, 13h
        int 10h
        jmp txt39
        msg39 db "Instructions to use editor:"
        txt39:  

        ;Displays First Instruction
        mov bh, 0
        mov bl, 70h
        mov cx, txt40 - offset msg40
        mov dl, 46
        mov dh, 7
        mov bp, offset msg40
        mov ah, 13h
        int 10h
        jmp txt40
        msg40 db "1)Use arrows to move on the screen"
        txt40:                         

        ;Displays Second Instruction
        mov bh, 0
        mov bl, 70h
        mov cx, txt41 - offset msg41
        mov dl, 46
        mov dh, 9
        mov bp, offset msg41
        mov ah, 13h
        int 10h
        jmp txt41
        msg41 db "2)Type any text on the screen"
        txt41:  

        ;Displays Third Instruction
        mov bh, 0
        mov bl, 70h
        mov cx, txt43 - offset msg43
        mov dl, 46
        mov dh, 11
        mov bp, offset msg43
        mov ah, 13h
        int 10h
        jmp txt43
        msg43 db "3)Press F1 to go into drawing mode"
        txt43:  

        ;Displays Fourth Instruction
        mov bh, 0
        mov bl, 70h
        mov cx, txt44 - offset msg44
        mov dl, 46
        mov dh, 13
        mov bp, offset msg44
        mov ah, 13h
        int 10h
        jmp txt44
        msg44 db "4)Use arrow keys to draw boxes"
        txt44:  

        ;Displays Fifth Instruction
        mov bh, 0
        mov bl, 70h
        mov cx, txt45 - offset msg45
        mov dl, 46
        mov dh, 15
        mov bp, offset msg45
        mov ah, 13h
        int 10h
        jmp txt45
        msg45 db "5)Press F2 to go back to editor"
        txt45:  

        ;Displays sixth Instruction
        mov bh, 0
        mov bl, 70h
        mov cx, txt46 - offset msg46
        mov dl, 46
        mov dh, 17
        mov bp, offset msg46
        mov ah, 13h
        int 10h
        jmp txt46
        msg46 db "6)Press F3 to clear Screen"
        txt46:  

        ;Displays seventh Instruction
        mov bh, 0
        mov bl, 70h
        mov cx, txt47 - offset msg47
        mov dl, 46
        mov dh, 19
        mov bp, offset msg47
        mov ah, 13h
        int 10h
        jmp txt47
        msg47 db "7)Press enter to save file"
        txt47:  
        
     ret

    ;--------------------

    printCode:
    mov bx, 0
    mov bl, al
    mov  ah, 02h
    mov  dl, bl
    add  dl, "0"
    int  21h
    ret

    printArrayElement:
    mov  ah, 02h
    mov  dl, al
    int  21h
    ret

    Horizontal_Line_Right:
    mov ax, di
    mov di, 1
    cmp ax, 3
    je TopLeft_Line
    cmp ax, 4
    je BottomLeft_Line
    mov  ah, 02h
    mov  dl, 196
    int  21h
    ending1:
    ret

    Horizontal_Line_Left:
    mov ax, di
    mov di, 2
    cmp ax, 3
    je TopRight_Line
    cmp ax, 4
    je BottomRight_Line
    mov  ah, 02h
    mov  dl, 196
    int  21h
    ending2:
    ret

    Vertical_Line_Up:
    mov ax, di
    mov di, 3
    cmp ax, 1
    je BottomRight_Line
    cmp ax, 2
    je BottomLeft_Line
    mov  ah, 02h
    mov  dl, 179
    int  21h
    ending3:
    ret

    Vertical_Line_Down:
    mov ax, di
    mov di, 4
    cmp ax, 1
    je TopRight_Line
    cmp ax, 2
    je TopLeft_Line
    mov  ah, 02h
    mov  dl, 179
    int  21h
    ending4:
    ret

    TopLeft_Line:
    mov  ah, 02h
    mov  dl, 218
    int  21h
    ret

    TopRight_Line:
    mov  ah, 02h
    mov  dl, 191
    int  21h
    ret

    BottomLeft_Line:
    mov  ah, 02h
    mov  dl, 192
    int  21h
    ret

    BottomRight_Line:
    mov  ah, 02h
    mov  dl, 217
    int  21h
    ret

    moveCursorLeft:
    mov ah, 3  
    int 10h
    dec dl
    mov cl, dl

    mov dl, cl
    mov bh, 0
    mov ah, 2
    int 10h
    ret

    moveCursorRight:
    mov ah, 3  
    int 10h
    inc dl
    mov cl, dl

    mov dl, cl
    mov bh, 0
    mov ah, 2
    int 10h
    ret

    writeToFile:
    mov bp, offset character
    mov [bp], dl
    mov ah, 40h 
    lea dx, [bp]
    mov cx, 1
    mov bx, outhandle
    int 21h 
    ret


    Enter_Pressed:
        ;Close Output file
        mov ah, 3Eh
        mov bx, outhandle
        int 21h

        ;Exit Program
        mov ax, 4c00h
        mov al, 0
        int 21h


main ENDP

End main


;196 = horizontal line
;179 = vertical line
;218 = top left cut
;191 = top right cut
;192= bottom left cut
;217 = bottom right cut


