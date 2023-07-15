;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                ; 4_2_Hafeli_S.asm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.586
.model  flat, stdcall
option casemap:none

; Link in the CRT.
includelib libcmt.lib
includelib libvcruntime.lib
includelib libucrt.lib
includelib legacy_stdio_definitions.lib

extern printf:NEAR
extern scanf:NEAR
extern _getch:NEAR
extern system:Near

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                ; Data
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.data
    newLine db 0ah, 0                   ; New Line string
    playerChar db '@', 0                ; Player icon
    endChar db 'X', 0                   ; End icon
    tileChar db '.', 0                  ; tile icon
    trapChar db 'T', 0                  ; Trap icon
    wallChar db '#', 0                  ; Wall icon
    enemyChar db 'E', 0                 ; Enemy icon
    menuStr db 0ah,'Masm Maze Game', 0ah,'Controls: W ^ , A < , S v , D >', 0ah, 'Get to the X to Win', 0ah, 'press: q to quit game', 0
    endMsgStr db 0ah,'Thank you for playing Masm Maze Game', 0ah, 'Player Energy was: %d Game Over', 0ah, 'Would you like to Play Again: y = Yes n = No?', 0
    playerPosition db 'Player is on Tile: %d', 0
    playerEnergyCount db 'Player Energy: %d', 0
    playerLiveCount db 'Player Lives: %d', 0
    wipeScreen db 'CLS', 0
    ;            Pc  Pe  Pl  t   t  t   w   w   w   w   w  E  F   WT  WR  WE     Pc = Player Location Pe = Player Energy t = Trap w = Wall E = Enemy F = Free / open WT = World Tile Count WR = World Row Count WE = World End
    levelData DD 49, 25, 3, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 50, 10, 38 
.code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                ; Main
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
main proc C
        push ebp 
        mov ebp, esp

        call MazeGame 

        mov esp, ebp
        pop ebp
        xor eax, eax
        ret
main endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                ; Clear Screen
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ClearScreen Proc
        push ebp 
        mov ebp, esp

        push offset wipeScreen
        call system
        add esp, 4

        mov esp, ebp
        pop ebp
        xor eax, eax
        ret
ClearScreen ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                ; Print new Line
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PrintNewLine Proc
        push ebp 
        mov ebp, esp

        push offset newLine     ; print new-line
        call printf
        add esp, 4

        mov esp, ebp
        pop ebp
        xor eax, eax
        ret
PrintNewLine ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ; Print Tile - pass offset to print
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GeneralPrint Proc
        push ebp 
        mov ebp, esp

        push [ebp + 8] 
        call printf
        add esp, 4

        mov esp, ebp
        pop ebp
        xor eax, eax
        ret 4
GeneralPrint ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ; Print In Game Stats
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PrintStats Proc
        push ebp 
        mov ebp, esp

        call PrintNewLine

        push levelData[0]          ; Player Tile position
        push offset playerPosition
        call printf
        add esp, 8

        call PrintNewLine

        push levelData[4]         ; Player Energy
        push offset playerEnergyCount
        call printf
        add esp, 8

        call PrintNewLine

        push levelData[8]         ; Player Lives
        push offset playerLiveCount
        call printf
        add esp, 8

        call PrintNewLine

        mov esp, ebp
        pop ebp
        ret 
PrintStats ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ; Print End Message
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PrintEndMsg Proc
        push ebp 
        mov ebp, esp

        push levelData[4]           ; Player energy
        push offset endMsgStr       ; print End
        call printf
        add esp, 8

        mov esp, ebp
        pop ebp
        ret 
PrintEndMsg ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ; Divide parameter one by parameter two : if no remainder returns eax 1 if True; eax 0 if false.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
IsNumberDivisibleBy PROC
        push ebp
        mov ebp, esp

        mov edx, 0              ; 0 edx before to prevent overflow 

        mov ecx, [ebp + 12]     ; getting parameter number to mod by
        mov eax, [ebp + 8]      ; getting parameter number in question

        cmp eax, 0              ; if eax is 0 return out to prevent / by 0 crash
        je ProcReturn

        idiv ecx

        mov eax, 1              ; return true default
        cmp edx, 0              ; if edx is 0 jump to return  
        jz ProcReturn 

        mov eax, 0              ; else eax is false 
