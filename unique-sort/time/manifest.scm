(import
  (gnu packages guile)
  (gnu packages guile-xyz)
  (guix profiles))


(packages->manifest
  (list guile-3.0-latest guile-readline guile-colorized))
