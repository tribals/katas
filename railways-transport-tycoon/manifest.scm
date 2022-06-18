(use-modules
  (guix channels)
  (guix inferior)
  (guix profiles)
  (srfi srfi-1))

(define channels
  (list
    (channel
      (name 'guix)
      (url "https://git.savannah.gnu.org/git/guix.git")
      (branch "master")
      (commit
        "8a04ac4b2f5d356719d896536dabc95a9520c938")
      (introduction
        (make-channel-introduction
          "9edb3f66fd807b096b48283debdcddccfea34bad"
          (openpgp-fingerprint
            "BBB0 2DDF 2CEA F6A8 0D1D  E643 A2A0 6DF2 A33A 54FA"))))))

(define inferior
  (inferior-for-channels channels))

(define (inferior-packages package-name)
  (lookup-inferior-packages inferior package-name))

(packages->manifest
  (map
    (compose first inferior-packages)
    (list
      "dash"
      "coreutils"
      "postgresql")))