ProcReturn:

        mov esp, ebp
        pop ebp
        ret 8
IsNumberDivisibleBy ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ; parameter one position ; -- if touching the bottom of the map -- returns eax 1 if True; eax 0 if false.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
IsTouchingBottom PROC
        push ebp
        mov ebp, esp

        mov ecx, [ebp + 8]      ; getting parameter number in question
        cmp ecx, 0              ; if ecx < 0 
        jge ProcReturn

        mov eax, 1              ; return true default
ProcReturn:

        mov esp, ebp
        pop ebp
        ret 4
IsTouchingBottom ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ; parameter one position ; parameter two is the amount of world tiles -- if touching the top of the map -- returns eax 1 if True; eax 0 if false.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
IsTouchingTop PROC
        push ebp
        mov ebp, esp

        mov edx, [ebp + 12]     ; this is the the tile total paramenter
        mov ecx, [ebp + 8]      

        mov eax, 0              ; false by default

        cmp ecx, edx            ; if ecx < (edx =  number of world tiles)
        jle ProcReturn

        mov eax, 1              ; return true if greater then world tiles
ProcReturn:

        mov esp, ebp
        pop ebp
        ret 8
IsTouchingTop ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ; Print Map
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;            Pc  Pe  Pl   t    t    t    w    w    w    w    w    E    F   WT   WR   WE           Pc = Player Location Pe = Player Energy t = Trap w = Wall E = Enemy WT = World Tile Count WR = World Row Count WE = World End
;           [0] [4] [8] [12] [16] [20] [24] [28] [32] [36] [40] [44] [48] [52] [56] [60]
Renderer PROC
        push ebp 
        mov ebp, esp

        push ebx                    ; save ebx now need for looping in
        mov ebx, levelData[52]      ; copy sacle this for number of tiles in the world   

ForLoop:
        cmp levelData[0], ebx      ; print player if index == player index
        je RenderPlayer

        cmp levelData[12], ebx      ; print trap if index == trap index
        je RenderTrap

        cmp levelData[16], ebx      ; print trap if index == trap index
        je RenderTrap

        cmp levelData[20], ebx      ; print trap if index == trap index
        je RenderTrap

        cmp levelData[24], ebx      ; print wall if index == wall index
        je RenderWall

        cmp levelData[28], ebx      ; print wall if index == wall index
        je RenderWall

        cmp levelData[32], ebx      ; print wall if index == wall index
        je RenderWall

        cmp levelData[36], ebx      ; print wall if index == wall index
        je RenderWall

        cmp levelData[40], ebx      ; print wall if index == wall index
        je RenderWall

        cmp levelData[44], ebx      ; print Enemy if index == Enemy index
        je RenderEnemy

        push levelData[56]          ; number to mod by    
        push ebx                    ; pass the copy to 
        call IsNumberDivisibleBy    ; if index is a muliple of number to mod by this returns 1 else returns 0 

        cmp eax, 1                  ; if mod by ten is true
        je ModByTenTrue

        cmp ebx, levelData[60]
        je RenderEnd

        push offset tileChar
        call GeneralPrint
Next:
        sub ebx, 1              ; evey time around - 1 
        cmp ebx, 0              ; if ebx is 0 then stop looping
        jne ForLoop          

        jmp Return              ; skip new line print 

ModByTenTrue:
        call PrintNewLine
        jmp Next                ;jump back to forloop

RenderPlayer:
        push offset playerChar
        call GeneralPrint
        jmp Next                ;jump back to forloop

RenderEnd:
        push offset endChar
        call GeneralPrint
        jmp Next                ;jump back to forloop

RenderTrap:
        push offset trapChar
        call GeneralPrint
        jmp Next                ;jump back to forloop

RenderWall:
        push offset wallChar
        call GeneralPrint
        jmp Next                ;jump back to forloop

RenderEnemy:
        push offset enemyChar
        call GeneralPrint
        jmp Next                ;jump back to forloop

Return:
        pop ebx                 ; ebx Returned

        mov esp, ebp
        pop ebp
        ret 
Renderer ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ; Render World handles calling print functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
RenderWorld PROC
        push ebp
        mov ebp, esp

        call ClearScreen

        call PrintStats
        
        call PrintNewLine                       

        call Renderer               ; Render game world

        call PrintNewLine

        push offset menuStr
        call GeneralPrint

        mov esp, ebp
        pop ebp
        ret 
