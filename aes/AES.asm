; state is 16 bytes
; optimization purposes probably needs it to be absolute
; stored in column major order
; probably shouldn't cross page boundary
!state = $0100

; lets say something like 16 bytes of scratch ram
; probably needs to be DP because addressing modes
!scratch = $00
; shorthand because lazy
!_ := !scratch

; 240 bytes for the key expansion thing
!keybuffer = $0110

; 16 bytes, used as buffer for IV/last block in CBC
!iv = $0200

; usage:
;   ECB mode:
;     Init: JSR KeyExpansion
;     Encrypt: write 16 bytes to !state, JSR Cipher (output in !state)
;     Decrypt: write 16 bytes to !state, JSR InvCipher (output in !state)
;   CBC mode:
;     Init: JSR KeyExpansion, write IV to !iv
;     Encrypt: JSR CBCEncrypt_PKCS7
;     Decrypt: JSR CBCDecrypt, then JSR CheckPKCS7Padding to check padding
;   CTR mode:
;     Init: JSR KeyExpansion, write IV to !iv. If you have a 64-bit IV, write it to the low 8 bytes and clear the rest to get the effect of concat-ing a 64-bit IV with a 64-bit block counter
;     Encrypt/Decrypt: JSR CTRxcrypt

incsrc SubBytes.asm
incsrc ShiftRows.asm
incsrc MixColumns.asm
incsrc InvMixColumns.asm
incsrc KeyExpansion.asm
incsrc AddRoundKey.asm
incsrc Cipher.asm
incsrc SBox.asm
incsrc CBCEncrypt.asm
incsrc CBCDecrypt.asm
incsrc CTR.asm
