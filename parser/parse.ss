#lang typed/scheme

(require
 (planet dherman/types:2))

(define-struct: Instruction ([name : Symbol] [forms : (Listof Form)]))
(define-struct: Form ([args : (Listof Arg)] [body : (Listof Code)]))
;; There are really ordering constraints between these but it is too tedious to specify them
(define-type-alias Code (U Opcode ModRM))

(define-type-alias Byte Natural)
(define-struct Opcode ([code : Byte]))
(define-datatype ModRM
  ([RegReg ([arg1 : ArgRef] [arg2 : ArgRef])]
   [RegRef ([arg1 : ArgRef] [arg2 : ArgRef])]))

(define-type-alias ArgRef (U '$1 '$2))
   
(define-type-alias Arg (U Reg Imm Ref))
(define-type-alias Reg (U Reg8 Reg16 Reg32 Reg64))

;; A Ref is a reference to a memory location the value of which is stored in a register. This is represented in the Intel/AMD docs by reg/memX
(define-struct Ref ([reg : Reg]))
  
(define-datatype Reg8
  [AL    #:constant al]
  [Any8  #:constant reg8])

(define-datatype Reg16
  [AX    #:constant ax]
  [Any16 #:constant reg16])

(define-datatype Reg32
  [EAX   #:constant eax]
  [Any32 #:constant reg32])

(define-datatype Reg64
  [RAX   #:constant rax]
  [Any64 #:constant reg64])
 

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
  