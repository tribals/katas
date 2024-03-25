(import
  (guix profiles)
  (gnu packages guile)
  (gnu packages guile-xyz))


(packages->manifest
  (list
    guile-3.0-latest
    guile-srfi-232))
