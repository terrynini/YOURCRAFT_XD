;gcc Main.obj -IC:\MinGW\include\SDL2 -LC:\MinGW\lib -w -Wl,-subsystem,windows -lmingw32 -lSDL2main -lSDL2 -lSDL2_image -lSDL2_ttf 
.386
.model flat, stdcall
option casemap:none

include ..\include\GameSdk.inc

LoadTexture proto :ptr DWORD 

SCREEN_WIDTH            equ 816d    
SCREEN_HEIGHT           equ 624d

.data
Caption          BYTE "YOURCRAFT X-D", 0
PIC_PNG          BYTE "img/WorldMap.png", 0
Literal_one      BYTE "1", 0
gWindow          DWORD ?
Background_text  DWORD ?
gRender          DWORD ?

SDL_HINT_RENDER_SCALE_QUALITY  BYTE "SDL_HINT_RENDER_SCALE_QUALITY", 0

.code
SDL_main PROC
    ;LOCAL will do the prologue & !!!!epilogue!!!! for you
    LOCAL   event[56]:BYTE
    LOCAL   quit:BYTE
    LOCAL   gCurrentSurface:DWORD
    LOCAL   gPNGSurface:DWORD
    ;init
    mov     quit, 0
    call    GameInit
    ;load iamge
    invoke  LoadTexture, addr PIC_PNG
    mov     Background_text, eax
    ;this is the game loop
    .WHILE !quit
        PollLoop:
            lea     eax, event
            push    eax
            call    SDL_PollEvent
            test    eax, eax    ;test if eax equ 0
            setne   al          ;if eax equ zero, set al 
            test    al, al      ;test if al has been set or not
            je      Render    ;if al has been set, break loop
            mov     eax, DWORD ptr event  
            ;if event == SDL_QUIT, then quit = true
            cmp     eax, SDL_QUIT
            sete    quit
        NextEvent:                  
            jmp     PollLoop    ;go back to deal with next event
        Render:
            call    GameRender
    .ENDW
    ;GameExit
    call    GameExit
    ret
SDL_main ENDP

GameInit PROC
    push    ebp
    mov     ebp, esp

    ;SDL_Init
    push    SDL_INIT_VIDEO
    call    SDL_Init
    ;SDL_SetHint
    push    offset Literal_one
    push    offset SDL_HINT_RENDER_SCALE_QUALITY
    call    SDL_SetHint
    ;SDL_CreateWindow
    push    SDL_WINDOW_SHOWN
    push    SCREEN_HEIGHT
    push    SCREEN_WIDTH
    push    SDL_WINDOWPOS_UNDEFINED
    push    SDL_WINDOWPOS_UNDEFINED
    push    OFFSET Caption
    call    SDL_CreateWindow
    mov     gWindow, eax
    ;SDL_CreateRenderer
    mov     eax, SDL_RENDERER_ACCELERATED
    or      eax, SDL_RENDERER_PRESENTVSYNC
    push    eax
    push    -1
    push    gWindow
    call    SDL_CreateRenderer
    mov     gRender, eax
    ;SDL_SetRenderDrawColor
    push    0ffh
    push    0ffh
    push    0ffh
    push    0ffh
    push    gRender
    call    SDL_SetRenderDrawColor
    ;IMG_Init
    push    IMG_INIT_PNG
    call    IMG_Init
    ;TTF_Init
    call    TTF_Init

    leave
    ret
GameInit ENDP

GameRender PROC
    push    ebp
    mov     ebp, esp

    push    gRender
    call    SDL_RenderClear
    push    0
    push    0
    push    Background_text
    push    gRender
    call    SDL_RenderCopy
    push    gRender
    call    SDL_RenderPresent

    leave
    ret
GameRender ENDP

GameExit PROC
    ;SDL_DestroyTexture
    push    Background_text
    call    SDL_DestroyTexture
    ;SDL_DestroyWindow
    push    gWindow
    call    SDL_DestroyWindow
    mov     gWindow, 0
    ;SDL_Quit
    call    IMG_Quit
    call    SDL_Quit
    ret
GameExit ENDP

LoadTexture PROC fileptr: ptr DWORD   ;return in eax
    LOCAL   loadedSurface:DWORD
    push    fileptr
    call    IMG_Load
    push    eax
    push    gRender
    call    SDL_CreateTextureFromSurface
    ret
LoadTexture ENDP

end