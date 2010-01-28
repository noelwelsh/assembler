#lang scheme/base

(require
 (planet schematics/schemeunit:3/test)
 "nasm-test.ss")

(define/provide-test-suite all-tests
  nasm-tests
  )