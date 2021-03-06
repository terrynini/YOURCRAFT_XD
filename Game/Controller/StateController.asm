.386
.model flat, stdcall
option casemap:none

include .\include\GameSdk.inc

.data

CurrentState    DWORD   STATE_TITLE

.code

State_Init PROC
    push    ebp
    mov     ebp, esp

    call    StatusBar_Init
    call    StateTitle_Init
    call    BackPack_Init
    call    StateGame_Init
    call    StateDead_Init 
    
    leave
    ret
State_Init ENDP

SetState PROC State:DWORD
    mov     eax, State
    mov     CurrentState, eax
    ret
SetState ENDP

StateTickTock PROC
    push    ebp
    mov     ebp, esp

    .IF CurrentState == STATE_TITLE
        call    StateTitle_TickTock
    .ELSEIF CurrentState == STATE_GAME
        call    StateGame_TickTock
    .ELSEIF CurrentState == STATE_BACKPACK
        call    BackPack_TickTock
    .ELSEIF CurrentState == STATE_DEAD
        call    StateDead_TickTock
    .ENDIF

    leave
    ret
StateTickTock ENDP

StateRender PROC
    push    ebp
    mov     ebp, esp

    .IF CurrentState == STATE_TITLE
        call    StateTitle_Render
    .ELSEIF CurrentState == STATE_GAME
        call    StateGame_Render
    .ELSEIF CurrentState == STATE_BACKPACK
        call    BackPack_Render
    .ELSEIF CurrentState == STATE_DEAD
        call    StateDead_Render  
    .ENDIF

    leave
    ret
StateRender ENDP
end

