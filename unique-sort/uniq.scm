(import
  (srfi srfi-1)
  (srfi srfi-64)
  (spec runner))


; srfi-1 doesn't have one, just for clarity...
(define rest cdr)


(define (uniq lst)
  (if (nil? lst)
    lst
    (let loop ((needle (first lst))
               (lst (rest lst))
               (result '()))
      (if (nil? lst)
        (reverse (cons needle result))  ; weird are FP programmers those
        (let ((next (first lst))
              (tail (rest lst)))
          (if (= next needle)
            (loop needle tail result)
            (loop next tail (cons needle result))))))))


(install-spec-runner-term)


(test-begin "Uniquely sorted lists")

(test-group "Simple examples"
  (test-equal "Sorted list contains no more same numbers"
    (list -11 1 7 17 42 101 177)
    (uniq (sort (list 1 42 -11 17 7 1 177 101 101) <)))

  (test-equal
    (list)
    (uniq '()))

  (test-equal
    (list 1)
    (uniq '(1)))

  (test-equal
    (list 1)
    (uniq '(1 1)))

  (test-equal
    (list 1 7)
    (uniq (sort '(7 1 1) <)))

  (test-equal
    (list 1 7)
    (uniq (sort '(1 7 1 1) <)))

  (test-equal
    (list -3 1)
    (uniq (sort '(1 -3 1 -3 1) <))))

(test-end)