RenderWorld ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ; User Input -- Returns either 0 = end game, 1 = up, 2 = down, 3 = left, 4 = right 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PlayerController PROC
        push ebp
        mov ebp, esp

        mov eax ,levelData[0]           ; Player : grabbing copys of player and enemy position not premitted to wirte to masters here for safty  

    InputLoop:   

        call _getch        

        cmp eax, 'q'
        je Quit
        cmp eax, 'w' 
        je Up
        cmp eax, 'a' 
        je Left
        cmp eax, 's'
        je Down
        cmp eax, 'd' 
        je Right

        jmp InputLoop 
    
    Up:
        mov eax, 1
        jmp Return 

    Down:
       mov eax, 2 
       jmp Return 

    Left:
       mov eax, 3
       jmp Return 

    Right:
        mov eax, 4
        jmp Return 

    Quit:
        mov eax, 0       
    Return:
    
        mov esp, ebp
        pop ebp
        ret 
PlayerController ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ; Enemy Controller -- Returns either 0 = end game, 1 = up, 2 = down, 3 = left, 4 = right 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
EnemyController PROC
        push ebp
        mov ebp, esp

    InputLoop:

        mov eax ,levelData[0]           ; Player : grabbing copys of player and enemy position not premitted to wirte to masters here for safty  

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;          Up Logic
        mov esi, levelData[44]          ; Enemy                
        add esi, levelData[56]          ; World row amount

        cmp eax, esi 
        je Up

        add esi, levelData[56]          ; World row amount
        cmp eax, esi 
        je Up
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;          Left logic
        mov esi, levelData[44]          ; Enemy                
        add esi, 1      
        cmp eax, esi 
        je Left

        add esi, 1      
        cmp eax, esi 
        je Left
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;          Down logic
        mov esi, levelData[44]          ; Enemy                
        sub esi, levelData[56]          ; World row amount
        cmp eax, esi 
        je Down

        sub esi, levelData[56]          ; World row amount
        cmp eax, esi 
        je Down
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;          Right logic
        mov esi, levelData[44]          ; Enemy                
        sub esi, 1      
        cmp eax, esi  
        je Right

        sub esi, 1      
        cmp eax, esi  
        je Right
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        jmp NoMove
    
    Up:
        mov eax, 1
        jmp Return 

    Down:
       mov eax, 2 
       jmp Return 

    Left:
       mov eax, 3
       jmp Return 

    Right:
        mov eax, 4
        jmp Return 

    NoMove:
        mov eax, 0       
    Return:
    
        mov esp, ebp
        pop ebp
        ret 
EnemyController ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;Check for world objects not pass able
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;            Pc  Pe  Pl   t    t    t    w    w    w    w    w    E    F   WT   WR   WE                            Pc = Player Location Pe = Player Energy t = Trap w = Wall E = Enemy WT = World Tile Count WR = World Row Count WE = World End
;           [0] [4] [8] [12] [16] [20] [24] [28] [32] [36] [40] [44] [48] [52] [56] [60]
CheckWorldObjects PROC
        push ebp 
        mov ebp, esp

        mov eax, [ebp + 8]  

        cmp levelData[24], eax      ; wall if object == wall index
        je Hit

        cmp levelData[28], eax      ; wall if object == wall index
        je Hit

        cmp levelData[32], eax      ; wall if object == wall index
        je Hit

        cmp levelData[36], eax      ; wall if object == wall index
        je Hit

        cmp levelData[40], eax      ; wall if object == wall index
        je Hit

        mov eax, 0
        jmp Return
    Hit:
        mov eax, 1
    Return:
        mov esp, ebp
        pop ebp
        ret 4
