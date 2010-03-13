#lang scheme/base

;; Integer (aka general purpose) IA-32 instructions

(require
 "instruction.ss"
 "register.ss"
 "reference.ss")

(define-instruction (add dest src)
  [(register? register?) (instruction (opcode #x03) (modr/m-std dest src))]
  [(register? reference?) (instruction (opcode #x03) (modr/m-std dest src))])

(define-instruction (int vec)
  [(imm8?) (instruction (opcode #xcd) (imm8 vec))])

(define-instruction (mov dest src)
  [(register?  register?)  (instruction (opcode #x89) (modr/m-std src dest))]
  [(reference? register?)  (instruction (opcode #x89) (modr/m-std src dest))]
  [(register?  reference?)   (instruction (opcode #x8b) (modr/m-std dest src))]
  [(register?  imm32?) (instruction (opcode+register #xb8 dest) (imm32 src))]
  [(reference? imm32?) (instruction (opcode #xc7) (modr/m #b11 0 dest) (imm32 src))])

(define-instruction (pop dest)
  [(register?)  (instruction (opcode+register #x58 dest))]
  [(reference?) (instruction (opcode #x8f) (modr/m #b00 0 dest))])

(define-instruction (push src)
  [(register?)  (instruction (opcode+register #x50 src))]
  [(reference?) (instruction (opcode #xff) (modr/m #b00 6 src))]
  [(imm32?)     (instruction (opcode #x68) (imm32 src))])

;; For now this is just a near return
(define-instruction (ret)
  [() (instruction (opcode #xc3))])

;; For now just a near jump, and we only support register, 32- and 8-bit offsets
(define-instruction (jmp disp)
  [(register?) (instruction (opcode #xff) (modr/m-std 4 disp))]
  [(immu8?) (instruction (opcode #xeb) (immu8 disp))]
  [(imm32?) (instruction (opcode #xe9) (imm32 disp))])

(provide
 (all-defined-out))