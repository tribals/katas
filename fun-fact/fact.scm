(import
  (ice-9 match)
  (srfi srfi-64)
  (srfi srfi-232))


(define-curried (fact acc n)
  (match n
    ((or 0 1) acc)
    ((and (? positive?)
          (? integer?))
     (fact (* acc n) (1- n)))))


(test-begin "Factorial")

(define factorial (fact 1))

(test-equal "0!" (factorial 0) 1)
(test-equal "1!" (factorial 1) 1)
(test-equal "5!" (factorial 5) 120)
(test-error "defined on non-negative" 'match-error (factorial -7))
(test-error "integers" 'match-error (factorial 3.14))

(test-end)
