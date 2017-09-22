  (autoload 'yatex-mode "yatex" "Yet Another LaTeX mode" t)
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
;;	YaTeX-template-file "~/テンプレート/template.tex"
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
        YaTeX-japan t
;;        YaTeX-help-file $doc-directory/../../site-lisp/YATEXHLP.ja
        )
  (fset 'YaTeX-intelligent-newline-centerenum 'YaTeX-intelligent-newline-itemize)
  (fset 'YaTeX-intelligent-newline-centerenum* 'YaTeX-intelligent-newline-itemize)
  (fset 'YaTeX-intelligent-newline-hlist 'YaTeX-intelligent-newline-itemize)
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
  (setq auto-mode-alist
        (cons (cons "\\.html?$" 'yahtml-mode) auto-mode-alist))
  (autoload 'yahtml-mode "yahtml" "Yet Another HTML mode" t)
  (setq yahtml-www-browser "/usr/bin/firefox"
        yahtml-always-/p t
        yahtml-fill-column 100;;default 72
        yahtml-kanji-code 4;;1:sjis 2:jis 3:euc
        ;;改行位置の設定
        fill-column 100);;default70以下[反映されず]
;; TeXのテンプレートを読み込みfilenameを現在のBuffer名に置き換える
  (defun my-tex-filename-replace ()
    (interactive)
    (progn (goto-char 0)
           (insert-file-contents "~/テンプレート/template.tex")
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
                 (insert (concat "\t\\IncludePDF{" figfile ".pdf}%\n"
                                 "\t\\beginpgfgraphicnamed{\\PATH " figfile "}%\n"
                                 "\t\\endpgfgraphicnamed\n"))
               (progn (goto-char (if (> beg end) beg end))
                      (insert "\t\\endpgfgraphicnamed\n")
                      (goto-char (if (> beg end) end beg))
                      ;;		    (insert (concat "\t\\includegraphics{\\PATH " figfile ".pdf}%\n"
                      (insert (concat "\t\\IncludePDF{" figfile ".pdf}%\n"
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
(provide 'tex-setting)
