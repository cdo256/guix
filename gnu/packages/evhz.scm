;;; GNU Guix --- Functional package management for GNU
;;; Copyright © 2024 Christina O'Donnell <cdo@mutix.org>
;;;
;;; This file is part of GNU Guix.
;;;
;;; GNU Guix is free software; you can redistribute it and/or modify it
;;; under the terms of the GNU General Public License as published by
;;; the Free Software Foundation; either version 3 of the License, or (at
;;; your option) any later version.
;;;
;;; GNU Guix is distributed in the hope that it will be useful, but
;;; WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with GNU Guix.  If not, see <http://www.gnu.org/licenses/>.

(define-module (gnu packages evhz)
  #:use-module (guix gexp)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix build-system trivial)
  #:use-module (guix utils)
  #:use-module (gnu packages)
  #:use-module (gnu packages base)
  #:use-module (gnu packages commencement)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages xorg))

(define-public evhz
  (let ((commit "35b7526e0655522bbdf92f6384f4e9dff74f38a0")
        (revision "1"))
      (package
        (name "evhz")
        (version (git-version "0.0.0" revision commit))
        (source (origin
                  (method git-fetch)
                  (uri (git-reference
                        (url "https://git.sr.ht/~iank/evhz")
                        (commit commit)))
                  (sha256
                   (base32
                     "1m2m60sh12jzc8f38g7g67b3avx2vg8ff0lai891jmjqvxw04bcl"))))
        (build-system trivial-build-system)
        (arguments
         `(#:modules ((guix build utils))
           #:builder (begin
                         (use-modules (guix build utils))
                         (let ((source (assoc-ref %build-inputs "source"))
                               (glibc (assoc-ref %build-inputs "glibc"))
                               (gcc (assoc-ref %build-inputs "gcc"))
                               (binutils (assoc-ref %build-inputs "binutils"))
                               (linux-libre-headers (assoc-ref %build-inputs "linux-libre-headers"))
                               (output (assoc-ref %outputs "out")))
                           (setenv "PATH" (string-join
                                           (list (string-append gcc "/bin")
                                                 (string-append binutils "/bin")
                                                 (getenv "PATH"))
                                           ":"))
                           (setenv "LIBRARY_PATH" (string-join
                                                   (list (string-append glibc "/lib"))
                                                   ":"))
                           (mkdir-p (string-append output "/bin"))
                           (invoke (string-append gcc "/bin/gcc")
                                   "-o" (string-append output "/bin/evhz")
                                   "-I" (string-append linux-libre-headers "/include")
                                   (string-append source "/evhz.c"))
                           #t))))
        (native-inputs
         (list binutils
               gcc
               gcc-toolchain
               glibc
               linux-libre-headers))
        (home-page "https://git.sr.ht/~iank/evhz")
        (synopsis "Show mouse refresh rate under linux + evdev.")
        (description
         "A simple diagnostic utility to show mouse refresh rate under linux +
evdev.")
        (license license:apsl2))))
