(use-modules
  (gnu packages base)            ; which
  (gnu packages virtualization)  ; qemu-aarch64
  (guix profiles))

(packages->manifest
  (list qemu which))
