(import
  (guix profiles)
  (guix transformations)
  (ice-9 match)
  (only (gnu packages clojure) clojure-tools)
  (only (gnu packages java) icedtea-8)
  (only (gnu packages node) node-lts)
  (only (guix utils) %current-system))


(packages->manifest
  (list
    node-lts
    icedtea-8
    (match (%current-system)
      ("aarch64-linux"
        (let ((with-my-java-xz
                (options->transformation '((with-input . "java-xz=java-xz")))))
          ; prevent building of openjdk@9
          (with-my-java-xz clojure-tools)))
      (_ clojure-tools))))
