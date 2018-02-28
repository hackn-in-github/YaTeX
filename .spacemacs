;; -*- mode: emacs-lisp -*-
;; This file is loaded by Spacemacs at startup.
;; It must be stored in your home directory.

(defun dotspacemacs/layers ()
  "Configuration Layers declaration.
You should not put any user code in this function besides modifying the variable
values."
  (setq-default
   ;; Base distribution to use. This is a layer contained in the directory
   ;; `+distribution'. For now available distributions are `spacemacs-base'
   ;; or `spacemacs'. (default 'spacemacs)
   dotspacemacs-distribution 'spacemacs
   ;; Lazy installation of layers (i.e. layers are installed only when a file
   ;; with a supported type is opened). Possible values are `all', `unused'
   ;; and `nil'. `unused' will lazy install only unused layers (i.e. layers
   ;; not listed in variable `dotspacemacs-configuration-layers'), `all' will
   ;; lazy install any layer that support lazy installation even the layers
   ;; listed in `dotspacemacs-configuration-layers'. `nil' disable the lazy
   ;; installation feature and you have to explicitly list a layer in the
   ;; variable `dotspacemacs-configuration-layers' to install it.
   ;; (default 'unused)
   dotspacemacs-enable-lazy-installation 'unused
   ;; If non-nil then Spacemacs will ask for confirmation before installing
   ;; a layer lazily. (default t)
   dotspacemacs-ask-for-lazy-installation t
   ;; If non-nil layers with lazy install support are lazy installed.
   ;; List of additional paths where to look for configuration layers.
   ;; Paths must have a trailing slash (i.e. `~/.mycontribs/')
   dotspacemacs-configuration-layer-path '()
   ;; List of configuration layers to load.
   dotspacemacs-configuration-layers
   '(
     ;; ----------------------------------------------------------------
     ;; Example of useful layers you may want to use right away.
     ;; Uncomment some layer names and press <SPC f e R> (Vim style) or
     ;; <M-m f e R> (Emacs style) to install them.
     ;; ----------------------------------------------------------------
     ;; auto-completion
     ;; better-defaults
     (colors :variables colors-enable-nyan-cat-progress-bar nil)
     emacs-lisp
     emoji
     git
     github
     imenu-list
     helm
     html
     lua
     markdown
     org
     python
     search-engine
     (shell :variables
            shell-default-term-shell "/bin/bash"
            shell-default-height 30
            shell-default-position 'bottom)
     ;; spell-checking
     ;; syntax-checking
     twitter
     ;; version-control
     )
   ;; List of additional packages that will be installed without being
   ;; wrapped in a layer. If you need some configuration for these
   ;; packages, then consider creating a layer. You can also put the
   ;; configuration in `dotspacemacs/user-config'.
   dotspacemacs-additional-packages '(
                                      info
                                      dbus
                                      migemo
                                      avy-migemo
                                      )
   ;; A list of packages that cannot be updated.
   dotspacemacs-frozen-packages '()
   ;; A list of packages that will not be installed and loaded.
   dotspacemacs-excluded-packages '()
   ;; Defines the behaviour of Spacemacs when installing packages.
   ;; Possible values are `used-only', `used-but-keep-unused' and `all'.
   ;; `used-only' installs only explicitly used packages and uninstall any
   ;; unused packages as well as their unused dependencies.
   ;; `used-but-keep-unused' installs only the used packages but won't uninstall
   ;; them if they become unused. `all' installs *all* packages supported by
   ;; Spacemacs and never uninstall them. (default is `used-only')
   dotspacemacs-install-packages 'used-only))

(defun dotspacemacs/init ()
  "Initialization function.
This function is called at the very startup of Spacemacs initialization
before layers configuration.
You should not put any user code in there besides modifying the variable
values."
  ;; This setq-default sexp is an exhaustive list of all the supported
  ;; spacemacs settings.
  (setq-default
   ;; If non nil ELPA repositories are contacted via HTTPS whenever it's
   ;; possible. Set it to nil if you have no way to use HTTPS in your
   ;; environment, otherwise it is strongly recommended to let it set to t.
   ;; This variable has no effect if Emacs is launched with the parameter
   ;; `--insecure' which forces the value of this variable to nil.
   ;; (default t)
   dotspacemacs-elpa-https t
   ;; Maximum allowed time in seconds to contact an ELPA repository.
   dotspacemacs-elpa-timeout 20
   ;; If non nil then spacemacs will check for updates at startup
   ;; when the current branch is not `develop'. Note that checking for
   ;; new versions works via git commands, thus it calls GitHub services
   ;; whenever you start Emacs. (default nil)
   dotspacemacs-check-for-update t
   ;; If non-nil, a form that evaluates to a package directory. For example, to
   ;; use different package directories for different Emacs versions, set this
   ;; to `emacs-version'.
   dotspacemacs-elpa-subdirectory nil
   ;; One of `vim', `emacs' or `hybrid'.
   ;; `hybrid' is like `vim' except that `insert state' is replaced by the
   ;; `hybrid state' with `emacs' key bindings. The value can also be a list
   ;; with `:variables' keyword (similar to layers). Check the editing styles
   ;; section of the documentation for details on available variables.
   ;; (default 'vim)
   dotspacemacs-editing-style 'vim
   ;; If non nil output loading progress in `*Messages*' buffer. (default nil)
   dotspacemacs-verbose-loading nil
   ;; Specify the startup banner. Default value is `official', it displays
   ;; the official spacemacs logo. An integer value is the index of text
   ;; banner, `random' chooses a random text banner in `core/banners'
   ;; directory. A string value must be a path to an image format supported
   ;; by your Emacs build.
   ;; If the value is nil then no banner is displayed. (default 'official)
   dotspacemacs-startup-banner 'official
   ;; List of items to show in startup buffer or an association list of
   ;; the form `(list-type . list-size)`. If nil then it is disabled.
   ;; Possible values for list-type are:
   ;; `recents' `bookmarks' `projects' `agenda' `todos'."
   ;; List sizes may be nil, in which case
   ;; `spacemacs-buffer-startup-lists-length' takes effect.
   dotspacemacs-startup-lists '((recents . 5)
                                (projects . 7))
   ;; True if the home buffer should respond to resize events.
   dotspacemacs-startup-buffer-responsive t
   ;; Default major mode of the scratch buffer (default `text-mode')
   dotspacemacs-scratch-mode 'text-mode
   ;; List of themes, the first of the list is loaded when spacemacs starts.
   ;; Press <SPC> T n to cycle to the next theme in the list (works great
   ;; with 2 themes variants, one dark and one light)
   dotspacemacs-themes '(spacemacs-dark
                         spacemacs-light)
   ;; If non nil the cursor color matches the state color in GUI Emacs.
   dotspacemacs-colorize-cursor-according-to-state t
   ;; Default font, or prioritized list of fonts. `powerline-scale' allows to
   ;; quickly tweak the mode-line size to make separators look not too crappy.
   dotspacemacs-default-font '("Source Code Pro"
                               :size 13
                               :weight normal
                               :width normal
                               :powerline-scale 1.1)
   ;; The leader key
   dotspacemacs-leader-key "SPC"
   ;; The key used for Emacs commands (M-x) (after pressing on the leader key).
   ;; (default "SPC")
   dotspacemacs-emacs-command-key "SPC"
   ;; The key used for Vim Ex commands (default ":")
   dotspacemacs-ex-command-key ":"
   ;; The leader key accessible in `emacs state' and `insert state'
   ;; (default "M-m")
   dotspacemacs-emacs-leader-key "M-m"
   ;; Major mode leader key is a shortcut key which is the equivalent of
   ;; pressing `<leader> m`. Set it to `nil` to disable it. (default ",")
   dotspacemacs-major-mode-leader-key ","
   ;; Major mode leader key accessible in `emacs state' and `insert state'.
   ;; (default "C-M-m")
   dotspacemacs-major-mode-emacs-leader-key "C-M-m"
   ;; These variables control whether separate commands are bound in the GUI to
   ;; the key pairs C-i, TAB and C-m, RET.
   ;; Setting it to a non-nil value, allows for separate commands under <C-i>
   ;; and TAB or <C-m> and RET.
   ;; In the terminal, these pairs are generally indistinguishable, so this only
   ;; works in the GUI. (default nil)
   dotspacemacs-distinguish-gui-tab nil
   ;; If non nil `Y' is remapped to `y$' in Evil states. (default nil)
   dotspacemacs-remap-Y-to-y$ nil
   ;; If non-nil, the shift mappings `<' and `>' retain visual state if used
   ;; there. (default t)
   dotspacemacs-retain-visual-state-on-shift t
   ;; If non-nil, J and K move lines up and down when in visual mode.
   ;; (default nil)
   dotspacemacs-visual-line-move-text nil
   ;; If non nil, inverse the meaning of `g' in `:substitute' Evil ex-command.
   ;; (default nil)
   dotspacemacs-ex-substitute-global nil
   ;; Name of the default layout (default "Default")
   dotspacemacs-default-layout-name "Default"
   ;; If non nil the default layout name is displayed in the mode-line.
   ;; (default nil)
   dotspacemacs-display-default-layout nil
   ;; If non nil then the last auto saved layouts are resume automatically upon
   ;; start. (default nil)
   dotspacemacs-auto-resume-layouts nil
   ;; Size (in MB) above which spacemacs will prompt to open the large file
   ;; literally to avoid performance issues. Opening a file literally means that
   ;; no major mode or minor modes are active. (default is 1)
   dotspacemacs-large-file-size 1
   ;; Location where to auto-save files. Possible values are `original' to
   ;; auto-save the file in-place, `cache' to auto-save the file to another
   ;; file stored in the cache directory and `nil' to disable auto-saving.
   ;; (default 'cache)
   dotspacemacs-auto-save-file-location 'cache
   ;; Maximum number of rollback slots to keep in the cache. (default 5)
   dotspacemacs-max-rollback-slots 5
   ;; If non nil, `helm' will try to minimize the space it uses. (default nil)
   dotspacemacs-helm-resize nil
   ;; if non nil, the helm header is hidden when there is only one source.
   ;; (default nil)
   dotspacemacs-helm-no-header nil
   ;; define the position to display `helm', options are `bottom', `top',
   ;; `left', or `right'. (default 'bottom)
   dotspacemacs-helm-position 'bottom
   ;; Controls fuzzy matching in helm. If set to `always', force fuzzy matching
   ;; in all non-asynchronous sources. If set to `source', preserve individual
   ;; source settings. Else, disable fuzzy matching in all sources.
   ;; (default 'always)
   dotspacemacs-helm-use-fuzzy 'always
   ;; If non nil the paste micro-state is enabled. When enabled pressing `p`
   ;; several times cycle between the kill ring content. (default nil)
   dotspacemacs-enable-paste-transient-state nil
   ;; Which-key delay in seconds. The which-key buffer is the popup listing
   ;; the commands bound to the current keystroke sequence. (default 0.4)
   dotspacemacs-which-key-delay 0.4
   ;; Which-key frame position. Possible values are `right', `bottom' and
   ;; `right-then-bottom'. right-then-bottom tries to display the frame to the
   ;; right; if there is insufficient space it displays it at the bottom.
   ;; (default 'bottom)
   dotspacemacs-which-key-position 'bottom
   ;; If non nil a progress bar is displayed when spacemacs is loading. This
   ;; may increase the boot time on some systems and emacs builds, set it to
   ;; nil to boost the loading time. (default t)
   dotspacemacs-loading-progress-bar t
   ;; If non nil the frame is fullscreen when Emacs starts up. (default nil)
   ;; (Emacs 24.4+ only)
   dotspacemacs-fullscreen-at-startup nil
   ;; If non nil `spacemacs/toggle-fullscreen' will not use native fullscreen.
   ;; Use to disable fullscreen animations in OSX. (default nil)
   dotspacemacs-fullscreen-use-non-native nil
   ;; If non nil the frame is maximized when Emacs starts up.
   ;; Takes effect only if `dotspacemacs-fullscreen-at-startup' is nil.
   ;; (default nil) (Emacs 24.4+ only)
   dotspacemacs-maximized-at-startup t
   ;; A value from the range (0..100), in increasing opacity, which describes
   ;; the transparency level of a frame when it's active or selected.
   ;; Transparency can be toggled through `toggle-transparency'. (default 90)
   dotspacemacs-active-transparency 90
   ;; A value from the range (0..100), in increasing opacity, which describes
   ;; the transparency level of a frame when it's inactive or deselected.
   ;; Transparency can be toggled through `toggle-transparency'. (default 90)
   dotspacemacs-inactive-transparency 90
   ;; If non nil show the titles of transient states. (default t)
   dotspacemacs-show-transient-state-title t
   ;; If non nil show the color guide hint for transient state keys. (default t)
   dotspacemacs-show-transient-state-color-guide t
   ;; If non nil unicode symbols are displayed in the mode line. (default t)
   dotspacemacs-mode-line-unicode-symbols t
   ;; If non nil smooth scrolling (native-scrolling) is enabled. Smooth
   ;; scrolling overrides the default behavior of Emacs which recenters point
   ;; when it reaches the top or bottom of the screen. (default t)
   dotspacemacs-smooth-scrolling t
   ;; Control line numbers activation.
   ;; If set to `t' or `relative' line numbers are turned on in all `prog-mode' and
   ;; `text-mode' derivatives. If set to `relative', line numbers are relative.
   ;; This variable can also be set to a property list for finer control:
   ;; '(:relative t
   ;;   :disabled-for-modes dired-mode
   ;;                       doc-view-mode
   ;;                       markdown-mode
   ;;                       org-mode
   ;;                       pdf-view-mode
   ;;                       text-mode
   ;;   :size-limit-kb 1000)
   ;; (default nil)
   dotspacemacs-line-numbers '(:relative t
                               :disabled-for-modes dired-mode
                               ;;doc-view-mode
                               markdown-mode
                               org-mode
                               pdf-view-mode
                               ;;text-mode
                               :size-limit-kb 1000)
   ;; Code folding method. Possible values are `evil' and `origami'.
   ;; (default 'evil)
   dotspacemacs-folding-method 'evil
   ;; If non-nil smartparens-strict-mode will be enabled in programming modes.
   ;; (default nil)
   dotspacemacs-smartparens-strict-mode nil
   ;; If non-nil pressing the closing parenthesis `)' key in insert mode passes
   ;; over any automatically added closing parenthesis, bracket, quote, etc…
   ;; This can be temporary disabled by pressing `C-q' before `)'. (default nil)
   dotspacemacs-smart-closing-parenthesis nil
   ;; Select a scope to highlight delimiters. Possible values are `any',
   ;; `current', `all' or `nil'. Default is `all' (highlight any scope and
   ;; emphasis the current one). (default 'all)
   dotspacemacs-highlight-delimiters 'all
   ;; If non nil, advise quit functions to keep server open when quitting.
   ;; (default nil)
   dotspacemacs-persistent-server nil
   ;; List of search tool executable names. Spacemacs uses the first installed
   ;; tool of the list. Supported tools are `ag', `pt', `ack' and `grep'.
   ;; (default '("ag" "pt" "ack" "grep"))
   dotspacemacs-search-tools '("ag" "pt" "ack" "grep")
   ;; The default package repository used if no explicit repository has been
   ;; specified with an installed package.
   ;; Not used for now. (default nil)
   dotspacemacs-default-package-repository nil
   ;; Delete whitespace while saving buffer. Possible values are `all'
   ;; to aggressively delete empty line and long sequences of whitespace,
   ;; `trailing' to delete only the whitespace at end of lines, `changed'to
   ;; delete only whitespace for changed lines or `nil' to disable cleanup.
   ;; (default nil)
   dotspacemacs-whitespace-cleanup nil
   ))

(defun dotspacemacs/user-init ()
  "Initialization function for user code.
It is called immediately after `dotspacemacs/init', before layer configuration
executes.
 This function is mostly useful for variables that need to be set
before packages are loaded. If you are unsure, you should try in setting them in
`dotspacemacs/user-config' first."
  (defun add-to-load-path (&rest paths)
    (let (path)
      (dolist (path paths paths)
        (let ((default-directory (expand-file-name (concat user-emacs-directory path))))
          (add-to-list 'load-path default-directory)
          (if (fboundp 'normal-top-level-add-subdirs-to-load-path)
              (normal-top-level-add-subdirs-to-load-path))))))
  (add-to-load-path "/private/local")
;;  (add-to-load-path "/site-lisp")
;;; 日本語環境設定
  (set-language-environment "utf-8")
  )

(defun dotspacemacs/user-config ()
  "Configuration function for user code.
This function is called at the very end of Spacemacs initialization after
layers configuration.
This is the place where most of your configurations should be done. Unless it is
explicitly specified that a variable should be set before a package is loaded,
you should place your code here."
  (with-eval-after-load "helm"
    (require 'tex-setting))
  (require 'my-setting)
  (require 'migemo)
  (require 'avy-migemo)
  (custom-set-variables
   '(cal-tex-diary t)
   '(column-number-mode t)
   '(diary-list-include-blanks t)
   '(display-time-24hr-format t)
   '(display-time-mode t)
   '(inhibit-startup-screen t)
   '(line-number-mode t)
   '(make-backup-files nil)
   '(next-line-add-newlines nil)
   '(show-paren-mode t)
   '(tool-bar-mode nil)
;; Emacs で全角スペース/タブ文字を可視化
;; http://weboo-returns.com/blog/emacs-shows-double-space-and-tab/
   '(whitespace-style '(face
                        trailing
                        tabs
                        tab-mark
                        spaces
                        space-mark))
   '(whitespace-space-regexp "\\(\x3000+\\)")
   '(whitespace-trailing-regexp "\\([\x20\x3000\t]+\\)$")
   '(whitespace-display-mappings '((space-mark ?\x3000 [?\x2603])
                                   (tab-mark ?\t [?\xBB?\t])))
;; migemo
   '(migemo-command "cmigemo")
   '(migemo-options '("-q" "--emacs" "-i" "\a"))
   '(migemo-dictionary "/usr/share/cmigemo/utf-8/migemo-dict");; system-type 'gnu/linux
;;   '(migemo-dictionary "/usr/local/share/migemo/utf-8/migemo-dict");; system-type 'darwin
;;   '(migemo-dictionary "c:/app/cmigemo-default-win64/dict/utf-8/migemo-dict");; system-type 'windows-nt
   '(migemo-user-dictionary nil)
   '(migemo-regex-dictionary nil)
   '(migemo-coding-system 'utf-8-unix)
   )
;; ウィンドウの透け透け度 0-100 (0で透け透け)
  (set-frame-parameter nil 'alpha 75)
;; japanese-holidays の設定等
  (with-eval-after-load "holidays"
    (require 'japanese-holidays)
    (setq calendar-holidays ; 他の国の祝日も表示させたい場合は適当に調整
          (append japanese-holidays holiday-local-holidays holiday-other-holidays)
          mark-holidays-in-calendar t ; 祝日をカレンダーに表示
;; 土曜日・日曜日を祝日として表示する場合、以下の設定を追加します。
;; 変数はデフォルトで設定済み
          japanese-holiday-weekend '(0 6)     ; 土日を祝日として表示
          japanese-holiday-weekend-marker     ; 土曜日を水色で表示
          '(holiday nil nil nil nil nil japanese-holiday-saturday))
    (add-hook 'calendar-today-visible-hook 'japanese-holiday-mark-weekend)
    (add-hook 'calendar-today-invisible-hook 'japanese-holiday-mark-weekend)
;; “きょう”をマークするには以下の設定を追加します。
    (add-hook 'calendar-today-visible-hook 'calendar-mark-today)
;; diaryの設定
    (add-hook 'list-diary-entries-hook 'include-other-diary-files)
    (add-hook 'mark-diary-entries-hook 'mark-included-diary-files)
;;装飾日誌表示
    (add-hook 'diary-display-hook 'fancy-diary-display))
;; Turn off the tildes in the fringe
  (global-vi-tilde-fringe-mode -1)
;; insert mode でのカーソル移動
  (define-key evil-insert-state-map "\C-e" 'end-of-line)
  (define-key evil-insert-state-map "\C-a" 'beginning-of-line)
  (define-key evil-insert-state-map "\C-n" 'next-line)
  (define-key evil-insert-state-map "\C-p" 'previous-line)
;; whitespace
  (global-whitespace-mode 1)
  (set-face-foreground 'whitespace-space "LightSlateGray")
  (set-face-background 'whitespace-space "DarkSlateGray")
  (set-face-foreground 'whitespace-tab "LightSlateGray")
  (set-face-background 'whitespace-tab "DarkSlateGray")
  (set-face-foreground 'whitespace-trailing "CornflowerBlue")
  (set-face-background 'whitespace-trailing "RoyalBlue")
;; initialize migemo
  (migemo-init)
;;
  (with-eval-after-load "helm"
    (helm-migemo-mode 1)
    )
;; avy-migemo
   (avy-migemo-mode 1)
  (setq hl-line-face 'underline)
  (global-hl-line-mode)
  (fset 'evil-visual-update-x-selection 'ignore)
;; latex in org mode
  (require 'ox-latex)
;; pdf process = lualatex
  (setq org-latex-pdf-process '("lualatex %f"))
;; default class = jsarticle
  (setq org-latex-default-class "bxjsreport")
;; org-latex-classes
  (add-to-list 'org-latex-classes
               '("bxjsreport"
                 "\\documentclass[a4j,lualatex,ja=standard,magstyle=nomag*]{bxjsreport}\n
                [NO-DEFAULT-PACKAGES]
                %\\setpagelayout{margin=20mm}\n
                \\setmainjfont[BoldFont=SourceHanSerifJP-Bold]{SourceHanSerifJP-Light}\n
                \\setsansjfont{SourceHanSansJP-Light}\n
                \\setmonofont{SourceCodePro-Light}\n
                \\usepackage{hyperref}\n
                 [PACKAGES] [EXTRA]"
                 ("\\section{%s}" . "\\section*{%s}")
                 ("\\subsection{%s}" . "\\subsection*{%s}")
                 ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
                 ("\\paragraph{%s}" . "\\paragraph*{%s}")
                 ("\\subparagraph{%s}" . "\\subparagraph*{%s}")
                 ))
;; org-export-latex-no-toc
  (defun org-export-latex-no-toc (depth)
    (when depth
      (format "%% Org-mode is exporting headings to %s levels.\n"
              depth)))
  (setq org-export-latex-format-toc-function 'org-export-latex-no-toc)
;;  (and
;;   (require 'centered-cursor-mode)
;;   (global-centered-cursor-mode +1))
  (setq magit-repository-directories '("~/ダウンロード/Github/"))
;;  (define-key evil-motion-state-map (kbd "SPC h c") #'helm-calcul-expression)
;;  (define-key evil-insert-state-map (kbd "\C-c h c") #'helm-calcul-expression)
;; http://emacs.rubikitch.com/bind-key/
;;(require 'bind-key);;spacemacsではすでに読みこまれているらしい
  (bind-key "SPC h c" 'helm-calcul-expression evil-motion-state-map)
  (bind-key "C-c h c" 'helm-calcul-expression evil-insert-state-map)
;; http://emacs.rubikitch.com/use-package-2/
;;(require 'use-package);;spacemacsではすでに読みこまれているらしい
  (bind-keys :map evil-motion-state-map
             ("SPC y p g" . my-pgf-graphic-named)
             ("SPC y t" . YaTeX-typeset-menu)
             ("SPC y x f" . my-tex-filename-replace)
             ("SPC y x k" . helm-tex-kijutsu-insert-include)
             ("SPC y x m" . my-tex-mark-setting)
             ("SPC y z c" . helm-tikz-colors)
             ("SPC y z d b" . my-tikz-decoration-brace)
             ("SPC y z f e" . my-tikz-foreach-evaluate)
             ("SPC y z f p" . helm-tikz-fill-pattern)
             ("SPC y z f r" . my-tikz-foreach-remember)
             ("SPC y z l c" . helm-tikz-line-cap)
             ("SPC y z l d a" . helm-tikz-line-dash)
             ("SPC y z l d o" . helm-tikz-line-double)
             ("SPC y z l j" . helm-tikz-line-join)
             ("SPC y z l w" . helm-tikz-line-width)
             ("SPC y z l w" . helm-tikz-line-width)
             ("SPC y z n p" . my-tikz-node-polygon)
             ("SPC y z t g" . my-tikz-transparency-group))
  (bind-keys :map evil-insert-state-map
             ("\C-c y p g" . my-pgf-graphic-named)
             ("\C-c y t" . YaTeX-typeset-menu)
             ("\C-c y x f" . my-tex-filename-replace)
             ("\C-c y x k" . helm-tex-kijutsu-insert-include)
             ("\C-c y x m" . my-tex-mark-setting)
             ("\C-c y z c" . helm-tikz-colors)
             ("\C-c y z d b" . my-tikz-decoration-brace)
             ("\C-c y z f e" . my-tikz-foreach-evaluate)
             ("\C-c y z f p" . helm-tikz-fill-pattern)
             ("\C-c y z f r" . my-tikz-foreach-remember)
             ("\C-c y z l c" . helm-tikz-line-cap)
             ("\C-c y z l d a" . helm-tikz-line-dash)
             ("\C-c y z l d o" . helm-tikz-line-double)
             ("\C-c y z l j" . helm-tikz-line-join)
             ("\C-c y z l w" . helm-tikz-line-width)
             ("\C-c y z n p" . my-tikz-node-polygon)
             ("\C-c y z t g" . my-tikz-transparency-group))
  (spacemacs/declare-prefix "h" "help/helm")
  (spacemacs/declare-prefix "h c" "calcul")
;;  (spacemacs/declare-prefix-for-mode 'yatex-mode "y" "TeX用関数")
;;  (spacemacs/declare-prefix-for-mode 'yatex-mode "y p" "PGF関係")
;;  (spacemacs/declare-prefix-for-mode 'yatex-mode "y p g" "PGF設定")
;;  (spacemacs/declare-prefix-for-mode 'yatex-mode "y t" "TeX Typeset")
;;  (spacemacs/declare-prefix-for-mode 'yatex-mode "y x" "TeXソース編集")
;;  (spacemacs/declare-prefix-for-mode 'yatex-mode "y x f" "ファイル初期設定")
;;  (spacemacs/declare-prefix-for-mode 'yatex-mode "y x k" "記述用設定")
;;  (spacemacs/declare-prefix-for-mode 'yatex-mode "y x m" "マーク用設定")
;;  (spacemacs/declare-prefix-for-mode 'yatex-mode "y z" "TikZ設定")
;;  (spacemacs/declare-prefix-for-mode 'yatex-mode "y z d" "decoration")
;;  (spacemacs/declare-prefix-for-mode 'yatex-mode "y z d b" "brace")
;;  (spacemacs/declare-prefix-for-mode 'yatex-mode "y z f" "foreach/fill")
;;  (spacemacs/declare-prefix-for-mode 'yatex-mode "y z f e" "foreach evaluate")
;;  (spacemacs/declare-prefix-for-mode 'yatex-mode "y z f p" "fill pattern")
;;  (spacemacs/declare-prefix-for-mode 'yatex-mode "y z f r" "foreach remember")
;;  (spacemacs/declare-prefix-for-mode 'yatex-mode "y z l" "line")
;;  (spacemacs/declare-prefix-for-mode 'yatex-mode "y z l c" "cap")
;;  (spacemacs/declare-prefix-for-mode 'yatex-mode "y z l d" "dash/double")
;;  (spacemacs/declare-prefix-for-mode 'yatex-mode "y z l d a" "dash")
;;  (spacemacs/declare-prefix-for-mode 'yatex-mode "y z l d o" "double")
;;  (spacemacs/declare-prefix-for-mode 'yatex-mode "y z l j" "join")
;;  (spacemacs/declare-prefix-for-mode 'yatex-mode "y z l w" "width")
;;  (spacemacs/declare-prefix-for-mode 'yatex-mode "y z n" "node")
;;  (spacemacs/declare-prefix-for-mode 'yatex-mode "y z n p" "polygon")
;;  (spacemacs/declare-prefix-for-mode 'yatex-mode "y z t" "transparency")
;;  (spacemacs/declare-prefix-for-mode 'yatex-mode "y z t g" "gruop")
  (which-key-add-major-mode-key-based-replacements
    'yatex-mode
    "SPC y" "TeX用関数"
    "\C-c y" "TeX用関数"
    "SPC y p" "PGF関数"
    "\C-c y p" "PGF関数"
    "SPC y p g" "PGF設定"
    "\C-c y p g" "PGF設定"
    "SPC y t" "TeX Typeset"
    "\C-c y t" "TeX Typeset"
    "SPC y x" "TeXソース編集"
    "\C-c y x" "TeXソース編集"
    "SPC y x f" "ファイル初期設定"
    "\C-c y x f" "ファイル初期設定"
    "SPC y x k" "記述用設定"
    "\C-c y x k" "記述用設定"
    "SPC y x m" "マーク用設定"
    "\C-c y x m" "マーク用設定"
    "SPC y z" "TikZ設定"
    "\C-c y z" "TikZ設定"
    "SPC y z c" "colors"
    "\C-c y z c" "colors"
    "SPC y z d" "decoration"
    "\C-c y z d" "decoration"
    "SPC y z d b" "brace"
    "\C-c y z d b" "brace"
    "SPC y z f" "foreach/fill"
    "\C-c y z f" "foreach/fill"
    "SPC y z f e" "foreach evaluate"
    "\C-c y z f e" "foreach evaluate"
    "SPC y z f p" "fill pattern"
    "\C-c y z f p" "fill pattern"
    "SPC y z f r" "foreach remember"
    "\C-c y z f r" "foreach remember"
    "SPC y z l" "line"
    "\C-c y z l" "line"
    "SPC y z l c" "cap"
    "\C-c y z l c" "cap"
    "SPC y z l d" "dash/double"
    "\C-c y z l d" "dash/double"
    "SPC y z l d a" "dash"
    "\C-c y z l d a" "dash"
    "SPC y z l d o" "double"
    "\C-c y z l d o" "double"
    "SPC y z l j" "join"
    "\C-c y z l j" "join"
    "SPC y z l w" "width"
    "\C-c y z l w" "width"
    "SPC y z n" "node"
    "\C-c y z n" "node"
    "SPC y z n p" "polygon"
    "\C-c y z n p" "polygon"
    "SPC y z t" "transparency"
    "\C-c y z t" "transparency"
    "SPC y z t g" "group"
    "\C-c y z t g" "group")
;Emacs YaTeX/yahtml の入力支援では helm を無効にする
;http://gordiustears.net/disabling-helm-on-yatex-yahtml/
  (with-eval-after-load "helm-mode"
    (add-to-list 'helm-completing-read-handlers-alist '(YaTeX-make-accent . nil))
    (add-to-list 'helm-completing-read-handlers-alist '(YaTeX-make-begin-end . nil))
    (add-to-list 'helm-completing-read-handlers-alist '(YaTeX-make-fontsize . nil))
    (add-to-list 'helm-completing-read-handlers-alist '(YaTeX-make-section . nil))
    (add-to-list 'helm-completing-read-handlers-alist '(YaTeX-make-singlecmd . nil))
    (add-to-list 'helm-completing-read-handlers-alist '(YaTeX-make-begin-end-region . nil))
    (add-to-list 'helm-completing-read-handlers-alist '(YaTeX-make-fontsize-region . nil))
    (add-to-list 'helm-completing-read-handlers-alist '(YaTeX-make-section-region . nil))
    )
; iedit で V で toggle visibility of lines with no occurrence を使えるようにする
  (fset 'iedit-toggle-unmatched-lines-visible 'iedit-show/hide-unmatched-lines)
; バグとして報告されている件だったので https://github.com/syl20bnr/spacemacs/issues/7999
; ~/.emacs.d/layers/+web-services/search-engine/package.el を直接編集することにする
;  (push '(wikipedia-ja
;          :name "Wikipedia (ja)"
;          :url "http://www.wikipedia.org/search-redirect.php?language=ja&go=Go&search=%s")
;        search-engine-alist)
  (push '(stack-overflow-ja
          :name "スタック・オーバーフロー"
          :url "https://ja.stackoverflow.com/search?q=%s")
        search-engine-alist)
  (push '(wikipedia-ja
          :name "ウィキペディア"
          :url "https://ja.wikipedia.org/w/index.php?search=%s")
        search-engine-alist)
  )

;; Do not write anything past this comment. This is where Emacs will
;; auto-generate custom variable definitions.
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(cal-tex-diary t)
 '(column-number-mode t)
 '(diary-list-include-blanks t)
 '(display-time-24hr-format t)
 '(display-time-mode t)
 '(inhibit-startup-screen t)
 '(line-number-mode t)
 '(make-backup-files nil)
 '(migemo-coding-system (quote utf-8-unix))
 '(migemo-command "cmigemo")
 '(migemo-dictionary "/usr/share/cmigemo/utf-8/migemo-dict")
 '(migemo-options (quote ("-q" "--emacs" "-i" "")))
 '(migemo-regex-dictionary nil)
 '(migemo-user-dictionary nil)
 '(next-line-add-newlines nil)
 '(package-selected-packages
   (quote
    (engine-mode imenu-list org-mime ghub let-alist twittering-mode xterm-color shell-pop multi-term eshell-z eshell-prompt-extras esh-help emoji-cheat-sheet-plus rainbow-mode rainbow-identifiers color-identifiers-mode yapfify pyvenv pytest pyenv-mode py-isort pip-requirements live-py-mode hy-mode dash-functional helm-pydoc cython-mode anaconda-mode pythonic eyebrowse expand-region exec-path-from-shell evil-visualstar evil-visual-mark-mode evil-tutor evil-search-highlight-persist evil-numbers evil-lisp-state evil-indent-plus evil-iedit-state evil-exchange evil-args evil-anzu anzu eval-sexp-fu elisp-slime-nav diminish column-enforce-mode clean-aindent-mode bind-map bind-key auto-highlight-symbol adaptive-wrap ace-jump-helm-line popup define-word evil-surround evil-escape ace-link iedit goto-chg org-category-capture evil-nerd-commenter evil-mc evil-matchit evil-ediff dumb-jump auto-compile packed aggressive-indent ace-window smartparens highlight evil undo-tree helm helm-core avy async web-mode tagedit smeargle slim-mode scss-mode sass-mode pug-mode orgit org-projectile org-present org-pomodoro alert log4e gntp org-download mmm-mode markdown-toc markdown-mode magit-gitflow magit-gh-pulls lua-mode less-css-mode htmlize helm-gitignore helm-css-scss haml-mode gnuplot gitignore-mode github-search github-clone github-browse-file gitconfig-mode gitattributes-mode git-timemachine git-messenger git-link gist gh marshal logito pcache ht gh-md evil-magit magit magit-popup git-commit with-editor emmet-mode avy-migemo migemo ws-butler winum which-key volatile-highlights vi-tilde-fringe uuidgen use-package toc-org spaceline powerline restart-emacs request rainbow-delimiters popwin persp-mode pcre2el paradox spinner org-plus-contrib org-bullets open-junk-file neotree move-text macrostep lorem-ipsum linum-relative link-hint info+ indent-guide hydra hungry-delete hl-todo highlight-parentheses highlight-numbers parent-mode highlight-indentation hide-comnt help-fns+ helm-themes helm-swoop helm-projectile helm-mode-manager helm-make projectile pkg-info epl helm-flx helm-descbinds helm-ag google-translate golden-ratio flx-ido flx fill-column-indicator fancy-battery evil-unimpaired f s dash)))
 '(show-paren-mode t)
 '(tool-bar-mode nil)
 '(whitespace-display-mappings (quote ((space-mark 12288 [9731]) (tab-mark 9 [187 9]))))
 '(whitespace-space-regexp "\\(　+\\)")
 '(whitespace-style (quote (face trailing tabs tab-mark spaces space-mark)))
 '(whitespace-trailing-regexp "\\([ 　	]+\\)$"))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
