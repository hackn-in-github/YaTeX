;; -*- Emacs-Lisp -*-
;;; Hooks for YaTeX

;;; 野鳥に関連する記述(たとえばアドイン関数)は yatexhks.el という名前の
;;; ファイルに入れてください。起動時に自動的にロードします。

;;; All the private definitions for YaTeX can be stuffed into the file
;;; named `yatexhks.el'.  The file `yatexhks.el' will be automatically
;;; loaded at the end of loading `yatex.el'.

;Private definitions begin from here.

;;97/1/27
(define-key YaTeX-user-extensional-map "v" 'YaTeX-section-overview)
;;initial version
(define-key YaTeX-user-extensional-map "0"
  '(lambda () (interactive) (YaTeX-make-section nil nil nil "part")))
(define-key YaTeX-user-extensional-map "1"
  '(lambda () (interactive) (YaTeX-make-section nil nil nil "chapter")))
(define-key YaTeX-user-extensional-map "2"
  '(lambda () (interactive) (YaTeX-make-section nil nil nil "section")))
(define-key YaTeX-user-extensional-map "3"
  '(lambda () (interactive) (YaTeX-make-section nil nil nil "subsection")))
(define-key YaTeX-user-extensional-map "4"
  '(lambda () (interactive) (YaTeX-make-section nil nil nil "subsubsection")))
(define-key YaTeX-user-extensional-map "5"
  '(lambda () (interactive) (YaTeX-make-section nil nil nil "paragraph")))
(define-key YaTeX-user-extensional-map "6"
  '(lambda () (interactive) (YaTeX-make-section nil nil nil "subparagraph")))
(define-key YaTeX-user-extensional-map "r"
  '(lambda () (interactive) (YaTeX-make-section nil nil nil "ref")))
(define-key YaTeX-user-extensional-map "i"
  '(lambda () (interactive) (YaTeX-make-singlecmd "item")))
(define-key YaTeX-user-extensional-map "\C-b"
  '(lambda () (interactive) (YaTeX-make-singlecmd "leftarrow")))
(define-key YaTeX-user-extensional-map "l"
  '(lambda () (interactive) (YaTeX-make-section nil nil nil "label")))
(define-key YaTeX-user-extensional-map "f"
  '(lambda () (interactive) (YaTeX-make-section nil nil nil "frac")))
(define-key YaTeX-user-extensional-map "S"
  '(lambda () (interactive) (YaTeX-make-section nil nil nil "setlength")))
(define-key YaTeX-user-extensional-map "b"
  '(lambda () (interactive) (YaTeX-make-fontsize nil "bf")))

(require 'for-emath-macro)
(require 'for-original-macro)

(fset 'YaTeX::eqref 'YaTeX::ref)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; YaTeX:read-position "htbp" --> [ht] などを作成
;; YaTeX:read-coordinates "(x,y) x,yとも単位付き数値 --> (1pt,2pt) などを作成"
;; (YaTeX:func arg) --> argを引数にしてYaTeX:func を呼び出す
;; (apply 'YaTeX:func arg) --> argを引数にしてYaTeX:func を呼び出すただし一番最後の引数はlistでなければいけない
;; (fset 'func1 'func2) --> func1 を func2 と同じ設定にする
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; YaTeX-my-dviout-search-and-jump
;;;
;;; dviout のジャンプ機能を Meadow から使えるようにする試み．
;;;
;;; [prefix] j で使用する `j' はjumpの意．YaTeX-define-keyを使って各々の環境に応じて変更可能．
;;; ポイントの側の文字列`strings'とその文字列がある行のファイル先頭からの行数`lineno'および
;;; 入力しているファイル名`texfile'とそのdviファイル名`dvifile'を
;;; ``dvi2-command'' に2つの引数 ``dvifile'' ``# lineno/strings texfile'' を渡す．
;;; `dvi2-command'はYaTeXの変数で各々の環境に合わせて設定する．通常は``c:/dviout/dviout''などとなっている．
;;; これはdvioutにパスが通っていれば``dviout''で構わないはずである．
;;;
;;; 通常は`dvifile'，`texfile'はカレントバッファに関するファイル名であるが，
;;; `YaTeX-my-dvifile'や`YaTeX-my-sourcefile'が`nil'以外のときはそれに従う．
;;; 例えば，ソースファイルが`main.tex'とそこから読み込まれる`sub.tex'のときは，`sub.tex'編集中に
;;; ``dviout sub.dvi "# lineno/search_strings sub.tex"''とdvioutを起動しても思うような結果にならない．
;;; ``dviout main.tex "# lineno/search_strings ./sub.tex"''としなければならないが，
;;; その際に`YaTeX-my-dvifile'に`main.dvi'，`YaTeX-my-sourcefile'に`./sub.tex'をセットしておくと
;;; 後者のようにdvioutに引数が送られる．詳しくはYaTeX-my-menuの説明で...
;;; この文字列のセットはYaTeX-my-menuで行なう．
(defvar YaTeX-my-dvifile nil)
(defvar YaTeX-my-sourcefile nil)
(YaTeX-define-key "j" 'YaTeX-my-dviout-tq)
(defun YaTeX-my-dviout-search-and-jump ()
  "Make a search condision from the number of lines and words of the region in current buffer,
send the condition to dviout and open a dvifile to the page that agree with the condition."
  (interactive)
  (let* ((basename (file-name-sans-extension (file-name-nondirectory (buffer-file-name))))
	 (texfile (if YaTeX-my-sourcefile YaTeX-my-sourcefile (concat basename ".tex")))
	 (dvifile (if YaTeX-my-dvifile YaTeX-my-dvifile (concat basename ".dvi")))
	 (lineno (+ (count-lines (point-min) (point)) (if (= (current-column) 0) 1 0)))
	 (searchstring (if (and transient-mark-mode mark-active)
			   (buffer-substring-no-properties (region-beginning) (region-end))
			 (thing-at-point 'word))))
    (if (> (length searchstring) 20)
	(message "Search string is too long. Set region again.\n:%s" searchstring)
      (progn (set-terminal-coding-system 'japanese-shift-jis)
	     (start-process "my-preview" "*search-and-jump*" dvi2-command dvifile
			    (format "# %d/%s %s" lineno searchstring texfile))))))
;; cmd 上では ``c:/dviout/dviout dvifilename "# lineno/search_strings texfilename"'' であるが
;; start-process では ``c:/dviout/dviout'' に ``dvifilename'' と ``# lineno/search_strings texfilename''
;; を渡している．これは ``"dvifilename"'' と ``"# lineno/search_strings texfilename"'' を渡しているのかな？
;; これで動作するのだから疑問に思わないことにする:-)
;; 暫定マークモードか否かで動作または使用する関数を変更する？
;; 取り敢えず，暫定マークモードかつ region が存在するときだけ region を利用して，
;; それ以外のときは thing-at-point を利用することにする．
;; 思い切って，thing-at-point を使わずに (interactive "r") にした方が使い勝手がいいのかな？
;; それとも，常に region を設定してから dviout を起動するのは手間かな？
;; 逆に，常に thing-at-point にしちゃう？
(defun my-tq-ans (x y)
  `(let ((x y))
    x))
