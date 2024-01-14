;;; GNU Guix --- Functional package management for GNU
;;; Copyright © 2013, 2014 Andreas Enge <andreas@enge.fr>
;;; Copyright © 2014, 2015, 2017, 2018, 2020 Mark H Weaver <mhw@netris.org>
;;; Copyright © 2014, 2015 Eric Bavier <bavier@member.fsf.org>
;;; Copyright © 2015-2022 Ludovic Courtès <ludo@gnu.org>
;;; Copyright © 2015 Eric Dvorsak <eric@dvorsak.fr>
;;; Copyright © 2016 Mathieu Lirzin <mthl@gnu.org>
;;; Copyright © 2015 Cyrill Schenkel <cyrill.schenkel@gmail.com>
;;; Copyright © 2016, 2017, 2019-2023 Efraim Flashner <efraim@flashner.co.il>
;;; Copyright © 2016 Nikita <nikita@n0.is>
;;; Copyright © 2016 Alex Kost <alezost@gmail.com>
;;; Copyright © 2016 David Craven <david@craven.ch>
;;; Copyright © 2016, 2017 John Darrington <jmd@gnu.org>
;;; Copyright © 2017-2022 Marius Bakke <marius@gnu.org>
;;; Copyright © 2017, 2018, 2019 Rutger Helling <rhelling@mykolab.com>
;;; Copyright © 2017, 2020 Arun Isaac <arunisaac@systemreboot.net>
;;; Copyright © 2018–2022 Tobias Geerinckx-Rice <me@tobias.gr>
;;; Copyright © 2018 Kei Kebreau <kkebreau@posteo.net>
;;; Copyright © 2018, 2020, 2022 Oleg Pykhalov <go.wigust@gmail.com>
;;; Copyright © 2018 Benjamin Slade <slade@jnanam.net>
;;; Copyright © 2019 nee <nee@cock.li>
;;; Copyright © 2019 Yoshinori Arai <kumagusu08@gmail.com>
;;; Copyright © 2019 Mathieu Othacehe <m.othacehe@gmail.com>
;;; Copyright © 2020 Liliana Marie Prikler <liliana.prikler@gmail.com>
;;; Copyright © 2020 Florian Pelz <pelzflorian@pelzflorian.de>
;;; Copyright © 2020, 2021 Michael Rohleder <mike@rohleder.de>
;;; Copyright © 2020, 2021, 2022, 2023 Maxim Cournoyer <maxim.cournoyer@gmail.com>
;;; Copyright © 2020 Jean-Baptiste Note <jean-baptiste.note@m4x.org>
;;; Copyright © 2021 Matthew James Kraai <kraai@ftbfs.org>
;;; Copyright © 2021 Nicolò Balzarotti <nicolo@nixo.xyz>
;;; Copyright © 2021 Matthew James Kraai <kraai@ftbfs.org>
;;; Copyright © 2021 Brice Waegeneire <brice@waegenei.re>
;;; Copyright © 2021 Matthew James Kraai <kraai@ftbfs.org>
;;; Copyright © 2021 Maxime Devos <maximedevos@telenet.be>
;;; Copyright © 2021 qblade <qblade@protonmail.com>
;;; Copyright © 2021 Lu Hui <luhux76@gmail.com>
;;; Copyright © 2023 Zheng Junjie <873216071@qq.com>
;;; Copyright © 2023 Janneke Nieuwenhuizen <janneke@gnu.org>
;;; Copyright © 2023 John Kehayias <john.kehayias@protonmail.com>
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
                           ;; (setenv "LD_LIBRARY_PATH"
                           ;;         (string-join
                           ;;          (list (string-append glibc "/lib")
                           ;;                (getenv "LD_LIBRARY_PATH"))
                           ;;          ":"))
                           (mkdir-p (string-append output "/bin"))
                           (invoke (string-append gcc "/bin/gcc")
                                   "-o" (string-append output "/bin/evhz")
                                   "-I" (string-append linux-libre-headers "/include")
                                   "-L" (string-append glibc "/lib")
                                   ;; In an attempt to get it working. I know this shouldn't be necessary!
                                   ;; "-l" (string-append glibc "/lib/crt1.o")
                                   ;; "-l" (string-append glibc "/lib/crti.o")
                                   (string-append source "/evhz.c"))
                           #t))))
        (inputs
         (list binutils
               gcc
               gcc-toolchain
               glibc
               linux-libre-headers))
        ;; (native-inputs
        ;;  (list binutils
        ;;        gcc
        ;;        gcc-toolchain
        ;;        glibc
        ;;        linux-libre-headers))
        (home-page "https://git.sr.ht/~iank/evhz")
        (synopsis "Show mouse refresh rate under linux + evdev.")
        (description
         "A simple diagnostic utility to show mouse refresh rate under linux +
evdev.")
        (license license:apsl2))))
