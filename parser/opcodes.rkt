#lang scheme/base

(provide
 opcodes)

(define add
  (parse
  #<<END
ADD AL imm8         04 ib    
ADD AX imm16        05 iw    
ADD EAX imm32       05 id    
ADD RAX imm32       05 id    
ADD reg/mem8 imm8   80 /0 ib 
ADD reg/mem16 imm16 81 /0 iw 
ADD reg/mem32 imm32 81 /0 id 
ADD reg/mem64 imm32 81 /0 id 
ADD reg/mem16 imm8  83 /0 ib 
ADD reg/mem32 imm8  83 /0 ib 
ADD reg/mem64 imm8  83 /0 ib 
ADD reg/mem8 reg8   00 /r    
ADD reg/mem16 reg16 01 /r    
ADD reg/mem32 reg32 01 /r    
ADD reg/mem64 reg64 01 /r    
ADD reg8 reg/mem8   02 /r    
ADD reg16 reg/mem16 03 /r    
ADD reg32 reg/mem32 03 /r    
ADD reg64 reg/mem64 03 /r    

END
)