CheckWorldObjects ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ; Collision Manager this return the amount to add to the Objects's position returns 0 is touched something
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;            Pc  Pe  Pl   t    t    t    w    w    w    w    w    E    F   WT   WR   WE                            Pc = Player Location Pe = Player Energy t = Trap w = Wall E = Enemy WT = World Tile Count WR = World Row Count WE = World End
;           [0] [4] [8] [12] [16] [20] [24] [28] [32] [36] [40] [44] [48] [52] [56] [60]
CollisionManager PROC
        push ebp
        mov ebp, esp

        push ebx 
        push esi
        push edi

        mov edi, levelData[52]  ; = WT
        mov esi, levelData[56]  ; = WR

        mov ebx, [ebp + 12]         ; this is Object current position
        mov eax, [ebp + 8]          ; move request

        cmp eax, 1                  ; Move request processing
        je Up
        cmp eax, 2            
        je Down
        cmp eax, 3            
        je Left
        cmp eax, 4            
        je Right


    Up:
        add ebx, esi
        push edi                    ; number of tiles in world
        push ebx
        call IsTouchingTop          ; return one if true
        cmp eax, 1                  ; if is true
        je Touching                 

        push ebx
        call CheckWorldObjects      ; Checks Object position to all other world objects
        cmp eax, 1
        je Touching

        mov eax, esi
        jmp Return
    Down:

        sub ebx, esi                ; Move Object 
        push ebx                    ; Test move
        call IsTouchingBottom       ; return one if true
        cmp eax, 1                  ; if is true
        je Touching

        push ebx
        call CheckWorldObjects      ; Checks Object position to all other world objects
        cmp eax, 1
        je Touching

        neg esi
        mov eax, esi
        jmp Return
    Left:
        add ebx, 1
        push levelData[56]          ; if Object position is a mod of number of rows then your on the left wall no more going left
        push ebx                    ; Object position
        call IsNumberDivisibleBy
        cmp eax, 1                  ; if is true
        je Touching

        push ebx
        call CheckWorldObjects      ; Checks Object position to all other world objects
        cmp eax, 1
        je Touching

        mov eax, 1
        jmp Return

    Right:
        sub ebx, 1
        cmp ebx, 0
        je Touching

        push esi                    ; if Object position is a mod of number of rows then your on the right wall no more going right
        push ebx                    ; Object position
        call IsNumberDivisibleBy
        cmp eax, 1                  ; if is true
        je Touching

        push ebx
        call CheckWorldObjects      ; Checks Object position to all other world objects
        cmp eax, 1
        je Touching

        mov eax, -1
        jmp Return

    Touching:
        mov eax, 0
    
    Return:
        pop edi
        pop esi
        pop ebx

        mov esp, ebp
        pop ebp
        ret 8
CollisionManager ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ; Game Status 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;            Pc  Pe  Pl   t    t    t    w    w    w    w    w    E    F   WT   WR   WE                            Pc = Player Location Pe = Player Energy t = Trap w = Wall E = Enemy WT = World Tile Count WR = World Row Count WE = World End
;           [0] [4] [8] [12] [16] [20] [24] [28] [32] [36] [40] [44] [48] [52] [56] [60]                                    Pl = Player Lives
GameStatus PROC
        push ebp 
        mov ebp, esp

        mov eax, levelData[0]       ; copy player Position Master  

        cmp levelData[60], eax      ; if player == End Tile index
        je Win

        cmp levelData[44], eax      ; if player == enemy index
        je Dead

        cmp levelData[12], eax      ; if player == trap index
        je Dead

        cmp levelData[16], eax      ; if player == trap index
        je Dead

        cmp levelData[20], eax      ; if player == trap index
        je Dead

        cmp levelData[8], 0 
        je GameOver

        mov eax, 0
        jmp Return

    GameOver:
        mov eax, 3
        jmp Return
    Dead:
        mov eax, 1
        jmp Return
    Win:
        mov eax, 2
    Return:
        mov esp, ebp
        pop ebp
        ret
