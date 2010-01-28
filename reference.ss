#lang scheme/base

;; We don't support scale+index+base addressing at this point, or 8- and 32-bit offsets.
;; At the moment a reference is only a value stored in a register

(define-struct reference (register))

(define ref make-reference)

(provide
 (struct-out reference)
 ref)