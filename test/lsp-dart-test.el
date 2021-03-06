;;; lsp-dart-test.el --- Tests for lsp-dart.el

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; Tests for lsp-dart.el

;;; Code:

(require 'lsp-dart)
(require 'el-mock)

(ert-deftest lsp-dart--library-folders--non-lib-file-test ()
  (with-mock
    (stub lsp-dart-get-sdk-dir => "/sdk")
    (stub buffer-file-name => "/project/main.dart")
    (should (equal (lsp-dart--library-folders) '()))))

(ert-deftest lsp-dart--library-folders--lib-file-test ()
  (with-mock
    (stub lsp-dart-get-sdk-dir => "/sdk")
    (stub buffer-file-name => "/sdk/lib/main.dart")
    (should (equal (lsp-dart--library-folders) '("/sdk/lib/")))))

(ert-deftest lsp-dart--library-folders--extra-folder-test ()
  (with-mock
    (stub lsp-dart-get-sdk-dir => "/sdk")
    (stub buffer-file-name => "/project/main.dart")
    (let ((lsp-dart-extra-library-directories '("/some/lib/")))
      (should (equal (lsp-dart--library-folders) '("/some/lib/"))))))

(ert-deftest lsp-dart--library-folders--extra-folder-and-lib-file-test ()
  (with-mock
    (stub lsp-dart-get-sdk-dir => "/sdk")
    (stub buffer-file-name => "/sdk/lib/main.dart")
    (let ((lsp-dart-extra-library-directories '("/some/lib/")))
      (should (equal (lsp-dart--library-folders) '("/sdk/lib/" "/some/lib/"))))))

(ert-deftest lsp-dart--server-command--custom-test ()
  (let ((lsp-dart-server-command "/some/path/to/server"))
    (should (equal (lsp-dart--server-command) "/some/path/to/server"))))

(ert-deftest lsp-dart--server-command--default-test ()
  (with-mock
    (stub lsp-dart-dart-command => "/sdk/bin/dart")
    (stub lsp-dart-get-sdk-dir => "/sdk")
    (should (equal (lsp-dart--server-command)
                   '("/sdk/bin/dart"
                     "/sdk/bin/snapshots/analysis_server.dart.snapshot"
                     "--lsp")))))

(ert-deftest lsp-dart--handle-analyzer-status--when-analyzing-test ()
  (with-mock
    (mock (lsp-dart-workspace-status "Analyzing project..." "workspace"))
    (lsp-dart--handle-analyzer-status "workspace" (lsp-make-analyzer-status-notification :is-analyzing t))))

(ert-deftest lsp-dart--handle-analyzer-status--when-not-analyzing-test ()
  (with-mock
    (mock (lsp-dart-workspace-status nil "workspace"))
    (lsp-dart--handle-analyzer-status "workspace" (lsp-make-analyzer-status-notification :is-analyzing nil))))

(ert-deftest lsp-dart-version--test ()
  (let ((pkg-version (lsp-dart-test-package-version "lsp-dart.el")))
    (with-mock
     (stub lsp-dart-get-full-dart-version => "2.8.2")
     (should (equal (lsp-dart-version) (format "[LSP Dart] %s at %s @ Emacs %s\n[Dart SDK] 2.8.2"
                                               pkg-version
                                               (format-time-string "%Y.%m.%d" (current-time))
                                               emacs-version))))))

;;; lsp-dart-test.el ends here
