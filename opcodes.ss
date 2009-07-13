#lang scheme/base

;; Based on AMD instruction reference at
;; http://www.amd.com/us-en/assets/content_type/white_papers_and_tech_docs/24594.pdf
;;
;; Intel references at
;; http://www.intel.com/products/processor/manuals/
;;
;; and source for Ikarus Scheme compiler

(require "register.ss")


;; ((U register immediate) register -> (listof byte))
;;
;; Move an immediate value (32-bit) into a register
;; Opcode: B8 +rd id
(define (mov src dest)
  (cond
   [(register? src)
    (list #x89 (modr/m dest src))]
   [else
    (cons (code+register #xB8 dest)
          (immediate src))]))

;; -> (listof byte)
;;
;; Near return
(define (ret)
  (list #xC3))

(define (push dest)
  (list (code+register #x50 dest)))

(define (pop dest)
  (list (code+register #x58 dest)))

;; Interrupt
(define (int value)
  (list #xCD (byte value)))


;;; Utilities to construct op codes

;; number register -> number
;;
;; Constructs an opcode that includes a register
(define (code+register code register)
  (bitwise-ior code (register-code register)))

;; number -> (listof byte)
(define (immediate value)
  (list (byte value)
        (byte (arithmetic-shift value -8))
        (byte (arithmetic-shift value -16))
        (byte (arithmetic-shift value -24))))

(define (modr/m r1 r2)
  (bitwise-ior
   #b11000000
   (arithmetic-shift (register-code r1) 3)
   (register-code r2)))


;; number -> number
;;
;; Returns the lowest 8-bits of a value
(define (byte value)
  (bitwise-and 255 value))


(provide mov
         ret
         push
         pop
         int)