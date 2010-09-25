#lang typed/racket

(struct: Instruction ([name : Symbol] [forms : (Listof Form)]))
(struct: Form ([args : (Listof Arg)] [body : (Listof Code)]))
;; There are really ordering constraints between these but it is too tedious to specify them
(define-type-alias Code (U Opcode ModRM))

(define-type-alias Byte Fixnum)
(struct: Opcode ([code : Byte]))

(struct: ModRM ())
(struct: RegReg ModRM ([arg1 : ArgRef] [arg2 : ArgRef]))
(struct: RegRef ModRM ([arg1 : ArgRef] [arg2 : ArgRef]))

(define-type-alias ArgRef (U '$1 '$2))
   
(define-type-alias Arg (U Reg Imm Ref))
(define-type-alias Reg (U Reg8 Reg16 Reg32 Reg64))

;; A Ref is a reference to a memory location the value of which is stored in a register. This is represented in the Intel/AMD docs by reg/memX
(struct: Ref ([reg : Reg]))

(struct: Reg8 ())
(define AL (Reg8))
(define Any8 (Reg8))

(struct: Reg16 ())
(define AX (Reg16))
(define Any16 (Reg16))

(struct: Reg32 ())
(define EAX (Reg32))
(define Any32 (Reg32))

(struct: Reg64 ())
(define RAX (Reg64))
(define Any64 (Reg64))

(struct: Imm ())
(define Imm8 (Imm))
(define Imm16 (Imm))
(define Imm32 (Imm))
(define Imm64 (Imm))

(: parse (String -> Instruction))
(define (parse opcodes)
  (for/list ([ins (in-lines (open-input-string opcodes))])
       (let-values (([name rep] (parse-ins ins)))
         rep)))

(: parse-form (String -> (values String Form)))
(define (parse-form line)
  (define terms (regexp-split #rx" +" line))
  ;; The form of the instruction should be
  ;;   arg1 arg2 opcode [modifier] [value]
  (match terms
         [(list name (? ->arg arg1) (? ->arg arg2) (? ->opcode op) ???)
          (assert (instruction-name name))
          (make-Form (list arg1 arg2) ...)]))

(: check-name (String -> (Option String)))
(define (instruction-name str)
  (if (regexp-match #rx"^[A-Z]+$" str)
      str
      #f))

(: ->arg (String -> (Option Arg)))
(define (->arg str)
  (match str
   ["AL" AL]
   ["AX" AX]
   ["EAX" EAX]
   ["RAX" RAX]
   ["reg/mem8" (Ref Any8)]
   ["reg/mem16" (Ref Any16)]
   ["reg/mem32" (Ref Any32)]
   ["reg/mem64" (Ref Any64)]
   ["reg8" Any8]
   ["reg16" Any16]
   ["reg32" Any32]
   ["reg64" Any64]
   ["imm8" Imm8]
   ["imm16" Imm16]
   ["imm32" Imm32]
   ["imm64" Imm64]))
