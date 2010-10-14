#lang racket/base

(require
 rackunit
 "parse.rkt")

(define/provide-test-suite parse-tests
  (test-case
   "parse-form"
   (check-equal?
    (parse-form "ADD reg/mem32 reg32 01 /r")
    (list (Form (list Any32 Any32) (list #x01 (ModRM '$2 '$1)))
          (Form (list (Ref Any32) Any32) (list #x01 (ModRM '$2 '$1)))))))