GameStatus ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ; level Two data
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;            Pc  Pe  Pl   t    t    t    w    w    w    w    w    E    F   WT   WR   WE                            Pc = Player Location Pe = Player Energy t = Trap w = Wall E = Enemy WT = World Tile Count WR = World Row Count WE = World End
;           [0] [4] [8] [12] [16] [20] [24] [28] [32] [36] [40] [44] [48] [52] [56] [60]                                    Pl = Player Lives
LevelTwoDataModify PROC
        push ebp 
        mov ebp, esp

        mov levelData[0], 499           ; player Position Master  
        mov levelData[4], 50            ; player Energy Master 
        mov levelData[8], 3             ; player Lifes Master 
        mov levelData[12], -1           ; Trap1 Master 
        mov levelData[16], -1           ; Trap2 Master 
        mov levelData[20], -1           ; trap3 Master 
        mov levelData[24], 44           ; wall1 Master 
        mov levelData[28], 55           ; wall2 Master 
        mov levelData[32], 205          ; wall3 Master 
        mov levelData[36], 476          ; wall4 Master 
        mov levelData[40], 327          ; wall5 Master 
        mov levelData[44], -1           ; Enemy Master 
        mov levelData[48], -1           ; Free / open Master       - ToDo: Maybe treasure stat or energy pick up 
        mov levelData[52], 500          ; World Tile count Master 
        mov levelData[56], 25           ; Wrold Tile per Row Master 
        mov levelData[60], 137          ; World End Master 

    Return:
        mov esp, ebp
        pop ebp
        ret
LevelTwoDataModify ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ; level Three data
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;            Pc  Pe  Pl   t    t    t    w    w    w    w    w    E    F   WT   WR   WE                            Pc = Player Location Pe = Player Energy t = Trap w = Wall E = Enemy WT = World Tile Count WR = World Row Count WE = World End
;           [0] [4] [8] [12] [16] [20] [24] [28] [32] [36] [40] [44] [48] [52] [56] [60]                                    Pl = Player Lives
LevelThreeDataModify PROC
        push ebp 
        mov ebp, esp

        mov levelData[0], 499           ; player Position Master  
        mov levelData[4], 100           ; player Energy Master 
        mov levelData[8], 3             ; player Lifes Master 
        mov levelData[12], 389          ; Trap1 Master 
        mov levelData[16], 444          ; Trap2 Master 
        mov levelData[20], 51           ; trap3 Master 
        mov levelData[24], 44           ; wall1 Master 
        mov levelData[28], 55           ; wall2 Master 
        mov levelData[32], 205          ; wall3 Master 
        mov levelData[36], 476          ; wall4 Master 
        mov levelData[40], 327          ; wall5 Master 
        mov levelData[44], 255          ; Enemy Master 
        mov levelData[48], -1           ; Free / open Master       - ToDo: Maybe treasure stat or energy pick up 
        mov levelData[52], 500          ; World Tile count Master 
        mov levelData[56], 20           ; Wrold Tile per Row Master 
        mov levelData[60], 152          ; World End Master 

    Return:
        mov esp, ebp
        pop ebp
        ret
LevelThreeDataModify ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ; Zero level data
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;            Pc  Pe  Pl   t    t    t    w    w    w    w    w    E    F   WT   WR   WE                            Pc = Player Location Pe = Player Energy t = Trap w = Wall E = Enemy WT = World Tile Count WR = World Row Count WE = World End
;           [0] [4] [8] [12] [16] [20] [24] [28] [32] [36] [40] [44] [48] [52] [56] [60]                                    Pl = Player Lives
LevelDataReset PROC
        push ebp 
        mov ebp, esp

        mov levelData[0], 49           ; player Position Master  
        mov levelData[4], 25           ; player Energy Master 
        mov levelData[8], 3            ; player Lifes Master 
        mov levelData[12], -1          ; Trap1 Master 
        mov levelData[16], -1          ; Trap2 Master 
        mov levelData[20], -1          ; trap3 Master 
        mov levelData[24], -1          ; wall1 Master 
        mov levelData[28], -1          ; wall2 Master 
        mov levelData[32], -1          ; wall3 Master 
        mov levelData[36], -1          ; wall4 Master 
        mov levelData[40], -1          ; wall5 Master 
        mov levelData[44], -1          ; Enemy Master 
        mov levelData[48], -1          ; Free / open Master       
        mov levelData[52], 50          ; World Tile count Master 
        mov levelData[56], 10          ; Wrold Tile per Row Master 
        mov levelData[60], 38          ; World End Master 

    Return:
        mov esp, ebp
        pop ebp
        ret
