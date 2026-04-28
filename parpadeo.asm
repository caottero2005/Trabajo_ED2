LIST P=16F887
include "p16f887.inc"
__CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_ON & _MCLRE_ON & _CP_OFF
__CONFIG _CONFIG2, _BOR40V & _WRT_OFF
    
  
CONTADOR1 EQU 0x23 
CONTADOR2 EQU 0x24
CONTADOR3 EQU 0x25
 
 
   ORG 0x00
   GOTO _INICIO
 
      ORG 0x05
 
     _INICIO BCF    STATUS, RP1   
             BSF    STATUS, RP0 ; Pasamos al Banco 1
	
	     CLRF TRISC 
	
	BCF    STATUS, RP0    ; Pasamos al Banco 0
        BCF    STATUS, RP1 
	
    RUTINA_PRINCIPAL  MOVLW 0XFF 
    MOVWF CONTADOR1
    MOVWF CONTADOR2
    MOVLW 0X05
    MOVWF CONTADOR3
    
    RETARDO1  DECFSZ CONTADOR1,1 
    GOTO RETARDO1
    MOVLW 0XFF
    MOVWF CONTADOR1
    
    RETARDO2 DECFSZ CONTADOR2,1 
    GOTO RETARDO1 
    MOVLW 0XFF 
    MOVWF CONTADOR2 
    
    RETARDO3 DECFSZ CONTADOR3,1
    GOTO RETARDO1 
    
    BTFSS PORTC,1 
    GOTO _SET
    BTFSC PORTC,1 
    GOTO _RESET 
    
    _RESET BCF PORTC,1 
    GOTO RUTINA_PRINCIPAL 
    _SET BSF PORTC,1 
    GOTO RUTINA_PRINCIPAL 


 END

Parpadeo con 2 frecuencias distintas 1 más lenta y 0 mas rapida)teniendo a RC4 como entrada)

;-------------------------------
; ENCABEZADO
;-------------------------------
LIST P=16F887              ; Define el microcontrolador
#include "p16f887.inc"     ; Incluye librerías del PIC

__CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_ON & _MCLRE_ON & _CP_OFF ; Configuración general
__CONFIG _CONFIG2, _BOR40V & _WRT_OFF ; Más configuración

CONTADOR1 EQU 0x23         ; Variable en memoria
CONTADOR2 EQU 0x24
CONTADOR3 EQU 0x25

;-------------------------------
; INICIO DEL PROGRAMA
;-------------------------------
ORG 0x00                   ; Dirección de inicio
GOTO MAIN                  ; Salta a MAIN

ORG 0x05                   ; (vector de interrupción, no usado)

;-------------------------------
; CONFIGURACIÓN
;-------------------------------
MAIN
BSF STATUS,RP0             ; Ir a Banco 1
BCF STATUS,RP1

MOVLW b'00010000'          ; RC4 entrada, resto salida
MOVWF TRISC                ; Configura puerto C

BCF STATUS,RP0             ; Volver a Banco 0
BCF STATUS,RP1

;-------------------------------
; BUCLE PRINCIPAL
;-------------------------------
RUTINA_PRINCIPAL

BTFSC PORTC,4              ; Lee RC4
GOTO LENTO                 ; Si RC4 = 1 → lento
GOTO RAPIDO                ; Si RC4 = 0 → rápido

;-------------------------------
; RETARDO LENTO
;-------------------------------
LENTO
MOVLW 0xFF
MOVWF CONTADOR1            ; C1 = 255
MOVWF CONTADOR2            ; C2 = 255
MOVLW 0x05
MOVWF CONTADOR3            ; C3 = 5

RETARDO1
DECFSZ CONTADOR1,1         ; C1--
GOTO RETARDO1              ; Repite hasta 0
MOVLW 0xFF
MOVWF CONTADOR1            ; Reinicia C1

RETARDO2
DECFSZ CONTADOR2,1         ; C2--
GOTO RETARDO1              ;  vuelve a RETARDO1 (delay más largo)
MOVLW 0xFF
MOVWF CONTADOR2            ; Reinicia C2

RETARDO3
DECFSZ CONTADOR3,1         ; C3--
GOTO RETARDO1              ; Vuelve a empezar ciclo

GOTO TOGGLE                ; Termina delay → cambia LED

;-------------------------------
; RETARDO RÁPIDO
;-------------------------------
RAPIDO
MOVLW 0xFF
MOVWF CONTADOR1            ; C1 = 255
MOVWF CONTADOR2            ; C2 = 255

RETARDO_R
DECFSZ CONTADOR1,1         ; C1--
GOTO RETARDO_R             ; Loop
DECFSZ CONTADOR2,1         ; C2--
GOTO RETARDO_R             ; Loop más corto que lento

GOTO TOGGLE                ; Termina delay

;-------------------------------
; CAMBIO DE ESTADO DEL LED
;-------------------------------
TOGGLE
BTFSS PORTC,1              ; ¿LED apagado?
GOTO _SET                  ; Sí → prender
GOTO _RESET                ; No → apagar

_RESET
BCF PORTC,1                ; Apaga LED
GOTO RUTINA_PRINCIPAL      ; Vuelve al inicio

_SET
BSF PORTC,1                ; Enciende LED
GOTO RUTINA_PRINCIPAL      ; Vuelve al inicio

END                        ; Fin del programa