(defun YaTeX-my-dviout-tq ()
  (interactive)
  (progn (list-processes)
	 (let* ((my-queue (tq-create (get-process "my-preview")))
		hoge tq-ans)
	   (tq-enqueue my-queue "[WinIconic]" "[-a-zA-Z0-9:/. \t\\]+" 'hoge 'my-tq-ans)
;;	   (message "mes:%s/%s" tq-ans hoge)
;;	   (tq-close my-queue)
)))
;; 備忘録
;;  (elt (member 'shift_jis (coding-system-list)) 1)
;;  set-terminal-coding-system CODING-SYSTEM
;;  encode-coding-string STRING CODING-SYSTEM
;;  detect-coding-string STRING HIGHEST
;;  find-coding-systems-string STRING
;;  shell-quote-argument
;;  file-name-nondirectory
;;  file-name-sans-extension
;;  dvi2-command は .emacs にて定義済み "c:/dviout/dviout"
;;  texputには対応していない...というか対応する必要はないよね
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; YaTeX-my-insert-paren
;;;
;;; regionを括弧で囲む
;;; 括弧といえば\left,\rightだよね
;;; ついでに数式環境もできるようにしたけど...
;;; YaTeX-insert-parens だと YaTeX の関数と衝突していた危ない危ない^^;
;;; ということで my を付加
(YaTeX-define-key "p" 'YaTeX-my-insert-paren)
(defun YaTeX-my-insert-paren (beg end)
  (interactive "r")
  (message (concat "(g)rouping:`{}' (b)race:`\\{\\}' (p)aren:`()' b(r)acket:`[]' less (t)han:`<>'\n"
		   "(m)ath:`$$' (d)isplay:`\\[\\]' (l)eft:`\\left\\right' "
		   "(s)elf:自分で設定 括弧類は大文字で\\left\\right付加"))
  (let* ((emchar (read-char))
	 (emleft (cond ((= emchar ?g) "{")
		       ((= emchar ?b) "\\{")
		       ((= emchar ?p) "(")
		       ((= emchar ?r) "[")
		       ((= emchar ?t) "<")
		       ((= emchar ?B) "\\left\\{")
		       ((= emchar ?P) "\\left(")
		       ((= emchar ?R) "\\left[")
		       ((= emchar ?T) "\\left<")
		       ((= emchar ?m) "$")
		       ((= emchar ?d) "\\[")
		       ((= emchar ?l) "\\left")
		       ((= emchar ?s) (read-string "左括弧を指定: "))
		       (t "")))
	 (emright (cond ((= emchar ?g) "}")
			((= emchar ?b) "\\}")
			((= emchar ?p) ")")
			((= emchar ?r) "]")
			((= emchar ?t) ">")
			((= emchar ?B) "\\right\\}")
			((= emchar ?P) "\\right)")
			((= emchar ?R) "\\right]")
			((= emchar ?T) "\\right>")
			((= emchar ?m) "$")
			((= emchar ?d) "\\]")
			((= emchar ?l) "\\right")
			((= emchar ?s) (read-string "右括弧を指定: "))
			(t ""))))
    (if (or (> (length emleft) 0)(> (length emright) 0))
	(progn (goto-char (if (> beg end) beg end))
	       (insert emright)
	       (goto-char (if (> beg end) end beg))
	       (insert emleft)
	       (goto-char (+ (if (> beg end) beg end) (length emleft) (length emright)))) "")))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; YaTeX-my-menu
;;;
;;; p で YaTeX-my-insert-paren を呼び出す(regionを設定していなければならない)．
;;; j で YaTeX-my-dviout-search-and-jump を呼び出す．
;;; t で 同じディレクトリにある texput.tex を開き %#!の行末のファイル名を texput に置き換える．
;;;   これはBEGIN-ENDの固定領域のタイプセットを行なうとき，その領域内にPerlの呼び出しに関わる
;;;   マクロがあると思うような表示がされないため，texput.texに一時的に移動して
;;;   ファイル名を`texput.tex'と編集し2度ほどコンパイルを行なってから元のソースファイルに戻ると
;;;   うまいこと固定領域のタイプセットを続けられるので，ファイル名を書き換えるのを自動化したもの．
;;;   変更したくないときは`q'で抜ければよい．
;;; s で ソースファイル内で\includeまたは\inputされているソースを編集する際に
;;;   \includeや\inputのある行にポイントを置きこれを実行しておく．
;;;   ただし，\includeや\inputは1行に1つかつこのコマンドしか書かれていないものとする．
;;;   main.texの\include{./sub.tex}においてこれを実行すると，
;;;   変数`YaTeX-my-dvifile'に`main.dvi'，変数`YaTeX-my-sourcefile'に`./sub.tex'が代入され，
;;;   YaTeX-my-dviout-search-and-jumpを実行するとdvioutに
;;;   ``main.dvi "# lineno/search_strings ./sub.tex"''が渡される．
;;;   また，\include{./hoge/sub.tex}の場合には`YaTeX-my-dvifile'に`../main.dvi'，
;;;   `YaTeX-my-sourcefile'に`./hoge/sub.tex'が代入され，dvioutに
;;;   ``../main.dvi "# lineno/search_strings ./hoge/sub.tex"''が渡される．
;;;   これは`./hoge/sub.tex'編集中に`main.dvi'を呼び出すときを考えると，
;;;   このときのカレントディレクトリは`./hoge/'でありここから`./main.dvi'を
;;;   呼び出そうとすると一つ上のディレクトリの`main.dvi'を呼び出すことになるのでdvioutには
;;;   ディレクトリ`./hoge/'から`../main.dvi'を読み込めと命令する必要がある．
;;;   さらに，その`./main.dvi'からみるとソースファイルは`./hoge/sub.tex'であるからサーチ&ジャンプの際は
;;;   TeXファイル名として`./hoge/sub.tex'を渡す必要があるからである．
;;;   また，\include，\inputの引数はカレントディレクトリを表す`./'が先頭に必ずあるものとしている．
;;;   先頭に\include{sub.tex}のように`./'がない場合は，"`YaTeX-my-sourcefile'の設定: sub.tex"
;;;   とデフォルト値を`sub.tex'として設定するファイル名を聞いてくるので，
;;;   先頭に`./'を付加して`./sub.tex'として入力をする．
;;; i で s で設定したファイル名をすべてnilにする．
(YaTeX-define-key "r" 'YaTeX-my-menu)
(defun YaTeX-my-menu ()
  (interactive)
  (message (concat "p)括弧付加 j)dvioutへの文字列サーチ&ジャンプ t)texput.texへ移動\n"
		   "s)`YaTeX-my-dvifile'および`YaTeX-my-sourcefile'の設定 "
		   "i)`YaTeX-my-dvifile'および`YaTeX-my-sourcefile'の初期化"))
  (let* ((emchar (read-char)))
    (cond ((= emchar ?p)(YaTeX-my-insert-paren (region-beginning) (region-end)))
	  ((= emchar ?j)(YaTeX-my-dviout-search-and-jump))
	  ((= emchar ?t)(progn (find-file "./texput.tex")
			       (perform-replace "[-0-9a-zA-Z]+$" "texput" t t nil)))
	  ((= emchar ?s)(save-excursion;;cond を save-excursion でくるむと insert-paren 終了後のカーソル位置も元に戻る
			  (setq-default
			   YaTeX-my-dvifile
			   (read-string
			    (format "%s: " "`YaTeX-my-dvifile'の設定")
			    (concat
			     (mapconcat
			      'concat
			      (make-list
			       (- (length (split-string
					   (buffer-substring-no-properties
					    (- (re-search-forward "\\(}\\| \\|$\\)") 1)
					    (+ (re-search-backward "\\({\\| \\)") 1)) "/" t)) 2)
			       "../") "")
			     (file-name-sans-extension (file-name-nondirectory (buffer-file-name)))
			     ".dvi"))
			   YaTeX-my-sourcefile
			   (read-string (format "%s: " "`YaTeX-my-sourcefile'の設定")
					(concat (buffer-substring-no-properties
						 (- (re-search-forward "\\(}\\| \\|$\\)") 1)
						 (+ (re-search-backward "\\({\\| \\)") 1))
						".tex")))))
	  ((= emchar ?i)(setq-default YaTeX-my-dvifile nil
				      YaTeX-my-sourcefile nil)))))
;
;;; End of yatexhks.el
(provide 'yatexhks)
