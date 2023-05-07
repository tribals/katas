(import
  (guix profiles)
  (only (gnu packages node) node-lts)
  (only (gnu packages java) openjdk11)
  (only (gnu packages clojure) clojure-tools))


(packages->manifest
  (list
    node-lts
    openjdk11
    clojure-tools))
