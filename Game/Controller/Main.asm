.386
.model flat, stdcall
option casemap:none

include .\include\GameSdk.inc
include .\include\Main.inc

.data
Caption          BYTE "Assembly-Language-Beast", 0
Font_gloria      BYTE "Fonts/GloriaHallelujah.ttf", 0
Font_Rationale   BYTE "Fonts/Rationale-Regular.ttf", 0
Font_Indie       BYTE "Fonts/IndieFlower.ttf", 0
MUS_BGM          BYTE "res/audio/bgm/CampFire.wav", 0
Cusor_SE         BYTE "res/audio/se/Cursor1.wav", 0
Icon             BYTE "res/img/icon.png", 0
Loading          BYTE "res/img/system/Loading.png", 0
Musicfile   BYTE "res/audio/bgm/Dungeon2.wav", 0

playing          DWORD 0
Currentoption    DWORD 0

S_GAMESTART      BYTE "New Game", 0
S_GAMEEXIT       BYTE "Exit", 0

GameQuit         BYTE  0
Literal_one      BYTE "1", 0
SDL_HINT_RENDER_SCALE_QUALITY  BYTE "SDL_HINT_RENDER_SCALE_QUALITY", 0

CurrentKeystate     DWORD ?  
gWindow             DWORD ?
gFont               DWORD ?
gFont_Ration        DWORD ?
gFont_Indie         DWORD ?
gRender             DWORD ?
gMusic              DWORD ?
SE_Cusor            DWORD ?
DMusic      DWORD ?

WorldMap            BYTE MAP_BLOCKS_X*MAP_BLOCKS_Y DUP (?)
Camera              SDL_Rect { 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT }

.code
SDL_main PROC
    ;LOCAL will do the prologue & !!!!epilogue!!!! for you
    LOCAL   startTime:DWORD
    LOCAL   delta:DWORD
    ;init
    mov     delta, 0
    call    GameInit
    ;TimerStart
    call    SDL_GetTicks
    mov     startTime, eax
    ;this is the game loop
    .WHILE !GameQuit
        call    SDL_GetTicks
        mov     ebx, eax
        sub     eax, startTime  
        add     delta, eax      ;delta += currentTime - startTime
        mov     startTime, ebx  ; startTime = currentTime
        .IF delta > UPDATE_MSEC
            call    GameUpdate
            call    GameRender
            sub     delta, UPDATE_MSEC
        .ENDIF
    .ENDW
    ;GameExit
    call    GameExit

    ret
SDL_main ENDP

LoadMedia PROC
    push    ebp
    mov     ebp, esp

    invoke  FontLoader, addr Font_gloria, addr gFont
    invoke  FontLoader, addr Font_Rationale, addr gFont_Ration
    invoke  FontLoader, addr Font_Indie, addr gFont_Indie
    invoke  MusicLoader, addr gMusic,addr MUS_BGM, AUDIO_MUSIC

    invoke  MusicLoader, addr SE_Cusor, addr Cusor_SE, AUDIO_WAV

    ;play   background music
    invoke  MusicPlayer, gMusic, AUDIO_MUSIC

    leave
    ret
LoadMedia ENDP  

GameUpdate PROC
    LOCAL   event[56]:BYTE
    
    PollLoop:
    lea     eax, event
    push    eax
    call    SDL_PollEvent
    test    eax, eax    ;test if eax equ 0
    setne   al          ;if eax equ zero, set al 
    test    al, al      ;test if al has been set or not
    je      GameUpdate_end     ;if al has been set, break loop
    mov     eax, DWORD ptr event  
    ;if event == SDL_QUIT, then quit = true
    cmp     eax, SDL_QUIT
    sete    GameQuit
    ;SDL_GetKeyboardState
    push    0
    call    SDL_GetKeyboardState
    mov     CurrentKeystate, eax
    NextEvent:                  
    jmp     PollLoop    ;go back to deal with next event
    GameUpdate_end:
    ;Update 
    call    StateTickTock
    ret
GameUpdate ENDP

GameRender PROC
    push    ebp
    mov     ebp, esp

    ;SDL_RenderClear
    push    gRender
    call    SDL_RenderClear
    ;Render to the screen
    call    StateRender
    ;SDL_RenderPresent
    push    gRender
    call    SDL_RenderPresent

    leave
    ret
GameRender ENDP

GameInit PROC
    push    ebp
    mov     ebp, esp

    ;SDL_Init
    mov     eax, SDL_INIT_VIDEO
    or      eax, SDL_INIT_AUDIO 
    push    eax
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
    ;SDL_SetWindowIcon
    push    offset Icon
    call    IMG_Load
    push    eax
    push    gWindow
    call    SDL_SetWindowIcon
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
    ;Mix_OpenAudio
    push    2048
    push    2
    push    MIX_DEFAULT_FORMAT
    push    44100
    call    Mix_OpenAudio
    ;load iamge
    call    LoadMedia
    ;Init State Card
    call    State_Init 
    leave
    ret
GameInit ENDP

GameExit PROC
    ;SDL_DestroyTexture
    ;push    offset BackgroundTexture
    ;call    SDL_DestroyTexture
    ;SDL_DestroyWindow
    push    gWindow
    call    SDL_DestroyWindow
    mov     gWindow, 0
    ;SDL_Quit
    call    IMG_Quit
    call    SDL_Quit
    ret
GameExit ENDP
end