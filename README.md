# my-evil-initial-emacs-state-mode
Attempts to reliably enforce emacs mode as an initial state in buffers under evil mode

This hack exists because (evil-set-initial-state 'X 'emacs) is sometimes flakey and doesn't seem to work for certain modes for reasons I haven't managed to clear up.

You'd think you could use these sorts of tricks but none of these work well either in some circumstances, but none of them seemed to work:

```
(add-hook 'evil-mode-hook 'my-evil-initial-emacs-state 100)
(add-hook 'after-change-major-mode-hook 'my-evil-initial-emacs-state 100)
(advice-add 'evil-mode-enable-in-buffer :after #'my-evil-initial-emacs-state)
```

Is it named like something you'd find in a Windows 95 system of like "My Recycle Bin", absolutely yes because this is weird bodge code that shouldn't exist.

So yeah, use it something like this:

```
(use-package my-evil-initial-emacs-state-mode
  :after (evil major-mode-change-watcher-mode)
  :config
  (my-evil-initial-emacs-state-mode t))

;; An example drawn from complete whole cloth obvously and not an actual example: 
(when (intern-soft 'my-evil-initial-emacs-state-modes)
  (add-to-list 'my-evil-initial-emacs-state-modes 'wl-summary-mode)
  (add-to-list 'my-evil-initial-emacs-state-modes 'wl-folder-mode)
  (add-to-list 'my-evil-initial-emacs-state-modes 'mime-view-mode)))
```