LevelDataReset ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ; Update
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;            Pc  Pe  Pl   t    t    t    w    w    w    w    w    E    F   WT   WR   WE                            Pc = Player Location Pe = Player Energy t = Trap w = Wall E = Enemy WT = World Tile Count WR = World Row Count WE = World End
;           [0] [4] [8] [12] [16] [20] [24] [28] [32] [36] [40] [44] [48] [52] [56] [60]                                    Pl = Player Lives
Update PROC
        push ebp 
        mov ebp, esp

        call PlayerController           ; handle player controls returns eax with a number for direction requested to move pass to collions checker to test move if return 0 then end game]
        push levelData[0]               ; pushing player Position Master
        push eax                        ; pushing requested move 

        cmp eax, 0                      
        je EndGame

        call CollisionManager           ; using the two pushes above
        mov ecx, levelData[0]           ; getting master player position add the resulting 
        add ecx, eax                    
        mov levelData[0], ecx


        cmp levelData[44], -1
        je ContinueGame
        call EnemyController           ; handle Enemy controls returns eax with a number for direction requested to move pass to collions checker to test move if return 0 if no move is to be made
        cmp eax, 0 
        je ContinueGame

        push levelData[44]              ; pushing Enemy Position Master
        push eax                        ; pushing requested move 

        call CollisionManager           ; using the two pushes above

        mov ecx, levelData[44]           ; getting master player position add the resulting 
        add ecx, eax                    
        mov levelData[44], ecx
        
        jmp ContinueGame

    EndGame:
        mov eax, 1
        jmp Return
    ContinueGame:
        mov eax, 0
    Return:
        mov esp, ebp
        pop ebp
        ret
Update ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                ; MazeGame Take in Player starting position, and move count
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;            Pc  Pe  Pl   t    t    t    w    w    w    w    w    E    F   WT   WR   WE                            Pc = Player Location Pe = Player Energy t = Trap w = Wall E = Enemy WT = World Tile Count WR = World Row Count WE = World End
;           [0] [4] [8] [12] [16] [20] [24] [28] [32] [36] [40] [44] [48] [52] [56] [60]
MazeGameMainLoop proc 
        push ebp 
        mov ebp, esp

        push ebx
        push esi 

        mov esi, levelData[4]           ; starting Player Enegry level
        mov ebx, levelData[0]           ; starting Player Position
        jmp Start

Restart:
        mov levelData[0], ebx
        mov levelData[4], esi           ; reset stats

        mov ecx, levelData[8]           ; lose a life
        sub ecx, 1
        cmp ecx, 0
        je GameOver

        mov levelData[8], ecx

        mov eax, 0                      ; player is alive again 
        jmp Start                       ; skips player losing Energy

GameLoop:

        mov eax, levelData[4]
        dec eax
        mov levelData[4], eax
        cmp eax, 0
        je Restart

        mov eax, 0                      
Start:
        call GameStatus

        cmp eax, 1                      ; is player dead 
        je Restart

        cmp eax, 2                      ; is level over
        je EndLevel

        cmp eax, 3                      ; is Game over
        je GameOver

        call RenderWorld                ; Rendering locgic and calls 
        call Update                     ; Update logic and calls

        cmp eax, 1                      ; if player requested to quit in controller pass to end game
        je GameOver

        jmp GameLoop

EndLevel:
        mov eax, 2
        jmp Return

GameOver:
        mov eax, 3
Return:
        pop ebx

        mov esp, ebp
        pop ebp
        ret
MazeGameMainLoop ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                ; Main
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MazeGame Proc 
        push ebp 
        mov ebp, esp
    LevelOne:
        call MazeGameMainLoop           ; level One is starting data

        cmp eax, 3                      ; check if player made it to next level
        je EndGame

    LevelTwo:
        call LevelTwoDataModify         ; Mod Level data to level two
        call MazeGameMainLoop           ; play

        cmp eax, 3                      ; check if player made it to next level
        je EndGame

    LevelThree:
        call LevelThreeDataModify       ; Mod Level data to level two
        call MazeGameMainLoop           ; play

        cmp eax, 3                      ; check if player made it to next level
        je EndGame

    EndGame:
        call ClearScreen
        call PrintEndMsg

    TryAgain:    
        call _getch

        cmp eax, 'y'
        je ResetGame

        cmp eax, 'n'
        je Return

        jmp TryAgain

    ResetGame:
        call LevelDataReset
        jmp LevelOne

    Return:
        mov esp, ebp
        pop ebp
        xor eax, eax
        ret
MazeGame ENDP
END
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;