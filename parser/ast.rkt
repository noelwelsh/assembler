#lang typed/racket

;; AST for describing ia32 and x86-64 assembler
;;
;; An assembly instruction is a function from typed
;; arguments to an encoding as a sequence of bytes. We
;; represent instructions declaratively, so later stages can
;; construct assemblers or disassemblers as desired. This
;; file contains the datastructures we use to represent
;; instructions.

;; An instruction is a group of forms that share the same
;; name E.g. ADD is an instruction, which is encoded in
;; many different ways (the different forms) depending on
;; the argument types.
(struct: Instruction ([name : Symbol] [forms : (Listof Form)]))

;; A form is a particular instance of an instruction
(struct: Form ([args : (Listof Arg)] [body : (Listof Code)]))

(define-type-alias Arg (U Reg Imm Ref))

(define-type-alias Reg (U Reg8 Reg16 Reg32 Reg64))

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

;; A Ref is an indirection via a register containing the
;; address of a memory location. This is represented in the
;; Intel/AMD docs by reg/memX. We don't encode all the
;; possible addressing modes (well, I don't think we do) as
;; it's too much craziness to process right now. Maybe
;; later.
(struct: Ref ([reg : Reg]))

;; In reality the Code forms must occur in a set order, but
;; encoding this ordering is tedious. For now we don't
;; bother.
(define-type-alias Code (U Opcode ModRM))

;; An opcode is actually a byte
(define-type-alias Opcode Fixnum)

;; The ModRM byte. This encoding is incomplete. It will be
;; extended as we run into instructions that demand it.
(struct: ModRM ([arg1 : ArgRef] [arg2 : ArgRef]))

(define-type-alias ArgRef (U '$1 '$2))

(provide
 (all-defined-out))