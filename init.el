;; load-pathを追加する関数
(defun add-to-load-path (&rest paths)
  (let (path)
    (dolist (path paths paths)
      (let ((default-directory (expand-file-name (concat user-emacs-directory path))))
	(add-to-list 'load-path default-directory)
	(if (fboundp 'normal-top-level-add-subdirs-to-load-path)
	    (normal-top-level-add-subdirs-to-load-path))))))
;; elispとconfディレクトリをサブディレクトリごとload-pathに追加
(add-to-load-path "/site-lisp")
;;; 日本語環境設定
(set-language-environment "utf-8")
;;;; メニューを日本語化する
;(require 'menu-tree)
;(dolist (x (list global-map vc-menu-map menu-bar-bookmark-map
;		 minibuffer-local-map emacs-lisp-mode-map))
;  (setcdr x (copy-tree x)))
(if (> emacs-major-version 23)
    ()
  (require 'menu-tree))
;;; Info
(require 'info)
(add-to-list 'Info-additional-directory-list "~/.emacs.d/info")
;; ウィンドウの透け透け度 0-100 (0で透け透け)
(if window-system 
    (progn
      (set-frame-parameter nil 'alpha 85)))
;; 起動時のウィンドウの位置とサイズの指定
(setq initial-frame-alist
      '((top . 0)
	(left . 0)
	(width . 110)
	(height . 60)))
;;;; スクリーンの最大化
;;(set-frame-parameter nil 'fullscreen 'maximized)
;;; M-yでキルリングのリストを表示させる
(require 'anything-config)
(global-set-key (kbd "M-y") 'anything-show-kill-ring)
;;; キルリングとクリップボードを同期させる
(setq x-select-enable-primary t)
(cond (window-system
       (setq x-select-enable-clipboard t)))
;;; font-lockの設定
(global-font-lock-mode t)
;; cursor の blink を止める
(blink-cursor-mode 0)
;; 指定行にジャンプする
(global-set-key "\C-xj" 'goto-line)
;; isearch の文字を取得
;; C-s した後に C-d すれば search する文字の入力を省けることに。
(defun isearch-yank-char ()
  "Pull next character from buffer into search string."
  (interactive)
  (isearch-yank-string
   (save-excursion
     (and (not isearch-forward) isearch-other-end
          (goto-char isearch-other-end))
     (buffer-substring (point) (1+ (point))))))
(define-key isearch-mode-map "\C-d" 'isearch-yank-char)
;;; なぜかC-M-sが使えないのでC-M->に割当
(global-set-key (kbd "C-M->") 're-search-forward)
;;(global-set-key (kbd "C-M-<") 're-search-backward)
;;(global-set-key (kbd "C-M->") 'isearch-forward-regexp)
;;(global-set-key (kbd "C-M-<") 'isearch-backward-regexp)
;; http://d.hatena.ne.jp/tomoya/20090215/1234692209 を参考
;;;; M-x customize-face で default を設定する
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :stipple nil :background "lemon chiffon" :foreground "dark blue" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 100 :width normal :foundry "unknown" :family "Liberation Mono"))))
 '(my-face-spc-at-eol ((t (:foreground "SteelBlue1" :underline t))))
 '(my-face-tab ((t (:underline (:color "chartreuse" :style wave)))))
 '(my-face-zenkaku-spc ((t (:underline (:color "blue" :style wave))))))
;;;;英語フォントの設定
;;(set-face-attribute 'default nil
;;		    :family "Liberation Mono" ;; font
;;		    :height 100)    ;; font size
;;日本語フォントの設定
;;(set-fontset-font nil 'japanese-jisx0208
;;		  (font-spec :family "Sawarabi Mincho")) ;; font
(set-fontset-font nil 'japanese-jisx0208
		  (font-spec :family "Sawarabi Gothic")) ;; font
;;(set-fontset-font nil 'japanese-jisx0208
;;		  (font-spec :family "M+ 2c regular")) ;; font
;;半角と全角の比を1:2にしたければ，
(setq face-font-rescale-alist
      '((".*Sawarabi Gothic.*" . 1.2)))
;;(setq face-font-rescale-alist
;;      '((".*TakaoExゴシック.*" . 1.1)
;;	(".*Liberation Mono.*" . 1.1)))
;;regionの色を変更
(set-face-background 'region "#afa");#RGB
;; http://openlab.dino.co.jp/2008/07/15/233005294.html を参考
;; タブ・全角空白・行末の空白文字列を目立たせる
;; Show tab, zenkaku-space, white spaces at end of line
;; http://www.bookshelf.jp/soft/meadow_26.html#SEC317
(defface my-face-tab         'my-face-tab nil :group 'my-faces);Yellow->#eff
(defface my-face-zenkaku-spc 'my-face-zenkaku-spc nil :group 'my-faces);LightBlue->
(defface my-face-spc-at-eol  'my-face-spc-at-eol nil :group 'my-faces);Red->#fcf
(defvar my-face-tab         'my-face-tab)
(defvar my-face-zenkaku-spc 'my-face-zenkaku-spc)
(defvar my-face-spc-at-eol  'my-face-spc-at-eol)
(defadvice font-lock-mode (before my-font-lock-mode ())
  (font-lock-add-keywords
   major-mode
   '(("\t" 0 my-face-tab append)
     ("　" 0 my-face-zenkaku-spc append)
     ("[ \t]+$" 0 my-face-spc-at-eol append)
     )))
(ad-enable-advice 'font-lock-mode 'before 'my-font-lock-mode)
(ad-activate 'font-lock-mode)
;; settings for text file
(add-hook 'text-mode-hook
          '(lambda ()
             (progn
               (font-lock-mode t)
               (font-lock-fontify-buffer))))
;; evince との連携
(require 'dbus)

(defun un-urlify (fname-or-url)
  "A trivial function that replaces a prefix of file:/// with just /."
  (if (string= (substring fname-or-url 0 8) "file:///")
      (substring fname-or-url 7)
    fname-or-url))

(defun evince-inverse-search (file linecol &rest ignored)
  (let* ((fname (un-urlify file))
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

;;forward-serach

(require 'synctex-for-evince-yatex)
(synctex-for-evince-dbus-initialize)
(add-hook 'yatex-mode-hook
	  '(lambda ()
	     (YaTeX-define-key "f" 'synctex-for-evince-yatex-forward-search)))

;; YaTeXの設定
(autoload 'yatex-mode "yatex" "Yet Another LaTeX mode" t)
(setq auto-mode-alist
      (append '(("\\.tex$" . yatex-mode)
                ("\\.ltx$" . yatex-mode)
                ("\\.cls$" . yatex-mode)
                ("\\.sty$" . yatex-mode)
                ("\\.clo$" . yatex-mode)
                ("\\.bbl$" . yatex-mode)) auto-mode-alist))
;;(setq auto-mode-alist
;;      (cons (cons "\\.tex$" 'yatex-mode) auto-mode-alist))
(setq	load-path (cons "~/.emacs.d/site-lisp/yatex" load-path)
	tex-command "/usr/local/bin/platex"
	dvi2-command "/usr/bin/evince"
	tex-pdfview-command "evince"
;;	dvi2-command "/usr/local/bin/xdvi"
;;	dvi2-command "c:/dviout/dviout -1 dvifilename \"# lineno *\""
;;	yatexhks.elで実装した
	YaTeX-inhibit-prefix-letter t;動く？
	YaTeX-template-file "~/iijima/template/template.tex"
	YaTeX-kanji-code 4;; 1:sjis 2:jis 3:euc 4:utf-8
;;	latex-message-kanji-code 4;;
	YaTeX-latex-message-code 'utf-8
	YaTeX-no-begend-shortcut t;;`[prefix] b ??' のショートカットを使わず、`[prefix] b' だけで補完入力に入る (`nil')
	YaTeX-fill-prefix "	"
	makeindex-command "mendex -g -s mystyle.ist "
	YaTeX-item-regexp "\\\\\\(eda\\)*item";;-->\\\(eda\)*item
;;itemの桁揃えの時に用いる、itemの正規表現 (`"\\\\(sub\\)*item"') <--嘘つきwww
	YaTeX-create-file-prefix-g t;;`\include'などで `prefix g'した時に、ジャンプ先が存在しないファイルであってもオープンする (`nil')
	YaTeX-fill-column 120;;反映される？
;;	YaTeX-ref-default-label-string (buffer-file-name)
	YaTeX-use-AMS-LaTeX t;align環境が数式モードのになるはず
	)
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
;;(eval-after-load "holidays"
;;  '(progn
(require 'japanese-holidays)
(setq calendar-holidays ; 他の国の祝日も表示させたい場合は適当に調整
      (append japanese-holidays local-holidays other-holidays)
      mark-holidays-in-calendar t); 祝日をカレンダーに表示
;; 土曜日・日曜日を祝日として表示する場合、以下の設定を追加します。
;; デフォルトで設定済み
(setq japanese-holiday-weekend '(0 6)     ; 土日を祝日として表示
      japanese-holiday-weekend-marker     ; 土曜日を水色で表示
      '(holiday nil nil nil nil nil japanese-holiday-saturday))
(add-hook 'calendar-today-visible-hook 'japanese-holiday-mark-weekend)
(add-hook 'calendar-today-invisible-hook 'japanese-holiday-mark-weekend)
(add-hook 'calendar-today-visible-hook 'calendar-mark-today)
;;“きょう”をマークするには以下の設定を追加します。
;;))
;; diaryの設定
(add-hook 'list-diary-entries-hook 'include-other-diary-files)
(add-hook 'mark-diary-entries-hook 'mark-included-diary-files)
;;(add-hook 'mark-diary-entries-hook 'mark-included-diary-files)
;;装飾日誌表示
(add-hook 'diary-display-hook 'fancy-diary-display)
(put 'narrow-to-region 'disabled nil)
;; 全角変換 M-x japanese-zenkaku-region
;; 半角変換 M-x japanese-hankaku-region
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
 '(next-line-add-newlines nil)
 '(show-paren-mode t)
 '(tool-bar-mode nil))
;; feedgeneratordで使用するmy-rss.pyの整形
;; 参考 http://d.hatena.ne.jp/gongoZ/20091127/1259330800
(defun my-rss-replace ()
  (interactive)
  (let* ((num-begin 0)
	 (num-end 0)
	 (rss-num 0)
	 (post-word (read-string "前置詞: " "//"))
	 (post-length (length post-word))
	 (search-word (concat "^" post-word "\\([0-9]+\\)$")))
    (progn (goto-char 0)
	   (while (re-search-forward search-word nil t)
	     (setq num-begin (+ (match-beginning 0) post-length)
		   num-end (match-end 0))
	     (narrow-to-region num-begin num-end)
	     (setq rss-num (string-to-number (buffer-string)))
	     (delete-region (point-min) (point-max))
	     (insert (number-to-string (+ rss-num 1)))
	     (widen)))))
(fset 'my-increment-number 'my-rss-replace)
;; Calenderでh m後に作られるhtmlファイルを整形するための関数
(defun my-calender2html ()
  (interactive)
  (progn (goto-char 0)
	 (re-search-forward "<HTML>\n<HEAD>" nil t)
	 (delete-region (match-beginning 0) (match-end 0))
	 (goto-char 0)
	 (while (re-search-forward "</?\\([[:upper:]]+\\)" nil t)
	   (downcase-region (match-beginning 0) (match-end 0)))
	 (goto-char 0)
	 (while (re-search-forward "[[:blank:]]+[[:upper:]]+[1-6]?\\([[:blank:]]\\|\.\\)" nil t)
	   (downcase-region (match-beginning 0) (match-end 0)))
	 (goto-char 0)
	 (perform-replace "name=\\([[:digit:]]+\\)" "id=\"\\1\"" nil t nil)
	 (goto-char 0)
	 (insert (concat "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
			 "<!DOCTYPE html>\n"
			 "<html xmlns=\"http://www.w3.org/1999/xhtml\" lang=\"ja\">\n"
			 "<head>\n"
			 "<meta charset=\"utf-8\" />\n"
			 "<meta http-equiv=\"content-type\" content=\"text/html\" />\n"
			 "<meta name=\"robots\" content=\"noindex,nofollow\" />\n"
			 "<meta name=\"author\" content=\"Toru Iijima\" />\n"))
	 (re-search-forward "<style[^>]+>")
	 (goto-char (+ (match-end 0) 1))
	 (insert "<!--\n")
	 (re-search-forward "</style>" nil t)
	 (goto-char (match-beginning 0))
	 (insert "-->\n")
	 ;;  (goto-char 0)
	 (re-search-forward "cal\.css" nil t)
	 (goto-char (match-beginning 0))
	 (insert "../")))

;;選択範囲内の全角英数字を半角英数字に変換
(defun hankaku-eisuu-region (start end)
  (interactive "r")
  (while (string-match
	  "[−！？０-９Ａ-Ｚａ-ｚ（）？！＝]+"
;;          "[０-９Ａ-Ｚａ-ｚ]+"
          (buffer-substring start end))
    (save-excursion
      (japanese-hankaku-region
       (+ start (match-beginning 0))
       (+ start (match-end 0))))))
;; TeXのテンプレートを読み込みfilenameを現在のBuffer名に置き換える
(defun my-tex-filename-replace ()
  (interactive)
  (progn (goto-char 0)
	 (insert-file-contents "~/iijima/template/template.tex")
	 (goto-char 0)
	 (perform-replace "filename"
			  (file-name-sans-extension (file-name-nondirectory (buffer-file-name)))
			  nil nil nil)
	 (re-search-backward "pdftitle={" nil t)
	 (goto-char (match-end 0))))
;; 記述の問題 include
(defun my-tex-kijutsu-insert-include ()
  (interactive)
  (let ((termno (read-number "0:前期 1:中期 2:後期 ? "))
	(preposition (read-string "前置詞: "))
	(max (read-number "問題数: "))
	(no 0))
    (while (> max no)
      (progn (setq no (+ no 1))
	     (insert (concat "\\HeadNumber"
			     (if (= no 1)
				 "*")
			     "\n\\include{"
			     (cond ((= termno 1) "中期/")
				   ((= termno 2) "後期/")
				   (t "前期/"))
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
;; mdframed の枠線を dashed にする
(defun my-tikz-mdframed-dashed ()
  (interactive)
  (insert (concat "linecolor=white,tikzsetting={dashed,"
		  "draw=" (read-string "破線の色: " "black") ","
		  "line width=" (read-string "破線の太さ: " ".4pt") ","
		  "dash pattern=on " (read-string "破線の実線の長さ: " "2pt")
		  " off " (read-string "破線の空白の長さ: " "2pt")
		  "}")))
;; mdframed のオプションを出力する
(defun my-tikz-mdframed-option ()
  (interactive)
  (insert (concat "\n% 環境外部の寸法パラメータ"
		  "\n%\tskipabove[0pt]                   skipbelow[0pt]"
		  "\n%\tleftmargin[0pt]                  rightmargin[0pt]"
		  "\n% 環境内部の寸法パラメータ"
		  "\n%\tinnertopmargin[5pt]              innerbottommargin[5pt]"
		  "\n%\tinnerleftmargin[10pt]            innerrightmargin[10pt]"
		  "\n% Frame部分の設定パラメータ"
		  "\n%\tlinewidth[.4pt]                  innerlinewidth[0pt]"
		  "\n%\tmiddlelinewidth[0pt]             outerlinewidth[0pt]"
		  "\n%\troundcorner[0pt]"
		  "\n%\tlinecolor[black]                 innerlinecolor[black]"
		  "\n%\tmiddlelinecolor[black]           outerlinecolor[black]"
		  "\n% 環境内部に関するパラメータ"
		  "\n%\tbackgroundcolor[white]           fontcolor[black]"
		  "\n%\ttopline[true]                    bottomline[true]"
		  "\n%\tleftline[true]                   rightline[true]"
		  "\n%\thidealllines[false]"
		  "\n% 改ページに関するパラメータ"
		  "\n%\tnobreak[false]                   everyline[false]"
		  "\n%\tsplittopskip[0pt]                splitbottomskip[0pt]"
		  "\n% タイトルに関するパラメータ"
		  "\n%\tframetitle[none]                 frametitlefont[\\normalfont\\bfseries]"
		  "\n%\tframetitlealignment[\\raggedleft] frametitlerule[false]"
		  "\n%\tframetitlerulewidth[.2pt]        frametitleaboveskip[5pt]"
		  "\n%\tframetitlebelowskip[5pt]         frametitlebackgroundcolor[backgroundcolor]"
		  "\n%\trepeatframetitle[false]"
		  "\n% その他のパラメータ"
		  "\n%\tuserdefinedwidth[\\linewidth]     align[left]")))

;; tikzpicture 環境だけをpdfにするための関数
(defun my-pgf-graphic-named (beg end)
  (interactive "r")
  (let ((figfile (read-string "figファイル名: " (file-name-sans-extension (buffer-name)))))
    (progn (if (= beg end)
	       (insert (concat "\t\\includegraphics{\\PATH " figfile ".pdf}%\n"
			       "\t\\beginpgfgraphicnamed{\\PATH " figfile "}%\n"
			       "\t\\endpgfgraphicnamed\n"))
	     (progn (goto-char (if (> beg end) beg end))
		    (insert "\t\\endpgfgraphicnamed\n")
		    (goto-char (if (> beg end) end beg))
		    (insert (concat "\t\\includegraphics{\\PATH " figfile ".pdf}%\n"
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

;; Diaryで入力したテキストを整形するための関数
(defun my-replace-string ()
  (interactive)
  (let ((FORM "")
	(REPLACEMENT "")
	(loopno 0))
    (goto-char 0)
    (while (re-search-forward "\\([−！？０-９Ａ-Ｚａ-ｚ（）？！＝]+\\)" nil t)
      (japanese-hankaku-region (match-beginning 0) (match-end 0)))
    (while (< loopno (length my-replace-list))
      (progn
	(setq FORM (car (nth loopno my-replace-list)))
	(setq REPLACEMENT (nth 1 (nth loopno my-replace-list)))
	(goto-char 0)
	(perform-replace FORM REPLACEMENT nil nil nil))
      (setq loopno (1+ loopno)))
    (setq loopno 0)
    (while (< loopno (length my-replace-reg-list))
      (progn
	(setq FORM (car (nth loopno my-replace-reg-list)))
	(setq REPLACEMENT (nth 1 (nth loopno my-replace-reg-list)))
	(goto-char 0)
	(perform-replace FORM REPLACEMENT nil 1 nil))
      (setq loopno (1+ loopno)))))
(setq my-replace-list
      `(("％" "%")
	("、" "，")
	("。" "．")
	("－" "-"))
      my-replace-reg-list
      `(("\\([0-9]+\\)\\(・\\|．\\)\\([0-9]+\\)" "\\1.\\3")
	("\\([0-9]+\\)[./]\\([0-9]+\\)[./]\\([0-9]+\\) \\([0-9]+\\):\\([0-9]+\\)\\(更新\\)*" "\\1年\\2月\\3日 \\4時\\5分")))
(defun my-html-tag-set (beg end)
  (interactive "r")
  (let* ((temp)
	 (first-char-flag 0)
	 (attr-body)
	 (common-list '("id" "class" "lang" "title"))
	 (tag-name (read-string "タグを指定して下さい: "))
	 (flag (assoc tag-name attr-alist))
	 (attr-list (append common-list (cdr (assoc tag-name attr-alist)))))
    (if flag
	(progn ;;(setq attribute-list (my-list-set a-attribute-list))
	  (while (> (length attr-list) 0)
	    (setq temp (read-string (format "%s:%d " (car attr-list) (length attr-list)))
		  attr-body (concat attr-body
				    (if (> (length temp) 0)
					(concat (if (> (length attr-body) 0) " " "")
						(format "%s=\"%s\"" (car attr-list) temp)) ""))
		  attr-list (cdr attr-list)))
;;	  (message (format "[%s]" attr-body))
;;	  (goto-char (if (> beg end) beg end))
	  (narrow-to-region (if (> beg end) end beg) (if (> beg end) beg end))
	  (hankaku-eisuu-region (point-min) (point-max))
	  (goto-char (point-min))
	  (perform-replace "\\(　\\| \\|\t\\)+$" "" nil 1 nil)
	  (goto-char (point-max))
	  (if (> (length (assoc tag-name single-tag-alist)) 0)
	      (insert (format "<%s%s%s />" tag-name (if (> (length attr-body) 0) " " "") attr-body))
	    (progn (insert (format "</%s>" tag-name))
		   (goto-char (point-min))
;		   (goto-char (if (> beg end) end beg))
		   (while (or (string= (string (following-char)) "　")
			      (string= (string (following-char)) " ")
			      (string= (string (following-char)) "\t"))
		     (delete-char 1))
		   (insert (format "<%s%s%s>" tag-name (if (> (length attr-body) 0) " " "") attr-body))))
	  (widen)) "")))


(setq single-tag-alist
      '(("area")("base")("br")("col")("embed")("img")("hr")("input")("keygen")("link")("meta")("param")("source")("track"))
      attr-alist
      '(
	("a" "href" "hreflang" "media" "rel" "target" "type")
	("abbr")
	("address")
	("area" "alt" "coords" "href" "hreflang" "media" "rel" "shape" "target" "type")
	("article")
	("aside")
	("audio" "autoplay" "controls" "loop" "preload" "src")
	("b")
	("base" "href" "target")
	("bdi")
	("bdo" "dir")
	("blockquote" "cite")
	("body")
	("br");single tag
	("button" "autofocus" "disabled" "form" "formaction" "formenctype" "formmethod" "formnovalidate" "formtarget" "name" "type" "value")
	("canvas" "height" "width")
	("caption")
	("cite")
	("code")
	("col" "span")
	("colgroup" "span")
	("command" "checked" "disabled" "icon" "label" "radiogroup" "type")
	("datalist")
	("dd")
	("del" "cite" "datetime:YYYY-MM-DDThh:mm:ssTZD")
	("details" "open")
	("dfn")
	("div")
	("dl")
	("dt")
	("em")
	("embed" "height" "src" "type" "width")
	("fieldset" "disabled" "form" "name")
	("figcaption")
	("figure")
	("footer")
	("form" "accept-charset" "action" "autocomplate" "enctype" "method" "name" "novalidate" "target")
	("h1")
	("h2")
	("h3")
	("h4")
	("h5")
	("h6")
	("head")
	("header")
	("hgroup")
	("hr");single tag
	("html" "manifest" "xmlns")
	("i")
	("iframe" "height" "name" "sandbox" "seamless" "src" "srcdoc" "width")
	("img" "src" "alt" "height" "ismap" "usemap" "width")
	("input" "accept" "alt" "autocomplate" "autofocus" "checked" "disabled" "form" "formaction" "formenctype" "formmethod" "formnovalidate" "formtaget" "height" "list" "max" "maxlength" "min" "multiple" "name" "pattern" "placeholder" "readonly" "required" "size" "src" "step" "type" "value" "width")
	("ins" "cite" "datetime=YYYY-MM-DDThh:mm:ssTZD")
	("kbd")
	("keygen" "autofocus" "challenge" "disabled" "form" "keytype" "name")
	("legend")
	("li" "value")
	("link" "href" "hreflang" "media" "rel" "sizes" "type")
	("map" "name")
	("mark")
	("menu" "label" "type")
	("meta" "charset" "content" "http-equiv" "name")
	("meter" "form" "high" "low" "max" "min" "optimum" "value")
	("nav")
	("noscript")
	("object" "data" "form" "height" "name" "type" "usemap" "width")
	("ol" "reversed" "start" "type")
	("optgroup" "label" "disabled")
	("option" "disabled" "label" "selected" "value")
	("output" "for" "form" "name")
	("p")
	("param" "name" "value")
	("pre")
	("progress" "max" "value")
	("q" "cite")
	("rp")
	("rt")
	("ruby")
	("s")
	("samp")
	("script" "async" "defer" "type" "charset" "src" "xml:space")
	("section")
	("select" "autofocus" "desabled" "form" "multiple" "name" "size")
	("small")
	("source" "media" "src" "type")
	("span")
	("strong")
	("style" "type" "media" "scoped")
	("sub")
	("summary")
	("sup")
	("table" "border")
	("tbody")
	("td" "colspan" "headers" "rowspan")
	("textarea" "autofocus" "cols" "disabled" "form" "maxlength" "name" "placeholder" "readonly" "required" "rows" "wrap")
	("tfoot")
	("th" "colspan" "headers" "rowspan" "scope")
	("thead")
	("time" "datetime" "pubdate")
	("title")
	("tr")
	("track" "default" "kind" "label" "src" "srclang")
	("ul")
	("var")
	("video" "autoplay" "controls" "height" "loop" "muted" "poster" "preload" "src" "width")
	("wbr")
	)
      rel-list
      '("alternate" "author" "bookmark" "help" "license" "next" "nofollow" "noreferrer" "prefetch" "prev" "search" "tag")
      shape-list
      '("default" "rect" "circle" "poly")
      target-list
      '("_blank" "_parent" "_self" "_topframename")
      bdo-list
      `("ltr" "rtl")
      formtarget-list
      '("_blank" "_parent" "_self" "_topframename")
      command-type-list
      '("checkbox" "command" "radio")
      form-method-list
      '("get" "post")
      form-target-list
      '("_blank" "_self" "_parent" "_top")
      iframe-sandbox-list
      '("\"\"" "allow-forms" "allow-same-origin" "allow-scripts" "allow-top-navigation")
      input-autocomplate-list
      '("on" "off")
      input-type-list
      '("button" "checkbox" "color" "date" "datetime" "datetime-local" "email" "file" "hidden" "image" "manth" "number" "password" "radio" "range" "reset" "search" "submit" "tel" "text" "time" "url" "week")
      keygen-keytype-list
      '("rsa" "dsa" "ec")
      link-rel-list
      '("alternate" "archives" "autor" "bookmark" "external" "first" "help" "icon" "last" "licence" "next" "nofollow" "noreferrer" "pingback" "prefetch" "prev" "search" "sidebar" "stylesheet" "tag" "up")
      menu-type-list
      '("context" "toolbar" "list")
      meta-http-equive-list
      '("content-type" "default-style" "refresh")
      meta-name-list
      '("application-name" "autor" "description" "generatorkeywords")
      ol-type-list
      '("1" "A" "a" "I" "i")
      textarea-wrap-list
      '("hard" "soft")
      th-scope-list
      '("col" "colgroup" "row" "rowgroup")
      track-kind-list
      '("captions" "chapters" "descriptions" "metadata" "subtitles")
      video-preload-list
      '("auto" "metadata" "none")
      )

(defun my-ruby-set (beg end)
  (interactive "r")
  (let ((starttag "<ruby>")
	(middletag "<rp>(</rp><rt>")
	(endtag "</rt><rp>)</rp></ruby>")
	(ruby (read-string "ふりがな: ")))
    (save-excursion
      (progn (if (= (length ruby) 0)
		 (progn (goto-char end)
			(if (string= (string (following-char)) "(")
			    (progn (re-search-forward "\([^)]+\)");(mark-sexp);
				   (setq ruby (substring
					       (buffer-substring (match-beginning 0) (match-end 0))
					       1 (- (match-end 0) (match-beginning 0) 1)))
				   (kill-region (match-beginning 0) (match-end 0))))))
	     (goto-char end)
	     (insert middletag)
	     (if (= (length ruby) 0)
		 (setq ruby (read-string "ルビを指定してください: ")))
	     (insert ruby)
	     (insert endtag)
	     (goto-char beg)
	     (insert starttag)))
    (goto-char (+ end (length starttag) (length middletag) (length ruby) (length endtag)))))

(defun my-html-lang-set (beg end)
  (interactive "r")
  (japanese-hankaku-region (if (> beg end) end beg)
			   (if (> beg end) beg end))
  (progn (goto-char (if (> beg end) beg end))
	 (insert "</span>")
	 (goto-char (if (> beg end) end beg))
	 (insert "<span lang=\"en-us\">")
	 (goto-char (+ (if (> beg end) beg end)
		       (length "</span>")
		       (length "<span lang=\"en-us\">")))))
(defun my-html-abbr-set (beg end)
  (interactive "r")
  (japanese-hankaku-region (if (> beg end) end beg)
			   (if (> beg end) beg end))
  (let* ((abbr-key (buffer-substring-no-properties beg end))
	 (abbr-value (nth 1 (assoc abbr-key my-html-abbr-alist)))
	 (abbr-value-jp (nth 2 (assoc abbr-key my-html-abbr-alist)))
	 (abbr-beg-tag (format "<abbr lang=\"en-us\" title=\"%s" abbr-value))
	 (abbr-end-tag "</abbr>"))
    (if (> (length abbr-value) 0)
	(progn (goto-char (if (> beg end) beg end))
	       (insert abbr-end-tag)
	       (goto-char (if (> beg end) end beg))
	       (if (> (length abbr-value-jp) 0)
		   (if (y-or-n-p (format "\"%s\"もtitleに設定しますか？" abbr-value-jp))
		       (setq abbr-beg-tag (format "%s,%s" abbr-beg-tag abbr-value-jp)) "") "")
	       (insert (format "%s\">" abbr-beg-tag))
	       (goto-char (+ (if (> beg end) beg end)
			     (length (format "%s\">%s" abbr-beg-tag abbr-end-tag)))))
      (message (format "\"%s\"はないなぁ :-<" abbr-key)))))
(setq my-html-abbr-alist
      '(
	("A2AD" "Anti Access Area Denial" "接近阻止・領域拒否")
	("A2/AD" "Anti Access Area Denial" "接近阻止・領域拒否")
	("AAAS" "American Association for the Advancement of Science" "アメリカ科学振興協会")
	("ABM" "antiballistic missile" "弾道弾迎撃ミサイル")
	("ABS" "anti-lock breke system")
	("ACSA" "Acquisition and Cross-Servicing Agreement" "物品役務相互提供協定")
	("ADB" "Asian Development Bank" "アジア開発銀行")
	("ADIZ" "Air Defense Identification Zone" "防空識別圏")
	("AFP" "Agence France-Presse")
	("AIIB" "Asian Infrastructure Investment Bank" "アジアインフラ投資銀行")
	("AIS" "automatic identification system" "自動船舶識別装置")
	("AP" "Associated Press")
	("APEC" "Asia-Pacific Economic Cooperration" "アジア太平洋経済協力会議")
	("ASAT" "anti-satelite weapon" "衛星攻撃兵器")
	("ASBM" "Anti-ship Ballistic Missile" "対艦弾道ミサイル")
	("ASEAN" "Association of SouthEast Asian Nations" "東南アジア諸国連合")
	("ASEM" "ASia-Europe Meeting" "アジア欧州会合")
	("ATM" "automatic teller machine")
	("AWACS" "Airborne Warning And Control System" "空中警戒管制機")
	("BBC" "British Broadcasting Corporation" "英国放送協会")
	("BBS" "bulletin board system")
	("bcc" "blind carbon copy")
	("BD" "Blu-ray Disc")
	("BMD" "Ballistic Missile Defense" "弾道ミサイル防衛")
	("BPO" "Broadcasting Ethics and Program Improvement Organization" "放送倫理・番組向上機構")
	("BSE" "bovine spongiform encephalopathy" "牛海綿状脳症")
	("cc" "carbon copy")
	("CD" "Compact Disc")
	("CDC" "Center for Disease Control and Prevention" "米国疾病予防管理センター")
	("CEO" "chief executive officer" "最高経営責任者")
	("CG" "Computer Graphics")
	("CIA" "Central Intelligence Agency" "米国中央情報局")
	("CIO" "chief infomation officer" "最高情報責任者")
	("CIS" "Commonwealth of Independent States" "独立国家共同体")
	("CPU" "Central Processing Unit" "中央演算処理装置")
	("CSIS" "Center for Strategic and International Studies" "戦略国際問題研究所")
	("CSS" "Cascading Style Sheets")
	("CTBT" "Comprehensive Nuclear-Test-Ban Treaty" "包括的核実験禁止条約")
	("CTBTO" "Comprehensive Nuclear-Test-Ban Treaty Organization" "包括的核実験禁止条約機関")
	("CTF" "Combined Task Force" "連合任務部隊")
	("CTF151" "Combined Task Force 151" "第151連合任務部隊")
	("CWC" "Chemical Weapons Convention" "化学兵器禁止条約")
	("DDoS" "distributed denial of services attack" "分散型サービス拒否攻撃")
	("DHA" "docosahexaenoic acid" "ドコサヘキサエン酸")
	("DIA" "Defense Intelligence Agency")
	("DMAT" "Disaster Medical Asistance Team" "災害派遣医療チーム")
	("DMZ" "demilitarized zone" "非武装地帯")
	("DNA" "DeoxyriboNucleic Acid" "デオキシリボ核酸")
	("DVD" "Digital Versatile Disc")
	("EAEC" "East Asia Economic Caucus" "東アジア経済会議")
	("EC" "European Community" "欧州共同体")
	("ECAFE" "Economic Commission for Asia and the Far East" "アジア極東経済委員会")
	("ECOSOC" "Economic and Social Council" "経済社会理事会")
	("EEZ" "Exclusive Economic Zone" "排他的経済水域")
	("EPA" "economic partnership agreement")
	("ESA" "European Space Agency" "欧州宇宙機関")
	("ESC" "Economic and Social Council" "経済社会理事会")
	("ESD" "education for sustainable development" "持続可能な開発のための教育")
	("EU" "European Union" "欧州連合")
	("FAO" "Food and Agriculture Organization of the United Nations" "国連食糧農業機関")
	("FATF" "Financial Action Task Force on Money Laundering" "金融活動作業部会")
	("FBI" "Federal Bureau of Investigation" "連邦捜査局")
	("FDA" "Food and Drug Administration" "食品医薬品局")
	("FMS" "foreign military sales" "対外有償軍事援助")
	("FRB" "Federal Reserve Board" "米連邦準備制度理事会")
	("FTA" "free trade agreement" "自由貿易協定")
	("FTAAP" "Free Trade Area of the Asia Pacific" "アジア太平洋自由貿易圏")
	("G7" "The Conference of Ministers and Governors of the Group of Seven" "主要7ヶ国財務相・中央銀行総裁会議")
	("GBI" "graund based interceptor")
	("GDP" "Gross Domestic Product" "国内総生産")
	("GHQ" "General Headquarters" "連合国軍最高司令官総司令部")
	("GNI" "Gross National Income" "国民総所得")
	("GNP" "Gross National Product" "国民総生産")
	("GPS" "Global Positioning System" "汎地球測位システム")
	("GRU" "Glavnoye Razvedyvatelnoye Upravleniye" "ロシア連邦軍参謀本部情報総局")
	("GSOMIA" "General Security of Military Information Agreement" "軍事情報包括保護協定")
	("HIV" "Human Immunodeficiency Virus")
	("HTML" "Hyper Text Markup Language")
	("HTTP" "hypertext transfer protocol")
	("IAEA" "International Atomic Energy Agency" "国際原子力機関")
	("IARC" "International Agency for Research on Cancer" "国際癌研究機関")
	("IBRD" "International Bank for Reconstruction and Development" "国際復興開発銀行")
	("ICAO" "International Civil Aviation Organization" "国際民間航空機関")
	("ICBM" "InterContinental Ballistic Missile" "大陸間弾道ミサイル")
	("ICC" "International Criminal Court" "国際刑事裁判所")
	("ICJ" "International Court of Justice" "国際司法裁判所")
	("ICPO" "International Criminal Police Organization" "国際刑事警察機構")
	("ICSID" "International Centre for Settlement of Investment Disputes" "国際投資紛争解決センター")
	("IDA" "International Development Association" "国際開発協会")
	("IFAD" "Internatilnal Fund for Agricultural Development" "国際農業開発基金")
	("IFC" "International Finance Corporation" "国際金融公社")
	("IHO" "International Hydrographic Organization" "国際水路機関")
	("ILO" "International Labor Organization" "国際労働機関")
	("IMF" "International Monetary Fund" "国際通貨基金")
	("IMO" "International Maritime Organization" "国際海事機関")
	("INES" "International Nuclear and Radiological Event Scale" "国際原子力事象評価尺度")
	("IOC" "International Olympic Committee" "国際オリンピック委員会")
	("IP" "Internet Protocol")
	("IPCC" "Intergovernmental Panel on Climete Change" "気候変動に関する政府間パネル")
	("iPS" "induces Pluripotent Stem cell")
	("ISAF" "International Security Assistance Force" "国際治安支援部隊")
	("ISIL" "Islamic State in Iraq and the Levant" "イラクとレバントのイスラーム国")
	("ISR" "intelligence, surveillance and reconnaissance" "情報・監視・偵察")
	("ISS" "International Space Station" "国際宇宙ステーション")
	("IT" "Infomation Technology" "情報技術")
	("ITU" "International Telecommunication Union" "国際電気通信連合")
	("IWC" "International Whaling Commission" "国際捕鯨委員会")
	("JA" "Japan Agricultural Cooperatives")
	("JAEA" "Japan Atomic Energy Agency" "日本原子力研究開発機構")
	("JAS" "Japanese Agricultural Standard" "日本農林規格")
	("JASDAQ" "Japan Securities Dealers Association Quotation System")
	("JASDF" "Japan Air Self-Defense Force" "航空自衛隊")
	("JASRAC" "Japanese Society for Rights of Authors, Composers and Publishers" "日本音楽著作権協会")
	("LAV" "Light Armored Vehicle")
	("JAXA" "Japan Aerospace Exploration Agency" "宇宙航空研究開発機構")
	("JBIC" "Japan Bank for International Cooperation" "国際協力銀行")
	("JICA" "Japan International Cooperation Agency" "国際協力機構")
	("JIS" "Japanese Industrial Standards" "日本工業規格")
	("JOGMEC" "Japan Oil, Gas and Metals National Corporation" "石油天然ガス・金属鉱物資源機構")
	("JR" "Japan Railways")
	("JRA" "Japan Racing Association" "日本中央競馬会")
	("JRCS" "Japanese Red Cross Society" "日本赤十字社")
	("J-PARC" "Japan Proton Accelerator Reserce Complex")
	("KGB" "Komitet Gosudarstvennoi Bezopasnosti")
	("LAN" "Local Area Network")
	("LCC" "Low-Cost Carrier" "格安航空会社")
	("LED" "Light Emitting Diode" "発光ダイオード")
	("LHC" "Large Hadron Collider" "大型ハドロン衝突型加速器")
	("LN" "League of Nations" "国際連盟")
	("LPG" "Liquefied Petroleum Gas" "液化石油ガス")
	("LNG" "liquefied natural gas" "液化天然ガス")
	("MD" "missile defense" "ミサイル防衛")
	("MERS" "Middle East Respiratory Syndrome" "中東呼吸器症候群")
	("MI6" "Military Intelligence 6")
	("MIGA" "Multilateral Investment Guarantee Agency" "多数国間投資保証機関")
	("MIRV" "Multiple Independently-targetable Reentry Vehicle")
	("MP" "Military Police" "米国陸軍憲兵隊")
	("MRI" "Magnetic Resonance Imaging" "磁気共鳴映像法")
	("NASA" "National Aeronautics and Space Administration" "アメリカ航空宇宙局")
	("NATO" "North Atlantic Treaty Organization" "北大西洋条約機構")
	("NEDO" "New Energy and Industrial Technology Develpment Organization" "新エネルギー・産業技術総合開発機構")
	("NGO" "NonGovernmental Organization" "非政府組織")
	("NHK" "Nippon Hoso Kyokai" "日本放送協会")
	("NHTSA" " National Highway Traffic Safety Administration" "国家道路交通安全局")
	("NICT" "Nationa Instirute of Information and Communications Technology" "情報通信研究機構")
	("NISC" "National Infomation Security Center" "内閣官房情報セキュリティセンター")
	("NLL" "Northern Limit Line" "北方境界線")
	("NOAA" "National Oceanic and Atmospheric Administration" "アメリカ海洋大気庁")
	("NORAD" "North American Aerospace Defense Command" "北アメリカ航空宇宙防衛司令部")
	("NPO" "Non-Profit Organization" "民間非営利団体")
	("NPT" "Non-Proliferation Treaty" "核不拡散条約")
	("NRC" "Nuclear Regulatory Commission" "原子力規制委員会")
	("NSA" "National Security Agency" "国家安全保障局")
	("NSC" "National Security Council" "国家安全保障会議")
	("NTT" "Nippon Telegraph and Telephone Company" "日本電信電話会社")
	("OCHA" "Office for the Coordination of Humanitarian Affairs" "国連人道問題調整部")
	("ODA" "Offcial Development Assistance" "政府開発援助")
	("OECD" "Organization for Economic Cooperation and Development" "経済協力開発機構")
	("OIE" "Office International des Epizooties" "国際獣疫事務局")
	("OPCW" "Organisation for the Prohibition of Chemical Weapons" "化学兵器禁止機関")
	("OS" "Operating System")
	("PAC3" "Patriot advanced capability 3")
	("PC" "Personal Computer")
	("PIF" "Pacific Islands Forum" "太平洋諸島フォーラム")
	("PKF" "PeaceKeeping Force" "国連平和維持軍")
	("PKO" "PeaceKeeping Operations" "国連平和維持活動")
	("PSI" "Proliferation Security Initiative" "大量破壊兵器拡散阻止構想")
	("PTA" "Parent-Teacher Association" "父母と教師の会")
	("ReCAAP" "Regional Cooperation Agreement on Combating Piracy and Armed Robbery against Ships in Asia" "アジア海賊対策地域協力協定")
	("RECAAP" "Regional Cooperation Agreement on Combating Piracy and Armed Robbery against Ships in Asia" "アジア海賊対策地域協力協定")
	("ROE" "Rules of Engagement" "部隊行動基準")
	("ROV" "remotely-operated vehicle" "水中無人探査機")
	("RSF" "Reporters Sans Fronti&#233;res" "国境なき記者団")
	("SAM" "surface-to-air missile" "地対空ミサイル")
	("SARS" "Severe Acute Respiratory Syndrome" "重症急性呼吸器症候群")
	("SAT" "scholastic assessment test" "大学進学適性試験")
	("SEC" "Securities and Exchange Commission" "米国証券取引委員会")
	("SF" "Science Fiction" "空想科学小説")
	("SIPRI" "Stockholm International Peace Research Institute" "ストックホルム国際平和研究所")
	("SLBM" "Submarine-Launched Ballistic Missile" "潜水艦発射弾道ミサイル")
	("SPC" "Special Purpose Company")
	("SNS" "Social Networking Service")
	("SOFA" "Japan Status of Forces Agreement")
	("SOSUS" "sound surveillance system")
	("SSBN" "Ballistic Missile Submarine Nuclear-Powered" "弾道ミサイル搭載原子潜水艦")
	("SSM" "surface-to-surface missile" "地対地ミサイル，地対艦ミサイル")
	("TC" "Trusteeship Council")
	("TEL" "transporter-elector-launcher")
	("THAAD" "terminal high altitude area defense" "最終段階高高度地域防衛")
	("TICAD" "Tokyo Internation Conference on Afrecan Development" "アフリカ開発会議")
	("TNT" "trinitrotoluene" "トリニトロトルエン")
	("TOEIC" "Test of English International Communication" "国際コミュニケーション英語能力テスト")
	("TPP" "Trans-Pacific Strategic Economic Partnership Agreement" "環太平洋戦略的経済連携協定")
	("UAE" "United Arab Emirates" "アラブ首長国連邦")
	("UFO" "Unidentified Flying Object" "未確認飛行物体")
	("UN" "United Nations" "国際連合")
	("UNC" "Charter of the United Nations" "国連憲章")
	("UNDOF" "United Nations Disengagement Observer Force" "国連兵力引き離し監視軍")
	("UNESCO" "United Nations Educational, Scientific and Cultural Organization" "国連教育科学文化機関")
	("UNGA" "United Nations General Assembly" "国連総会")
	("UNHCR" "Office of the United Nations High Commissioner for Refugees" "国連高等難民弁務官事務所")
	("UNIDO" "United Nations Industrial Development Organization" "国連工業開発機関")
	("UNSCEAR" "United Nations Scientific Committee on the Effects of Atomic Radiation")
	("UNTC" "United Nations Trusteeship Council")
	("UNODC" "United Nations Office on Drugs and Crime" "国連薬物犯罪事務所")
	("UPU" "Universal Postal Union" "万国郵便連合")
	("URL" "Uniform Resource Locator")
	("USGS" "United States Geological Survey" "アメリカ地質調査所")
	("VANK" "Voluntary Agancy Network Korean")
	("VIP" "very important person")
	("WBC" "World Baseball Classic")
	("WGIP" "War Guilt Information Program")
	("WHO" "World Health Organization" "世界保健機関")
	("Wi-Fi" "Wireless Fidelity")
	("WiFi" "Wireless Fidelity")
	("WIPO" "World Intellectual Property Organization" "世界知的所有権機関")
	("WMO" "World Meteorological Organization" "世界気象機関")
	("WTO" "World Trade Organization" "世界貿易機関")
	))
