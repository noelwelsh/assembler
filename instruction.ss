#lang scheme/base

(require
 (planet untyped/unlib/parameter)
 "register.ss"
 "reference.ss"

 (for-syntax scheme/base))


;; imm32? : Any -> Boolean
;;
;; A 32-bit immediate value
(define (imm32? x)
  ;; This might limit precision to 31 bits (on a 32-bit platform)
  (exact-integer? x))

;; imm8? : Any -> Boolean
(define (imm8? x)
  (and (exact-integer? x) (<= 0 x 255)))

(define-syntax (define-instruction stx)
  (syntax-case stx ()
    [(define-instruction (name arg ...)
       [(pred ...) expr] ...)
     (syntax
      (define (name arg ...)
        (cond
         [(and (pred arg) ...) expr] ...
         [else
          (raise-type-error 'name
                            "No arguments matched opcode predicates"
                            (list arg ...))])))]))

(define-parameter current-assembler-port
  (open-output-bytes)
  (make-guard output-port? "output-port?")
  with-current-assembler-port)

(define-syntax-rule (instruction expr ...)
  (begin expr ...))

(define (opcode code)
  (write-byte code (current-assembler-port)))

(define (opcode+register code reg)
  (write-byte (bitwise-ior code (register-code reg))
              (current-assembler-port)))

(define (modr/m code reg r/m)
  (write-byte
   (bitwise-ior (arithmetic-shift code 6)
                (arithmetic-shift
                 (cond
                  [(register? reg)  (register-code reg)]
                  [(reference? reg) (register-code (reference-register reg))]
                  [else reg])
                 3)
                (cond
                 [(register? r/m)  (register-code r/m)]
                 [(reference? r/m) (register-code (reference-register r/m))]
                 [else reg]))
   (current-assembler-port)))

;; Register (U Register Reference) -> Void
;;
;; Implement standard ModR/M where the code determines addressing mode. Only references without displacements are currently implemented.
(define (modr/m-std reg r/m)
  (if (register? r/m)
      (modr/m #b11 reg r/m)
      (modr/m #b00 reg r/m)))

;; Integer -> Void
(define (imm32 value)
  (write-bytes (integer->integer-bytes value 4 #t) (current-assembler-port)))

;; Integer -> Void
(define (imm8 value)
  (write-byte value (current-assembler-port)))

(provide
 (all-defined-out))