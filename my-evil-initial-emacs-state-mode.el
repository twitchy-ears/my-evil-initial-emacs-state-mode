;;; my-evil-initial-emacs-state-mode.el --- Attempts to reliably enforce emacs mode as an initial state in buffers -*- lexical-binding: t -*-

;; Copyright 2025 - Twitchy Ears

;; Author: Twitchy Ears https://github.com/twitchy-ears/
;; URL: https://github.com/twitchy-ears/my-evil-initial-emacs-state-mode
;; Version: 0.1
;; Package-Requires ((emacs "30.1"))
;; Keywords: mode evil

;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 3, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth
;; Floor, Boston, MA 02110-1301, USA.

;;; History
;;
;; 2025-08-11 Initial version.

;;; Commentary:
;;
;; This hack exists because (evil-set-initial-state 'X 'emacs) is
;; sometimes flakey and doesn't seem to work for certain modes for
;; reasons I haven't managed to clear up.
;; 
;; You'd think you could use these sorts of tricks but none of these
;; work well either in some circumstances:
;; 
;; (add-hook 'evil-mode-hook 'my-evil-initial-emacs-state 100)
;; (add-hook 'after-change-major-mode-hook 'my-evil-initial-emacs-state 100)
;; (advice-add 'evil-mode-enable-in-buffer :after #'my-evil-initial-emacs-state)
;;
;; Is it named like something you'd find in a Windows 95 system of
;; like "My Recycle Bin", absolutely yes because this is weird bodge
;; code that shouldn't exist.
;;
;; So yeah, use it something like this:
;;
;; (use-package my-evil-initial-emacs-state-mode
;;   :after (evil major-mode-change-watcher-mode)
;;   :config
;;   (my-evil-initial-emacs-state-mode t))
;;
;; ;; An example drawn from complete whole cloth obvously and not an actual example: 
;; (when (intern-soft 'my-evil-initial-emacs-state-modes)
;;   (add-to-list 'my-evil-initial-emacs-state-modes 'wl-summary-mode)
;;   (add-to-list 'my-evil-initial-emacs-state-modes 'wl-folder-mode)
;;   (add-to-list 'my-evil-initial-emacs-state-modes 'mime-view-mode)))

(require 'major-mode-change-watcher-mode)

(defvar my-evil-initial-emacs-state-mode-debug
  nil
  "Controls debugging messages")

(defvar my-evil-initial-emacs-state-mode-after-hook
  nil
  "Runs after mode activated/deactivated")

(defvar my-evil-initial-emacs-state-modes
  '()
  "List of major-mode variable settings that will have the emacs initial state forced on them in a more reliable manner than evil-set-initial-state")

(defun my-evil-initial-emacs-state-enforcer (newmode oldmode type where)
  "Forces emacs mode via watching the major-mode variable

Takes a list of major modes and forces emacs mode after switching to
 that because evil-set-initial-mode is sometimes obtuse"
  (if (and evil-mode
           (equal type 'set))
      
      ;; If we're setting the variable and we're in evil mode already
      ;; then check what major-mode we're switching to to force the
      ;; issue.
      (if (member newmode my-evil-initial-emacs-state-modes)
          (progn
            (when my-evil-initial-emacs-state-mode-debug
              (message "Mode '%s' in '%s' so forcing (evil-emacs-state)"
                       newmode
                       my-evil-initial-emacs-state-modes))
            (evil-emacs-state t))

        ;; debug if the major-mode not in the list
        (when my-evil-initial-emacs-state-mode-debug
          (message "Mode '%s' NOT in '%s' so NOT forcing (evil-emacs-state)"
                   newmode
                   my-evil-initial-emacs-state-modes)))

    ;; Debug when we're not in evil-mode or not setting a variable.
    (when my-evil-initial-emacs-state-mode-debug
      (message "Buffer '%s' newmode '%s' oldmode '%s' not in evil-mode (%s)"
               (buffer-name)
               newmode
               oldmode
               evil-mode))))


(define-minor-mode my-evil-initial-emacs-state-mode ()
  "Attempts to force an emacs-state by major mode

Done because sometimes evil-set-initial-state doesn't seem to actually
trip in all circumstances for reasons I've not managed to debug yet.
If I work out why that happens to me this code can be ditched.

Relies on major-mode-change-watcher-mode to monitor for major mode changes"
  
  :init-value nil
  :global t
  :lighter ""
  :after-hook my-evil-initial-emacs-state-mode-after-hook
  
  (if my-evil-initial-emacs-state-mode

      ;; Activate
      (progn
        (add-to-list 'major-mode-change-watcher-functions
                     #'my-evil-initial-emacs-state-enforcer))


    ;; Deactivate
    (progn
      (delete #'my-evil-initial-emacs-state
              major-mode-change-watcher-functions-enforcer))))


(provide 'my-evil-initial-emacs-state-mode)
