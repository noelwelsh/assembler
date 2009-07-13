#lang scheme/base

;; register : symbol number number
;;
;; Name is the common name of the regiseter. E.g. eax
;; Width is the width in bits of the register
;; Code is the value emitted in assembler to denote this register
(define-struct register (name width code))

(define eax (make-register 'eax 32 0))
(define ecx (make-register 'eax 32 1))
(define edx (make-register 'eax 32 2))
(define ebx (make-register 'eax 32 3))

(define esp (make-register 'esp 32 4))
(define ebp (make-register 'ebp 32 5))
(define esi (make-register 'esi 32 6))
(define edi (make-register 'edi 32 7))

(provide
 (struct-out register)
 eax ecx edx ebx
 esp ebp esi edi)