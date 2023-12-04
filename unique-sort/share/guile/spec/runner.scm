; https://framagit.org/Jeko/guile-spec/-/blob/master/spec/runner.scm

(define-module (spec runner)
  #:use-module (ice-9 format)
  #:use-module (srfi srfi-64)
  #:use-module (srfi srfi-26)
  #:use-module (ice-9 pretty-print)
  #:export (install-spec-runner-term)
       install-spec-runner-rep)

(define (install-spec-runner-repl)
  (let ((spec-runner (test-runner-null)))
    (test-runner-on-group-begin! spec-runner test-on-test-begin-spec)
    (test-runner-on-test-end! spec-runner test-on-test-end-spec)
    (test-runner-factory (lambda () spec-runner))))

(define (install-spec-runner-term)
  (let ((spec-runner (test-runner-null)))
    (test-runner-on-group-begin! spec-runner test-on-test-begin-spec)
    (test-runner-on-test-end! spec-runner test-on-test-end-spec)
    (test-runner-on-final! spec-runner (test-on-test-final-spec))
    (test-runner-factory (lambda () spec-runner))))

(define (test-on-test-end-spec runner)
  (let* ((results (test-result-alist runner))
         (result? (cut assq <> results))
         (result  (cut assq-ref results <>)))
    (if (equal? 'fail (result 'result-kind))
	(begin
	  (format #t "~v_~a ~A~%"
		  (+ 1 (string-length START_PREFIX))
		  (result->string (result 'result-kind))
		  (result 'test-name))
	  (when (result? 'expected-value)
            (test-display "expected-value" (result 'expected-value)))
	  (when (result? 'expected-error)
            (test-display "expected-error" (result 'expected-error) #:pretty? #t))
	  (when (result? 'actual-value)
            (test-display "actual-value" (result 'actual-value)))
	  (when (result? 'actual-error)
	    (test-display "actual-error" (result 'actual-error) #:pretty? #t)))
	(begin
	  (format #t "~v_~a ~A~%"
		  (+ 1 (string-length START_PREFIX))
		  (result->string (result 'result-kind))
		  (result 'test-name))))))

(define (test-on-test-begin-spec runner suite-name count)
  (if (null? (test-runner-group-stack runner))
      (begin
	(display suite-name)
	(newline))
      (begin
	(if (not (string-null? (test-runner-test-name runner)))
	    (begin
	      (display (string-append "- " (test-runner-test-name runner)))
	      (newline))))))

(define (test-on-test-final-spec)
  (lambda (runner)
    (exit (+ (test-runner-fail-count runner)
             (test-runner-xfail-count runner)))))


(define START_PREFIX "%%%%")

(define* (test-display field value  #:optional (port (current-output-port))
                       #:key pretty?)
  "Display 'FIELD: VALUE\n' on PORT."
  (if pretty?
      (begin
        (format port "~v_~A:~%"
		(+ 1 (string-length START_PREFIX))
		field)
        (pretty-print value port #:per-line-prefix "+ "))
      (format port "~v_~A: ~S~%"
	      (+ 6 (string-length START_PREFIX))
	      field
	      value)))

(define* (result->string symbol)
  "Return SYMBOL as an upper case string.  Use colors when COLORIZE is #t."
  (let ((result (string-upcase (symbol->string symbol))))
    (string-append (case symbol
                     ((pass)       "[0;32m")  ;green
                     ((xfail)      "[1;32m")  ;light green
                     ((skip)       "[1;34m")  ;blue
                     ((fail xpass) "[0;31m")  ;red
                     ((error)      "[0;35m")) ;magenta
                   result
                   "[m")))
