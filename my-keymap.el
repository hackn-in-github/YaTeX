;; insert mode でのカーソル移動
(define-key evil-insert-state-map "\C-e" 'end-of-line)
(define-key evil-insert-state-map "\C-a" 'beginning-of-line)
(define-key evil-insert-state-map "\C-n" 'next-line)
(define-key evil-insert-state-map "\C-p" 'previous-line)
;;  (define-key evil-motion-state-map (kbd "SPC h c") #'helm-calcul-expression)
;;  (define-key evil-insert-state-map (kbd "\C-c h c") #'helm-calcul-expression)
;; http://emacs.rubikitch.com/bind-key/
;;(require 'bind-key);;spacemacsではすでに読みこまれているらしい
;;  (bind-key "SPC h c" 'helm-calcul-expression evil-motion-state-map)
;;  (bind-key "C-c h c" 'helm-calcul-expression evil-insert-state-map)
(bind-keys :map evil-motion-state-map
           ("SPC s o" . helm-occur)
           ("SPC h c" . helm-calcul-expression)
           ("SPC a D" . find-dired)
           ("SPC a w" . wdired-change-to-wdired-mode)
           :map evil-insert-state-map
           ("\C-c s o" . helm-occur)
           ("\C-c h c" . helm-calcul-expression)
           ("\C-c a D" . find-dired))
(with-eval-after-load "dired"
  (progn
    (bind-keys :map dired-mode-map
               ("w" . wdired-change-to-wdired-mode))
    (spacemacs/declare-prefix "a D" "find-dired")
    (spacemacs/declare-prefix "a w" "change-wdired-mode")
    (which-key-add-major-mode-key-based-replacements
      'dired-mode
      "\C-c a" "applications"
      "\C-c a w" "change-wdired-mode")))
; vim-surround の設定
;(evil-define-key 'visual evil-surround-mode-map "s" #'evil-substitute)
;(evil-define-key 'visual evil-surround-mode-map "S" #'evil-surround-region)
; TeX 関係の設定
(bind-keys :map evil-motion-state-map
           ("SPC y a a p" . my-align-phantom)
;;           ("SPC y d a" . dired-very-clean-tex)
;;           ("SPC y d f" . dired-clean-tex)
           ("SPC y i f" . my-pgf-fpu-sci-format-insert)
           ("SPC y i h" . my-insert-half-paren)
           ("SPC y i p" . my-insert-parens)
           ("SPC y i s" . my-insert-shoumei)
           ("SPC y l a" . my-label-ref-space-add)
           ("SPC y p g" . my-pgf-graphic-named)
           ("SPC y t c s" . helm-tcolorbox-sharp-corners)
           ("SPC y t c r" . helm-tcolorbox-rounded-corners)
           ("SPC y t s a" . helm-tcolorbox-sidebyside-align)
           ("SPC y t t h" . helm-tcolorbox-text-halign)
           ("SPC y t t v" . helm-tcolorbox-text-valign)
           ("SPC y T" . YaTeX-typeset-menu)
           ("SPC y x f" . my-tex-filename-replace)
           ("SPC y x i" . my-get-ready-for-TeX)
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
           ("\C-c y a a p" . my-align-phantom)
;;           ("\C-c y d a" . dired-very-clean-tex)
;;           ("\C-c y d f" . dired-clean-tex)
           ("\C-c y i f" . my-pgf-fpu-sci-format-insert)
           ("\C-c y i h" . my-insert-halp-paren)
           ("\C-c y i p" . my-insert-parens)
           ("\C-c y i s" . my-insert-shoumei)
           ("\C-c y l a" . my-label-ref-space-add)
           ("\C-c y p g" . my-pgf-graphic-named)
           ("\C-c y t c s" . helm-tcolorbox-sharp-corners)
           ("\C-c y t c r" . helm-tcolorbox-rounded-corners)
           ("\C-c y t s a" . helm-tcolorbox-sidebyside-align)
           ("\C-c y t t h" . helm-tcolorbox-text-halign)
           ("\C-c y t t v" . helm-tcolorbox-text-valign)
           ("\C-c y T" . YaTeX-typeset-menu)
           ("\C-c y x f" . my-tex-filename-replace)
           ("\C-c y x i" . my-get-ready-for-TeX)
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
  "SPC y a" "AMS"
  "\C-c y a" "AMS"
  "SPC y a a" "align環境"
  "\C-c y a a" "align環境"
  "SPC y a a p" "phantom"
  "\C-c y a a p" "phantom"
;;  "SPC y d" "delete aux files"
;;  "\C-c y d" "delete aux files"
;;  "SPC y d a" "delete all files(toc aux log dvi)"
;;  "\C-c y d a" "delete all files(toc aux log dvi)"
;;  "SPC y d f" "deleat files(toc aux log)"
;;  "\C-c y d f" "deleat files(toc aux log)"
  "SPC y i" "insert"
  "\C-c y i" "insert"
  "SPC y i f" "set PGF Floating Point Unit"
  "\C-c y i f" "set PGF Floating Point Unit"
  "SPC y i h" "半括弧"
  "\C-c y i h" "半括弧"
  "SPC y i p" "括弧類"
  "\C-c y i p" "括弧類"
  "SPC y i s" "証明"
  "\C-c y i s" "証明"
  "SPC y l" "label"
  "\C-c y l" "label"
  "SPC y l a" "add space"
  "\C-c y l a" "add space"
  "SPC y p" "PGF関数"
  "\C-c y p" "PGF関数"
  "SPC y p g" "PGF設定"
  "\C-c y p g" "PGF設定"
  "SPC y t" "tcolorbox"
  "\C-c y t" "tcolorbox"
  "SPC y t c" "corners"
  "\C-c y t c" "corners"
  "SPC y t c s" "sharp corners"
  "\C-c y t c s" "sharp corners"
  "SPC y t c r" "rounded corners"
  "\C-c y t c r" "rounded corners"
  "SPC y t s" "sidebyside"
  "\C-c y t s" "sidebyside"
  "SPC y t s a" "align"
  "\C-c y t s a" "align"
  "SPC y t t" "text"
  "\C-c y t t" "text"
  "SPC y t t h" "halign"
  "\C-c y t t h" "halign"
  "SPC y t t v" "valign"
  "\C-c y t t v" "valign"
  "SPC y T" "TeX Typeset"
  "\C-c y T" "TeX Typeset"
  "SPC y x" "TeXソース編集"
  "\C-c y x" "TeXソース編集"
  "SPC y x f" "ファイル初期設定"
  "\C-c y x f" "ファイル初期設定"
  "SPC y x i" "TeXソース入力準備"
  "\C-c y x i" "TeXソース入力準備"
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
(provide 'my-keymap)
