(autoload 'yatex-mode "yatex" "Yet Another LaTeX mode" t)
(with-eval-after-load 'yatexhks
  (require 'for-emath-macro)
  (require 'for-original-macro))
(setq auto-mode-alist
      (append '(("\\.tex$" . yatex-mode)
                ("\\.ltx$" . yatex-mode)
                ("\\.cls$" . yatex-mode)
                ("\\.sty$" . yatex-mode)
                ("\\.clo$" . yatex-mode)
                ("\\.bbl$" . yatex-mode)) auto-mode-alist))
(setq	tex-command "/usr/local/bin/ptex2pdf -l -u"
        dvi2-command "/usr/bin/evince"
        tex-pdfview-command "evince"
        YaTeX-dvi2-command-ext-alist '(("evince\\|okular\\|zathura\\|qpdfview\\|pdfopen\\|xdg-open\\|open\\|start" . ".pdf"))
;;	dvi2-command "/usr/local/bin/xdvi"
;;	dvi2-command "c:/dviout/dviout -1 dvifilename \"# lineno *\""
;;	yatexhks.elで実装した
        YaTeX-inhibit-prefix-letter t;動く？
;;	YaTeX-template-file "~/Templates/template.tex"
        YaTeX-kanji-code 4;; 1:sjis 2:jis 3:euc 4:utf-8
;;	latex-message-kanji-code 4;;
        YaTeX-latex-message-code 'utf-8
        YaTeX-no-begend-shortcut t;;`[prefix] b ??' のショートカットを使わず、`[prefix] b' だけで補完入力に入る (`nil')
        YaTeX-fill-prefix ""
        makeindex-command "mendex -g -s mystyle.ist "
        YaTeX-item-regexp "\\\\\\(eda\\|h\\)*item";;-->\\\(eda\|h\)*item
;;itemの桁揃えの時に用いる、itemの正規表現 (`"\\\\(sub\\)*item"') <--嘘つきwww
        YaTeX-create-file-prefix-g t;;`\include'などで `prefix g'した時に、ジャンプ先が存在しないファイルであってもオープンする (`nil')
        YaTeX-fill-column 120;;反映される？
;;	YaTeX-ref-default-label-string (buffer-file-name)
        YaTeX-use-AMS-LaTeX t;align環境が数式モードのになるはず
        YaTeX-electric-indent-mode t;emacs24.4以降に必要
        YaTeX-on-the-fly-preview-interval nil;[prefix] t e で即時プレビューを行わない
        YaTeX-japan t
;;        YaTeX-help-file $doc-directory/../../site-lisp/YATEXHLP.ja
        )
(fset 'YaTeX-intelligent-newline-centerenum 'YaTeX-intelligent-newline-itemize)
(fset 'YaTeX-intelligent-newline-centerenum* 'YaTeX-intelligent-newline-itemize)
(defun YaTeX-intelligent-newline-hlist ()
  "Insert '\\hitem '."
  (insert "\\hitem ")
  (YaTeX-indent-line))
;;  (fset 'YaTeX-intelligent-newline-hlist 'YaTeX-intelligent-newline-itemize)
(setq
 YaTeX-math-sign-alist-private
 '(
   ("q"         "Q"          "(Q)")
   ("z"         "Z"          "ZZ")
   ("t""text""text")
   ("qu"        "quad"         "__")
   ("qq"        "qquad"         "____")
   ("ls"        "varlimsup"     "___\nlim")
   ("li"        "varliminf"     "lim\n---")
   ("il"        "varinjlim"     "lim\n-->")
   ("pl"        "varprojlim"    "lim\n<--")
   ("st"        "text{ s.t. }" "s.t.")
   ("bigop"     "bigoplus"      "_\n(+)~")
   ("bigot"     "bigotimes"     "_\n(x)\n ~")
   ))
(require 'dbus)
(defun un-urlify (fname-or-url)
  "A trivial function that replaces a prefix of file:/// with just /."
  (if (string= (substring fname-or-url 0 8) "file:///")
      (substring fname-or-url 7)
    fname-or-url))
;; TeX Wiki の関数の fname へのファイル名代入において
;; file に(decode-coding-string (url-unhex-string ) 'utf-8)を噛ませる
(defun evince-inverse-search (file linecol &rest ignored)
  (let* ((fname (decode-coding-string (url-unhex-string (un-urlify file)) 'utf-8))
         (buf (find-file fname))
         (line (car linecol))
         (col (cadr linecol)))
    (if (null buf)
        (message "[Synctex]: %s is not opened..." fname)
      (switch-to-buffer buf)
      (goto-line (car linecol))
      (unless (= col -1)
        (move-to-column col)))))
(dbus-register-signal
 :session nil "/org/gnome/evince/Window/0"
 "org.gnome.evince.Window" "SyncSource"
 'evince-inverse-search)
;; forward-serach は YaTeX で対応:平文においてC-c C-g
;; 01/08/2016 広瀬さん御本人が YaTeX-preview-junp-line を訂正してくださる．
;; 訂正内容:yatexprc.elの
;;         (cf (file-relative-name (buffer-file-name) pdir))を
;;         (cf (buffer-file-name))に
;; これにより以下の関数などが不要に
;; ~/.emacs.d/site-lisp/synctex-for-evince-yatex 以下も不要に
;;forward-serach
;;(require 'synctex-for-evince-yatex)
;;(synctex-for-evince-dbus-initialize)
;;(add-hook 'yatex-mode-hook
;;	  '(lambda ()
;;	     (YaTeX-define-key "f" 'synctex-for-evince-yatex-forward-search)))
;;  (eval-after-load 'yatexprc
;;    '(progn
;;       (defun YaTeX-preview-jump-line ()
;;         "Call jump-line function of various previewer on current main file"
;;         (interactive)
;;         (save-excursion
;;           (save-restriction
;;             (widen)
;;             (let*((pf (or YaTeX-parent-file
;;                           (save-excursion (YaTeX-visit-main t) (buffer-file-name))))
;;                   (pdir (file-name-directory pf))
;;                   (bnr (substring pf 0 (string-match "\\....$" pf)))
;;;;	      (cf (file-relative-name (buffer-file-name) pdir))
;;                   (cf (buffer-file-name))
;;                   (buffer (get-buffer-create " *preview-jump-line*"))
;;                   (line (count-lines (point-min) (point-end-of-line)))
;;                   (previewer (YaTeX-preview-default-previewer))
;;                   (cmd (cond
;;                         ((string-match "xdvi" previewer)
;;                          (format "%s -nofork -sourceposition '%d %s' %s.dvi"
;;                                  YaTeX-xdvi-remote-program
;;                                  line cf bnr))
;;                         ((string-match "Skim" previewer)
;;                          (format "%s %d '%s.pdf' '%s'"
;;                                  YaTeX-cmd-displayline line bnr cf))
;;                         ((string-match "evince" previewer)
;;                          (format "%s '%s.pdf' %d '%s'"
;;                                  "fwdevince" bnr line cf))
;;                         ;;
;;                         ;; These lines below for other PDF viewer is not confirmed
;;                         ;; yet. If you find correct command line, PLEASE TELL
;;                         ;; IT TO THE AUTHOR before publishing patch on the web.
;;                         ;; ..PLEASE PLEASE PLEASE PLEASE PLEASE PLEASE PLEASE..
;;                         ((string-match "sumatra" previewer)	;;??
;;                          (format "%s \"%s.pdf\" -forward-search \"%s\" %d"
;;                                  ;;Send patch to the author, please
;;                                  previewer bnr cf line))
;;                         ((string-match "qpdfview" previewer)	;;??
;;                          (format "%s '%s.pdf#src:%s:%d:0'"
;;                                  ;;Send patch to the author, please
;;                                  previewer bnr cf line))
;;                         ((string-match "okular" previewer)	;;??
;;                          (format "%s '%s.pdf#src:%d' '%s'"
;;                                  ;;Send patch to the author, please
;;                                  previewer bnr line cf))
;;                         )))
;;               (YaTeX-system cmd "jump-line" 'noask pdir)))))
;;       ))
;; c-c c-s ref 時に\label配置場所一覧に(sub)?numcases環境を追加
;; c-c c-s ref 時に自動生成するラベルの再定義
;;  (eval-after-load 'yatexadd
;;    `(progn
;;       (setq YaTeX::ref-mathenv-regexp (concat YaTeX::ref-mathenv-regexp "\\|\\(sub\\)?numcases")
;;             YaTeX-ref-generate-label-function 'my-yatex-generate-label)
;;       (defun my-yatex-generate-label (command value)
;;         (and (string= command "caption")
;;              (re-search-backward "\\\\begin{\\(figure\\|table\\)}" nil t)
;;              (setq command (match-string 1)))
;;         (let ((alist '(("chapter" . "chap")
;;                        ("section" . "sec")
;;                        ("subsection" . "subsec")
;;                        ("figure" . "fig")
;;                        ("table" . "tbl")
;;                        ("align" . "eq")
;;                        ("gather" . "eq")
;;                        ("numcases" . "eq")
;;                        ("subnumcases" . "eq")
;;                        ("equation" . "eq")
;;                        ("eqnarray" . "eq")
;;                        ("item" . "enu")))
;;               (labelname (replace-regexp-in-string
;;                           "\\(：\\|-\\)" ":"
;;                           (concat (if (> (length YaTeX-parent-file) 0)
;;                                       (concat (file-name-sans-extension
;;                                                (file-name-nondirectory
;;                                                 YaTeX-parent-file)) ":"))
;;                                   (file-name-sans-extension
;;                                    (file-name-nondirectory
;;                                     (buffer-name)))))))
;;           (if (setq command (cdr (assoc command alist)))
;;               (concat command ":"
;;                       (read-string "ユニークな番号などを入力してください: "
;;                                    (concat labelname ":" value)))
;;             (YaTeX::ref-generate-label nil nil))))
;;       ))
;;Yahtmlの設定
;;  (setq auto-mode-alist
;;        (cons (cons "\\.html?$" 'yahtml-mode) auto-mode-alist))
;;  (autoload 'yahtml-mode "yahtml" "Yet Another HTML mode" t)
;;  (setq yahtml-www-browser "/usr/bin/firefox"
;;        yahtml-always-/p t
;;        yahtml-fill-column 100;;default 72
;;        yahtml-kanji-code 4;;1:sjis 2:jis 3:euc
;;        ;;改行位置の設定
;;        fill-column 100);;default70以下[反映されず]
;; TeXのテンプレートを読み込みfilenameを現在のBuffer名に置き換える
(defun my-tex-filename-replace ()
  (interactive)
  (progn (goto-char 0)
         (insert-file-contents "~/Templates/template.tex")
         (goto-char 0)
         (perform-replace "filename"
                          (file-name-sans-extension (file-name-nondirectory (buffer-file-name)))
                          nil nil nil)
         (re-search-backward "pdftitle={" nil t)
         (goto-char (match-end 0))))
;; 記述の問題 include
(defun my-tex-kijutsu-insert-include ()
  (interactive)
  (let ((term (read-string "ターム等: " "前期"))
        (preposition (read-string "前置詞: "))
        (max (read-number "問題数: "))
        (no 0))
    (while (> max no)
      (progn (setq no (+ no 1))
             (insert (concat "\\HeadNumber"
                             (if (= no 1)
                                 "*")
                             "\n\\include{"
                             term "/"
;;			     (cond ((= termno 1) "中期/")
;;				   ((= termno 2) "後期/")
;;				   (t "前期/"))
;;			     (if (> (length preposition) 0)
;;				 (concat preposition "-"))
                             preposition
                             (number-to-string no)
                             "}\n"))))))
;; my-tex-kijutsu-iinsert-include の helm 版
(defun helm-tex-kijutsu-insert-include ()
  (interactive)
  (let ((term (helm :sources (helm-build-sync-source "Terms"
                               :candidates '("前期" "中期" "後期")
                               :migemo t
                               :action (lambda (candidate) (concat candidate)))
                    :buffer "*helm Term 選択*"))
        (preposition (read-string "前置詞: "))
        (max (read-number "問題数: "))
        (no 0))
    (while (> max no)
      (progn (setq no (+ no 1))
             (insert (concat "\\HeadNumber"
                             (if (= no 1)
                                 "*")
                             "\n\\include{"
                             term "/" preposition
                             (number-to-string no)
                             "}\n"))))))
;; TikZの塗りつぶしパターンを選択させる
  (defun my-tikz-fill-pattern ()
    (interactive)
    (progn (message "0:横 1:縦 2:右上 3:右下 4:グリッド 5:クロスハッチ 6:ドット 7:クロスハッチ・ドット 8:五芒星 9:六芒星 a:煉瓦 b:チェッカーボード")
           (let ((chr (read-char)))
             (insert (concat "pattern="
                             (cond ((char-equal chr ?0) "horizontal lines")
                                   ((char-equal chr ?1) "vertical lines")
                                   ((char-equal chr ?2) "north east lines")
                                   ((char-equal chr ?3) "north west lines")
                                   ((char-equal chr ?4) "grid")
                                   ((char-equal chr ?5) "crosshatch")
                                   ((char-equal chr ?6) "dots")
                                   ((char-equal chr ?7) "crosshatch dots")
                                   ((char-equal chr ?8) "fivepointed stars")
                                   ((char-equal chr ?9) "sixpointed stars")
                                   ((char-equal chr ?a) "bricks")
                                   ((char-equal chr ?b) "checkerboard")
                                   (t "error")))))))
;; my-tikz-fill-patter の helm 版
(defvar helm-tikz-fill-pattern--source
  (helm-build-sync-source "[TikZ] Fill Patterns"
    :candidates '(("水平線" . "horizontal lines")
                  ("垂直線" . "vertical lines")
                  ("右上" . "north east lines")
                  ("右下" . "north west lines")
                  ("グリッド" . "grid")
                  ("クロスハッチ" . "crosshatch")
                  ("ドット" . "dots")
                  ("五芒星" . "fivepointed stars")
                  ("六芒星" . "sixpointes stars")
                  ("煉瓦" . "bricks")
                  ("チェッカーボード" . "checkerboard"))
    :migemo t
    :action (lambda (candidate) (insert (format "pattern=%s" candidate)))))
(defun helm-tikz-fill-pattern ()
  (interactive)
  (helm :sources '(helm-tikz-fill-pattern--source)
        :buffer "*helm [TikZ] Fill Pattern*"))
;; TikzのLine Widthの選択
  (defun my-tikz-line-width ()
    (interactive)
    (progn (message "0:ultra thin 1:very thin 2:thin 3:semithick 4:thick 5:very thick 6:ultra thick 7:任意の太さ")
           (let ((chr (read-char)))
             (insert (cond ((char-equal chr ?0) "ultra thin")
                           ((char-equal chr ?1) "very thin")
                           ((char-equal chr ?2) "thin")
                           ((char-equal chr ?3) "semithick")
                           ((char-equal chr ?4) "thick")
                           ((char-equal chr ?5) "very thick")
                           ((char-equal chr ?6) "ultra thick")
                           (t (concat "line width=" (read-string "線の太さを指定: "))))))))
;; my-tikz-line-width の helm 版
(defvar helm-tikz-line-width--source
  (helm-build-sync-source "[TikZ] Line Width"
    :candidates `("ultra thin" "very thin" "thin" "semithick" "thick" "very thick" "ultra thick" "line width=")
    :migemo t
    :action #'insert))
(defun helm-tikz-line-width ()
  (interactive)
  (helm :sources '(helm-tikz-line-width--source)
        :buffer "*helm [TikZ] Line Width*"))
;; TikzのLine Capの選択
  (defun my-tikz-line-cap ()
    (interactive)
    (progn (message "0:round 1:butt(default) 2:rect")
           (let ((chr (read-char)))
             (insert (concat "line cap="
                             (cond ((char-equal chr ?0) "round")
                                   ((char-equal chr ?1) "butt")
                                   ((char-equal chr ?2) "rect")
                                   (t "error")))))))
;; my-tikz-line-cap の helm 版
(defvar helm-tikz-line-cap--source
  (helm-build-sync-source "[TikZ] Line Cap"
    :candidates '(("round" . "round")
                  ("butt(default)" . "butt")
                  ("rect" . "rect"))
    :migemo t
    :action (lambda (candidate) (insert (format "line cap=%s" candidate)))))
(defun helm-tikz-line-cap ()
  (interactive)
  (helm :sources '(helm-tikz-line-cap--source)
        :buffer "*helm [TikZ] Line Cap*"))
;; TikzのLine Joinの選択
(defun my-tikz-line-join ()
  (interactive)
  (progn (message "0:round 1:bevel 2:miter(default)")
         (let ((chr (read-char)))
           (insert (concat "line join="
                           (cond ((char-equal chr ?0) "round")
                                 ((char-equal chr ?1) "bevel")
                                 ((char-equal chr ?2) "miter")
                                 (t "error")))))))
;; my-tikz-line-join の helm 版
(defvar helm-tikz-line-join--source
  (helm-build-sync-source "[TikZ] Line Join"
    :candidates '(("round" . "round")
                  ("bevel" . "bevel")
                  ("miter(default)" . "miter"))
    :migemo t
    :action (lambda (candidate) (insert (format "line join=%s" candidate)))))
(defun helm-tikz-line-join ()
  (interactive)
  (helm :sources '(helm-tikz-line-join--source)
        :buffer "*helm [TikZ] Line Join*"))
;; TikzのDash Patternの選択
(defun my-tikz-line-dash ()
  (interactive)
  (let ((chr1)
        (chr2)
        (op1)
        (op2))
    (progn (message "0:dotted 1:dashed 2:dash dot 3:dash dot dot")
           (setq chr1 (read-char)
                 op1 (cond ((char-equal chr1 ?0) "dotted")
                           ((char-equal chr1 ?1) "dashed")
                           ((char-equal chr1 ?2) "dash dot")
                           ((char-equal chr1 ?3) "dash dot dot")))
           (message "0:normal 1:densely 2:loosely")
           (setq chr2 (read-char)
                 op2 (cond ((char-equal chr2 ?0) "")
                           ((char-equal chr2 ?1) "densely ")
                           ((char-equal chr2 ?2) "loosely ")))
           (insert (concat op2 op1)))))
;; my-tikz-line-dash の helm 版
(defvar helm-tikz-line-dash-gap--source
  (helm-build-sync-source "[TikZ] Dashline Gap"
    :candidates '("densely" "loosely")
    :migemo t
    :action (lambda (candidate) (concat candidate))))
(defvar helm-tikz-line-dash-type--source
  (helm-build-sync-source "[TikZ] Dashline Type"
    :candidates '("dotted" "dashed" "dash dot" "dash dot dot")
    :migemo t
    :action (lambda (candidate) (concat candidate))))
(defun helm-tikz-line-dash ()
  (interactive)
  (let ((gap (helm :sources '(helm-tikz-line-dash-gap--source)
                   :buffer "*helm [TikZ] Dashline Gap*"))
        (type (helm :sources '(helm-tikz-line-dash-type--source)
                    :buffer "*helm [TikZ] Dashline Type*")))
    (insert (concat gap (if (> (length gap) 0) " ") type))))
;;(defvar helm-tikz-line-dash-gap--source
;;  (helm-build-sync-source "TikZ Dash Line Gap"
;;    :candidates '("densely " "loosely ")
;;    :migemo t
;;    :action #'insert))
;;(defvar helm-tikz-line-dash-type--source
;;  (helm-build-sync-source "TikZ Dash Line Type"
;;    :candidates '("dotted" "dashed" "dash dot" "dash dot dot")
;;    :migemo t
;;    :action #'insert))
;;(defun helm-tikz-line-dash ()
;;  (interactive)
;;  (progn (helm :sources '(helm-tikz-line-dash-gap--source)
;;               :buffer "*helm TikZ Dashline Gap*")
;;         (insert " ")
;;         (helm :sources '(helm-tikz-line-dash-type--source)
;;               :buffer "*helm TikZ Dashline Type*")))
;; TikZのdoubleの設定
(defun my-tikz-line-double ()
  (interactive)
  (let ((double "double")
        (distance (read-string "内側のラインの間隔(.6pt): "))
        (linecenterdis (read-string "2本の線の中央間の間隔: ")))
    (insert (concat double
                    (if (> (length distance) 0)
                        (concat ",double distance=" distance))
                    (if (> (length linecenterdis) 0)
                        (concat ",double distance between line centers=" linecenterdis))))))
;; my-tikz-line-double の helm 版
(defvar helm-tikz-line-double-type--source
  (helm-build-sync-source "[TikZ] Line Double Type"
    :candidates '("double distance=" "double distance between line centers=")
    :migemo t
    :action #'insert))
(defun helm-tikz-line-double ()
  (interactive)
  (progn (insert "double,")
         (helm :sources '(helm-tikz-line-double-type--source)
               :buffer "*helm [TikZ] Line Double Types*")))
;; TikZのcolor指定
;; red、green、blue、cyan、magenta、yellow、black、gray、white、darkgray、lightgray、brown、lime、olive、orange、pink、purple、teal、violet
(defun my-tikz-color ()
  (interactive)
  (let ((chr))
    (progn (message "0:red 1:green 2:blue 3:cyan 4:magenta 5:yellow 6:black 7:gray 8:white 9:darkgray a:lightgray b:brown c:lime d:olive e:orange f:pink g:purple h:teal i:violet")
           (setq chr (read-char))
           (insert (cond ((char-equal chr ?0) "red")
                         ((char-equal chr ?1) "green")
                         ((char-equal chr ?2) "blue")
                         ((char-equal chr ?3) "cyan")
                         ((char-equal chr ?4) "magenta")
                         ((char-equal chr ?5) "yellow")
                         ((char-equal chr ?6) "black")
                         ((char-equal chr ?7) "gray")
                         ((char-equal chr ?8) "white")
                         ((char-equal chr ?9) "darkgray")
                         ((char-equal chr ?a) "lightgray")
                         ((char-equal chr ?b) "brown")
                         ((char-equal chr ?c) "lime")
                         ((char-equal chr ?d) "olive")
                         ((char-equal chr ?e) "orange")
                         ((char-equal chr ?f) "pink")
                         ((char-equal chr ?g) "purple")
                         ((char-equal chr ?h) "teal")
                         ((char-equal chr ?i) "violet")
                         (t "error"))))))
;; my-tikz-color の helm 版
(defvar helm-tikz-colors--source
  (helm-build-sync-source "[TikZ] color"
    :candidates '("red" "green" "blue" "cyan" "magenta" "yellow" "black" "gray" "white"
                  "darkgray" "lightgray" "brown" "lime" "olive" "orange" "pink" "purple" "teal" "violet")
    :migemo t
    :action #'insert))
(defun helm-tikz-colors ()
  (interactive)
  (helm :sources '(helm-tikz-colors--source) :buffer "*helm [TikZ] color*"))
;; TikZ \foreach の remember オプション
(defun my-tikz-foreach-remember ()
  (interactive)
  (insert (concat "remember="
                  (read-string "変数: " "\\P")
                  " as "
                  (read-string "変数を格納する制御綴: " "\\lastP")
                  " (initially "
                  (read-string "制御綴の初期値: " "A")
                  ")")))
;; TikZ \foreach の evaluate オプション
(defun my-tikz-foreach-evaluate ()
  (interactive)
  (insert (concat "evaluate="
                  (read-string "変数: " "\\x")
                  (if (y-or-n-p "変数を展開したものを別に使用しますか?: ")
                      (concat " as "
                              (read-string "変数を展開したものを格納する制御綴: " "\\xeval"))))))
;; TikZ plot のオプション
(defun my-tikz-plot-main-option ()
  (interactive)
  (let ((domain (concat (read-string "start domain(-5): " "\\xmin")
                        ":"
                        (read-string "end domain(5): " "\\xmax")))
        (samples (read-string "samples(25): "))
        (variable (read-string "variable(\\x): ")))
    (insert (concat "domain="
                    domain
                    (if (> (length samples) 0)
                        (concat ",samples="
                                samples))
                    (if (> (length variable) 0)
                        (concat ",variable="
                                variable))))))
;; TikZ opacity の group 指定
(defun my-tikz-transparency-group ()
  (interactive)
  (insert "\\begin{scope}[transparency group]\n\t\n\t\\end{scope}"))
;; TikZ decoration brace の指定
(defun my-tikz-decoration-brace ()
  (interactive)
  (insert (concat "decorate,decoration={brace"
                  (if (y-or-n-p "use mirror option?: ")
                      ",mirror")
                  (if (y-or-n-p "use raise option?: ")
                      (concat ",raise="
                              (read-string "raise value: ")))
                  "}")))
;; TikZ angle のオプション
(defun my-tikz-pic-angle ()
  (interactive)
  (let ((radius (read-string "radius(5mm): "))
        (eccentricity (read-string "eccentricity(.6): ")))
    (insert (concat (if (> (length radius) 0)
                        (concat "angle radius="
                                radius
                                (if (> (length eccentricity) 0)
                                    (concat ",angle eccentricity="
                                            eccentricity)))
                      (if (> (length eccentricity) 0)
                          (concat "angle eccentricity="
                                  eccentricity)))))))
;; tikzpicture 環境だけをpdfにするための関数
(defun my-pgf-graphic-named (beg end)
  (interactive "r")
  (let ((figfile (read-string "figファイル名: " (file-name-sans-extension (buffer-name)))))
    (progn (if (= beg end)
;;	       (insert (concat "\t\\includegraphics{\\PATH " figfile ".pdf}%\n"
               (insert (concat "\t\\IncludeGraphics{" figfile ".pdf}%\n"
                               "\t\\beginpgfgraphicnamed{\\PATH " figfile "}%\n"
                               "\t\\endpgfgraphicnamed\n"))
             (progn (goto-char (if (> beg end) beg end))
                    (insert "\t\\endpgfgraphicnamed\n")
                    (goto-char (if (> beg end) end beg))
;;		    (insert (concat "\t\\includegraphics{\\PATH " figfile ".pdf}%\n"
                    (insert (concat "\t\\IncludeGraphics{" figfile ".pdf}%\n"
                                    "\t\\beginpgfgraphicnamed{\\PATH " figfile "}%\n")))))))
;; TikZ の scope 環境を clip 付きで挿入する
(defun my-tikz-scope-with-clip ()
  (interactive)
  (let ((CoordLB (read-string "左下の座標: " "LB"))
        (CoordRT (read-string "右上の座標: " "RT"))
        (rectangle-name (read-string "矩形範囲の名前: " "frame")))
    (insert (concat "\\begin{scope}\n"
                    "\t\\clip"
                    (if (> (length rectangle-name) 0)
                        (concat "[name path global=" rectangle-name "]"))
                    "(" CoordLB ")rectangle(" CoordRT ");%\n"
                    "\t\\end{scope}"))))
;; align 環境にダミーの \Longleftrightarrow または = を配置する
(defun my-align-phantom ()
  (interactive)
  (insert (concat "&\\phantom{\\mbox{}"
                  (if (y-or-n-p "\\Longleftrightarrow ですか?: ") "\\Longleftrightarrow" "=")
                  "\\mbox{}}")))

;; node の概形を多角形にする
(defun my-tikz-node-polygon ()
  (interactive)
  (let ((sides (read-string "多角形の辺の個数を入力: " "5"))
        (minisize (read-string "外接円の直径を入力: " "8pt")))
    (insert (concat "regular polygon,regular polygon sides=" sides
                    ",minimum size=" minisize ",draw,inner sep=0pt"))))
;; tcolorbox の sidebyside align オプションの指定
(defun helm-tcolorbox-sidebyside-align ()
  (interactive)
  (progn (insert "sidebyside algin=")
         (helm :sources (helm-build-sync-source "[tcolorbox] sidebyside align"
                          :candidates '("center" "top" "bottom" "center seam" "top seam" "bottom seam")
                          :migemo t
                          :action #'insert)
               :buffer "*helm [tcolorbox] sidebyside align*")))
;; tcolorbox の frame の corner の指定
(defun helm-tcolorbox-sharp-corners ()
  (interactive)
  (progn (insert "sharp corners=")
         (helm :sources (helm-build-sync-source "[tcolorbox] sharp corners"
                          :candidates `("northwest" "northeast" "southwest" "southeast" "north"
                                        "south" "east" "west" "downhill" "uphill" "all")
                          :migemo t
                          :action #'insert)
               :buffer "*helm [tcolorbox] sharp corners*")))
;; tcolorbox の frame の corner の指定
(defun helm-tcolorbox-rounded-corners ()
  (interactive)
  (progn (insert "rounded corners=")
         (helm :sources (helm-build-sync-source "[tcolorbox] rounded corners"
                          :candidates `("northwest" "northeast" "southwest" "southeast" "north"
                                        "south" "east" "west" "downhill" "uphill" "all")
                          :migemo t
                          :action #'insert)
               :buffer "*helm [tcolorbox] rounded corners*")))
;; tcolorbox の text の配置
(defun helm-tcolorbox-text-halign ()
  (interactive)
  (progn (insert "halign=")
         (helm :sources (helm-build-sync-source "[tcolorbox] halign"
                          :candidates `("justify" "left" "flush left" "right" "flush right"
                                        "center" "flush center")
                          :migemo t
                          :action #'insert)
               :buffer "*helm [tcolorbox] halign*")))
;; tcolorbox の text の配置
(defun helm-tcolorbox-text-valign ()
  (interactive)
  (progn (insert "valign=")
         (helm :sources (helm-build-sync-source "[tcolorbox] valign"
                          :candidates `("top" "center" "bottom" "scale" "scale*")
                          :migemo t
                          :action #'insert)
               :buffer "*helm [tcolorbox] valign*")))
;; YaTeX でソースファイルのセーブ時に「、」を「，」に「。」を「．」に置換する
(defun replace-dot-comma ()
  (let ((curpos (point)))
    (goto-char (point-min))
    (while (search-forward "。" nil t) (replace-match "．"))
    (goto-char (point-min))
    (while (search-forward "、" nil t) (replace-match "，"))
    (goto-char curpos)))
;; \label および \ref をそれぞれ \spacelabel \spaceref に変換
(defun my-label-ref-space-add ()
  (interactive)
  (helm :sources (helm-build-sync-source "[MY] change label & ref command in spacename env"
        :candidates `("enum" "eq" "chapter" "section" "subsection" "subsubsection")
        :migemo t
        :action (lambda (candidates)
                  (progn (goto-char 0)
                         (while (search-forward "\\label" nil t)
                           (replace-match "\\\\spacelabel"))
                         (goto-char 0)
                         (while (search-forward "\\ref" nil t)
                           (replace-match (format "\\\\spaceref{%s}" candidates))))))))
;; tikz において 浮動小数点の設定を挿入する
(defun my-pgf-fpu-sci-format-insert ()
  (interactive)
  (insert "\\pgfkeys{/pgf/fpu,/pgf/fpu/output format=fixed}%\n"))
;; 【証明】と\qedを挿入し行頭を揃えるため\prnindも挿入する
(defun my-insert-shoumei ()
  (interactive)
  (insert "\\prnind【証明】\n\t\\qed"))
;; 括弧類の挿入
(defun my-insert-parens (beg end)
  (interactive "r")
  (let ((lrflag (if (y-or-n-p "use \\left & \\right?: ") t nil)))
    (helm :sources (helm-build-sync-source "[MY] insert parens"
          :candidates `(("grouping `{ & }'" . "g")
                        ("parens `( & )'" . "p")
                        ("braces `\{ & \}'" . "b")
                        ("brackets `[ & ]'" . "r")
                        ("l & r angle `\\langle & \\rangle'" . "a")
                        ("l & r floor `\\lfloor & \\rfloor'" . "f")
                        ("l & r ceil `\\lceil & \\rceil'" . "c")
                        ("none" . "n"))
          :migemo t
          :action (lambda (candidates)
                    (progn (goto-char (if (> beg end) beg end))
                           (insert (concat (if lrflag "\\right")
                                           (cond ((string= candidates "g") "}")
                                                 ((string= candidates "p") ")")
                                                 ((string= candidates "b") "\\}")
                                                 ((string= candidates "r") "]")
                                                 ((string= candidates "a") "\\rangle")
                                                 ((string= candidates "f") "\\rfloor")
                                                 ((string= candidates "c") "\\rceil")
                                                 (t ""))))
                           (goto-char (if (> beg end) end beg))
                           (insert (concat (if lrflag "\\left")
                                           (cond ((string= candidates "g") "{")
                                                 ((string= candidates "p") "(")
                                                 ((string= candidates "b") "\\{")
                                                 ((string= candidates "r") "[")
                                                 ((string= candidates "a") "\\langle")
                                                 ((string= candidates "f") "\\lfloor")
                                                 ((string= candidates "c") "\\lceil")
                                                 (t ""))))))))))

(defun my-insert-half-paren (beg end)
  (interactive "r")
  (helm :sources (helm-build-sync-source "[MY] insert half paren"
                   :candidates `(("left paren `\\left( & \\right.'" . "lp")
                                 ("right paren `\\left. & \\right)'" . "rp")
                                 ("left brace `\\left\\{ & \\right.'" . "lb")
                                 ("right brace `\\left. & \\right\\}'" . "rb")
                                 ("left bracket `\\left[ & \\right.'" . "lB")
                                 ("right bracket `\\left. & \\right]'" . "rB"))
                   :migemo t
                   :action (lambda (candidates)
                             (progn (goto-char (if (> beg end) beg end))
                                    (insert (cond ((string= candidates "lp") "\\right.")
                                                  ((string= candidates "rp") "\\right)")
                                                  ((string= candidates "lb") "\\right.")
                                                  ((string= candidates "rb") "\\right\\}")
                                                  ((string= candidates "lB") "\\right.")
                                                  ((string= candidates "rB") "\\right]")
                                                  (t "")))
                                    (goto-char (if (> beg end) end beg))
                                    (insert (cond ((string= candidates "lp") "\\left(")
                                                  ((string= candidates "rp") "\\left.")
                                                  ((string= candidates "lb") "\\left\\{")
                                                  ((string= candidates "rb") "\\left.")
                                                  ((string= candidates "lB") "\\left[")
                                                  ((string= candidates "rB") "\\left.")
                                                  (t ""))))))))
(add-hook 'yatex-mode-hook
          '(lambda ()
             (add-hook 'before-save-hook 'replace-dot-comma nil 'make-it-local)))
;; http://emacs.rubikitch.com/use-package-2/
;;(require 'use-package);;spacemacsではすでに読みこまれているらしい
(bind-keys :map evil-motion-state-map
           ("SPC y a a p" . my-align-phantom)
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
  (add-to-list 'helm-completing-read-handlers-alist '(YaTeX-change-environment . nil))
  )
(provide 'tex-setting)
