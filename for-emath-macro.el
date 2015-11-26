;; for-emath-macro.el (utf-8) 2013/12/09版
;; 内容
;; ・YaTeXを使用している場合，emathのコマンドや環境を入力を便利にするために作ったマクロ．
;;   オプションを忘れてしまっても聞いてくれる．
;; 設定方法
;; ・yatexディレクトリに放り込む
;; ・yatexhks.elに (require 'for-emath-macro) を追加する．
;; ・-Linux環境などでは sudo make install
;;   -Meadow環境などでは(yatexディレクトリに *.elc が存在していれば)
;;    yatexhks.el と for-emath-macro.el で M-x byte-compile-file
;;   -上記の2つに該当しなければ何もしない(Windows上のGNU emacsなど)
;; 使い方
;; ・環境は普通に [prefix] b その他のコマンドは引数をとるものであっても引数なしのコマンドとして
;;   [prefix] m すればよい．
;;   ただし，オプションを何でもかんでも尋ねるので手入力で済むのであれば手入力をした方が効率がよい
;;   場合もある．
;; ・yes or noという選択肢でなければEnterすればデフォルトの値になるようにしているつもりです．
;; その他
;; ・このファイルにはゴミも色々あるので気にしないようにしてください．
;; ・描画環境は pszahyou(*) 環境をメインにしています．zahyou 環境固有のオプションやコマンドには
;;   対応していません．
;; ・出来るだけ共通のマクロで済まそうとしたため，そのコマンドでは定義されていないオプションを聞く
;;   時もたまにあります．その場合は無視してください＾＾；
;; ・不具合などは yatex.macro.for.emath@gmail.com まで
;; ・配布場所
;;  Google Drive https://drive.google.com/folderview?id=0B7ea9WttAQx8aUVkU3VFSHF3M2c&usp=sharing
;; ・もちろん自己責任で使用してください．
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 忘備録
;; printf  "% f:浮動小数点 d:10進整数 x:16進整数 o:8進整数"
;; delq (elt list 0) list --> list 内の最初のアイテムを取り除く
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; emath-select-key-value "hoge" "[option]" `(("ふが" "fuga") ("あわわ" "awawa")) ;;;
;;;         ``[option] 0:設定しない 1:ふが 2:あわわ: '' という選択肢を表示し                   ;;;
;;;         入力した数字によって 1 --> hoge=fuga 2 -->hoge=awawa という文字列を返す            ;;;
;;;         "hoge"を""としたときは 1--> fuga 2-->awawa という文字列を返す                      ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;(defun emath-select-key-value (key title lists &optional guides values)
;;  (if (> (length lists) 0)
;;      (let* ((guidelist `(,@guides ,(car (car lists))))
;;	     (valuelist `(,@values ,(nth 1 (car lists)))))
;;	(emath-select-key-value key title (cdr lists) guidelist valuelist))
;;    (let* ((emtitle (cond ((> (length title) 0)(concat title " "))))
;;	   (emnum (emath-get-number-from-list title guides)))
;;      (if (or (< emnum 1)(> emnum (length guides))) ""
;;	(emath-option-combine "=" `(,key ,(nth (- emnum 1) values)))))))
;; mapcar の存在を知ってループさせずに済む
(defun emath-select-key-value (key title lists)
  (let* ((guidelist (mapcar 'car lists));;lists内の各々のリストに対してcarを実行して新たなリストを作成
	 (valuelist (mapcar '(lambda (x) (nth 1 x)) lists));;mapcarの第1引数が引数をとる関数のときの処理
;; この無名関数はリストの引数を1つとりその2番目の要素を返す
;; すなわち valuelist は lists の要素である各々のリストに対して2番目の要素を次々と取り出して並べたリスト
	 (emnum (emath-get-number-from-list title guidelist)))
    (if (or (< emnum 1)(> emnum (length guidelist))) ""
	(emath-option-combine "=" `(,key ,(nth (- emnum 1) valuelist))))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; emath-get-number-from-list "[option]" `("ほげ" "ふが" "あわわ") "attention"            ;;;
;;;   emath-select-key-value の下請け関数                                                  ;;;
;;;   "[option] 1:ほげ 2:ふが 3:あわわ attention" と表示し数字の入力を促し，入力された数値を返す ;;;
;;;   単独で (cond ((= num 1)(...))((= num 2)(...))(()()))                                       ;;;
;;;   などの num の設定にも使える                                                                ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun emath-get-number-from-list (title guides &optional addguide)
  (message (format "%s%s%s: "
		   (if (> (length title) 0)(concat title " ")"")
		   (emath-make-guide 1 guides)
		   (if (> (length addguide) 0) addguide "")))
  (let* ((string (read-char)))
    (string-to-number (char-to-string string))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; emath-make-guide 0 `("ほげ" "ふが" "あわわ")            ;;;
;;;         listから中身を順に取り出し ``0:ほげ 1:ふが 2:あわわ'' ;;;
;;;         のように番号付けをした文字列を作り出す                ;;;
;;;         第1引数が 1 なら ``1:ほげ 2:ふが 3:あわわ'' となる    ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; さらにmapcarとmapconcatをつかってwhileすら必要なくなった
(defun emath-make-guide (num guides)
  (let* ((emnum num)
	 (emlist (mapcar '(lambda (x) (prog1 (format "%s:%s " emnum x)
					(setq emnum (+ emnum 1)))) guides)))
    (mapconcat 'concat emlist "")))
;; whileを使ってループさせずに済む
;; setqは必ずglobalかと思ったが使い方の問題だったみたい
;; letで値を設定してからwhileのBODYで使用する分には大丈夫なようだ
;;(defun emath-make-guide (num guides)
;;  (let* ((emnum num)(emguide ""))
;;    (concat (while (< emnum (+ (length guides) num))
;;	      (setq emguide (concat emguide (format "%s:%s " emnum (nth (- emnum num) guides))))
;;	      (setq emnum (+ emnum 1)))
;;	    emguide)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; YaTeX:fuga () emath-select-key-value の使用例                                ;;;
;;;      [option] 0:設定しない 1:ほげ 2:ふが 3:あわわ 4:およよ という選択肢を表示し    ;;;
;;;      入力した数値によって 1->key=hoge 2->key=fuga 3->key=awawa 4->key=oyoyo を返す ;;;
;;;      1<=num<=4以外の値だと "" を返す                                               ;;;
;;;      第1引数の"key"を""とすると 1->hoge 2->fuga 3->awawa 4->oyoyo を返す           ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun YaTeX-list-or-not (lists)
  (if (listp lists) (message (format "リストだよ[%s]" lists)) (message (format "リストじゃないよ[%s]" lists))))
(defun YaTeX:fuga ()
;;  (YaTeX-list-or-not `(("ほげ" "hoge") ("ふが" "fuga"))))
  (emath-select-key-value "key" "[option]" `(("ほげ" "hoge") ("ふが" "fuga") ("あわわ" "awawa") ("およよ" "oyoyo"))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; emath-option-combine separator optionlist                          ;;;
;;;        optionlist の中身を separator で繋げる                            ;;;
;;;        そのとき前後の変数のどちらか "" であれば separator はつかない     ;;;
;;; emath-option-combine "," `("hoge" "fuga") "awawa,oyoyo"            ;;;
;;; という使い方もできるが，                                                 ;;;
;;; emath-option-combine "," `("awawa" "oyoyo" "hoge" "fuga")          ;;;
;;; と変わらない                                                             ;;;
;;; リストに変数 var1,var2,var3 がある場合は `(,var1 ,var2 ,var3) と指定する ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; mapconcat の存在を知ってループさせずに済むようになる
;; split-string の説明に``文字列の先頭や末尾で一致した場合には、リストの先頭や末尾に空文字列は現れない。''
;; と書かれていて，その例が``(split-string "out to moo" "o+") => ("ut t" " m")''だったので
;; ",,hoge,fuga,,awawa,,,,oyoyo,,"という文字列を`,+'で分割したら
;; ("hoge" "fuga" "awawa" "oyoyo")になると思ったら("" "hoge" "fuga" "awawa" "oyoyo" "")だった...orz
;; 仕方がないからoptionが連なった文字列optionsを作成した後，optionsの前後にseparatorを付加し
;; split-string options separator+ を実行してリストを作り先頭と末尾のリストの要素" "を取り除いた
;; split-string の 第3引数の存在を知る
;; split-string string separators omit-nulls において，omit-nulls が`t'ならzero-length substrings
;;                                           をオミットする
;; ヘルプだけじゃなく (defun split-string で検索してみるもんだね
;; `separator'でリストの要素を接合して`空要素'を除くように`separator+'でリストに分解し
;; そのリストの要素を`separator'で接合する
;; 具体的には`separator'が`,'のとき (a "" b "" c d "" "" "" e f "" "") から
;; a,"",b,"",c,d,"","","",e,f,"","" という文字列を作ってから (a b c d e f) というリストを作り
;; そこから a,b,c,d,e,f という文字列を作る
(defun emath-option-combine (separator oplist)
  (let* ((emlist (split-string (mapconcat 'concat oplist separator) (concat separator "+") t)))
    (mapconcat 'concat emlist separator)))
(defun YaTeX:hogehoge ()
  (emath-option-combine "=" `("" "hoge" "" "" "fuga" "awawa" "" "oyoyo" "" "" "" "arere" "" "")))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; emath-setoption options str guide leftbrace rightbrace default   ;;;
;;;       options に guide を表示して str=leftbrace input_words rightbrace ;;;
;;;       を加えるleftbrace および rightbrace は省略可能                   ;;;
;;;       defaultを指定するとミニバッファからの入力時にdefalut初期値になる ;;;
;;;       下の YaTeX:hoge() が使用例                                       ;;;
;;;  ``[option] guide: ''と表示して文字入力を促す                          ;;;
;;;  入力した文字列([RET]で""を入力することも可)を ``str=input_strings''   ;;;
;;;  (""の場合は"")として options の最後に ``,'' を介して接続する          ;;;
;;;  どちらかが "" の場合は ``,'' は付かない．                             ;;;
;;;  leftbrace rightbrace が指定されていれば                               ;;;
;;;  ``str=leftbrace input_strings rightbrace'' となる                     ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;(defun emath-setoption (options key guide &optional leftbrace rightbrace default)
;;  (let* ((temp (read-string (format "[option] %s: " guide) default))
;;	 (option (concat options
;;			 (if (string= temp "") ""
;;			   (concat (if (string= options "") ""
;;				     (concat ","))
;;				   key "=" leftbrace temp rightbrace)))))
;;    (concat option)))
(defun emath-setoption (options key guide &optional leftbrace rightbrace default)
  (let* ((temp (read-string (format "[option] %s: " guide) default))
	 (emleft (if leftbrace leftbrace ""))
	 (emright (if rightbrace rightbrace ""))
	 (emoption (concat options ","
			   (if (> (length temp) 0) (format "%s=%s%s%s" key emleft temp emright) "")))
	 (emlist (split-string emoption "," t)))
    (mapconcat 'concat emlist ",")))
(defun YaTeX:hoge ()
  (let* ((option (emath-setoption "" "linewidth" "線の太さ" nil nil ".4pt"))
	 (option (emath-setoption option "iro" "線の色"))
	 (option (emath-setoption option "houi" "方位" "{" "}" "s")))
    (if (string= option "") ""
      (concat "[" option "]"))))
(defun emath-set-dash ()
  (let* ((emnum (emath-get-number-from-list "[option] 破線の設定" `("hasenLG" "dash" "指定しない")))
	 (option (cond ((= emnum 1) (concat "hasenLG={"
					    (read-string "[option] hasenLG 描画部分(1mm): ")
					    ","
					    (read-string "[option] hasenLG ギャップ部(.9mm): ")
					    "}"))
		       ((= emnum 2) (concat "dash={"
					    (emath-setdash)
					    "}"))
		       (t ""))))
    (concat option)))
(defun emath-drawline-option ()
  (let* ((option "")
	 (emnum 0)
	 (option (emath-setoption "" "color" "色の指定"))
	 (option (emath-setoption option "linethickness" "線の太さの指定"))
	 (line ""))
    (progn (setq emnum (emath-get-number-from-list "[option] 線種の指定" `("hasenLG" "dash" "ten" "指定しない"))
		 line (concat (cond ((= emnum 1) (concat "hasenLG={"
							 (read-string "[option] hasenLG 描画部(1mm): ")
							 ","
							 (read-string "[option] hasenLG ギャップ部(.9mm): ")
							 "}"))
				    ((= emnum 2) (concat "dash={" (emath-setdash) "}"))
				    ((= emnum 3) (concat "ten=" (read-string "点の個数: ")))
				    (t ""))))
	   (setq option (emath-option-combine "," `(,option ,line)))
	   (concat option))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; emath-setdash ()                                                           ;;;
;;;   ``[num0]{num1,num2,num3,num4,...,num2n-1,num2n}'' の入力を促す                 ;;;
;;;   ``num0''は[RET]で省略可．後続の数字の列は必ず2個1組で入力させ，num2k-1のときは ;;;
;;;   ``描画部の長さ([RET]で終了): ''と表示する                                      ;;;
;;;      \setdash の引数を入力させる\setdash の他にオプション引数の                  ;;;
;;;      dash= の設定にも使えるただし，dash=では"dash={" (emath-setdash) "}"   ;;;
;;;      のように設定しないとオフセットの[]がTeXでのエラーの原因となる可能性がある   ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun emath-setdash ()
  (let* ((offset (read-string "[option] オフセットの設定: ")))
    (concat (if (string= offset "") ""
	      (concat "[" offset "]"))
	    "{" (emath-setdash-loop) "}")))
(defun emath-setdash-loop (&optional setting)
  (let* ((line (read-string "描画部の長さ([Enter]で終了): ")))
    (if (string= line "")
	(concat setting)
      (let* ((space (read-string "非描画部の長さ: "))
	     (lines (emath-option-combine "," `(,setting ,line ,space))))
	(emath-setdash-loop lines)))))
;;; emath-setarrow () 引数を省略すると軸の指定はしない
(defun emath-setarrow (&optional ziku-or-not)
  (let* ((emop (read-string "[option] 窪みの比率(省略可): ")))
    (concat (if (string= emop "") ""
	      (concat "<" emop ">"))
	    "{" (if ziku-or-not (read-string "軸の太さ(3): ") "")
	    "}{" (read-string "鏃の太さ(25): ") "}{"
	    (read-string "鏃の長さ(50): ") "}")))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; emath-tenretu-loop guide separator seq                           ;;;
;;;      "guide: "を表示してseqにseparatorで区切りながら点列を追加し続ける ;;;
;;;       seqは省略可能というか最初は設定しない．この関数が利用する        ;;;
;;;   使用例 emath-tenretu-loop "線分の端点" ";"                     ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun emath-tenretu-loop (separator guide &optional seq)
  (let* ((empoint (read-string (format "%s: " guide))))
    (if (> (length empoint) 0)
	(let* ((empoint (emath-option-combine separator `(,seq ,empoint))))
	  (emath-tenretu-loop separator guide empoint))
      (concat seq))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; emath-Put-HouiSitei ()                 ;;;
;;;       直交座標指定 :(xunit,yunit)(0,10pt)[l] ;;;
;;;       極座標指定   :[r](r,θ) [r](2,60)[c]   ;;;
;;;       簡易指定     :n,ne,e,se,s,sw,w,nw [ne] ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;(defun emath-Put-HouiShitei ()
;;  (let* ((emnum (read-number "[option] 1:簡易指定 2:直交座標指定 3:極座標指定: "))
;;	 (option (cond ((= emnum 1)(YaTeX:read-position "news"))
;;		       ((= emnum 2)(YaTeX:read-coordinates "(x,y)単位付き成分を指定: "))
;;		       ((= emnum 3)(concat "[r]" (YaTeX:read-coordinates "(r,θ)単位付き長さを指定: ")))
;;		       (()()))))
;;    (concat option
;;	    (if (= emnum 1) "" 
;;	      (YaTeX:read-position "rcltb")))))
(defun emath-Put-HouiShitei ()
  (let* ((emnum (emath-get-number-from-list "[option]" `("簡易指定" "直交座標指定" "極座標指定")))
	 (option (cond ((= emnum 1)(YaTeX:read-position "newsc"))
		       ((= emnum 2)(YaTeX:read-coordinates "(x,y): "))
		       ((= emnum 3)(concat "[r]" (YaTeX:read-coordinates "(r,θ): ")))
		       (t ""))))
    (concat option
	    (if (= emnum 1) ""
	      (YaTeX:read-position "rcltb")))))
(fset 'YaTeX:yokoenumerate 'YaTeX:enumerate)
(fset 'YaTeX-intelligent-newline-yokoenumerate 'YaTeX-intelligent-newline-itemize)
(fset 'YaTeX:betaenumerate 'YaTeX:enumerate)
(fset 'YaTeX-intelligent-newline-betaenumerate 'YaTeX-intelligent-newline-itemize)
(fset 'YaTeX-intelligent-newline-edaenumerate 'YaTeX-intelligent-newline-itemize)
;\begin{edaenumerate}<#1>[#2]
;　　\item .....
;　　\item .....
;　　...........
;\end{edaenumerate}
;    #1: *横に並べる項目数
;    または key=val
;          retusuu:横に並べる項目数の指定
;          syokiti:
;          gyoukan:行間の指定[\vfillで均等割]
;          edaLmargin:左インデントの指定
;          edafirstindent:第1項のみに対する左インデント指定
;          edatopsep:前段落との行間指定
;          edabottomsep:後段落との行間指定
;    #2: enumerate環境と同じく，項目番号の書式指定
;t-or-nil=t:edaitemを使用する環境
(defun emath-edaenumerate-option (&optional t-or-nil)
  (let* ((emnum 0)
	 (option (emath-setoption "" "retusuu" "列数の指定(2)"))
	 (option (emath-setoption option "syokiti" "番号付けの初期値[設定値の次の自然数から始まる](0)"))
	 (option (emath-setoption option "gyoukan" "行間の指定[\\vfillで均等割]"))
	 (option (emath-setoption option "edaLmargin" "左インデントの指定"))
	 (option (emath-setoption option "edafirstindent" "第1項目に対する左インデント"))
	 (option (emath-setoption option "edatopsep" "前段落との行間指定"))
	 (option (emath-setoption option "edabottomsep" "後段落との行間指定"))
	 (emnum (if t-or-nil (emath-get-number-from-list "[option] edaenumerate環境下でのリスト環境" `("使用する" "使用しない")) 0))
	 (edaitem (cond ((= emnum 1) "useitem=false")
			(t "")))
	 (option (emath-option-combine "," `(,option ,edaitem))))
    (list emnum option)))
(defun YaTeX:edaenumerate ()
  (let* ((option (emath-edaenumerate-option t))
	 (emnum (car option))
	 (option (car (cdr option))))
    (concat (if (> (length option) 0)
		(concat "<" option ">") "")
	    (if (y-or-n-p "[option] 項目番号の書式を設定しますか？: ")
		(concat "[" (read-string "[option] 番号の書式: ") "]%") "")
	    "\n%\t広域でedaLmarginを設定するには\\edaLmarginを使用する"
	    (if (= emnum 1)
		"\n%\t\\itemの使用不可\\edaitemを使用する"))))
;\begin{yokoenumerate}<#1>[#2]
;　　\item .....
;　　\item .....
;　　...........
;\end{yokoenumerate}
;    #1: edaenumerate環境に引き継がれるオプション
;    #2: enumerate環境と同じく，項目番号の書式指定
(defun YaTeX:yokoenumerate ()
  (let* ((option (emath-edaenumerate-option))
	 (emnum (car option))
	 (option (car (cdr option))))
    (concat (if (> (length option) 0)
		(concat "<" option ">") "")
	    (if (y-or-n-p "[option] 項目番号の書式を設定しますか？: ")
		(concat "[" (read-string "[option] 番号の書式: ") "]%") "")
	    "\n%\t広域でedaLmarginを設定するには\\edaLmarginを使用する")))
;\begin{betaenumerate}<#1>[#2]
;　　\item .....
;　　\item .....
;　　...........
;\end{betaenumerate}
;    #1: key=val
;         syokiti:番号付けの初期値を変更します。右辺値に指定した値の次の番号から始まります。
;         edaLmargin:左インデントを指定します。
;         postedasep:項目間の空きを調整します。
;         betaraggedlines:最終行以外の行に対して両端揃えとするか否かのスイッチ
;         betaraggedlastline:最終行を両端揃えとするか否かのスイッチ
;    #2: enumerate環境と同じく，項目番号の書式指定
(defun YaTeX:betaenumerate ()
  (let* ((option (emath-setoption "" "syokiti" "番号付けの初期値[設定値の次の自然数から始まる](0)"))
	 (option (emath-setoption option "edaLmargin" "左インデントの設定"))
	 (option (emath-setoption option "postedasep" "項目間の空きの調整"))
	 (emnum (emath-get-number-from-list "[option] 最終行以外の行の両端揃え" `("する" "しない")))
	 (lines (cond ((= emnum 1) "betaraggedlines=true")
		      (t "")))
	 (emnum (emath-get-number-from-list "[option] 最終行の両端揃え" `("する" "しない")))
	 (lastline (cond ((= emnum 1) "betaraggedlastline=true")
			 (t "")))
	 (option (emath-option-combine "," `(,option ,lines ,lastline))))
    (concat (if (> (length option) 0)
		(concat "<" option ">") "")
	    (if (y-or-n-p "[option] 項目番号の書式を設定しますか？: ")
		(concat "[" (read-string "[option] 番号の書式: ") "]%"))
	    "\n%\t広域でpostedasepを設定するときは\\setpostedasepコマンドを使用する"
	    "\n%\t広域で両端揃え・左揃えを設定するときは\\betaraggedlinesfalse,\\betaraggedlastlinefalse"
	    "\n%\t\\betaraggedlinestrue,\\betaraggedlastlinetrueを使用する")))
(defun emath-lineto-func (guide &optional polar-or-not)
  (concat (if polar-or-not (concat "[r]" (YaTeX:read-coordinates (format "%s(r,θ): " guide)))
	    (YaTeX:read-coordinates (format "%s(x,y): " guide)))
	  "%\\emCurPにカレントポイントが格納されている"))
(defun YaTeX:emlineto ()
  (emath-lineto-func "移動先の指定"))
(defun YaTeX:emrlineto ()
  (emath-lineto-func "移動先の指定" t))
(defun YaTeX:emmoveto ()
  (emath-lineto-func "移動量の指定"))
(defun YaTeX:emrmoveto ()
  (emath-lineto-func "移動量の指定" t))
(defun YaTeX:setdash ()
  (emath-setdash))
;\hasenLG#1#2
; #1:実線部分の長さ（デフォルト値：1mm）
; #2:実線部分の間隔（デフォルト値：0.9mm）
(defun YaTeX:hasenLG ()
  (insert (concat "{" (read-string "描画部の長さ(1mm): ") "}"
		  "{" (read-string "ギャップ部の長さ(.9mm)") "}%")))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; emath-psovalbox-option             ;;;
;;; \psovalbox のオプションの設定            ;;;
;;;            linewidth=枠線の太さ          ;;;
;;;            dash=枠線の線種               ;;;
;;;            ovalsep=枠線とテキストの間隔  ;;;
;;;            ovalradius=コーナーの半径     ;;;
;;;            iro=枠線の色                  ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun emath-psovalbox-option ()
  (let* ((option (emath-setoption "" "linewidth" "枠線の太さ"))
	 (option (emath-setoption option "ovalsep" "枠線とテキストの間隔(\\fboxsep)"))
	 (option (emath-setoption option "ovalradius" "コーナーの半径(2pt)"))
	 (option (emath-setoption option "iro" "枠線の色"))
	 (temp (if (y-or-n-p "[option] 線種の設定をしますか？")
		   (concat "dash={" (emath-setdash) "}") ""))
	 (option (emath-option-combine "," `(,option ,temp))))
    (concat option)))
;;; \psovalbox[option]{strings}
;;; \psovalbox*[option]{strings}
;;; section型
(defun YaTeX:psovalbox ()
  (let ((option (emath-psovalbox-option)))
    (if (string= option "") ""
      (concat "<" option ">"))))
(defun YaTeX:psovalbox* ()
  (let ((option1 (if (y-or-n-p "[option] 背景色を設定しますか？")
		     (emath-setoption "" "paintcolor" "背景色")
		   (if (y-or-n-p "[option] 濃度を設定しますか？")
		       (emath-setoption "" "noudo" "濃度(.5)") ())))
	(option2 (emath-psovalbox-option)))
    (concat (if (string= option1 "") ""
	      (concat "[" option1 "]"))
	    (if (string= option2 "") ""
	      (concat "<" option2 ">")))))
(fset 'YaTeX:EMpsovalbox 'YaTeX:psovalbox)
(fset 'YaTeX:EMpsovalbox* 'YaTeX:psovalbox*)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; \pskasen<option>[space between 2lines]'put item in pszahyo env'{strings} ;;;
;;;   option linewidth:線の太さ(4)                                           ;;;
;;;          dash:破線の設定{}                                               ;;;
;;;          iro:下線の色の設定                                              ;;;
;;;          kasenUehosei:文字列と下線との間隔(unit)                         ;;;
;;;          kasenSitahosei:下線とその下の行との間隔(unit)                   ;;;
;;;          kasenFunc:\psnamikasenのみ                                      ;;;
;;; 広域でkasenUehoseiを設定するときは\\kasenUehosei{unit}%                  ;;;
;;;       kasenSitahoseiを設定するときは\\kasenSitahosei{unit}%              ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun emath-pskasen-option (&optional nami-or-not)
  (let* ((option (emath-setoption "" "linewidth" "線の太さ(4)"))
	 (option (emath-setoption option "iro" "下線の色"))
	 (option (emath-setoption option "kasenUehosei" "文字列と下線との間隔(要単位)"))
	 (option (emath-setoption option "kasenSitahosei" "下線とその下の行との間隔(要単位)"))
	 (option (concat option
			 (if (y-or-n-p "[option] 破線にしますか？")
			     (concat (if (string= option "") ""
				       (concat ","))
				     "dash="
				     (emath-setdash))
			   (if nami-or-not
			       (if (y-or-n-p "[option] 関数を設定しますか？")
				   (concat (if (string= option "") ""
					     (concat ","))
					   (emath-setoption option "kasenFunc" "関数" "{" "}")) "") ())))))
    (concat (if (string= option "") ""
	      (concat "<" option ">"))
	    (if nami-or-not ""
	      (if (y-or-n-p "2重下線にしますか？")
		  (concat "[" (read-string "[option] 下線間の間隔(無名数で単位にはptが付く): ") "]") ""))
	    (if (y-or-n-p "[option] 下線にアイテムを置きますか？")
		(concat "'\\Put" (YaTeX:emathPut) "\n'"))
	    "%\n%\t広域でkasenUehoseiやkasenSitahoseiを設定するときは\n"
	    "%\t\\kasenUehosei{unit}や\\kasenSitahosei{unit}を使用する\n")))
(defun YaTeX:pskasen ()
  (emath-pskasen-option))
(defun YaTeX:psnamikasen ()
  (emath-pskasen-option t))
(defun YaTeX:defineEMpscolor ()
  (concat "{" (read-string "R(0-1): ") "}"
	  "{" (read-string "G(0-1): ") "}"
	  "{" (read-string "B(0-1): ") "}"))
(defun YaTeX:EMpscolor ()
  (concat "{" (read-string "色: ") "}"))
(defun YaTeX:EPSkaiten ()
  (concat "{" (read-string "回転の中心: ") "}"
	  "{" (read-string "回転角: ") "}"
	  "%\n{" (read-string "回転の対象") "}%"))
(defun emath-useperllib-func (ext)
  (concat (read-string (format "[ファイル名の指定] *.%s(拡張子除く): " ext))
	  (if (y-or-n-p "続けますか？")
	      (concat ","
		      (emath-useperllib-func ext)) ())))
(defun YaTeX:useperllib ()
  (concat "{" (emath-useperllib-func "pl") "}"))
(defun YaTeX:useperlpm ()
  (concat "{" (emath-useperllib-func "pm") "}"))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; \kubunkyuusekizu:短冊のみ                             ;;;
;;; \kubunkyuusekizu*[濃度]:ベタ塗り                      ;;;
;;; \kubunkyuusekizu**[斜線の方向角]<斜線の間隔>:斜線塗り ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun emath-kubunkyuuseki-body ()
  (concat "{" (read-string "関数式: ")
	  "}{" (read-string "区間の左端: ")
	  "}{" (read-string "区間の右端: ")
	  "}{" (read-string "分割数: ")
	  "}{" (if (y-or-n-p "短冊の右辺を高さにしますか？")
		   (concat "r")
		 (concat "l"))
	  "}"))
(defun YaTeX:kubunkyuusekizu ()
  (emath-kubunkyuuseki-body))
(defun YaTeX:kubunkyuusekizu* ()
  (let* ((option (read-string "濃度(.5): ")))
    (concat (if (string= option "") ""
	      (concat "[" option "]"))
	    (emath-kubunkyuuseki-body))))
(defun YaTeX:kubunkyuusekizu** ()
  (let* ((angle (read-string "[option] 斜線の方向角: "))
	 (space (read-string "[option] 斜線の間隔(無名数): ")))
    (concat (if (string= angle "") ""
	      (concat "[" angle "]"))
	    (if (string= space "") ""
	      (concat "<" space ">"))
	    (emath-kubunkyuuseki-body))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; \YNuri[濃度]<xの刻み値>{f(x)}{xmin}{xmax}        ;;;
;;; \YNurii[濃度]<xの刻み値>{f(x)}{g(x)}{xmin}{xmax} ;;;
;;; \XNuri[濃度]<yの刻み値>{f(y)}{ymin}{ymax}        ;;;
;;; \XNurii[濃度]<yの刻み値>{f(y)}{g(y)}{ymin}{ymax} ;;;
;;; \BNuri[濃度]<tの刻み値>{f(t)}{g(t)}{tmin}{tmax}  ;;;
;;; \RNuri[濃度]<θの刻み値>{f(θ){θmin}{θmax}     ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun emath-YNuri-body (var func1 &optional func2)
  (concat "{" (read-string (format "%sの指定: " func1))
	  (if func2 (concat "}{" (read-string (format "%sの指定: " func2))) "")
	  "}{" (read-string (format "%sの最小値: " var))
	  "}{" (read-string (format "%sの最大値: " var))
	  "}"))
(defun emath-YNuri-option (var)
  (let* ((temp (read-string "[option] 濃度(.5): "))
	 (option (concat (if (string= temp "") ""
			   (concat "[" temp "]"))))
	 (temp (read-string (format "[option] %sの刻み値: " var)))
	 (option (concat option
			 (if (string= temp "") ""
			   (concat "<" temp ">")))))
    (concat option)))
(defun YaTeX:YNuri ()
  (concat (emath-YNuri-option "x")
	  (emath-YNuri-body "x" "f(x)")))
(defun YaTeX:YNurii ()
  (concat (emath-YNuri-option "x")
	  (emath-YNuri-body "x" "f(x)" "g(x)")))
(defun YaTeX:XNuri ()
  (concat (emath-YNuri-option "y")
	  (emath-YNuri-body "y" "f(y)")))
(defun YaTeX:XNurii ()
  (concat (emath-YNuri-option "y")
	  (emath-YNuri-body "y" "f(y)" "g(y)")))
(defun YaTeX:BNuri ()
  (concat (emath-YNuri-option "t")
	  (emath-YNuri-body "t" "f(t)" "g(t)")))
(defun YaTeX:RNuri ()
  (concat (emath-YNuri-option "θ")
	  (emath-YNuri-body "θ" "f(θ)")))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; \YNuri*[斜線の方向角]<斜線の間隔>(xの刻み値){f(x)}{xmin}{xmax}        ;;;
;;; \YNurii*[斜線の方向角]<斜線の間隔>(xの刻み値){f(x)}{g(x)}{xmin}{xmax} ;;;
;;; \XNuri*[斜線の方向角]<斜線の間隔>(yの刻み値){f(y)}{ymin}{ymax}        ;;;
;;; \XNurii*[斜線の方向角]<斜線の間隔>(yの刻み値){f(y)}{g(y)}{ymin}{ymax} ;;;
;;; \BNuri*[斜線の方向角]<斜線の間隔>(tの刻み値){f(t)}{g(t)}{tmin}{tmax}  ;;;
;;; \RNuri*[斜線の方向角]<斜線の間隔>(θの刻み値){f(θ)}{θmin}{θmax}    ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun emath-YNuri*-option (var)
  (let* ((temp (read-string "[option] 斜線の方向角(45): "))
	 (option (if (string= temp "") ""
		   (concat "[" temp "]")))
	 (temp (read-string "[option] 斜線の間隔(.125): "))
	 (option (concat option
			 (if (string= temp "") ""
			   (concat "<" temp ">"))))
	 (temp (read-string (format "[option] %sの刻み値: " var)))
	 (option (concat option
			 (if (string= temp "") ""
			   (concat "(" temp ")")))))
    (concat option)))
(defun emath-YNuri*-body (var func1 &optional func2)
  (concat "{" (read-string (format "%sの設定: " func1)) "}{"
	  (if func2 (concat (read-string (format "%sの設定: " func2)) "}{") "")
	  (read-string (format "%sの最小値: " var))
	  "}{" (read-string (format "%sの最大値: " var)) "}"))
(defun YaTeX:YNuri* ()
  (concat (emath-YNuri*-option "x")
	  (emath-YNuri*-body "x" "f(x)")))
(defun YaTeX:YNurii* ()
  (concat (emath-YNuri*-option "x")
	  (emath-YNuri*-body "x" "f(x)" "g(x)")))
(defun YaTeX:XNuri* ()
  (concat (emath-YNuri*-option "y")
	  (emath-YNuri*-body "y" "f(y)")))
(defun YaTeX:XNurii* ()
  (concat (emath-YNuri*-option "y")
	  (emath-YNuri*-body "y" "f(y)" "g(y)")))
(defun YaTeX:BNuri* ()
  (concat (emath-YNuri*-option "t")
	  (emath-YNuri*-body "t" "f(t)" "g(t)")))
(defun YaTeX:RNuri* ()
  (concat (emath-YNuri*-option "θ")
	  (emath-YNuri*-body "θ" "f(θ)")))
;\YandY<#1>#2#3#4
;二つの関数 f(x), g(x) を与えて，交点の座標を取得します。
;    #1: key=val 形式のオプション引数で，有効なキーは
;         infx:交点を探索する x の下限値（デフォルトは \xmin）
;         supx:交点を探索する x の上限値（デフォルトは \xmax）
;         xval:交点の x座標を受け取る制御綴名
;         yval:交点の y座標を受け取る制御綴名
;    #2: f(x)
;    #3: g(x)
;    #4: 交点の座標を格納する制御綴
(defun YaTeX:YandY ()
  (let* ((option (emath-setoption "" "infx" "xの下限値(\\xmin)"))
	 (option (emath-setoption option "supx" "xの上限値(\\xmax)"))
	 (option (emath-setoption option "xval" "x座標を受け取る制御綴り"))
	 (option (emath-setoption option "yval" "y座標を受け取る制御綴り")))
    (insert (concat (if (> (length option) 0)
			(concat "<" option ">") "")
		    "{" (read-string "関数1: ") "}"
		    "{" (read-string "関数2: ") "}"
		    (read-string "交点の座標を受け取る制御綴り: ")))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; \YTen[option]{f(x)}{xの値}{座標を受け取る制御綴り}       ;;;
;;;    option xformat=x座標のフォーマット指定(s)             ;;;
;;;           yformat=y座標のフォーマット指定(s)             ;;;
;;; \XTen[option]{f(y)}{yの値}{座標を受け取る制御綴り}       ;;;
;;; \BTen[option]{f(t)}{g(t)}{tの値}{座標を受け取る制御綴り} ;;;
;;; \RTen[option]{f(θ)}{θの値}{座標を受け取る制御綴り}     ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun emath-YTen-body (var func1 &optional func2)
  (let* ((option (emath-setoption "" "xformat" "x座標のフォーマット(s)"))
	 (option (emath-setoption option "yformat" "y座標のフォーマット(s)")))
    (concat (if (string= option "") ""
	      (concat "[" option "]"))
	    "{" (read-string (format "%sの指定: " func1)) "}{"
	    (if func2 (concat (read-string (format "%sの指定: " func2)) "}{") "")
	    (read-string (format "%sの値: " var)) "}"
	    (read-string "座標を受け取る制御綴り: "))))
(defun YaTeX:YTen ()
  (emath-YTen-body "x" "f(x)"))
(defun YaTeX:XTen ()
  (emath-YTen-body "y" "f(y)"))
(defun YaTeX:BTen ()
  (emath-YTen-body "t" "f(t)" "g(t)"))
(fset `YaTeX:ParamP `YaTeX:BTen)
(defun YaTeX:RTen ()
  (emath-YTen-body "θ" "f(θ)"))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; \namisen[option]\A\B                         ;;;
;;;    \A\B間を高さ0.25の5周期分の正弦曲線を描く ;;;
;;;    option namisuu=\A\B間の周期数(5)          ;;;
;;;           namitakasa=波の高さ(.25)           ;;;
;;; \namisen*\A\B                                ;;;
;;;    \A\B間を2つの正弦曲線で結び間を白塗りする ;;;
;;;    option namikankaku=波の間隔(.1)           ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun emath-namisen-option (&optional ast-or-not)
  (let* ((option (emath-setoption "" "namisuu" "波の数(5)"))
	 (option (emath-setoption option "namitakasa" "波の高さ(.25)"))
	 (temp (concat 
		(if ast-or-not
		    (emath-setoption "" "namikankaku" "波の間隔(.1)") "")))
	 (option (emath-option-combine "," `(,option ,temp))))
    (if (string= option "") ""
      (concat "[" option "]"))))
(defun YaTeX:namisen ()
  (concat (emath-namisen-option)
	  "{" (read-string "始点: ") "}{"
	  (read-string "終点: ") "}%"))
(defun YaTeX:namisen* ()
  (concat (emath-namisen-option t)
	  "{" (read-string "始点: ") "}{"
	  (read-string "終点: ") "}%"))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; \YGurafu(xの刻み値[0.05]){f(x)}{xmin}{xmax}       ;;;
;;; \XGurafu(yの刻み値[0.05]){f(y)}{ymin}{ymax}       ;;;
;;; \BGurafu(tの刻み値[0.05]){f(t)}{g(t)}{tmin}{tmax} ;;;
;;; \RGurafu(θの刻み値[0.05]){f(θ)}{θmin}{θmax}   ;;;
;;; \YGurafu*[option](xの刻み値[0.05]){f(x)}          ;;;
;;;     右端点が\migiTに左端点が\hidariTに保存される  ;;;
;;;     option hidarix=定義域の指定                   ;;;
;;;            migix=定義域の指定                     ;;;
;;; \XGurafu*[option](yの刻み値){f(y)}                ;;;
;;;     上端点が\ueTに下端点が\sitaTに保存される      ;;;
;;;     option uey=定義域の指定                       ;;;
;;;            sitay=定義域の指定                     ;;;
;;; \BGurafu*[option](tの刻み値[0.05]){f(t)}{g(t)}    ;;;
;;;     開始点が\hazimeTに終了点が\owariTに保存される ;;;
;;;     option hazimet=定義域の指定                   ;;;
;;;            owarit=定義域の指定                    ;;;
;;; \RGurafu*(θの刻み値[0.05]){f(θ)}                ;;;
;;;    開始点が\hazimeTに終了点が\owariTに保存される  ;;;
;;;    option hazimet=定義域の指定                    ;;;
;;;           owarit=定義域の指定                     ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;(defun emath-YGurafu*-option (var begin bpoint end epoint)
;;;  (let* ((option (emath-setoption ""  begin (concat var "の" bpoint "点" )))
;;;	 (option (emath-setoption option end (concat var "の" epoint "点"))))
;;;    (if (string= option "") ""
;;;      (concat "[" option "]"))))
;;;(defun emath-YGurafu-body (var func1 &optional func2 ast-or-not)
;;;  (let* ((cut (read-string (format "[option] %sの刻み値(.05): " var))))
;;;    (concat (if (string= cut "") ""
;;;	      (concat "(" cut ")"))
;;;	    "{" (read-string (format "%sの設定: " func1)) "}"
;;;	    (if func2 (concat "{" (read-string (format "%sの設定: " func2)) "}") "")
;;;	    (if ast-or-not ""
;;;	      (concat "{" (read-string (format "%sの最小値: " var))
;;;		      "}{" (read-string (format "%sの最大値: " var)) "}")))))
;;;(defun YaTeX:YGurafu ()
;;;  (emath-YGurafu-body "x" "f(x)"))
;;;(defun YaTeX:XGurafu ()
;;;  (emath-YGurafu-body "y" "f(y)"))
;;;(defun YaTeX:RGurafu ()
;;;  (emath-YGurafu-body "θ" "f(θ)"))
;;;(defun YaTeX:BGurafu ()
;;;  (emath-YGurafu-body "t" "f(t)" "g(t)"))
;;;(defun YaTeX:YGurafu* ()
;;;  (concat (emath-YGurafu*-option "x" "hidarix" "左端" "migix" "右端")
;;;	  (emath-YGurafu-body "x" "f(x)" nil t)
;;;	  "%\n%\t\\hidariTに左端点，\\migiTに右端点が保存される\n"))
;;;(defun YaTeX:XGurafu* ()
;;;  (concat (emath-YGurafu*-option "y" "sitay" "下端" "uey" "上端")
;;;	  (emath-YGurafu-body "y" "f(y)" nil t)
;;;	  "%\n%\t\\sitaTに下端点，\\ueTに上端点が保存される\n"))
;;;(defun YaTeX:RGurafu* ()
;;;  (concat (emath-YGurafu*-option "θ" "hazimet" "開始" "owarit" "終了")
;;;	  (emath-YGurafu-body "θ" "f(θ)" nil t)
;;;	  "%\n%\t\\hazimeTに開始点，\\owariTに終了点が保存される\n"))
;;;(defun YaTeX:BGurafu* ()
;;;  (concat (emath-YGurafu*-option "t" "hazimet" "開始" "owarit" "終了")
;;;	  (emath-YGurafu-body "t" "f(t)" "g(t)" t)
;;;	  "%\n%\t\\hazimeTに開始点，\\owariTに終了点が保存される\n"))
;;\YGraph<#1>'#2'^#3#4
;;#1: key=val
;;    color,linethickness,dash,dx,minx,maxx,infx,supx,leftP,rightP
;;#2: 定義域の指定
;;    [x1,x2] 閉区間指定
;;    (x1,x2) 開区間指定
;;    (,x2) [x1,] など端点省略
;;    (x1,x2] 半開区間
;;    それらを | でつなげた複数区間
;;#3: 不連続点/分割点
;;    不連続点/分割点をコンマ区切 csv列で与えます（分割点の場合は * を前置）
;;#4: 関数式
;; #2 と #3 は併用不可
(defun emath-Graph-Common (xory min max)
  (let* ((option "")
	 (dash "")
	 (leftP "")
	 (rightP ""))
    (progn (if (y-or-n-p "オプションを指定しますか？")
	       (progn (setq option (emath-setoption option "color" "色の指定")
			    option (emath-setoption option "linethickness" "太さの指定")
			    option (emath-setoption option "dx" "刻み値の指定")
			    option (emath-setoption option (format "min%s" xory) "最小値の指定[閉区間]")
			    option (emath-setoption option (format "inf%s" xory) "最小値の指定[開区間]")
			    option (emath-setoption option (format "max%s" xory) "最大値の指定[閉区間]")
			    option (emath-setoption option (format "sup%s" xory) "最大値の指定[開区間]"))
		      (if (y-or-n-p "破線の設定をしますか？")
			  (setq dash (concat "dash={" (emath-setdash) "}"))
			())
		      (if (y-or-n-p (format "%s端点を取得しますか？" min))
			  (if (y-or-n-p (format "%s端点名を指定しますか？" min))
			      (setq leftP (concat "leftP=" (read-string (format "%s端点名: " min))))
			    (setq leftP "leftP"))
			())
		      (if (y-or-n-p (format "%s端点を取得しますか？" max))
			  (if (y-or-n-p (format "%s端点名を指定しますか？" max))
			      (setq rightP (concat "rightP=" (read-string (format "%s端点名: " max))))
			    (setq rightP "rightP")) ())) ())
	   (setq option (emath-option-combine "," `(,option ,dash ,leftP ,rightP)))
	   (if (> (length option) 0)
	       (insert (concat "<" option ">")) ()))))
(defun emath-Graph-divide-option ()
  (let* ((option "")
	 (flag (emath-get-number-from-list "[option]" `("区間で指定する" "不連続点で指定する" "指定しない"))))
    (progn (setq option (cond ((= flag 1)(concat "'" (read-string "[option] 区間の設定: ") "'"))
			      ((= flag 2)(concat "^{" (read-string "[option] 不連続点の設定: ") "}"))
			      (t "")))
	   (if (> (length option) 0)
	       (insert option) ()))))
(defun YaTeX:YGraph ()
  (progn (emath-Graph-Common "x" "左" "右")
	 (emath-Graph-divide-option)
	 (insert (read-string "描画関数: "))))
(defun YaTeX:XGraph ()
  (progn (emath-Graph-Common "y" "下" "上")
	 (emath-Graph-divide-option)
	 (insert (read-string "描画関数: "))))
;\ParamC<#1>#2#3
; #1: key=val
;    color:曲線に色をつけます。
;    dash:曲線を破線で描画します。
;    linethickness:線の太さを指定します。
;    mint:媒介変数 t の動く最小値を指定します。デフォルトは 0 です。
;    maxt:媒介変数 t の動く最大値を指定します。デフォルトは 2π です。
;    inft:媒介変数 t の動く下限値を指定します。
;    supt:媒介変数 t の動く上限値を指定します。
;    #2: x=f(t) 媒介変数は T で表します。
;    #3: y=g(t)
(defun YaTeX:ParamC ()
  (progn (emath-Graph-Common "t" "始" "終")
	 (insert (concat (read-string "描画関数(x): ")
			 (read-string "描画関数(y): ")))))
;\PolarC<#1>#2
;    #1: key=val
;       dash:曲線を破線で描画します。
;       mint, maxt
;         θの範囲は，デフォルトでは 0～2π となっています。
;         これを変更する key です。
;    #2: R=f(θ) 媒介変数は T で表します。
(defun YaTeX:PolarC ()
  (progn (emath-Graph-Common "t" "始" "終")
	 (insert (read-string "描画関数: "))))
;\YDiff<#1>#2#3#4
;    #1: key=val
;         setten:指定した点の座標を受け取ります。
;         yval:指定した点の y座標を受け取ります。
;         sessen:指定した点における接線を表す一次関数式を受け取ります。
;         sessencsv:指定した点における接線を表す一次関数式の係数列（降順）を受け取ります。
;         housen:指定した点における法線を表す一次関数式を受け取ります。
;         housencsv:指定した点における法線を表す一次関数式の係数列（降順）を受け取ります。
;    #2: 関数式(f(x))
;    #3: xの値(a)
;    #4: 微分係数(f'(a))を受け取る制御綴
(defun YaTeX:YDiff ()
  (let* ((option (emath-setoption "" "setten" "接点の座標を受け取る制御綴り"))
	 (option (emath-setoption option "yval" "接点のy座標を受け取る制御綴り"))
	 (option (emath-setoption option "sessen" "接線の式を受け取る制御綴り"))
	 (option (emath-setoption option "sessencsv" "接線の式の係数列を受け取る制御綴り"))
	 (option (emath-setoption option "housen" "法線の式を受け取る制御綴り"))
	 (option (emath-setoption option "housencsv" "法線の式の係数列を受け取る制御綴り")))
    (insert (concat (if (> (length option) 0)
			(concat "<" option ">") "")
		    "{" (read-string "関数式: ") "}"
		    "{" (read-string "接点のx座標: ") "}"
		    (read-string "微分係数を受け取る制御綴り: ")))))
;\ParamDiff<#1>#2#3#4#5
;    #1: key=val
;         setten:右辺値は，指定した点の座標を受け取る制御綴名
;    #2: x=f(t)
;    #3: y=f(t)
;    #4: tの値(a) （ perl の計算式を与えることが出来ます）
;    #5: 接ベクトル (f'(a),g'(a))を受け取る制御綴
(defun YaTeX:ParamDiff ()
  (let* ((option (emath-setoption "" "setten" "接点の座標を受け取る制御綴り名")))
    (insert (concat (if (string= option "")
			"" (concat "<" option ">"))
		    "{" (read-string "x座標を表す関数: ") "}"
		    "{" (read-string "y座標を表す関数: ") "}"
		    "{" (read-string "接点を指定するパラメータの値: ") "}"
		    (read-string "接ベクトルを受け取る制御綴り: ")))))
;\YPaint<#1>#2
;    #1: key=val
;         minx:弦の左端端点の x座標を指定します。
;         maxx:弦の右端端点の x座標を指定します。
;         nuriiro:塗りの色を指定します。
;         paintcolor:塗りの色を指定します。
;         thickness:塗りつぶしの濃度を指定します。
;                   0～1 の無名数で，0 は白，1は黒で，デフォルト値は 0.5 となっています。
;    #2: 関数式
(defun YaTeX:YPaint ()
  (let* ((option (emath-emPaint-paintonly-option))
	 (option (emath-setoption option "minx" "左端点のx座標の指定"))
	 (option (emath-setoption option "maxx" "右端点のx座標の指定")))
    (insert (concat (if (> (length option) 0)
			(concat "<" option ">") "")
		    "{" (read-string "関数式: ") "}%"))))
(defun YaTeX:YPaint* ()
  (let* ((option (emath-emPaint*-slashonly-option))
	 (option (emath-setoption option "minx" "左端点のx座標の指定"))
	 (option (emath-setoption option "maxx" "右端点のx座標の指定")))
    (insert (concat (if (> (length option) 0)
			(concat "<" option ">") "")
		    "{" (read-string "関数式: ") "}%"))))
;\YPaintii<#1>#2#3
;    #1: key=val:\YPaintと同じ
;    #2: 関数式1
;    #3: 関数式2
(defun YaTeX:YPaintii ()
  (let* ((option (emath-emPaint-paintonly-option))
	 (option (emath-setoption option "minx" "左端点のx座標の指定"))
	 (option (emath-setoption option "maxx" "右端点のx座標の指定")))
    (insert (concat (if (> (length option) 0)
			(concat "<" option ">") "")
		    "{" (read-string "関数式1: ") "}"
		    "{" (read-string "関数式2: ") "}%"))))
;\YPaintii*<#1>#2#3
;    #1: key=val
;         minx:x の範囲について，最小値を指定します。
;         maxx:x の範囲について，最大値を指定します。
;         borderthickness:境界線の太さを指定します。
;         slashangle:斜線の角度を指定します。
;         slashspace:斜線の間隔を指定します。
;         slashthickness:斜線の太さを指定します。（デフォルトは 0.3pt）
;    #2: 関数式1
;    #3: 関数式2
(defun YaTeX:YPaintii* ()
  (let* ((option (emath-emPaint*-slashonly-option))
	 (option (emath-setoption option "minx" "左端点のx座標の指定"))
	 (option (emath-setoption option "maxx" "右端点のx座標の指定")))
    (insert (concat (if (> (length option) 0)
			(concat "<" option ">") "")
		    "{" (read-string "関数式1: ") "}"
		    "{" (read-string "関数式2: ") "}%"))))
;\Soukyokusen<#1>#2#3#4
;  主軸が x軸に平行な双曲線を描画します。
;\ySoukyokusen<#1>#2#3#4
;  主軸が y軸に平行な双曲線を描画します。
;    #1: key=val 形式をコンマ区切りで並べます。
;         linethickness:双曲線の太さを変更
;         dash双曲線を破線で描画
;         iro:双曲線に色を付与（color も同義のキーです）
;         lbP:双曲線の左下端点に名前をつけて保存
;         ltP:双曲線の左上端点に名前をつけて保存
;         rbP:双曲線の右下端点に名前をつけて保存
;         rtP:双曲線の右上端点に名前をつけて保存
;         zenkinsen:双曲線の漸近線を付加
;         zenkinseniro:漸近線に色を付与
;         *zenkinsensyu:漸近線の線種を変更
;         zenkinsenthickness:漸近線の太さを変更
;    #2: 中心
;    #3: a
;    #4: b
;  コマンドを実行後，4つの端点（右上，右下，左上，左下）をそれぞれ
;  \rtP, \rbP, \ltP, \lbP に保存しています。
(defun emath-Soukyokusen-common ()
  (let* ((emnum 0)
	 (option (emath-setoption "" "linethickness" "太さの設定"))
	 (dash (if (y-or-n-p "破線にしますか？: ")
		   (concat "dash={" (emath-setdash) "}") ""))
	 (option (emath-setoption option "color" "色の指定"))
	 (zenkinsen ""))
    (progn (if (y-or-n-p "[option] 描画端点の名前を指定しますか？: ")
	       (setq option (emath-setoption option "ltP" "左上の端点")
		     option (emath-setoption option "lbP" "左下の端点")
		     option (emath-setoption option "rtP" "右上の端点")
		     option (emath-setoption option "rbP" "右下の端点")))
	   (if (y-or-n-p "[option] 漸近線を描画しますか？: ")
	       (setq zenkinsen "zenkinsen"
		     option (emath-setoption option "zenkinsenthickness" "漸近線の太さの指定")
		     option (emath-setoption option "zenkinseniro" "漸近線の色の指定")))
	   (setq option (emath-option-combine "," `(,option ,dash ,zenkinsen)))
	   (concat option))))
(defun YaTeX:Soukyokusen ()
  (let* ((option (emath-Soukyokusen-common)))
    (progn (insert (concat (if (> (length option) 0)
			       (concat "<" option ">") "")
			   "{" (read-string "中心の座標: ") "}"
			   "{" (read-string "a: ") "}"
			   "{" (read-string "b: ") "}%\\ltP，\\lbP，\\rtP，\\rbPに描画端点が保存されている")))))
(fset `YaTeX:ySoukyokusen `YaTeX:Soukyokusen)
; 近似折線の共通設定
(defun emath-Kinzi-Common (var dx &optional min max)
  (let* ((option (emath-setoption "" (format "d%s" var) (format "%sの刻み値(%s)" var dx)))
	 (option (emath-setoption option (format "min%s" var) (format "%sの最小値(%s)" var min)))
	 (option (emath-setoption option (format "max%s" var) (format "%sの最大値(%s)" var max))))
    (if (> (length option) 0)
	(insert (concat "<" option ">")) ())))
;\YLGraph<#1>#2#3
;    #1: key=val 形式のオプション引数
;         dx:x の刻み値を指定します。デフォルトは 0.05 です。
;         maxx:x の範囲について，最大値を指定します。
;         minx:x の範囲について，最小値を指定します。
;    #2: 式 (f(x))
;    #3: 折れ線を受け取る制御綴
(defun YaTeX:YLGraph ()
  (progn (emath-Kinzi-Common "x" ".05")
	 (insert (concat (read-string "関数: ")
			 (read-string "折線を受け取る制御綴り: ")))))
;\ParamLC<#1>#2#3#4
;    #1: key=val
;         dt:媒介変数の刻み値を指定します。デフォルトは 0.02 です。
;         maxt:媒介変数 t の動く最大値を指定します。デフォルトは 2π です。
;         mint:媒介変数 t の動く最小値を指定します。デフォルトは 0 です。
;    #2: x=f(t)
;    #3: y=g(t)
;    #4: 近似折れ線を受け取る制御綴
(defun YaTeX:ParamLC ()
  (progn (emath-Kinzi-Common "t" ".02" "0" "2\\pi")
	 (insert (concat (read-string "関数(x): ")
			 (read-string "関数(y): ")
			 (read-string "折線を受け取る制御綴り: ")))))
;;;;\Hantyokusen<#1>#2#3
;;;; 端点と通過点（1点）を指定して半直線を描画します。
;;;;    #1: key=val （\Drawline に引き継がれる）
;;;;    #2: 端点
;;;;    #3: 半直線が通過する1点
;;;(defun YaTeX:Hantyokusen ()
;;;  (let* ((option (emath-Drawline-option)))
;;;    (insert (concat (if (> (length option) 0)
;;;			(concat "<" option ">") "")
;;;		    "{" (read-string "端点の指定: ") "}"
;;;		    "{" (read-string "半直線が通過する点の指定: ") "}"
;;;		    "% \\HtyokuT=描画領域の端点\n"))))
;;;;\mHantyokusen<#1>#2#3
;;;; 端点と方向ベクトルを指定して半直線を描画します。
;;;;    #1: key=val （\Drawline に引き継がれる）
;;;;    #2: 端点
;;;;    #3: 半直線の方向ベクトル
;;;(defun YaTeX:mHantyokusen ()
;;;  (let* ((option (emath-Drawline-option)))
;;;    (insert (concat (if (> (length option) 0)
;;;			(concat "<" option ">") "")
;;;		    "{" (read-string "端点の指定: ") "}"
;;;		    "{" (read-string "方向ベクトルの指定: ") "}"
;;;		    "% \\HtyokuT=描画領域の端点\n"))))
;;;;\kHantyokusen<#1>#2#3
;;;; 端点と方向角を指定して半直線を描画します。
;;;;    #1: key=val （\Drawline に引き継がれる）
;;;;    #2: 端点
;;;;    #3: 半直線の方向角
;;;(defun YaTeX:Hantyokusen ()
;;;  (let* ((option (emath-Drawline-option)))
;;;    (insert (concat (if (> (length option) 0)
;;;			(concat "<" option ">") "")
;;;		    "{" (read-string "端点の指定: ") "}"
;;;		    "{" (read-string "方向角の指定: ") "}"
;;;		    "% \\HtyokuT=描画領域の端点\n"))))
;;;(defun YaTeX:Hantyokusen ()
;;;  (concat "{" (read-string "端点: ") "}"
;;;	  "{" (read-string "通過点: ") "}%\\HtyokuTに描画領域の端点が保存される"))
;;;(defun YaTeX:mHantyokusen ()
;;;  (concat "{" (read-string "端点: ") "}"
;;;	  (YaTeX:read-coordinates "方向ベクトル (x,y): ")
;;;	  "%\\HtyokuTに描画領域の端点が保存される"))
;;;(defun YaTeX:kHantyokusen ()
;;;  (concat (read-string "端点: ")
;;;	  "{" (read-string "方向角: ") "}%\\HtyokuTに描画領域の端点が保存される"))
(defun YaTeX:KTGAISessen ()
  (concat "{" (read-string "円1の中心: ") "}"
	  "{" (read-string "円1の半径: ") "}"
	  "{" (read-string "円2の中心: ") "}"
	  "{" (read-string "円2の半径: ") "}"
	   (read-string "共通接線1と円1の接点を受け取る制御綴り: ")
	   (read-string "共通接線1と円2の接点を受け取る制御綴り: ")
	   (read-string "共通接線2と円1の接点を受け取る制御綴り: ")
	   (read-string "共通接線2と円2の接点を受け取る制御綴り: ")))
(fset 'YaTeX:KTNAISessen 'YaTeX:KTGAISessen)
(defun YaTeX:enniSessen ()
  (concat "{" (read-string "中心: ") "}"
	  "{" (read-string "半径: ") "}"
	  "{" (read-string "外部の点: ") "}"
	  (read-string "接点を受け取る制御綴り1: ")
	  (read-string "接点を受け取る制御綴り2: ")))
(defun YaTeX:ennoSessen ()
  (concat "{" (read-string "円の中心: ") "}"
	  "{" (read-string "円周上の点: ") "}"
	  (read-string "方向ベクトルを受け取る制御綴り: : ")))
;\YniSessen<#1>#2#3#4#5
;    #1: key=val
;         infx:接点の存在範囲下限を指定します。
;         supx:接点の存在範囲上限を指定します。
;         xval:接点の x座標を受け取ります。
;         lim:近似誤差の目安を指定します。(.0001)
;             精度を上げるにはこの値を小さくする
;    #2: 関数式(f(x))
;    #3: 導関数(f'(x))
;    #4: 指定点
;    #5: 接点を受け取る制御綴
(defun YaTeX:YniSessen ()
  (let* ((option (emath-setoption "" "infx" "計算範囲のxの下限"))
	 (option (emath-setoption option "supx" "計算範囲のxの上限"))
	 (option (emath-setoption option "xval" "接点のx座標を受け取る制御綴り"))
	 (option (emath-setoption option "lim" "近似の精度の調整[値を小さくすると精度が上がる](.0001)")))
    (insert (concat (if (> (length option) 0)
			(concat "<" option ">"))
		    "{" (read-string "関数: ") "}"
		    "{" (read-string "導関数: ") "}"
		    "{" (read-string "曲線上にない点の指定: ") "}"
		    (read-string "接点を受け取る制御綴り: ")))))
(defun YaTeX:tentoTyokusen ()
  (concat "{" (read-string "点: ") "}"
	  "{" (read-string "通過点1: ") "}"
	  "{" (read-string "通過点2: ") "}"
	  (read-string "距離を受け取る制御綴り: ")))
(defun YaTeX:tentotyokusen ()
  (concat "{" (read-string "点: ") "}"
	  "{" (read-string "xの係数: ") "}"
	  "{" (read-string "yの係数: ") "}"
	  "{" (read-string "定数項: ") "}"
	  (read-string "距離を受け取る制御綴り: ")))
;;;(defun YaTeX:tyokusen ()
;;;  (concat (if (y-or-n-p "\\qbezierで直線を引きますか?")
;;;	      (concat "[" (read-string "[...]") "]") ())
;;;	  "{" (read-string "xの係数: ") "}"
;;;	  "{" (read-string "yの係数: ") "}"
;;;	  "{" (read-string "定数項: ") "}"
;;;	  (if (y-or-n-p "y座標で左端点を指定しますか?")
;;;	      (concat "[y]{" (read-string "y座標: ") "}")
;;;	    (concat "{" (read-string "x座標: ") "}"))
;;;	  (if (y-or-n-p "y座標で右端点を指定しますか?")
;;;	      (concat "[y]{" (read-string "y座標: ") "}")
;;;	    (concat "{" (read-string "x座標: ") "}"))))
;;;(defun YaTeX:kTyokusen ()
;;;  (concat (if (y-or-n-p "\\qbezierで直線を引きますか?")
;;;	      (concat "[" (read-string "[...]") "]") ())
;;;	  "{" (read-string "通過点: ") "}{"
;;;	  (read-string "方向角: ") "}"
;;;	  (if (y-or-n-p "y座標で左端点を指定しますか?")
;;;	      (concat "[y]{" (read-string "y座標: ") "}")
;;;	    (concat "{" (read-string "x座標: ") "}"))
;;;	  (if (y-or-n-p "y座標で右端点を指定しますか?")
;;;	      (concat "[y]{" (read-string "y座標: ") "}")
;;;	    (concat "{" (read-string "x座標: ") "}"))))
;;;(defun YaTeX:mTyokusen ()
;;;  (concat (if (y-or-n-p "\\qbezierで直線を引きますか?")
;;;	      (concat "[" (read-string "[...]") "]"))
;;;	  "{" (read-string "通過点: ") "}{"
;;;	  (YaTeX:read-coordinates "方向ベクトル (x,y)") "}"
;;;	  (if (y-or-n-p "y座標で左端点を指定しますか?")
;;;	      (concat "[y]{" (read-string "y座標: ") "}")
;;;	    (concat "{" (read-string "x座標: ") "}"))
;;;	  (if (y-or-n-p "y座標で右端点を指定しますか?")
;;;	      (concat "[y]{" (read-string "y座標: ") "}")
;;;	    (concat "{" (read-string "x座標: ") "}"))))
;;;(defun YaTeX:Tyokusen ()
;;;  (concat (if (y-or-n-p "\\qbezierで直線を引きますか?")
;;;	      (concat "[" (read-string "[...]") "]") ())
;;;	  "{" (read-string "点1: ")"}{"
;;;	  (read-string "点2: ") "}"
;;;	  (if (y-or-n-p "y座標で左端点を指定しますか?")
;;;	      (concat "[y]{" (read-string "y座標: ") "}")
;;;	    (concat "{" (read-string "x座標: ") "}"))
;;;	  (if (y-or-n-p "y座標で右端点を指定しますか?")
;;;	      (concat "[y]{" (read-string "y座標: ") "}")
;;;	    (concat "{" (read-string "x座標: ") "}"))))
;\Kyori<#1>#2#3#4
;    #1 : perl を指定したときは，perl を用いて計算します。
;    #2,#3: 2点の座標
;    #4 : 結果を受け取る制御綴
(defun YaTeX:Kyori ()
  (insert (concat (if (y-or-n-p "Perlと連携しますか？: ")
		      "<perl>" "")
		  "{" (read-string "点1: ") "}"
		  "{" (read-string "点2: ") "}"
		  (read-string "結果を受け取る制御綴り: "))))
(fset 'YaTeX:Kyorii 'YaTeX:Kyori)
;\KTkukan[#1]#2[#3]#4
;    #1: 各区間のラベル指定オプション
;        デフォルトは [auto] で，\maru1, \maru2, .....が付与されます。
;        各不等式に \label がついているときは，ラベル名を`;'区切りで並べます。
;        [] と指定すれば，区間にラベルはつきません。
;       下の \kukantakasa を用いて，自由に配置してもよい。
;    #2: 各不等式の解区間を ; で区切って並べます。
;        区間は
;        　　開区間 : (-3,5)
;        　　閉区間 : [-3,5]
;        　　半開区間 : (-3,5], [-3,5)
;        　　無限区間 : (,-3), (5,)
;       などと表す。
;       2つの区間の和集合は (,-3)|(5,) などのように，`|'を用いる
;    #3: 答の表示に関するオプション。 key=val 形式で有効なキーは
;         color:答を表示するカラーを指定します。
;         iro:答を表示するカラーを指定します。
;         paintoption:\emPaint のオプションを指定します。
;                     デフォルトは paintoption=* （すなわち斜線塗り）となっています。
;    #4: 答の区間
(defun YaTeX:KTkukan ()
  (let* ((emnum 0)
	 (option "")
	 (color "")
	 (paintoption ""))
    (progn (insert (concat (if (y-or-n-p "ラベルの設定をしますか？: ")
			       (concat "[" (emath-tenretu-loop "," "ラベルの指定") "]") "")
			   "{" (emath-tenretu-loop ";" "区間の設定") "}"))
	   (setq color (emath-setoption "" "color" "数直線上の解答部分の配色")
		 emnum (emath-get-number-from-list "[option] 共通部分の塗り方" `("塗り潰し" "斜塗り"))
		 paintoption (concat "paintoption={"
				     (cond ((= emnum 1)(concat "<" (emath-emPaint-option "") ">"))
					   ((= emnum 2)(concat "*<" (emath-emPaint*-option "") ">"))
					   (t ""))
				     "}"))
	   (setq option (emath-option-combine "," `(,color ,paintoption)))
	   (insert (concat (if (> (length option) 0)
			       (concat "[" option "]") ""))
		   "{" (read-string "解答の区間: ") "}"))))
(defun YaTeX:suutyokusen ()
  (let* ((option (if (y-or-n-p "[option] 正の数に\"+\"を付けますか？")
		     "[+]" ""))
	 (temp (read-string "[option] 目盛りの刻み値(1): "))
	 (option (concat option
			 (if (string= temp "") ""
			   (concat "(" temp ")")))))
    (concat option
	    "{" (read-string "xの上限: ") "}{"
	    (read-string "xの下限: ") "}")))
;\Kaiten[#1]<#2>#3#4#5#6
;\perlKaiten[#1]<#2>#3#4#5#6
; 点 #3 を中心として
; 点 #4 を #5°回転した点を #6 の制御綴に与える．
;   #1 : 長さ指定 単位を伴う長さを指定しますが，無名数の場合は \unitlength が単位であるとみなされます。
;   #2 : 長さの倍率指定
;    \perlKaiten は，計算を perl で行います。また，#1, #2 に perlの計算式を記述することができます。
(defun YaTeX:Kaiten ()
  (let* ((emnum (emath-get-number-from-list "[option] 長さの指定" `("長さ" "倍率" "指定しない")))
	 (option (cond ((= emnum 1)(concat "[" (read-string "[option] 長さの設定: ") "]"))
		       ((= emnum 2)(concat "<" (read-string "[option] 倍率の設定: ") ">"))
		       (t ""))))
    (insert (concat option
		    "{" (read-string "回転の中心: ") "}"
		    "{" (read-string "回転させる点: ") "}"
		    "{" (read-string "回転角: ") "}"
		    (read-string "結果を受け取る制御綴り: ")))))
(fset `YaTeX:perlKaiten `YaTeX:Kaiten)
(fset 'YaTeX:Rotvec 'YaTeX:Kaiten)
(defun YaTeX:vecXY ()
  (concat (read-string "元になるベクトル: ")
	  (read-string "x成分を受け取る制御綴り: ")
	  (read-string "y成分を受け取る制御綴り: ")))
(defun YaTeX:Nvec ()
  (concat "{" (read-string "元になるベクトル: ") "}"
	  (read-string "結果を受け取る制御綴り: ")))
;Addvec#1#2#3
;    #1: ベクトル
;    #2: ベクトル
;    #3: (#1)+(#2)を受け取る制御綴
;\Addvec*#1#2#3
;    #1: ベクトル
;    #2: ベクトル（成分は，単位付きの長さ）
;    #3: (#1)+(#2)を受け取る制御綴
(defun YaTeX:Addvec ()
  (concat "{" (read-string "ベクトル1: ") "}"
	  "{" (read-string "ベクトル2: ") "}"
	  (read-string "結果を受け取る制御綴り: ")))
(fset 'YaTeX:Subvec 'YaTeX:Addvec)
(defun YaTeX:Addvec* ()
  (concat "{" (read-string "ベクトル1: ") "}"
	  "{" (read-string "ベクトル2(成分は単位付き数値): ") "}"
	  (read-string "結果を受け取る制御綴り: ")))
(fset 'YaTeX:Subvec* 'YaTeX:Addvec*)
(fset 'YaTeX:perlAddvec* 'YaTeX:Addvec*)
;\itiziketugou<#1>#2#3
;    #1: key=val
;      iii:空間ベクトルを扱います。
;      perl:係数に perl の計算式を許容します。
;    #2: 実係数 a1, a2, ... , aN
;    ベクトル　v1, v2, ... , vN
;    を 　a1,v1;a2,v2; ... ;aN,vN
;    と列記します。
;    #3: 一次結合 a1v1 + a2v2 + ... + aNvN を受け取る制御綴
(defun emath-itiziketugou-loop (seq)
  (let* ((vector "")
	 (keisuu (read-string "係数の指定(returnで終了): ")))
    (if (> (length keisuu) 0) 
	(progn (setq vector (read-string "ベクトルの指定: ")
		     vector (emath-option-combine "," `(,keisuu ,vector))
		     vector (emath-option-combine ";" `(,seq ,vector)))
	       (emath-itiziketugou-loop vector))
      (insert (concat "{" seq "}")))))
(defun YaTeX:itiziketugou ()
  (let* ((option "")
	 (iii (if (y-or-n-p "空間ベクトルですか？")
		  "iii" ""))
	 (perl (if (y-or-n-p "Perlと連携しますか？")
		   "perl" "")))
    (progn (setq option (emath-option-combine "," `(,iii ,perl)))
	   (if (> (length option) 0)
	       (insert (concat "<" option ">")) "")
	   (emath-itiziketugou-loop "")
	   (insert (read-string "結果を受け取る制御綴り: ")))))
(defun YaTeX:Mulvec ()
  (concat "{" (read-string "スカラー: ") "}{"
	  (read-string "ベクトル: ") "}"
	  (read-string "スカラー倍したベクトルを受け取る制御綴り: ")))
(defun YaTeX:Mulvec* ()
  (concat "{" (read-string "単位付き数値: ") "}{"
	  (read-string "ベクトル: ") "}"
	  (read-string "長さを決めたベクトルを受け取る制御綴り: ")))
(defun YaTeX:Mulvecself ()
  (concat "{" (read-string "スカラー: ") "}"
	  (read-string "スカラー倍するベクトル(かつ受け取る制御綴り): ")))
;\Absvec<#1>#2#3
;    #1: オプション引数で，<perl>を指定したときは，perl との連携機能を用います。
;    #2: ベクトル
;    #3: ベクトル#2 の大きさを格納する制御綴
(defun YaTeX:Absvec ()
  (progn (if (y-or-n-p "Perlとの連携をしますか？")
	     (insert "<perl>") "")
	 (concat "{" (read-string "元となるベクトルの指定: ") "}"
		 (read-string "結果を受け取る制御綴り: "))))
;\Argvec<#1>#2#3
;    #1: オプション引数で，<perl>を指定したときは，perl との連携機能を用います。
;    #2: ベクトル
;    #3: ベクトル#2 の方向角（度数法で，-180＜#3≦180）を格納する制御綴 
(fset 'YaTeX:Argvec 'YaTeX:Absvec)
;\Unitvec<#1>#2#3
;    #1: オプション引数で，<perl>を指定したときは，perl との連携機能を用います。
;    #2: ベクトル
;    #3: 結果を受け取る制御綴
(fset 'YaTeX:Unitvec 'YaTeX:Absvec)
(defun YaTeX:Yogen ()
  (let* ((option (concat (if (y-or-n-p "[option] 角度を求めますか？")
			     "[a]" ""))))
    (concat (if (string= option "") ""
	      (concat option))
	    "{" (read-string "対辺の長さ: ") "}{"
	    (read-string "他の辺の長さ1: ") "}{"
	    (read-string "他の辺の長さ2: ") "}"
	    (read-string "結果を受け取る制御綴り: "))))
(defun YaTeX:yogen ()
  (concat "{" (read-string "辺の長さ1: ") "}{"
	  (read-string "辺の長さ2: ") "}{"
	  (read-string "挟まれた角度: ") "}"
	  (read-string "対辺の長さを受け取る制御綴り: ")))
(defun YaTeX:Seigen ()
  (concat (if (y-or-n-p "[option] 鈍角を求めますか?")
	      "[d]" "")
	  "{" (read-string "辺の長さ: ") "}"
	  (read-string "角の大きさを受け取る制御綴り: ")))
(defun YaTeX:seigen ()
  (concat "{" (read-string "角の大きさ: ") "}"
	  (read-string "辺の長さを受け取る制御綴り: ")))
(defun YaTeX:seigenR ()
  (concat "{" (read-string "向かい合う辺の長さ: ")
	  "}{" (read-string "向かい合う角の大きさ: ")
	  "}%外接円の直径が\\lRRに半径が\\lRに格納されています．\n"
	  "%続けて\\seigen(辺を求める),\\Seigen(角を求める)を使用できます．"))
(defun YaTeX:Nitoubunsen ()
  (concat (if (y-or-n-p "[option] 外角の二等分線も求めますか?")
	      (concat "[" (read-string "外角の二等分線と頂点1と頂点3を結んだ直線との交点: ") "]") ())
	  "{" (read-string "頂点1: ") "}{"
	  (read-string "頂点2: ") "}{"
	  (read-string "頂点3: ") "}"
	  (read-string "角の二等分線と頂点1と頂点3を結んだ直線との交点: ")))
(defun YaTeX:KinziEnko ()
  (concat (if (y-or-n-p "[option] 刻み値を指定しますか")
	      (concat "<" (read-string "刻み値(.02): ") ">")
	    ())
	  "{" (read-string "中心: ") "}"
	  (emath-Enko-body)
	  (read-string "近似折れ線を受け取る制御綴り: ")))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;; 斜線塗り                                             ;;;
;;;;;; \Nuritubusi*[斜線の方向角(45)]<option>{点列}         ;;;
;;;;;; \En**[斜線の方向角(45)]<option>{中心}{半径}          ;;;
;;;;;;      option border:1で境界を描画する                 ;;;
;;;;;;             syanurisiteiten:斜線群が通過する点を指定 ;;;
;;;;;;             syanurikankaku:斜線の間隔(.125)          ;;;
;;;;;; \Daen**,\yumigata**,\ougigata**,\Daenko**も同様      ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;(defun emath-nuritubusi-option ()
;;;  (let* ((option "")
;;;	 (emnum 0))
;;;    (progn (if (y-or-n-p "塗り潰しの指定をしますか？: ")
;;;	       (setq emnum (emath-get-number-from-list "[option] 塗り潰しの指定" `("白黒指定" "カラー指定"))) "")
;;;	   (setq option (cond ((= emnum 1)(concat "noudo=" (read-string "[option] 濃度指定(.5): ")))
;;;			      ((= emnum 2)(concat "paintcolor=" (read-string "[option] 色指定: ")))
;;;			      (t "")))
;;;	   (if (= emnum 2)
;;;	       (setq option (emath-setoption option "dilutecolor" "塗り色の濃度指定[0で段階的に薄くする]")) "")
;;;	   (concat option))))
;;;(defun emath-syanuri-option ()
;;;  (let* ((temp (read-string "[option] 斜線の方向角(45): "))
;;;	 (angle (if (string= temp "") ""
;;;		  (concat "[" temp "]")))
;;;	 (option (emath-setoption "" "border" "1で境界を表示(1)"))
;;;	 (option (emath-setoption option "bordercolor" "境界の色"))
;;;	 (option (emath-setoption option "syanurisiteiten" "斜線群が通過する点の指定"))
;;;	 (option (emath-setoption option "syanurikankaku" "斜線の間隔(.125)"))
;;;	 (option (emath-setoption option "syanuriKankaku" "斜線の間隔(要単位)"))
;;;	 (option (emath-setoption option "slashcolor" "斜線の色"))
;;;	 (option (emath-setoption option "syasentanmatu" "斜線の端と囲む線との間隔(要単位)")))
;;;    (concat angle
;;;	    (if (string= option "") ""
;;;	      (concat "<" option ">")))))
(defun emath-En-body ()
  (let* ((emnum 0)
	 (hankei ""))
    (concat "{" (read-string "円の中心: ") "}"
	    "{" (setq emnum (emath-get-number-from-list "半径の指定方法" `("半径指定" "通過点指定"))
		      hankei (cond ((= emnum 2) (concat "tuukaten=" (read-string "円の通過点: ")))
				   (t (read-string "円の半径: ")))) "}")))
(defun YaTeX:En ()
  (let* ((option (emath-drawline-option)))
    (concat (if (string= option "") ""
	      (concat "<" option ">"))
	    (emath-En-body))))
(defun YaTeX:En* ()
  (let* ((option (emath-emPaint-paintonly-option));(emath-nuritubusi-option))
	 (border (if (y-or-n-p "円周を描画しますか？: ")
		     "border" ""))
	 (color (if (> (length border) 0)
		    (concat "color=" (read-string "[option] 円周の色の指定: ")) "")))
    (progn (setq option (emath-option-combine "," `(,option ,border ,color)))
	   (insert (if (> (length option) 0)
		       (concat "<" option ">") ""))
	   (emath-En-body))))
(fset `YaTeX:Enban `YaTeX:En*)
(defun YaTeX:En** ()
  (concat (emath-emPaint*-option "")
;	  (emath-syanuri-option)
	  (emath-En-body)))
;arcn:描画方向を逆にする
;hamidasikaku:円弧を延長
;hazimeT:円弧の始点に名前を付けて保存
;owariT:円弧の終点に名前を付けて保存
;yazirusi:円弧に矢印
;        yazirusi=a : 正の向きに矢印
;        yazirusi=r : 負の向きに矢印
;        yazirusi=b : 両向きに矢印
;        yazirusi=n : 矢印をつけない（デフォルト）
;arrowsize:円弧に付与する鏃のサイズ変更
(defun emath-Enko-option ()
  (let* ((emnum 0)
	 (arc (if (y-or-n-p "描画方向を逆にしますか？: ") "arcn" ""))
	 (option (emath-setoption "" "hamidasikaku" "はみ出し角"))
	 (option (emath-setoption option "hazimeT" "始点の名前変更(hazimeT)"))
	 (option (emath-setoption option "owariT" "終点の名前変更(owariT)"))
	 (yazirusi ""))
    (progn (if (y-or-n-p "矢印を付加しますけ？: ")
	       (setq emnum (emath-get-number-from-list "[option] 矢印の位置の指定" `("正の向き" "負の向き" "両端"))
		     yazirusi (concat "yazirusi="
				      (cond ((= emnum 1) (concat "a"))
					    ((= emnum 2) (concat "r"))
					    ((= emnum 3) (concat "b"))))) "")
	   (setq option (emath-option-combine "," `(,arc ,option ,yazirusi)))
	   (concat option))))
(defun emath-Enko-body ()
  (concat "{"
	  (let* ((empoint (emath-setoption "" "tuukaten" "[半径] 円の通過点")))
	    (if (string= empoint "")
		(read-string "円の半径: ")
	      (concat empoint)))
	  "}{"
	  (let* ((empoint (emath-setoption "" "hazimeten" "[開始角] 開始点")))
	    (if (string= empoint "")
		(read-string "開始角: ")
	      (concat empoint)))
	  "}{"
	  (let* ((empoint (emath-setoption "" "owariten" "[終了角] 終了点")))
	    (if (string= empoint "")
		(read-string "終了角: ")
	      (concat empoint)))
	  "}"))
(defun YaTeX:Enko ()
  (let* ((option "")
	 (lineop (emath-drawline-option))
	 (enkoop (emath-Enko-option)))
    (progn (setq option (emath-option-combine "," `(,lineop ,enkoop)))
	   (if (> (length option) 0)
	       (insert (concat "<" option ">")) "")
	   (insert (concat "{" (read-string "円の中心: ") "}"))
	   (emath-Enko-body))))
;\EnkoToubun<#1>#2#3#4#5#6#7
;    #1: key=val, 有効なキーは
;         dousa:定義した点列を結ぶ折れ線に対する動作を指定します。右辺値は
;               D:\Drawline を呼び出し，折れ線を描画します。'D'に引き続き \Drawline のオプション引数を記述することも可能です。
;               T:\Takakkei を呼び出し，多角形を描画します。'T'に引き続き \Takakkei のオプション引数を記述することも可能です。
;               P:\emPaint を呼び出し，塗りつぶします。'P'に引き続き \emPaint のオプション引数を記述することも可能です。
;         kuromaru:定義した点に黒丸を描画します。
;         nahuda:定義した点に名前を表示します。
;         oresen:定義した点列を結ぶ折れ線を取得します。右辺値は取得する制御綴名です。
;    #2: 中心
;    #3: 半径を直接与えるか
;        tuukaten=xx として，円弧の周上の一点を与えます。
;    #4: 始め角を直接与えるか
;        hazimeten=xx として，中心を始点，xx を終点とするベクトルの 方向角を 始め角とするように指定します。
;    #5: 終り角を直接与えるか
;        owariten=xx として，中心を始点，xx を終点とするベクトルの 方向角を 終り角とするように指定します。
;        　　　　　　（+ と指定した場合は，#5=#4+360）
;        　　　　　　（- と指定した場合は，#5=#4-360）
;    #6: 分割数
;    #7: 分点の名前（配列基幹名，または，コンマ区切り点列名）
;    　　#7 において，戻る分点の個数は
;    　　　#5 で +, - を指定した場合は， n個
;    　　　　　 それ以外の場合は両端を含め (n+1)個
;;; dousa=Pでの斜塗り指定には対応していない
(defun emath-EnkoToubun-option ()
  (let* ((emnum 0)
	 (dousa "")
	 (kuromaru (if (y-or-n-p "[option] 各頂点に黒丸を設定しますか？: ")
		       "kuromaru" ""))
	 (nahuda (if (y-or-n-p "[option] 各頂点に名札を設定しますか？: ")
		     "nahuda" ""))
	 (option (emath-setoption "" "oresen" "点列を保存するの制御綴り名")))
    (progn (if (y-or-n-p "[option] 折線を描画しますか？: ")
	       (setq emnum (emath-get-number-from-list "[option] 描画方法"
							     `("\\Drawline" "\\Takakkei" "\\emPaint" "\\emPaint*"))
		     dousa (cond ((= emnum 1)
				  (concat "dousa={D"
					  (if (y-or-n-p "[option] \\Drawlineのオプションを設定しますか？: ")
					      (concat "<" (emath-Drawline-option) ">") "")
					  "}"))
				 ((= emnum 2)
				  (concat "dousa={T"
					  (if (y-or-n-p "[option] \\Takakkeiのオプションを設定しますか？: ")
					      (concat "<" (emath-drawline-option) ">") "")
					  "}"))
				 ((= emnum 3)
				  (concat "dousa={P"
					  (if (y-or-n-p "[option] \\emPaintのオプションを設定しますか？: ")
					      (concat "<" (emath-emPaint-option "") ">") "")
					  "}"))
				 ((= emnum 4)
				  (concat "dousa={P*"
					  (if (y-or-n-p "[option] \\emPaint*のオプションを設定しますか？: ")
					      (concat "<" (emath-emPaint*-option "") ">") "")
					  "}"))
				 (t ""))))
	   (setq option (emath-option-combine "," `(,option ,kuromaru ,nahuda ,dousa)))
	   (concat option))))
(defun YaTeX:EnkoToubun ()
  (let* ((option (emath-EnkoToubun-option)))
    (progn (insert (concat (if (> (length option) 0)
			       (concat "<" option ">") "")
			   "{" (read-string "円弧の中心: ") "}"))
	   (emath-Enko-body)
	   (insert (concat "{" (read-string "分割数: ") "}"
			   "{" (read-string "分点の名前: ") "}%")))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;% 矢線付き円弧（両端の点指定）                          ;;;
;;;%   \ArrowArc<#1>[#2]#3#4#5                             ;;;
;;;%   #1 : \Enko に渡すオプション                         ;;;
;;;%   #2 : [r]を付けると負の回転となるように矢印をつける．;;;
;;;%   #3 : 半径 (<0 のときは，[r]をつけたものとみなす。） ;;;
;;;%   #4 : 始点                                           ;;;
;;;%   #5 : 終点                                           ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun YaTeX:ArrowArc ()
  (let* ((option (emath-Enko-option)))
    (concat (if (string= option "") ""
	      (concat "<" option ">"))
	    "{" (read-string "半径: ") "}{"
	    (read-string "始点: ") "}{"
	    (read-string "終点: ") "}%円の中心:\\ArrowArcC")))
(defun YaTeX:ougigata ()
  (let* ((option (emath-drawline-option)))
    (concat (if (string= option "") ""
	      (concat "<" option ">"))
	    (emath-Enko-body))))
(defun YaTeX:ougigata* ()
  (let* ((option (emath-emPaint-paintonly-option)));(emath-nuritubusi-option)))
    (concat (if (string= option "") ""
	      (concat "<" option ">"))
	    (emath-Enko-body))))
(defun YaTeX:ougigata** ()
  (concat (emath-emPaint*-option "")
;	  (emath-syanuri-option)
	  (emath-Enko-body)))
(fset 'YaTeX:yumigata 'YaTeX:ougigata)
(fset 'YaTeX:yumigata* 'YaTeX:ougigata*)
(fset 'YaTeX:yumigata** 'YaTeX:ougigata**)
(defun emath-Daen-body ()
  (concat "{" (read-string "中心の座標: ") "}{"
	  (read-string "横軸方向の半径: ") "}{"
	  (read-string "縦軸方向の半径: ") "}"))
(defun YaTeX:Daen ()
  (let* ((option (emath-drawline-option)))
    (concat (if (string= option "") ""
	      (concat "<" option ">"))
	    (emath-Daen-body))))
(defun YaTeX:Daen* ()
  (let* ((option (emath-emPaint-paintonly-option)));(emath-nuritubusi-option)))
    (concat  (if (string= option "") ""
	       (concat "[" option "]"))
	     (emath-Daen-body))))
(defun YaTeX:Daen** ()
  (concat (emath-emPaint*-option "")
;	  (emath-syanuri-option)
	  (emath-Daen-body)))
(defun emath-Daenko-body ()
  (concat (emath-Daen-body)
	  "{" (read-string "開始角: ") "}{"
	  (read-string "終了角: ") "}"))
(defun YaTeX:Daenko ()
  (let* ((option (emath-drawline-option))
	 (option (emath-setoption option "yazirusi" "矢印の指定[arbn](n)")))
    (concat (if (string= option "") ""
	      (concat "<" option ">"))
	    (emath-Daenko-body))))
(defun YaTeX:Daenko* ()
  (let* ((option (emath-emPaint-paintonly-option)));(emath-nuritubusi-option)))
    (concat (if (string= option "") ""
	      (concat "[" option "]"))
	    (emath-Daenko-body))))
(defun YaTeX:Daenko** ()
  (concat (emath-emPaint*-option "")
;	  (emath-syanuri-option)
	  (emath-Daenko-body)))
(defun YaTeX:Earg ()
  (concat (read-string "楕円の中心: ")
	  "{" (read-string "x軸方向の半径: ") "}"
	  "{" (read-string "y軸方向の半径: ") "}"
	  (read-string "周上の点: ")
	  (read-string "媒介変数の値を受け取るコントロールシーケンス: ")))
(defun YaTeX:DaenmSessen ()
  (progn (insert (concat (read-string "中心の座標: ")
			 "{" (read-string "x軸方向の半径: ") "}"
			 "{" (read-string "y軸方向の半径: ") "}"
			 "{" (read-string "接線の方向ベクトル") "}"
			 (read-string "接点を受け取る制御綴り1: ")
			 (read-string "接点を受け取る制御綴り2: ")))))
(defun YaTeX:DaenniSessen ()
  (concat (read-string "楕円の中心: ")
	  "{" (read-string "x軸方向の半径: ") "}"
	  "{" (read-string "y軸方向の半径: ") "}"
	  (read-string "楕円の外部の点: ")
	  (read-string "接点1を受け取るコントロールシーケンス: ")
	  (read-string "接点2を受け取るコントロールシーケンス: ")))
(defun YaTeX:DaennoSessen ()
  (concat (read-string "楕円の中心: ")
	  "{" (read-string "x軸方向の半径: ") "}"
	  "{" (read-string "y軸方向の半径: ") "}"
	  (read-string "接点: ")
	  (read-string "接線の方向ベクトルを受け取るコントロールシーケンス: ")))
(defun YaTeX:Eandk ()
  (concat (read-string "楕円の中心: ")
	  "{" (read-string "x軸方向の半径: ") "}"
	  "{" (read-string "y軸方向の半径: ") "}"
	  (read-string "直線の通る点: ")
	  "{" (read-string "直線のなす角度: ") "}"
	  (read-string "交点1を受け取るコントロールシーケンス: ")
	  (read-string "交点2を受け取るコントロールシーケンス: ")))
(defun YaTeX:Eandl ()
  (concat (read-string "楕円の中心: ")
	  "{" (read-string "x軸方向の半径: ") "}"
	  "{" (read-string "y軸方向の半径: ") "}"
	  (read-string "直線の通る点: ")
	  "{" (read-string "直線の方向ベクトル") "}"
	  (read-string "交点1を受け取るコントロールシーケンス: ")
	  (read-string "交点2を受け取るコントロールシーケンス: ")))
(defun YaTeX:EandL ()
  (concat (read-string "楕円の中心: ")
	  "{" (read-string "x軸方向の半径") "}"
	  "{" (read-string "y軸方向の半径") "}"
	  (read-string "直線上の点1: ")
	  (read-string "直線上の点2: ")
	  (read-string "交点1を受け取るコントロールシーケンス: ")
	  (read-string "交点2を受け取るコントロールシーケンス: ")))
(defun YaTeX:CandC ()
  (concat (read-string "円1の中心: ")
	  "{" (read-string "円2の半径: ") "}"
	  (read-string "円2の中心: ")
	  "{" (read-string "円2の半径: ") "}"
	  (read-string "交点の座標1: ")
	  (read-string "交点の座標2: ")))
(fset 'YaTeX:CandC* 'YaTeX:CandC)
(defun YaTeX:Candk ()
  (concat (read-string "円の中心: ")
	  "{" (read-string "円の半径: ") "}"
	  (read-string "直線の通る点: ")
	  "{" (read-string "直線の方向角: ") "}"
	  (read-string "交点の座標1: ")
	  (read-string "交点の座標2: ")))
(fset 'YaTeX:Candk* 'YaTeX:Candk)
(defun YaTeX:Candl ()
  (concat (read-string "円の中心: ")
	  "{" (read-string "円の半径: ") "}"
	  (read-string "直線の通る点: ")
	  "{" (YaTeX:read-coordinates "直線の方向ベクトル (x,y): ") "}"
	  (read-string "交点の座標1: ")
	  (read-string "交点の座標2: ")))
(fset 'YaTeX:Candl* 'YaTeX:Candl)
(defun YaTeX:CandL ()
  (concat (read-string "円の中心: ")
	  "{" (read-string "円の半径: ") "}"
	  (read-string "直線の通る点1: ")
	  (read-string "直線の通る点2: ")
	  (read-string "交点の座標1: ")
	  (read-string "交点の座標2: ")))
(fset 'YaTeX:CandL* 'YaTeX:CandL)
(defun YaTeX:Candg ()
  (insert (concat (read-string "円の中心: ")
		  "{" (read-string "円の半径: ") "}"
		  (read-string "直線の通る点: ")
		  "{" (read-string "直線の傾き: ") "}"
		  (read-string "交点の座標1: ")
		  (read-string "交点の座標2: "))))
(fset 'YaTeX:Candg* 'YaTeX:Candg)
(defun YaTeX:Suisen ()
  (insert (concat "{" (read-string "垂線の始点: ") "}"
		  "{" (read-string "垂線を下ろす直線の通過点1: ") "}"
		  "{" (read-string "垂線を下ろす直線の通過点2: ") "}"
		  (read-string "垂線の足の座標を受け取る制御綴り: "))))
(defun YaTeX:gSuisen ()
  (insert (concat "{" (read-string "垂線の始点: ") "}"
		  "{" (read-string "垂線を下ろす直線の通過点: ") "}"
		  "{" (read-string "垂線を下ろす直線の傾き: ") "}"
		  (read-string "垂線の足の座標を受け取る制御綴り: "))))
(defun YaTeX:kSuisen ()
  (insert (concat "{" (read-string "垂線の始点: ") "}"
		  "{" (read-string "垂線を下ろす直線の通過点: ") "}"
		  "{" (read-string "垂線を下ろす直線の方向角: ") "}"
		  (read-string "垂線の足の座標を受け取る制御綴り: "))))
(defun YaTeX:lSuisen ()
  (insert (concat "{" (read-string "垂線の始点: ") "}"
		  "{" (read-string "垂線を下ろす直線の通過点: ") "}"
		  "{" (read-string "垂線を下ろす直線の方向ベクトル: ") "}"
		  (read-string "垂線の足の座標を受け取る制御綴り: "))))
(defun YaTeX:abcSuisen ()
  (insert (concat "{" (read-string "垂線の始点: ") "}"
		  "{" (read-string "直線のxの係数: ") ","
		  (read-string "直線のyの係数: ") ","
		  (read-string "直線の定数項: ") "}"
		  (read-string "垂線の足の座標を受け取る制御綴り: "))))
(defun YaTeX:Landk ()
  (concat (read-string "直線1の通る点1: ")
	  (read-string "直線1の通る点2: ")
	  (read-string "直線2の通る点: ")
	  "{" (read-string "直線2の方向角: ") "}"
	  (read-string "2直線の交点: ")))
(defun YaTeX:kandk ()
  (concat "{" (read-string "通過点1: ") "}"
	  "{" (read-string "角度1: ") "}"
	  "{" (read-string "通過点2: ") "}"
	  "{" (read-string "角度2: ") "}"
	  (read-string "2直線の交点: ")))
(defun YaTeX:landl ()
  (concat (read-string "直線1の通る点: ")
	  "{" (YaTeX:read-coordinates "直線1の方向ベクトル (x,y): ") "}"
	  (read-string "直線2の通る点: ")
	  "{" (YaTeX:read-coordinates "直線2の方向ベクトル (x,y): ") "}"
	  (read-string "2直線の交点: ")))
(defun YaTeX:Landl ()
  (concat (read-string "直線1の通る点1: ")
	  (read-string "直線1の通る点2: ")
	  (read-string "直線2の通る点: ")
	  "{" (YaTeX:read-coordinates "直線2の方向ベクトル (x,y): ") "}"
	  (read-string "2直線の交点: ")))
(defun YaTeX:LandL ()
  (let ((op ""))
    (progn (insert (concat (read-string "直線1の通過点1: ")
			   (read-string "直線1の通過点2: ")
			   (read-string "直線2の通過点1: ")
			   (read-string "直線2の通過点2: ")))
	   (setq op (read-string "2直線の交点: "))
	   (insert (if (y-or-n-p "[option] 交点にラベルをつけますか?: ")
		       (concat "{" op "[" (emathPut-syaei-option) "]}%")
		     op)))))
;\Landng<#1>#2#3#4#5#6
;    #1: key=val
;    2点 #2, #3 を通る直線と
;    点 #4 を通り，法線の傾きが #5 である直線
;    との交点を #6 の制御綴に返します。
(defun YaTeX:Landng ()
  (insert (concat "{" (read-string "直線1の通過点1: ") "}"
		  "{" (read-string "直線1の通過点2: ") "}"
		  "{" (read-string "直線2の通過通過点: ") "}"
		  "{" (read-string "直線2の傾き: ") "}"
		  (read-string "結果を受け取る制御綴り: "))))
;\gandg#1#2#3#4
; 点 #1 を通り，傾き #2 の直線と
; 点 #3 を通り，傾き #4 の直線との
; 交点を #5 の制御綴に返します。
;    #1: 点1
;    #2: 傾き1
;    #3: 点2
;    #4: 傾き2
;    #5: 交点を受け取る制御綴
(defun YaTeX:gandg ()
  (concat "{" (read-string "直線1の通過点: ") "}"
	  "{" (read-string "直線1の傾き: ") "}"
	  "{" (read-string "直線2の通過点: ") "}"
	  "{" (read-string "直線2の傾き: ") "}"
	  (read-string "結果を受け取る制御綴り: ")))
;;; 直線の接頭語の意味
;    L: 2点を指定*
;    l: 1点と方向ベクトルを指定（m も同義）*
;    g: 1点と傾きを指定*
;    k: 1点と方向角を指定*
;    n: 1点と法線ベクトルを指定*
;    ng: 1点と法線の傾きを指定
;    abc: ax+by+c=0 の係数 csv列*
;\Lline<#1>#2#3
;    #1: key=val
;         linethickness:直線の太さを変更
;         dash:直線を破線で描画
;         hasenLG:直線を破線で描画
;         color:直線に色を付与（iro も同義のキーです）
;         hidariM:左端点に出力する文字列を指定
;         migiM:右端点に出力する文字列を指定
;         hidariT:直線の左端点に名前をつけて保存
;         migiT:直線の右端点に名前をつけて保存
;         func:直線を表す一次関数式を保存します。
;    #2: 点1
;    #3: 点2
(defun emath-Lline-option ()
  (let* ((option (emath-setoption "" "linethickness" "直線の太さを指定"))
	 (dash (emath-set-dash))
	 (option (emath-setoption option "color" "直線の色の指定"))
	 (hidariM (if (y-or-n-p "左端点の文字列を指定しますか？: ")
		      (concat "hidariM={" (emath-Put-HouiShitei)
			      "{" (read-string "[option] [左端点] 文字列の指定: ") "}}") ""))
	 (migiM (if (y-or-n-p "右端点の文字列を指定しますか？: ")
		    (concat "migiM={" (emath-Put-HouiShitei)
			    "{" (read-string "[option] [右端点] 文字列の指定: ") "}}") ""))
	 (tanten (emath-set-tanten-csname))
;	 (option (emath-setoption option "hidariT" "左端点の名前を指定"))
;	 (option (emath-setoption option "migiT" "右端点の名前を指定"))
	 (option (emath-setoption option "func" "Perl形式の直線の式を保存する制御綴り"))
	 (option (emath-option-combine "," `(,option ,dash ,hidariM ,migiM ,tanten))))
    (concat option)))
(defun YaTeX:Lline ()
  (let* ((option (emath-Lline-option)))
    (insert (concat (if (> (length option) 0)
			(concat "<" option ">") "")
		    "{" (read-string "通過点1: ") "}"
		    "{" (read-string "通過点2: ") "}%"))))
;\lline<#1>#2#3
;    #1: key=val \Llineと共通+perl(傾きのPerlの計算式を許容する)
;    #2: 点
;    #3: 方向ベクトル
(defun YaTeX:lline ()
  (let* ((option (emath-Lline-option)))
    (insert (concat (if (> (length option) 0)
			(concat "<" option ">") "")
		    "{" (read-string "通過点: ") "}"
		    "{" (read-string "方向ベクトル: ") "}%"))))
(fset `YaTeX:mline `YaTeX:lline)
;\gline<#1>#2#3
;    #1: key=val \Llineと共通+perl(傾きのPerlの計算式を許容する)
;    #2: 点
;    #3: 傾き
(defun YaTeX:gline ()
  (let* ((option (emath-Lline-option))
	 (perl (if (y-or-n-p "傾きにPerlの計算式を許容しますか？: ")
		   "perl" ""))
	 (option (emath-option-combine "," `(,option ,perl))))
    (insert (concat (if (> (length option) 0)
			(concat "<" option ">") "")
		    "{" (read-string "通過点: ") "}"
		    "{" (read-string "傾き: ") "}%"))))
;\kline<#1>#2#3
;1点と方向角を与えて直線を描画します。
;    #1: key=val:Llineと同じ
;    #2: 点
;    #3: 方向角（度数法）
;\kline*<#1>#2#3
;方向角 #3 をラジアンで与えます。
;\perlkline<#1>#2#3
;\perlkline*<#1>#2#3
;方向角 #3 に perl の計算式を記述することが出来ます。
;;; \kline(*)にperlオプションの方がいいよね
(defun emath-kline-common (angle)
  (let* ((option (emath-Lline-option)))
    (insert (concat (if (> (length option) 0)
			(concat "<" option ">") "")
		    "{" (read-string "通過点: ") "}"
		    "{" (read-string (format "方向角(%s): " angle)) "}%"))))
(defun YaTeX:kline ()
  (emath-kline-common "度数法"))
(fset `YaTeX:perlkline `YaTeX:kline)
(defun YaTeX:kline* ()
  (emath-kline-common "弧度法"))
(fset `YaTeX:perlkline* `YaTeX:kline*)
;\nline<#1>#2#3
;1点と方向角を与えて直線を描画します。
;    #1: key=val:Llineと同じ
;    #2: 点
;    #3: 法線ベクトル
(defun YaTeX:nline ()
  (let* ((option (emath-Lline-option)))
    (insert (concat (if (> (length option) 0)
			(concat "<" option ">") "")
		    "{" (read-string "通過点: ") "}"
		    "{" (read-string "法線ベクトル: ") "}%"))))
(defun YaTeX:ngline ()
  (let* ((option (emath-Lline-option)))
    (insert (concat (if (> (length option) 0)
			(concat "<" option ">") "")
		    "{" (read-string "通過点: ") "}"
		    "{" (read-string "法線の傾き: ") "}%"))))
;\abcline<#1>#2
;    #1: key=val
;         key は \Lline コマンド と同様です。
;    #2: csv列 a,b,c
(defun YaTeX:abcline ()
  (let* ((option (emath-Lline-option)))
    (insert (concat (if (> (length option) 0)
			(concat "<" option ">") "")
		    "{" (read-string "xの係数: ")
		    "," (read-string "yの係数: ")
		    "," (read-string "定数項: ") "}%"))))
;;; 半直線はL,l,kのみ
;\LHline<#1>#2#3
;    #1: key=val
;         linethickness:半直線の太さを変更
;         dash:半直線を破線で描画
;         iro:半直線に色を付与
;         HlineT:半直線が描画領域を外れる点に名前をつけて保存
;    #2: 始点
;    #3: 通過点
(defun emath-Hline-common ()
  (let* ((option (emath-setoption "" "linethickness" "半直線の太さ"))
	 (option (emath-setoption option "color" "半直線の色"))
	 (dash (emath-set-dash))
	 (option (emath-setoption option "HlineT" "描画端点を表す制御綴り"))
	 (option (emath-option-combine "," `(,option ,dash))))
    (concat option)))
(defun YaTeX:LHline ()
  (let* ((option (emath-Hline-common)))
    (insert (concat (if (> (length option) 0)
			(concat "<" option ">") "")
		    "{" (read-string "始点: ") "}"
		    "{" (read-string "通過点: ") "}%"))))
;\lHline<#1>#2#3
;    #1: key=val
;    #2: 始点
;    #3: 方向ベクトル
(defun YaTeX:lHline ()
  (let* ((option (emath-Hline-common)))
    (insert (concat (if (> (length option) 0)
			(concat "<" option ">"))
		    "{" (read-string "始点: ") "}"
		    "{" (read-string "方向ベクトル: ") "}%"))))
;\kHline<#1>#2#3
;    #1: key=val:\LHlineと同じ
;    #2: 始点
;    #3: 方向角（度数法）
(defun YaTeX:kHline ()
  (let* ((option (emath-Hline-common)))
    (insert (concat (if (> (length option) 0)
			(concat "<" option ">"))
		    "{" (read-string "始点: ") "}"
		    "{" (read-string "方向角: ") "}%"))))
;\kousifill<#1>
;    #1key=val
;       dash:格子線を破線で描画します。
;       ex:横軸の基本ベクトルを変更します。
;       ey:縦軸の基本ベクトルを変更します。
;       linethickness:格子線の太さを指定します。
(defun YaTeX:kousifill ()
  (let* ((option (emath-drawline-option))
	 (option (if (> (length option) 0)
		     (concat "<" option ">%") "")))
    (insert option)))
;\LlineLR#1#2#3#4
;    #1, #2: 通る2点
;    #3: \hidariT
;    #4: \migiT
(defun YaTeX:LlineLR ()
  (insert (concat "{" (read-string "通過点1: ") "}"
		  "{" (read-string "通過点2: ") "}"
		  (read-string "左端点を受け取る制御綴り: ")
		  (read-string "右端点を受け取る制御綴り: "))))
;\llineLR#1#2#3#4
;    #1: 通過点
;    #2: 方向ベクトル
;    #3: \hidariT
;    #4: \migiT
(defun YaTeX:llineLR ()
  (insert (concat "{" (read-string "通過点: ") "}"
		  "{" (read-string "方向ベクトル: ") "}"
		  (read-string "左端点を受け取る制御綴り: ")
		  (read-string "右端点を受け取る制御綴り: "))))
;\glineLR#1#2#3#4
;    #1: 通過点
;    #2: 傾き
;    #3: \hidariT
;    #4: \migiT
(defun YaTeX:glineLR ()
  (insert (concat "{" (read-string "通過点: ") "}"
		  "{" (read-string "傾き: ") "}"
		  (read-string "左端点を受け取る制御綴り: ")
		  (read-string "右端点を受け取る制御綴り: "))))
;\klineLR#1#2#3#4
;    #1: 通過点
;    #2: 方向角
;    #3: \hidariT
;    #4: \migiT
(defun YaTeX:klineLR ()
  (insert (concat "{" (read-string "通過点: ") "}"
		  "{" (read-string "方向角: ") "}"
		  (read-string "左端点を受け取る制御綴り: ")
		  (read-string "右端点を受け取る制御綴り: "))))
;\nlineLR#1#2#3#4
;    #1: 通過点
;    #2: 法線ベクトル
;    #3: \hidariT
;    #4: \migiT
(defun YaTeX:nlineLR ()
  (insert (concat "{" (read-string "通過点: ") "}"
		  "{" (read-string "法線ベクトル: ") "}"
		  (read-string "左端点を受け取る制御綴り: ")
		  (read-string "右端点を受け取る制御綴り: "))))
;\nglineLR#1#2#3#4
;    #1: 通過点
;    #2: 法線ベクトル
;    #3: \hidariT
;    #4: \migiT
(defun YaTeX:nglineLR ()
  (insert (concat "{" (read-string "通過点: ") "}"
		  "{" (read-string "法線の傾き: ") "}"
		  (read-string "左端点を受け取る制御綴り: ")
		  (read-string "右端点を受け取る制御綴り: "))))
;\kaitenkigou<#1>[#2]
;    #1: 倍率 または key=val 形式で，有効なキーは
;     linethickness:楕円の太さ
;     yazirusi:矢印の向きを指定するキーで，右辺値は
;        　　r: 負の回転を表す向き
;        　　a: 正の回転を表す向き（デフォルト）
;        　　b: 両向き
;        のいずれかです。muki も yazirusi と同義のキーです。
;     bairitu:楕円の拡大率
;     hazimekaku:楕円弧始点の離心角（デフォルト値は 15）
;     owarikaku:楕円弧終点の離心角（デフォルト値は 345）
;     tyouhankei:楕円の長半径（回転軸に垂直な方向の半径），デフォルト値は 3mm
;     tanhankei:楕円の短半径（回転軸方向の半径），デフォルト値は 1.5mm
;    #2: 軸の方向角（デフォルト値：0）
(defun YaTeX:kaitenkigou ()
  (let* ((option (emath-setoption "" "linethickness" "楕円の太さ"))
	 (emnum (emath-get-number-from-list "[option] 矢印の向き"
						  `("正の回転方向(defalut)" "負の回転方向" "両方向")))
	 (yazirusi (cond ((= emnum 2) "yazirusi=r")
			 ((= emnum 3) "yazirusi=b")
			 (t "")))
	 (option (emath-setoption option "bairitu" "倍率(1)"))
	 (option (emath-setoption option "hazimekaku" "開始角(15)"))
	 (option (emath-setoption option "owarikaku" "終了角(345)"))
	 (option (emath-setoption option "tyouhankei" "長半径(3mm)"))
	 (option (emath-setoption option "tanhankei" "短半径(1.5mm)"))
	 (arg (read-string "回転の軸を表す直線の方向角(0): ")))
    (concat (if (string= option "") ""
	      (concat "<" option ">"))
	    (if (string= arg "") ""
	      (concat "[" arg "]")))))
(defun YaTeX:Toukokigou ()
  (let* ((num (read-string "記号の個数(1): ")))
    (concat (if (string= num "") ""
	      (concat "<" num ">"))
	    "{" (read-string "円弧の中心: ") "}{"
	    (read-string "弧の端点1: ") "}{"
	    (read-string "弧の端点2: ") "}%")))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; \toukakukigou[#1]<#2>{#3}<#4><$5>%                                     ;;;
;;; %#1:a=矢印 r=逆向き |=棒(default)                                      ;;;
;;; %#2:弧の個数(default:1)                                                ;;;
;;; %#3:角の点列                                                           ;;;
;;; %#4:hankei=半径(無名数)                                                ;;;
;;; %  :Hankei=半径(単位付)                                                ;;;
;;; %  :siteiten=弧が通る点の指定                                          ;;;
;;; %  :kokukigou=角内に配置する記号                                       ;;;
;;; %  :Kakukigoubounagasa=等弧記号の棒の長さ                              ;;;
;;; %#5:円弧の中心と角の頂点位置(0)                                        ;;;
;;;  \define@key{emP}{kakukigou}{\def\toukaku@kigou{##1}}%                 ;;;
;;;  \define@key{emP}{toukakukigou}{\def\toukaku@kigou{##1}}%              ;;;
;;;  \define@key{emP}{hankei}{\def\u@pt{##1}}%                             ;;;
;;;  \define@key{emP}{Hankei}{\ukansan{##1}\u@pt}%                         ;;;
;;;  \define@key{emP}{siteiten}{\Kyori{##1}{#4}\u@pt}%                     ;;;
;;;  \define@key{emP}{Kakukigoukankaku}{\ukansan{##1}\Kakukigou@kankaku}%  ;;;
;;;  \define@key{emP}{bezier}{\def\kakuki@bz{##1}}%                        ;;;
;;;  \define@key{emP}{Kakukigoubounagasa}{\def\Kakukigou@bounagasa{##1}}%  ;;;
;;;  \define@key{emP}{moziiti}{\def\mozi@iti{##1}}%                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;\Kakukigou[#1]<#2>#3#4#5<#6><#7>
;    #1: 円弧修飾
;      #1=a : 円弧に矢印（正の回転）
;      #1=r : 円弧に矢印（負の回転）
;      #1=b : 円弧に矢印（両向き）
;      #1=| : 円弧中央に，円弧と垂直な短い線分を配置
;        　　　注：| は，アルファベット小文字のエル(l)ではなく，縦棒(|)です。
;    #2: 円弧の個数
;    #3#4#5 : 角#5#4#3 （#4 が角の頂点）
;    #6: key=val をコンマ区切りで並べる
;         bezier:円弧ではなく放物線を描画
;         Hankei:円弧の半径
;         hasen:円弧を破線で描画
;               dash,hasenLG共に使用可
;         Kakukigoubounagasa:円弧に付与される棒の長さ
;         Kakukigoukankaku:複数円弧の間隔
;         linethickness:円弧の太さ変更
;         moziiti:文字列配置基準点と頂点の距離
;        *kakukigou:\toukakukigouコマンドのみ
;    #7: obsolete
;    以下，
;    　　　円弧の中点(\KakukigouP)を，文字列配置基準点として
;    \emathPut に引き渡されます。
(defun emath-kakukigou-common (str)
  (let* ((emnum 0)
	 (op1num (emath-get-number-from-list "[option] 円弧修飾" 
						   `("矢印[正方向]" "矢印[負方向]" "矢印[両端]" "円弧中央に縦棒" "設定しない")))
	 (op1 (cond ((= op1num 1) "[a]")
			   ((= op1num 2) "[r]")
			   ((= op1num 3) "[b]")
			   ((= op1num 4) "[|]")
			   (t "")))
	 (enkonum (if (y-or-n-p "円弧の個数を変更しますか(1)？: ")
		      (string-to-number (read-string "円弧の個数の指定[0-3]: ")) 1))
	 (op2 (if (not (= enkonum 1))
		       (concat "<" (number-to-string enkonum) ">") ""))
	 (option "")
	 (dash "")
	 (bezier "")
	 (bounagasa "")
	 (kankaku "")
	 (kakukigou ""))
    (progn (insert (concat op1 op2
			   (if (string= str "loop")
			       (concat "{" (emath-tenretu-loop ";" "角を表す点列") "}")
			     (read-string "角を表す点列: "))))
	   (setq option (emath-setoption "" "linethickness" "弧の太さ")
		 dash (emath-set-dash)
		 emnum (emath-get-number-from-list "[option] 円弧の描画法" `("円(default)" "bezier"))
		 bezier (if (= emnum 2) (emath-setoption "" "bezier" "頂点から円弧中央に対する比の設定: ") "")
		 option (emath-setoption option "Hankei" "円弧の半径指定")
		 bounagasa (if (= op1num 4) (emath-setoption "" "Kakukigoubounagasa" "縦棒の長さ指定") "")
		 kankaku (if (> enkonum 1)
			     (emath-setoption "" "Kakukigoukankaku" "円弧の間隔指定") "")
		 option (emath-setoption option "moziiti" "文字列配置位置の設定(10pt)")
		 kakukigou (if (string= str "loop")
			       (emath-setoption "" "kakukigou" "各内に配置する記号の設定") "")
		 option (emath-option-combine "," `(,option ,dash ,bezier ,bounagasa ,kankaku ,kakukigou)))
	   (insert (if (> (length option) 0)
		       (concat "<" option ">") "")))))
(defun YaTeX:Kakukigou ()
  (progn (concat (emath-kakukigou-common "")
		 (emath-Put-HouiShitei)
		 "{" (read-string "配置文字列: ") "}%\\KakukigouP=円弧の中点")))
(defun YaTeX:toukakukigou ()
  (emath-kakukigou-common "loop"))
;\toukakukigou[#1]<#2>#3<#4>
;    #1: 円弧修飾
;        |: 円弧の中央に，円弧と垂直に交わる短い棒（デフォルト）
;        a: 矢印（正の向き）
;        r:　 　（負の向き）
;        b: 　　（両向き）
;    #2: 円弧の個数 (#2=0,1(default),2,3)
;    #3: 角を ; を区切りとして列記
;    #4: key=val
;         kakukigou:角内に配置する記号
;         その他:\Kakukigou の [#6] 参照
(fset 'YaTeX:Kakukigou* 'YaTeX:Kakukigou)
(defun YaTeX:EnT ()
  (concat (read-string "直径の端点1: ")
	  (read-string "直径の端点2: ")))
;\ippankaku<#1>#2
;    #1: key=val
;         linethickness:螺線の太さを指定します。
;         iro:螺線の色を指定します。
;         hazimekaku:始め角を指定します。
;         rasenA:螺線の極方程式 r=aθ+b における a に対する倍率を指定します。
;         rasenAval:螺線の極方程式 r=aθ+b における a の値を指定します。
;                   右辺値は単位を伴う寸法です（無名数の場合，単位は \unitlength として扱われます）。
;         rasenB:螺線の極方程式 r=aθ+b における b に対する倍率を指定します。
;         rasenBval:螺線の極方程式 r=aθ+b における b の値を指定します。
;                   右辺値は単位を伴う寸法です（無名数の場合，単位は \unitlength として扱われます）。
;         yazirusi:螺線の先端に付加する矢印を指定します。
;                 a: 終端（デフォルト）
;                 r: 始端
;                 b: 両端
;                 n: なし
;    #2: 一般角（度数法）
(defun YaTeX:ippankaku ()
  (let* ((option (emath-setoption "" "hazimekaku" "始め角の指定"))
	 (option (emath-setoption option "linethickness" "螺旋の太さ"))
	 (option (emath-setoption option "color" "螺旋の色"))
	 (emnum (emath-get-number-from-list "[option] r=aθ+bの係数aの設定"
						  `("aに対する倍率を指定" "aの値を指定" "指定しない(.02)")))
	 (rasenA (cond ((= emnum 1) (concat "rasenA=" (read-string "[option] aに対する倍率: ")))
		       ((= emnum 2) (concat "rasenAval=" (read-string "[option] aの値: ")))
		       (t "")))
	 (emnum (emath-get-number-from-list "[option] r=aθ+bの係数bの設定"
						  `("bに対する倍率を指定" "bの値を指定" "指定しない(.2)")))
	 (rasenB (cond ((= emnum 1) (concat "rasenB=" (read-string "[option] bに対する倍率: ")))
		       ((= emnum 2) (concat "rasenBval=" (read-string "[option] bの値: ")))
		       (t "")))
	 (emnum (emath-get-number-from-list "[option] 矢印の設定"
						  `("終点のみ(default)" "始点のみ" "両端" "なし")))
	 (yazirusi (cond ((= emnum 2) "yazirusi=r")
			 ((= emnum 3) "yazirusi=b")
			 ((= emnum 4) "yazirusi=n")
			 (t "")))
	 (option (emath-option-combine "," `(,option ,rasenA ,rasenB ,yazirusi))))
    (insert (concat (if (> (length option) 0)
			(concat "<" option ">") "")
		    "{" (read-string "一般角指定: ") "}%"))))
;\Tyokkakukigou<#1>#2#3#4
;∠#2#3#4 に直角を表す記号を配置します。
;    #1: key=val
;         kakukikaiten:直角を表す記号の配置場所を変更します。
;         linethickness:線の太さを指定します。
;         size:直角を表す記号の大きさを指定します。（デフォルトは 5pt）
;    #2, #3, #4: 角
(defun emath-tyokkakukigou-option ()
  (let* ((option (emath-setoption "" "size" "記号のサイズの指定(5pt)"))
	 (option (emath-setoption option "linethickness" "線の太さの指定"))
	 (emnum (emath-get-number-from-list "[option] 記号の回転" 
						  `("回転させない" "90度回転" "180度回転" "-90度回転")))
	 (kaiten (if (and (> emnum 1) (> 4 emnum))
		     (concat "kaiten=" (number-to-string (* 90 (- emnum 1)))) ""))
	 (option (emath-option-combine "," `(,option ,kaiten))))
    (concat option)))
(defun YaTeX:Tyokkakukigou ()
  (let* ((option (emath-tyokkakukigou-option)))
    (insert (concat (if (> (length option) 0)
			(concat "<" option ">") "")
		    (read-string "直角を作る点列[3点]: ")))))
(defun YaTeX:tyokkakukigou ()
  (let* ((option (emath-tyokkakukigou-option)))
    (insert (concat (if (> (length option) 0)
			(concat "<" option ">") "")
		    "{" (emath-tenretu-loop ";" "直角を作る点列[3点]") "}%"))))
(fset `YaTeX:perpmark `YaTeX:Tyokkakukigou)
(defun YaTeX:heikoukigou ()
  (let* ((option (emath-setoption "" "heikoukigoukosuu" "記号の個数(1)"))
	 (option (emath-setoption option "heikoukigouiti" "記号の位置(.5)"))
	 (option (emath-setoption option "heikoukigoukankaku" "記号の間隔(1mm)"))
	 (option (emath-setoption option "heikoukigousize" "記号の大きさ(2)")))
    (concat (if (string= option "") ""
	      (concat "[" option "]"))
	    "{" (emath-tenretu-loop ";" "記号を置く線分の2端点") "}%")))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;%   \touhenkigou[#1]<#2><#3>(#4)#5                              ;;;
;;;;;;%     #1 : 記号（デフォルトは | ）                              ;;;
;;;;;;%     #2 : 個数                                                 ;;;
;;;;;;%     #3 : #2で複数を指定した場合の記号間間隔（デフォルト0.5pt）;;;
;;;;;;%     #4 : 位置（デフォルトは0.5，すなわち中点）                ;;;
;;;;;;%     #5 : 線分列（区切子は`;'）                                ;;;
;;;;;;%   \Touhenkigou[#1]<#2><#3>(#4)#5#6                            ;;;
;;;;;;%     #1 : 記号（デフォルトは | ）                              ;;;
;;;;;;%     #2 : 個数                                                 ;;;
;;;;;;%     #3 : #2で複数を指定した場合の記号間間隔（デフォルト0.5pt）;;;
;;;;;;%     #4 : 位置（デフォルトは0.5，すなわち中点）                ;;;
;;;;;;%          or key=val                                           ;;;
;;;;;;%             ex. haitiT=...                                    ;;;
;;;;;;%     #5, #6 : 線分の両端                                       ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;(defun emath-touhenkigou-option ()
;;;  (let* ((emsymbol (read-string "[option] 記号の設定(|): "))
;;;	 (emnum (read-string "[option] 記号の個数(1): "))
;;;	 (emspace (concat (if (string= emnum "") ""
;;;			    (read-string "[option] 記号の間隔(.5pt): "))))
;;;	 (emposition (read-string "[option] 記号の位置(.5): ")))
;;;    (concat (if (string= emsymbol "") ""
;;;	      (concat "[" emsymbol "]"))
;;;	    (if (string= emnum "") ""
;;;	      (concat "<" emnum ">"))
;;;	    (if (string= emspace "") ""
;;;	      (concat "<" emspace ">"))
;;;	    (if (string= emposition "") ""
;;;	      (concat "(" emposition ")")))))
;;;(defun YaTeX:touhenkigou ()
;;;  (concat (emath-touhenkigou-option)
;;;	  "{" (emath-tenretu-loop ";" "線分の2端点") "}"))
;;;(defun YaTeX:Touhenkigou ()
;;;  (concat (emath-touhenkigou-option)
;;;	  (read-string "線分の端点1: ")
;;;	  (read-string "線分の端点2: ")))
(defun YaTeX:showEx ()
  (concat (if (y-or-n-p "[option] 表示幅を変更しますか?")
	      (YaTeX:read-coordinates "(ソース部,結果部) \\linewidthの何倍かを指定(default .45)")
	    ())
	  "{" (read-string "表題: ") "}"))
(defun YaTeX:rotObrace ()
  (concat (if (y-or-n-p "[option] 線分と\\overbraceの距離を調整しますか?")
	      (concat "[height=" (read-string "height(単位付き数値)=? ") "]") ())
	  "{" (read-string "始点: ") "}"
	  "{" (read-string "終点: ") "}"
	  "{" (read-string "文字列: ") "}%"))
(defun YaTeX:rotUbrace ()
  (concat (if (y-or-n-p "線分と\\underbraceの距離を調整しますか?")
	      (concat "[depth=" (read-string "depth(単位付き数値)=? ") "]") ())
	  "{" (read-string "始点: ") "}"
	  "{" (read-string "終点: ") "}"
	  "{" (read-string "文字列: ") "}%"))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; emath-tenretu-input-elements ()                                 ;;;
;;; \tenretu などの [label]Name(x.y)[pos].. を繰り返し入力させる          ;;;
;;;   emath-tenretu-input-elements "" "x" "y"              ;;;
;;;     \tenretuの ``[label]point_name(coord)`adjustment''' の            ;;;
;;;     coord を ``座標の設定 (x,y): ''と表示して YaTeX:read-coordinates  ;;;
;;;     を利用して入力させる                                              ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; ast-or-not=t でラベルと包囲指定をしない\tenretu*用
;;; coord=t で座標の入力をしない\tenretu**用
(defun emath-tenretu-input-elements (var1 var2 &optional ast-or-not coord seq)
  (let* ((emlabel (concat (if ast-or-not ""
			    (read-string "[option] ラベルの設定: "))))
	 (emname (read-string "点の名前の設定: "))
	 (emcoord (if (not coord) (YaTeX:read-coordinates (format "座標の設定 (%s,%s): " var1 var2)) ""))
	 (empos (concat (if ast-or-not ""
			  (emath-Put-HouiShitei)))))
    (let* ((option (concat (if (string= emlabel "") ""
			     (concat "[" emlabel "]"))
			   emname emcoord empos))
	   (emseq (if seq seq ""))
	   (option (emath-option-combine ";" `(,emseq ,option))))
      (if (y-or-n-p "続けますか？")
	  (emath-tenretu-input-elements var1 var2 ast-or-not coord option)
	(concat "{" option "}")))))
(defun emath-tenretu-option ()
  (let* ((op1 (if (y-or-n-p "[option] Perlと連携しますか？: ")
		  "perl" ""))
	 (kuromaru (if (y-or-n-p "[option] 設定した点に黒丸を配置しますか？: ")
		       "kuromaru" ""))
	 (emnum (emath-get-number-from-list "[option] 点の結び方の設定"
						 `("折線" "多角形" "塗り潰し" "斜線" "設定しない")))
	 (dousa (cond ((= emnum 1) (concat "dousa={D<" (emath-drawline-option) ">}"))
		      ((= emnum 2) (concat "dousa={T<" (emath-drawline-option) ">}"))
		      ((= emnum 3) (concat "dousa={P<" (emath-emPaint-option "") ">}"))
		      ((= emnum 4) (concat "dousa={P*<" (emath-emPaint*-slashonly-option) ">}"))
		      (t "")))
	 (op1 (emath-setoption op1 "oresen" "点列を保存する制御綴り名"))
	 (op1 (emath-option-combine "," `(,op1 ,kuromaru ,dousa)))
	 (op1 (if (> (length op1) 0) (concat "<" op1 ">") ""))
	 (op2 (read-string "極の指定(\\O): "))
	 (op2 (if (> (length op2) 0) (concat "[" op2 "]") "")))
    (list op1 op2)))
(defun YaTeX:tenretu ()
  (let* ((option (emath-tenretu-option))
	 (op1 (car option))
	 (op2 (car (cdr option))))
    (insert (concat op1 op2
		    (emath-tenretu-input-elements "x" "y")))))
(defun YaTeX:tenretu* ()
  (let* ((option (emath-tenretu-option))
	 (op1 (car option))
	 (op2 (car (cdr option))))
    (insert (concat op1 op2
		    (emath-tenretu-input-elements "x" "y" t)))))
(defun YaTeX:tenretu** ()
  (let* ((option (if (y-or-n-p "各点に黒丸を設定しますか？: ")
		       "kuromaru" ""))
	 (showlabel (if (y-or-n-p "名札を非表示にしますか？: ")
			"showlabel=0" ""))
	 (option (emath-option-combine "," `(,option ,showlabel))))
    (insert (concat (if (> (length option) 0)
			(concat "<" option ">") "")
		    (emath-tenretu-input-elements "x" "y" nil t)))))
(defun YaTeX:rtenretu ()
  (let* ((option (emath-tenretu-option))
	 (op1 (car option))
	 (op2 (car (cdr option))))
    (insert (concat op1 op2
		    (emath-tenretu-input-elements "r" "θ")))))
(defun YaTeX:rtenretu* ()
  (let* ((option (emath-tenretu-option))
	 (op1 (car option))
	 (op2 (car (cdr option))))
    (insert (concat op1 op2
		    (emath-tenretu-input-elements "r" "θ" t)))))
;;;\Ytenretu<#1>#2#3
;;;　　#1 は key=val 形式で，\tenretu に引き継がれます。
;;;　　#2 は関数 f(x)
;;;　　#3 は点列を `;' で区切った列
;;;　　点列は
;;;　　　　[##1]##2(##3)[##4]
;;;　　の形式で点列を `;' で区切る。（[##4]は，##4 と略記可）
;;;
;;;    ##1: オプションで，点の位置に置く文字列
;;;    　　　（省略時は，##2 と同じ）
;;;    ##2: \##2 という変数の頂点名（空文字列も許容します）
;;;    (##3): 点のx座標（perl の計算式を許容します）
;;;    [##4]: emathPut へ引き継ぐオプション
;;;    #1: key=val で，有効なキーは：
;;;
;;;kuromaru
;;;    定義した点に黒丸を描画します。
;;;siromaru
;;;    定義した点に白丸を描画します。
(defun emath-Ytenretu-loop ()
  (let ((name "")
	(item "")
	(allitem "")
	(syaei ""))
    (progn (while (progn (setq item (read-string "定義する点の名前[Enterで終了]: "))
			 (if (> (length item) 0)
			     (setq name (read-string "[option] ラベルの指定[Enterで指定なし]: ")
				   item (concat (if (> (length name) 0)
						    (concat "[" name "]"))
						item "(" (read-string "点のx座標[Perl形式可]: ") ")")
				   syaei (emathPut-syaei-option)
				   item (concat item (if (> (length syaei) 0)
							 (concat "[" syaei "]")))
				   allitem (emath-option-combine ";" `(,allitem ,item))
				   item ""
				   name "") nil)))
	   (concat allitem))))
(defun YaTeX:Ytenretu ()
  (let* ((emnum (emath-get-number-from-list "[option] (黒|白)丸の描画指定" `("黒丸を描画" "白丸を描画" "描画しない")))
	 (option (cond ((= emnum 1) "kuromaru")
		       ((= emnum 2) "siromaru")
		       (t ""))))
    (insert (concat (if (> (length option) 0)
			(concat "<" option ">") "")
		    "{" (read-string "関数f(x): ") "}"
		    "{" (emath-Ytenretu-loop) "}"))))
(defun YaTeX:Ptenretu ()
  (let* ((emnum (emath-get-number-from-list "[option] (黒|白)丸の描画指定" `("黒丸を描画" "白丸を描画" "描画しない")))
	 (option (cond ((= emnum 1) "kuromaru")
		       ((= emnum 2) "siromaru")
		       (t ""))))
    (insert (concat (if (> (length option) 0)
			(concat "<" option ">") "")
		    "{" (read-string "関数x(t): ") "}"
		    "{" (read-string "関数y(t): ") "}"
		    "{" (emath-Ytenretu-loop) "}"))))
;\emRbezier<#1>#2#3#4
;    #1: key=val
;     frame:制御点を結ぶ折れ線を表示します。
;    #2: 制御点0(P0)
;    #3: 制御点3(P3)
;    #4: 制御点1,2 を定める成分列
;        #4 は (r1,t1);(r2,t2) の形式で
;    　　P0 を原点とし，極座標が (r1,t1) の点を制御点1(P1)
;    　　P3 を原点とし，極座標が (r2,t2) の点を制御点2(P2)
;    として得られる点列 P0, P1, P2, P3 を制御点とする3次のベジェ曲線を描画します。
;    角 t1, t2 は度数法です。
; t-or-not=t で#1と#4のみ入力させる
(defun emath-emRbezier-body (&optional t-or-not)
  (let* ((option (if (y-or-n-p "制御点を結ぶ折線を表示しますか？: ")
		     "<frame>" "")))
    (concat (if (> (length option) 0) option "")
		    (if t-or-not (concat "{" (read-string "点1: ") "}"
			      "{" (read-string "点2: ") "}") "")
		    "{" (YaTeX:read-coordinates "[制御点1の指定] (r,θ) r:点1からの距離[無名数] θ:60分法: ") ";"
		    (YaTeX:read-coordinates "[制御点2の指定] (r,θ) r:点2からの距離[無名数] θ:60分法: ") "}")))
(defun YaTeX:emRbezier ()
  (let* ((option (emath-emRbezier-body t)))
    (insert option)))
;\PutStr#1#2to[#3]#4
; 点#1 に文字列#2 を配置し，そこから点#4 に矢印をひきます。
; #1 と #2 の間に \emathPut の配置オプションを置くことが出来ます。
;    #1 : 文字列を配置する点
;    #2 : 文字列（emathPut の配置オプションを前置することができます）。
;    #3 : *文字列から出る矢印を円弧にしたいときはその半径を指定する。
;         または，key=val 形式で，有効なキーは
;     Hankei:円弧の半径を指定します。
;     enkoH:円弧と弦の距離を指定します。
;     arrowsize:矢印のサイズを指定します(pszahyou環境)。
;     linethickness:線の太さを指定します。
;     bezier:矢線を bezier曲線で描画します。(pszahyou環境)。
;     addvec:終点の修正ベクトル（成分は単位付の数値--r(dx,dy)のときは，極座標形式）
;     *arrowheadsize:矢印のサイズを指定します(zahyou環境)。
;    #4 : 矢線の終点
(defun emath-addvec-common ()
  (let* ((emnum (emath-get-number-from-list "[option] 方向と長さの指定" `("直交座標" "極座標")))
	 (option (cond ((= emnum 1)(YaTeX:read-coordinates "[option] (x,y): " "x" "y"))
		       ((= emnum 2)(concat "r" (YaTeX:read-coordinates "[option] (r,θ): " "r" "θ"))))))
    (concat option)))
(defun emath-PutStr-option ()
  (let* ((emnum (emath-get-number-from-list "[option] 弧のサイズ指定"
						  `("円弧の半径" "円弧と弦の距離" "ベジェ曲線" "指定しない")))
	 (hankei (cond ((= emnum 1)(concat "Hankei=" (read-string "半径[無名数]: ")))
		       ((= emnum 2)(concat "emkoH=" (read-string "円弧と弦の距離[要単位]: ")))
		       ((= emnum 3)(concat "bezier={" (emath-emRbezier-body) "}"))
		       (t "")))
	 (addvec (if (y-or-n-p "終点の位置を修正しますか？: ")
		     (concat "addvec={" (emath-addvec-common) "}") ""))
	 (arrowsize (if (y-or-n-p "矢印の大きさを指定しますか？: ")
			(concat "arrowsize={" (emath-setarrow ) "}") ""))
	 (linethickness (emath-setoption "" "linethickness" "線の太さ"))
	 (option (emath-option-combine "," `(,hankei ,addvec ,arrowsize ,linethickness))))
    (concat option)))
(defun YaTeX:PutStr ()
  (let* ((option ""))
    (progn (insert (concat "{" (read-string "文字列を配置する点: ") "}"
			   (emath-Put-HouiShitei)
			   "{" (read-string "配置する文字列: ") "}to"))
	   (setq option (emath-PutStr-option))
	   (insert (concat (if (> (length option) 0)
			       (concat "[" option "]") "")
			   "{" (read-string "矢線の終点: ") "}")))))
(defun YaTeX:PutStr* ()
  (let* ((option ""))
    (progn (insert (concat "{" (YaTeX:read-coordinates "終点からの変位ベクトルの指定 (x,y): " "x" "y") "}"
			   (emath-Put-HouiShitei)
			   "{" (read-string "配置する文字列: ") "}to"))
	   (setq option (emath-PutStr-option))
	   (insert (concat (if (> (length option) 0)
			       (concat "[" option "]") "")
			   "{" (read-string "矢線の終点: ") "}")))))
(defun YaTeX:PutStr ()
  (let* ((empos (emath-Put-HouiShitei))
	 (option (emath-setoption "" "enkoH" "線分の中点と弧の中点との距離(要単位)"))
	 (option (emath-setoption option "Hankei" "弧の半径"))
	 (option (emath-setoption option "arrowheadsize" "鏃の倍率"))
	 (option (emath-setoption option "addvec" "矢印の先端の微調整 (x,y) or r(r,θ)" "{" "}")))
    (concat (read-string "矢線の始点: ")
	    empos
	    "{" (read-string "始点に配置する文字列: ") "}to"
	    (if (string= option "") ""
	      (concat "[" option "]"))
	    (read-string "矢線の終点"))))
(defun YaTeX:PutStr* ()
  (let* ((empos (emath-Put-HouiShitei))
	 (option (emath-setoption "" "enkoH" "線分の中点と弧の中点との距離(要単位)"))
	 (option (emath-setoption option "hankei" "弧の半径(無名数)"))
	 (option (emath-setoption option "Hankei" "弧の半径(要単位)"))
	 (option (emath-setoption option "arrowheadsize" "鏃の倍率"))
	 (option (emath-setoption option "addvec" "矢印の先端の微調整 (x,y) or r(r,θ)" "{" "}")))
    (concat (YaTeX:read-coordinates "終点からみた始点の変移ベクトル(要単位) (x,y): ")
	    empos
	    "{" (read-string "始点に配置する文字列: ") "}to"
	    (if (string= option "") ""
	      (concat "[" option "]"))
	    (read-string "矢線の終点"))))
(defun YaTeX:kousi ()
  (let* ((emcoord (if (y-or-n-p "格子のサイズを変更しますか？")
		   (YaTeX:read-coordinates "[option] (dx,dy): ") "")))
    (concat emcoord
	    "{" (read-string "x軸方向のブロック数: ") "}{"
	    (read-string "y軸方向のブロック数: ") "}%")))
;\Bunten<#1>#2#3#4#5#6
;    #1: key=val
;    #2: 端点1
;    #3: 端点2
;    #4,#5: 内分比（外分比は符号を付加）
;    一方が * の場合は，#4 + #5 = 1 となるように * がセットされる。
;    #6: 分点を受け取る制御綴
(defun YaTeX:Bunten ()
  (insert (concat (if (y-or-n-p "Perlと連携しますか？: ")
		      "<perl>" "")
		  "{" (read-string "端点1: ") "}"
		  "{" (read-string "端点2: ") "}"
		  "{" (read-string "比1: ") "}"
		  "{" (read-string "比2: ") "}"
		  (read-string "分点を受け取る制御綴り: "))))
;\Tyuuten<#1>#2#3#4
;    線分#2#3 の中点を #4 の制御綴に返します。
;    #1: key=val
;         perl:計算を perl で行います。当然，emathPp.sty が必要です。
;    #2: 端点1
;    #3: 端点2
;    #4: 結果を受け取る制御綴
(defun YaTeX:Tyuuten ()
  (insert (concat (if (y-or-n-p "Perlと連携しますか？: ")
		      "<perl>" "")
		  "{" (read-string "端点1: ") "}"
		  "{" (read-string "端点2: ") "}"
		  "中点を受け取る制御綴り: ")))
(defun emath-Takakkei-common ()
  (let* ((option (emath-Drawline-option))
	 (option (emath-setoption option "boutyou" "多角形の拡大縮小[要単位]"))
	 (paintcolor (if (y-or-n-p "多角形を塗りつぶしますか？: ")
			 (read-string "塗り潰す色の指定: ") ""))
	 (noudo (if (> (length paintcolor) 0)
		    (read-string "濃度の指定: ") ""))
	 (paintcolor (if (> (length paintcolor) 0)
			 (concat "paintcolor={"
				 (if (> (length noudo) 0)
				     (concat "<" noudo ">") "")
				 paintcolor "}") ""))
	 (setxyrange (if (y-or-n-p "多角形を内包する長方形の大きさを書き出しますか？: ")
			 "setxyrange" ""))
	 (option (emath-option-combine "," `(,option ,paintcolor ,setxyrange))))
    (concat option)))
(defun YaTeX:Takakkei ()
  (let* ((option (emath-Takakkei-common)))
    (insert (concat (if (> (length option) 0)
			(concat "<" option ">") "")
		    "{" (read-string "多角形を作る点列: ") "}%"))))
(defun YaTeX:Takakkeis ()
  (let* ((option (emath-Takakkei-common)))
    (insert (concat (if (> (length option) 0)
			(concat "<" option ">") "")
		    "{" (emath-tenretu-loop ";" "多角形を作る点列: ") "}%"))))
(defun YaTeX:ovalTakakkei ()
  (let* ((option (emath-drawline-option)))
    (concat (if (string= option "") ""
	      (concat "<" option ">"))
	    "{" (read-string "角の円弧の半径(要単位): ")
	    "}{" (read-string "多角形を作る点列: ") "}%")))
(defun YaTeX:kyokuTyoku ()
  (concat (YaTeX:read-coordinates "(r,θ) r:単位付き数値 θ:60分法")
	  (read-string "変換した座標を受け取る制御綴り: ")
	  "%"))
;;;;;(defun emath-zahyou-body (&optional ps-or-not)
;;;;;  (concat (YaTeX:read-coordinates "(xmin,xmax): ")
;;;;;	  (YaTeX:read-coordinates "(ymin,ymax): ")
;;;;;	  "%\n"
;;;;;	  (let* ((emfontsize (emath-get-number-from-list "文字の大きさ" `("\\small" "\\scriptsize" "自分で設定"))))
;;;;;	    (concat (cond ((= emfontsize 1) "\\small\n")
;;;;;			  ((= emfontsize 2) "\\scriptsize\n")
;;;;;			  ((= emfontsize 3)(concat (read-string "文字サイズの設定: ") "\n"))
;;;;;			  (()()))))
;;;;;	  (if ps-or-not "\\setlinewidth{" "\\allinethickness{")
;;;;;	  (read-string "線の太さ: ") "}%"
;;;;;	  "\n%%%\t!!! xscale,yscaleはemathPxy.sty必須 !!!\n%%%\t!!! ex,eyはemathPha.sty必須 !!!"))
;;;;;(defun emath-zahyou-option ()
;;;;;  (let* ((emsymbol (if (y-or-n-p "[option] 座標の記号を変更しますか？")
;;;;;		       (let* ((temp (emath-setoption "" "gentenkigou" "原点記号(O)"))
;;;;;			      (temp (emath-setoption temp "yokozikukigou" "横軸記号($x$)"))
;;;;;			      (temp (emath-setoption temp "tatezikukigou" "縦軸記号($y$)")))
;;;;;			 (concat temp)) ""))
;;;;;	 (empos (if (y-or-n-p "[option] 座標の配置を変更しますか？")
;;;;;		    (let* ((temp (emath-setoption "" "gentenhaiti" "原点の配置(se)" "{[" "]}"))
;;;;;			   (temp (emath-setoption temp "yokozikuhaiti" "横軸記号の配置" "{[" "]}"))
;;;;;			   (temp (emath-setoption temp "tatezikuhaiti" "縦軸記号の配置" "{[" "]}")))
;;;;;		      (concat temp)) ""))
;;;;;	 (emarrow (if (y-or-n-p "[option] 軸の形状を変えますか？")
;;;;;		      (let* ((temp (emath-setoption "" "arrowheadsize" "鏃の倍率(1)"))
;;;;;			     (temp (emath-setoption temp "zikusensyu" "軸の線種")))
;;;;;			(concat temp)) "")))
;;;;;    (concat (emath-option-combine "," `(,emsymbol ,empos ,emarrow)))))
;;;;;(defun emath-zahyou*-option ()
;;;;;  (let* ((emul (emath-setoption "" "ul" "1目盛りの単位長(要単位)"))
;;;;;	 (emmargin (if (y-or-n-p "[option] 余白の調整をしますか？")
;;;;;		       (let* ((temp (emath-setoption "" "Yohaku" "余白(要単位)"))
;;;;;			      (temp (emath-setoption temp "yohaku" "余白(無名数)"))
;;;;;			      (temp (emath-setoption temp "Migiyohaku" "右余白(要単位)"))
;;;;;			      (temp (emath-setoption temp "migiyohaku" "右余白(無名数)"))
;;;;;			      (temp (emath-setoption temp "Hidariyohaku" "左余白(要単位)"))
;;;;;			      (temp (emath-setoption temp "hidariyohaku" "左余白(無名数)"))
;;;;;			      (temp (emath-setoption temp "Ueyohaku" "上余白(要単位)"))
;;;;;			      (temp (emath-setoption temp "ueyohaku" "上余白(無名数)"))
;;;;;			      (temp (emath-setoption temp "Sitayohaku" "下余白(要単位)"))
;;;;;			      (temp (emath-setoption temp "sitayohaku" "下余白(無名数)")))
;;;;;			 (concat temp)) ""))
;;;;;	 (emscale (if (y-or-n-p "[option] 縦横比を変えますか？")
;;;;;		      (let* ((temp (emath-setoption "" "xscale" "横の比率(1)"))
;;;;;			     (temp (emath-setoption temp "yscale" "縦の比率(1)")))
;;;;;			(concat temp)) ""))
;;;;;	 (empos (if (y-or-n-p "[option] 環境自体の縦の配置を調整しますか？")
;;;;;		    (emath-select-key-value "haiti" "[option]" `(("上揃え" "t") ("下揃え" "b") ("中央揃え" "c") ("x軸揃え" "x")))
;;;;;		  ""))
;;;;;	 (emunit (if (y-or-n-p "[option] 斜交座標にしますか？")
;;;;;		     (let* ((temp (emath-setoption "" "ex" "x軸の単位ベクトル"))
;;;;;			    (temp (emath-setoption temp "ey" "y軸の単位ベクトル")))
;;;;;		       (concat temp)) "")))
;;;;;    (emath-option-combine "," `(,emul ,emmargin ,emscale ,empos ,emunit))))
;;;;;(defun emath-pszahyou-option ()
;;;;;  (let* ((emps (emath-setoption "" "borderwidth" "クリッピング対策で実描画部を広くするマージンの設定"))
;;;;;	 (emps (emath-setoption emps "EPSfilename" "独自のEPSファイル名の設定"))
;;;;;	 (emclip (if (y-or-n-p "[option] クリッピングを止めますか？")
;;;;;		     "EPSclip=false" "")))
;;;;;    (emath-option-combine "," `(,emps ,emclip))))
;;;;;(defun YaTeX:zahyou ()
;;;;;  (let* ((astop (emath-zahyou*-option))
;;;;;	 (zop (emath-zahyou-option))
;;;;;	 (option (emath-option-combine "," `(,astop ,zop))))
;;;;;    (concat (if (string= option "") ""
;;;;;	      (concat "[" option "]"))
;;;;;	    "%\n\t\t"
;;;;;	    (emath-zahyou-body))))
;;;;;(defun YaTeX:zahyou* ()
;;;;;  (let* ((option (emath-zahyou*-option)))
;;;;;    (concat (if (string= option "") ""
;;;;;	      (concat "[" option "]"))
;;;;;	    "%\n\t\t"
;;;;;	    (emath-zahyou-body)
;;;;;	    "\n%\\drawXaxis \\drawYaxis \\drawXYaxis で軸を描ける")))
;;;;;(defun YaTeX:pszahyou ()
;;;;;  (let* ((astop (emath-zahyou*-option))
;;;;;	 (zop (emath-zahyou-option))
;;;;;	 (psop (emath-pszahyou-option))
;;;;;	 (option (emath-option-combine "," `(,astop ,zop ,psop))))
;;;;;    (concat (if (string= option "") ""
;;;;;	      (concat "[" option "]"))
;;;;;	    "%\n\t\t"
;;;;;	    (emath-zahyou-body t)
;;;;;	    "\n%\t\\xmax=\\truexmax+borderwidthのようになっているので\\xmaxなどを使用するときは注意")))
;;;;;(defun YaTeX:pszahyou* ()
;;;;;  (let* ((astop (emath-zahyou*-option))
;;;;;	 (psop (emath-pszahyou-option))
;;;;;	 (option (emath-option-combine "," `(,astop ,psop))))
;;;;;    (concat (if (string= option "") ""
;;;;;	      (concat "[" option "]"))
;;;;;	    "%\n\t\t"
;;;;;	    (emath-zahyou-body t)
;;;;;	    "\n%\\drawXaxis \\drawYaxis \\drawXYaxis で軸を描ける")))
(defun emath-zahyou-axis-option ()
  (let* ((option (emath-setoption "" "zikusensyu" "縦・横軸の線種設定"))
	 (xscale (emath-setoption "" "xscale" "横軸方向の伸縮率[要emathPxy]"))
	 (yscale (emath-setoption "" "yscale" "縦軸方向の伸縮率[要emathPxy]"))
	 (advice (if (or (> (length xscale) 0) (> (length yscale) 0))
		     "xscale,yscaleオプションはemathPxyが必要" ""))
	 (kigou "")
	 (haiti ""))
    (progn (if (y-or-n-p "記号の設定をしますか？: ")
	       (setq kigou (emath-setoption "" "gentenkigou" "原点の記号(O)")
		     kigou (emath-setoption kigou "yokozikukigou" "横軸の記号($x$)")
		     kigou (emath-setoption kigou "tatezikukigou" "縦軸の記号($y$)")))
	   (if (y-or-n-p "記号の配置に関する設定をしますか？: ")
	       (setq haiti (emath-setoption "" "gentenhaiti" "原点の配置([sw])" "{" "}")
		     haiti (emath-setoption haiti "yokozikuhaiti" "横軸記号の配置((0,-3pt)[rt])" "{" "}")
		     haiti (emath-setoption haiti "tatezikuhaiti" "縦軸記号の配置((-3pt,0)[rt])" "{" "}")))
	   (setq option (emath-option-combine "," `(,option ,xscale ,yscale ,kigou ,haiti)))
	   (list option advice))))
(defun emath-zahyou-option (&optional axis)
  (let* ((emnum 0)
	 (option (emath-setoption "" "ul" "単位長の設定[1cm程度を推奨](1pt)"))
	 (axisop (if axis (emath-zahyou-axis-option) ""))
	 (advice (if axis (car (cdr axisop)) ""))
	 (axisop (if axis (car axisop) ""))
	 (option (if axis (emath-option-combine "," `(,option ,axisop)) option))
	 (yohaku "");yohaku,ueyohaku,sitayohaku,migiyohaku,hidariyohaku
	 (envhaiti ""))
    (progn (if (y-or-n-p "余白の設定をしますか？: ")
	       (setq emnum (emath-get-number-from-list "[option] 余白の設定"
							     `("一括設定" "上下左右の個別設定"))
		     yohaku (if (= emnum 1)
				(emath-setoption "" "yohaku" "上下左右の余白") "")
		     yohaku (if (= emnum 2)
				(emath-setoption "" "ueyohaku" "環境上部の余白") yohaku)
		     yohaku (if (= emnum 2)
				(emath-setoption yohaku "sitayohaku" "環境下部の余白") yohaku)
		     yohaku (if (= emnum 2)
				(emath-setoption yohaku "hidariyohaku" "環境左部の余白") yohaku)
		     yohaku (if (= emnum 2)
				(emath-setoption yohaku "migiyohaku" "環境右部の余白") yohaku)) "")
	   (setq emnum (emath-get-number-from-list "[option] 環境のベースラインの設定" `("下辺(default)" "上辺" "x軸"))
		 envhaiti (cond ((= emnum 2) "haiti=t")
				((= emnum 3) "haiti=x")
				(t ""))
		 option (emath-option-combine "," `(,option ,yohaku ,envhaiti)))
	   (list option advice))))
(defun emath-zahyou-common ()
  (concat (YaTeX:read-coordinates "横軸の範囲指定 (xmin,xmax): " "xmin" "xmax")
	  (YaTeX:read-coordinates "縦軸の範囲指定 (ymin,ymax): " "ymin" "ymax")))
(defun YaTeX:zahyou ()
  (let* ((option (emath-zahyou-option t))
	 (advice (car (cdr option)))
	 (option (car option))
	 (ex (emath-setoption "" "ex" "横軸の単位ベクトル(要emathPha)" "{" "}"))
	 (ey (emath-setoption "" "ey" "縦軸の単位ベクトル(要emathPha)" "{" "}"))
	 (advice (if (or (> (length ex) 0) (> (length ey) 0))
		     (concat advice (if (> (length advice) 0) " : " "") "ex,eyオプションはemathPhaが必要です")))
	 (option (emath-option-combine "," `(,option ,ex ,ey))))
    (concat "%\n\t" (if (> (length option) 0)
			(concat "[" option "]") "")
	    "%\n\t"
	    (emath-zahyou-common)
	    "%" advice)))
(defun YaTeX:zahyou* ()
  (let* ((option (emath-zahyou-option))
	 (option (car option)))
    (concat "%\n\t" (if (> (length option) 0)
			(concat "[" option "]") "")
	    "%\n\t"
	    (emath-zahyou-common)
	    "%")))
(defun YaTeX:pszahyou ()
  (let* ((option (emath-zahyou-option t))
	 (advice (car (cdr option)))
	 (option (car option))
	 (option (emath-setoption option "borderwidth" "クリッピング対策で実描画部を広くするマージンの設定"))
	 (range (if (y-or-n-p "getxyrangeを設定しますか？: ")
		    "getxyrange" ""))
	 (clip (if (y-or-n-p "クリッピングを止めますか？: ")
		   "EPSclip=false" ""))
	 (option (emath-setoption option "EPSfilename" "独自のEPSファイル名の設定"))
	 (option (emath-option-combine "," `(,option ,range ,clip)))
	 (emnum (emath-get-number-from-list "文字の大きさ" `("変更しない" "\\small" "\\scriptsize")))
	 (size (cond ((= emnum 2) "\\small\n\t")
		     ((= emnum 3) "\\scriptsize\n\t")
		     (t "")))
	 (line (concat "\\setlinewidth{" (read-string "線の太さ: ") "}%\n\t")))
    (concat "%\n\t" (if (> (length option) 0)
			(concat "[" option "]") "")
	    "%\n\t"
	    (emath-zahyou-common)
	    "%\n\t"
	    size line
	    "%\\xmax=\\truexmax+borderwidthのようになっているので\\xmaxなどを使用するときは注意"
	    (if (> (length advice) 0)
		(concat "\n%\t" advice)))))
(defun YaTeX:pszahyou* ()
  (let* ((option (emath-zahyou-option))
	 (option (car option))
	 (option (emath-setoption option "borderwidth" "クリッピング対策で実描画部を広くするマージンの設定"))
	 (range (if (y-or-n-p "getxyrangeを設定しますか？: ")
		    "getxyrange" ""))
	 (clip (if (y-or-n-p "クリッピングを止めますか？: ")
		   "EPSclip=false" ""))
	 (option (emath-setoption option "EPSfilename" "独自のEPSファイル名の設定"))
	 (option (emath-option-combine "," `(,option ,range ,clip)))
	 (emnum (emath-get-number-from-list "文字の大きさ" `("変更しない" "\\small" "\\scriptsize")))
	 (size (cond ((= emnum 2) "\\small\n\t")
		     ((= emnum 3) "\\scriptsize\n\t")
		     (t "")))
	 (line (concat "\\setlinewidth{" (read-string "線の太さ: ") "}%\n\t")))
    (concat "%\n\t" (if (> (length option) 0)
			(concat "[" option "]") "")
	    "%\n\t"
	    (emath-zahyou-common)
	    "%\n\t"
	    size line
	    "%\\xmax=\\truexmax+borderwidthのようになっているので\\xmaxなどを使用するときは注意")))
(defun YaTeX:psazahyou ()
  (let* ((option (emath-zahyou-option t))
	 (advice (car (cdr option)))
	 (option (car option))
	 (option (emath-setoption option "ex" "横軸の単位ベクトル" "{" "}"))
	 (option (emath-setoption option "ey" "縦軸の単位ベクトル" "{" "}"))
	 (option (emath-setoption option "borderwidth" "クリッピング対策で実描画部を広くするマージンの設定"))
	 (range (if (y-or-n-p "getxyrangeを設定しますか？: ")
		    "getxyrange" ""))
	 (clip (if (y-or-n-p "クリッピングを止めますか？: ")
		   "EPSclip=false" ""))
	 (option (emath-setoption option "EPSfilename" "独自のEPSファイル名の設定"))
	 (option (emath-option-combine "," `(,option ,range ,clip))))
    (concat "%\n\t" (if (> (length option) 0)
			(concat "[" option "]") "")
	    "%\n\t"
	    (emath-zahyou-common)
	    "%\n%\t要emathPsa.sty"
	    "%\n%\t\\xmax=\\truexmax+borderwidthのようになっているので\\xmaxなどを使用するときは注意"
	    (if (> (length advice) 0)
		(concat "%\n\t" advice)))))
(defun YaTeX:psazahyou ()
  (let* ((option (emath-zahyou-option))
	 (option (car option))
	 (option (emath-setoption option "ex" "横軸の単位ベクトル" "{" "}"))
	 (option (emath-setoption option "ey" "縦軸の単位ベクトル" "{" "}"))
	 (option (emath-setoption option "borderwidth" "クリッピング対策で実描画部を広くするマージンの設定"))
	 (range (if (y-or-n-p "getxyrangeを設定しますか？: ")
		    "getxyrange" ""))
	 (clip (if (y-or-n-p "クリッピングを止めますか？: ")
		   "EPSclip=false" ""))
	 (option (emath-setoption option "EPSfilename" "独自のEPSファイル名の設定"))
	 (option (emath-option-combine "," `(,option ,range ,clip))))
    (concat "%\n\t" (if (> (length option) 0)
			(concat "[" option "]") "")
	    "%\n\t"
	    (emath-zahyou-common)
	    "%\n%\t要emathPsa.sty"
	    "%\n%\t\\xmax=\\truexmax+borderwidthのようになっているので\\xmaxなどを使用するときは注意")))
(defun YaTeX:zahyouMemori ()
  (let* ((emnum (emath-get-number-from-list "[option] 格子点等の指定"
						  `("軸上に+(default)" "グリッド" "+マーク" "黒丸" "なし")))
	 (emgrid (cond ((= emnum 2) "[g]")
		       ((= emnum 3) "[+]")
		       ((= emnum 4) "[o]")
		       ((= emnum 5) "[n]")
		       (t "")))
	 (emonlygrid (if (y-or-n-p "グリッドのみにしますか？")
			 "[n]" ""))
	 (option (emath-drawline-option))
	 (option (emath-setoption option "dx" "xの刻み値"))
	 (option (emath-setoption option "dy" "yの刻み値"))
	 (option (emath-setoption option "ox" "xの基準値"))
	 (option (emath-setoption option "oy" "yの基準値")))
    (concat emgrid emonlygrid
	    (if (string= option "") ""
	      (concat "<" option ">")))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; \xMemori<option>{No}                       ;;;
;;; option label       :No以外のものを表示する ;;;
;;;        perl        :Noに計算式を使用する   ;;;
;;;        memoriiti   :Noの配置を決める       ;;;
;;;        memorinagasa:目盛りの長さ           ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun YaTeX:xMemori ()
  (let* ((option (if (y-or-n-p "[option] Perlと連携しますか？")
		     "perl" ""))
	 (option (emath-setoption option "label" "数字以外のものを表示"))
	 (option (emath-setoption option "memorinagasa" "目盛りの長さ"))
	 (temp (emath-Put-HouiShitei))
	 (emhoui (if (string= temp "") ""
		   (concat "memoriiti={" temp "}")))
	 (option (emath-option-combine "," `(,option ,emhoui))))
    (concat (if (string= option "") ""
	      (concat "<" option ">"))
	    "{" (read-string "目盛りの位置の指定: ") "}%")))
(fset 'YaTeX:yMemori 'YaTeX:xMemori)
(defun YaTeX:tasuki ()
  (let* ((emdis (if (y-or-n-p "[option] たすき掛けの左側のみ表示しますか？")
		    "[l]" "")))
    (concat emdis
	    "{" (read-string "acx^2+(ad+bc)x+bdのa: ") "}{"
	    (read-string "acx^2+(ad+bc)x+bdのc: ") "}{"
	    (read-string "acx^2+(ad+bc)x+bdのb: ") "}{"
	    (read-string "acx^2+(ad+bc)x+bdのd: ") "}%\n"
	    "%\t3行目を表示しない(default)\\def\\tasukikata{0}\n"
	    "%\t3行目のad+bcのみを表示\\def\\tasukikata{1}\n"
	    "%\t3行目をすべて表示\\def\\tasukikata{2}\n"
	    "%\tこれを\\tasukiの前に設定して表示方法を決める")))
(fset 'YaTeX:stasuki 'YaTeX:tasuki)
(defun YaTeX:syndiv ()
  (concat "{" (read-string "割られる式の係数(csv形式): ") "}{"
	  (read-string "除式のゼロ点: ") "}% すべて整数\n"
	  "%\t$\\syndiv{1,-6,11,6}{2,3}$のように第2引数を複数設定すると多段組の組み立て除法が得られる"))
(defun YaTeX:setlinewidth ()
  (concat "{" (read-string "線の太さ: ") "}% 単位付き数値,無名数どちらも可"))
(defun YaTeX:setarrowsize ()
  (concat (emath-setarrow t)
	  "%\n%\tdefault <0[0-9]>{3(.3pt)}{25(2.5pt)}{50(5pt)} #2-#4は単位付きでも指定可"))
(defun YaTeX:kagetukiKyuu ()
  (let* ((noudo (read-string "[option] 一番濃い部分の濃度指定(.8): "))
	 (noudo (if (string= noudo "") ""
		  (concat "[" noudo "]"))))
    (concat noudo
	    "{" (read-string "球の半径: ") "}{"
	    (YaTeX:read-coordinates "(r,θ): ") "}{"
	    (read-string "光が当たる部分の円の半径: ") "}%")))
(defun YaTeX:csyndiv ()
  (concat "{" (read-string "割られる式の係数(csv形式): ") ";%\n"
	  (read-string "経過の係数(csv形式): ") ";%\n"
	  (read-string "結果の係数(csv形式): ") "%\n}{"
	  (read-string "代入する数値: ") "}"))
(defun YaTeX:calcval ()
  (let* ((emnum (emath-get-number-from-list "[option] printfの書式設定" `("浮動小数点(default)" "10進整数" "16進整数" "8進整数" "自分で設定")))
	 (option (cond ((= emnum 1) "")
		       ((= emnum 2) "[d]")
		       ((= emnum 3) "[x]")
		       ((= emnum 4) "[o]")
		       ((= emnum 5)(concat "[" (read-string "先頭の%を除いたフォーマットを設定して下さい(ex. 2d 2.2fなど): ") "]"))
		       (t ""))))
    (concat option
	    "{" (read-string "Perlの計算式: ") "}"
	    (read-string "結果を受け取る制御綴り"))))
(defun YaTeX:funcval ()
  (let* ((emnum (emath-get-number-from-list "[option] printfの書式設定" `("浮動小数点(default)" "10進整数" "16進整数" "8進整数" "自分で設定")))
	 (option (cond ((= emnum 1) "[f]")
		       ((= emnum 2) "[d]")
		       ((= emnum 3) "[x]")
		       ((= emnum 4) "[o]")
		       ((= emnum 5)(concat "[" (read-string "先頭の%を除いたフォーマットを設定して下さい(ex. 2d 2.2fなど): ") "]"))
		       (t ""))))
    (concat option
	    (read-string "関数式f(x): ")
	    "{" (read-string "xの値: ") "}"
	    (read-string "f(x)を受け取る制御綴り"))))
(defun YaTeX:Zyuusin ()
  (concat "{" (read-string "頂点1: ") "}{"
	  (read-string "頂点2: ") "}{"
	  (read-string "頂点3: ") "}"
	  (read-string "重心を受け取る制御綴り: ")))
(defun emath-Zahyou-body (&optional ps-or-not)
  (concat (YaTeX:read-coordinates "(xmin,xmax): ")
	  (YaTeX:read-coordinates "(ymin,ymax): ")
	  (YaTeX:read-coordinates "(zmin,zmax): ")
	  "%\n"
	  (let* ((emfontsize (emath-get-number-from-list "文字の大きさ" `("\\small" "\\scriptsize" "自分で設定"))))
	    (concat (cond ((= emfontsize 1) "\\small\n")
			  ((= emfontsize 2) "\\scriptsize\n")
			  ((= emfontsize 3)(concat (read-string "文字サイズの設定: ") "\n"))
			  (t ")"))))
	  (if ps-or-not "\\setlinewidth{" "\\allinethickness{")
	  (read-string "線の太さ: ") "}%"))
;;(defun emath-Zahyou-option ()
;;  (let* ((emsymbol (if (y-or-n-p "[option] 座標の記号を変更しますか？")
;;		       (let* ((temp (emath-setoption "" "gentenkigou" "原点記号(O)"))
;;			      (temp (emath-setoption temp "yokozikukigou" "横軸記号($x$)"))
;;			      (temp (emath-setoption temp "tatezikukigou" "縦軸記号($y$)")))
;;			 (concat temp)) ""))
;;	 (empos (if (y-or-n-p "[option] 座標の配置を変更しますか？")
;;		    (let* ((temp (emath-setoption "" "gentenhaiti" "原点の配置(se)" "{[" "]}"))
;;			   (temp (emath-setoption temp "yokozikuhaiti" "横軸記号の配置" "{[" "]}"))
;;			   (temp (emath-setoption temp "tatezikuhaiti" "縦軸記号の配置" "{[" "]}")))
;;		      (concat temp)) ""))
;;	 (emarrow (if (y-or-n-p "[option] 軸の形状を変えますか？")
;;		      (let* ((temp (emath-setoption "" "arrowheadsize" "鏃の倍率(1)"))
;;			     (temp (emath-setoption temp "zikusensyu" "軸の線種")))
;;			(concat temp)) "")))
;;    (concat (emath-option-combine (list "," `(,emsymbol ,empos ,emarrow))))))
(defun emath-Zahyou*-option ()
  (let* ((emul (emath-setoption "" "ul" "1目盛りの単位長(要単位)"))
	 (emunit (if (y-or-n-p "[option] 各軸の基本ベクトルを調整しますか？")
		     (let* ((unitx (emath-setoption "" "Ex" "x軸の単位ベクトル(r(.667,138))"))
			    (unity (emath-setoption "" "Ey" "y軸の単位ベクトル((1,0))"))
			    (unitz (emath-setoption "" "Ez" "z軸の単位ベクトル((0,1))")))
		       (concat (emath-option-combine "," `(,unitx ,unity ,unitz)))) ""))
	 (emmargin (if (y-or-n-p "[option] 余白の調整をしますか？")
		       (let* ((temp (emath-setoption "" "Yohaku" "余白(要単位)"))
			      (temp (emath-setoption temp "yohaku" "余白(無名数)"))
			      (temp (emath-setoption temp "Migiyohaku" "右余白(要単位)"))
			      (temp (emath-setoption temp "migiyohaku" "右余白(無名数)"))
			      (temp (emath-setoption temp "Hidariyohaku" "左余白(要単位)"))
			      (temp (emath-setoption temp "hidariyohaku" "左余白(無名数)"))
			      (temp (emath-setoption temp "Ueyohaku" "上余白(要単位)"))
			      (temp (emath-setoption temp "ueyohaku" "上余白(無名数)"))
			      (temp (emath-setoption temp "Sitayohaku" "下余白(要単位)"))
			      (temp (emath-setoption temp "sitayohaku" "下余白(無名数)")))
			 (concat temp)) ""))
	 (empos (if (y-or-n-p "[option] 環境自体の縦の配置を調整しますか？")
		    (emath-select-key-value "haiti" "[option]" `(("上揃え" "t") ("下揃え" "b") ("中央揃え" "c") ("x軸揃え" "x"))))))
    (emath-option-combine "," `(,emul ,emunit ,emmargin ,empos))))
(defun YaTeX:Zahyou ()
  (let* ((astop (emath-Zahyou*-option)))
    (concat (if (string= astop "") ""
	      (concat "[" astop "]"))
	    "%\n\t\t"
	    (emath-Zahyou-body))))
(fset 'YaTeX:Zahyou* 'YaTeX:Zahyou)
(defun YaTeX:psZahyou ()
  (let* ((astop (emath-Zahyou*-option))
	 (psop (emath-pszahyou-option))
	 (option (emath-option-combine "," `(,astop ,psop))))
    (concat (if (string= option "") ""
	      (concat "[" option "]"))
	    "%\n\t\t"
	    (emath-Zahyou-body t))))
(fset 'YaTeX:psZahyou* 'YaTeX:psZahyou)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; \emathPut[#1]#2[#3]#4                                                 ;;;
;;; #1=key *1                                                             ;;;
;;;   key : *background=white                                              ;;;
;;;       : kaiten=60分法                                                 ;;;
;;;       : houkou=方向ベクトル                                           ;;;
;;;       : form=始点[toと併用]                                           ;;;
;;;       : to=終点[fromと併用]                                           ;;;
;;; #2=点 *2                                                              ;;;
;;; #3=key                                                                ;;;
;;;   key : syaei=x|y|xy                                                  ;;;
;;;               =以降を省略でsyaei=xyと同等?
;;;       : houi=n|s|e|w|ne|nw|se|sw                                      ;;;
;;;       : xlabel=                                                       ;;;
;;;       : ylabel=                                                       ;;;
;;;       : xpos=                                                         ;;;
;;;       : ypos=                                                         ;;;
;;;       : syaeisensyu= ps --> dash={n,n}                                ;;;
;;;       : linewidth (ps)                                                ;;;
;;;       : kuromaru ?
;;;       : syaeiiro ?
;;; *syaeiオプション使用時はhouiによる簡易指定のみ[r](7.5pt,60)などは不可 ;;;
;;; #4=文字列                                                             ;;;
;;; \emathPut[#1]#2(#3,#4)[#5]#6                                          ;;;
;;; #1= *1                                                                ;;;
;;; #2= *2                                                                ;;;
;;; (#3,#4)=修正ベクトル(単位付き)                                        ;;;
;;; #5=r|l|t|b                                                            ;;;
;;; #6=文字列                                                             ;;;
;;; 直交座標 (#3,#4)[#5] --> 極座標 [r](#3,#4)=#3:単位付き長さ,#4:60分法  ;;;
;;; emath-Put-HouiShitei () を使用する                              ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun emathPut-kaiten-option ()
  (let* ((emnum (emath-get-number-from-list "[option] 回転方法"
					    `("回転角指定" "方向ベクトル指定[ベクトル自体]" "方向ベクトル指定[始点と終点]")))
	 (option (cond ((= emnum 1) (concat "kaiten=" (read-string "[option] 回転角の指定: ")))
		       ((= emnum 2) (concat "houkou={" (read-string "[option] 方向ベクトルの指定: ") "}"))
		       ((= emnum 3) (concat "from={" (read-string "[option] 方向ベクトルの始点: ") "}"
					    ",to={" (read-string "[option] 方向ベクトルの終点: ") "}"))
		       (t ""))))
    (concat option)))
(defun emathPut-syaei-option ()
  (let* ((emnum (emath-get-number-from-list "[option] 射影の種類" `("xy" "x" "y")))
	 (option (cond ((= emnum 1) "syaei=xy")
		       ((= emnum 2) "syaei=x")
		       ((= emnum 3) "syaei=y")
		       (t "")))
	 (xlabel (if (or (= emnum 1) (= emnum 2))
		     (emath-setoption "" "xlabel" "垂線の足に置く文字列[x]") ""))
	 (ylabel (if (or (= emnum 1) (= emnum 3))
		     (emath-setoption "" "ylabel" "垂線の足に置く文字列[y]") ""))
	 (xpos (if (or (= emnum 1) (= emnum 2))
		   (if (y-or-n-p "xposを設定しますか？: ")
		       (emath-Put-HouiShitei) "") ""))
	 (ypos (if (or (= emnum 1) (= emnum 3))
		   (if (y-or-n-p "yposを設定しますか？: ")
		       (emath-Put-HouiShitei) "") ""))
	 (xpos (if (> (length xpos) 0)
		   (concat "xpos={" xpos "}") ""))
	 (ypos (if (> (length ypos) 0)
		   (concat "ypos={" ypos "}") ""))
	 (option (if (> (length option) 0)
		     (emath-setoption option "linewidth" "線の太さ指定") ""))
	 (dash (if (> (length option) 0)
		   (emath-set-dash) ""))
	 (option (if (> (length option) 0)
		     (emath-setoption option "syaeiiro" "線分の色指定") ""))
	 (houi (if (y-or-n-p "配置文字列の位置を指定しますか？: ")
		   (YaTeX:read-position "news") ""))
	 (houi (if (> (length houi) 0)
		   (concat "houi={" houi "}")))
	 (kuromaru (if (y-or-n-p "黒丸を設定しますか？: ");siromaruオプションもあるのかな？
		       "kuromaru" ""))
	 (option (emath-option-combine "," `(,option ,xlabel ,ylabel ,xpos ,ypos ,dash ,houi ,kuromaru))))
    (concat option)))
(defun YaTeX:emathPut ()
    (progn (insert (concat (if (y-or-n-p "配置文字列を回転させますか？: ")
			       (concat "[" (emathPut-kaiten-option) "]") "")
			   (read-string "文字列を置く座標の指定: ")
			   (if (y-or-n-p "射影を設定しますか？: ")
			       (concat "[" (emathPut-syaei-option) "]")
			     (emath-Put-HouiShitei))
			   "{" (read-string "配置文字列: ") "}%"))))
(fset 'YaTeX:Put 'YaTeX:emathPut)
(fset 'YaTeX:cPut 'YaTeX:emathPut)
(defun YaTeX:YTenPut ()
  (let* ((option (emath-setoption "" "xformat" "x座標のフォーマット指定(s)"))
	 (option (emath-setoption option "yformat" "y座標のフォーマット(f)")))
    (concat (if (string= option "") ""
	      (concat "[" option "]"))
	    "{" (read-string "関数の指定: ") "}{"
	    (read-string "x座標の指定(xformat=fならばPerlの関数での指定も可): ") "}"
	    (emath-Put-HouiShitei))))
(defun YaTeX:Unitvec ()
  (concat (if (y-or-n-p "[option] Perlとの連携をしますか?")
	      "<perl>" "")
	  "{" (read-string "ベクトル: ") "}"
	  (read-string "単位ベクトルを受け取る制御綴り: ")))
(defun YaTeX:SuityokuNitoubunsen ()
  (concat "{" (read-string "端点1: ") "}{"
	  (read-string "端点2: ") "}"
	  (read-string "線分の中点を受け取る制御綴り: ")
	  (read-string "垂直二等分線の方向ベクトルを受け取る制御綴り: ")))
(defun YaTeX:Suisin ()
  (let* ((empoint1 (read-string "頂点1: "))
	 (empoint2 (read-string "頂点2: "))
	 (empoint3 (read-string "頂点3: ")))
    (concat "{" empoint1 "}{"
	    empoint2 "}{"
	    empoint3 "}"
	    (read-string "垂心を受け取る制御綴り: ")
	    "\n%\t\\Suisini:" empoint1 "から対辺に下ろした垂線の足"
	    "\n%\t\\Suisinii:" empoint2 "から対辺に下ろした垂線の足"
	    "\n%\t\\Suisiniii:" empoint3 "から対辺に下ろした垂線の足")))
;;; emath??
(defun YaTeX:PutParts ()
  (let* ((emlabel (emath-setoption "" "label" "labelの設定"))
	 (emparts (emath-select-key-value "" "パーツの選択"
						`(("resistor" "resistor") ("condenser" "condenser")
						  ("capacitor" "capacitor") ("battery" "battery")
						  ("coil" "coil") ("inductor" "inductor")
						  ("meter" "meter") ("switch" "switch") ("current" "current")))))
    (concat (if (string= emlabel "") ""
	      (concat "<" emlabel ">"))
	    "{" emparts "}{"
	    (read-string "始点: ")
	    "}{" (read-string "終点: ") "}%")))
(defun YaTeX:Naisin ()
  (concat "{" (read-string "頂点1: ") "}{"
	  (read-string "頂点2: ") "}{"
	  (read-string "頂点3: ") "}"
	  (read-string "内心を受け取る制御綴り: ")
	  "%\\lrに半径が格納されています"))
(defun YaTeX:Naisetuen ()
  (concat "{" (read-string "頂点1: ") "}{"
	  (read-string "頂点2: ") "}{"
	  (read-string "頂点3: ")
	  "}%内心が\\vNaisinに半径が\\lrに格納されています"))
;\Kuromaru<#1>#2
;    #1: key=val の形式
;         nuriiro:塗りつぶす色を指定します。
;         paintcolor:塗りつぶす色を指定します。
;         size:黒丸の半径を指定します。
;    #2: 黒丸を打つべき点列を与えます。
(defun emath-kuromaru-option ()
  (let* ((option "")
	 (size (emath-setoption "" "size" "黒丸の半径の指定"))
	 (paintcolor (emath-setoption "" "paintcolor" "色の指定")))
    (setq option (emath-option-combine "," `(,size ,paintcolor)))))
(defun YaTeX:Kuromaru ()
  (let* ((option (emath-kuromaru-option)))
    (insert (concat (if (> (length option) 0)
			(concat "<" option ">") "")
		    "{" (emath-tenretu-loop "" "黒丸を打つ点の指定")
		    "}%\n%\t広域で半径を指定するには\\KuromaruHankeiを利用する\n"
		    "%\tただし，白丸の半径にも影響するので注意\n"))))
(defun emath-siromaru-option ()
  (let* ((option "")
	 (size (emath-setoption "" "size" "白丸の半径の指定"))
	 (linethickness (emath-setoption "" "linethickness" "円周の太さの指定"))
	 (color (emath-setoption "" "color" "円周の色の指定")))
    (setq option (emath-option-combine "," `(,size ,linethickness ,color)))))
(defun YaTeX:Siromaru ()
  (let* ((option (emath-siromaru-option)))
    (insert (concat (if (> (length option) 0)
			(concat "<" option ">") "")
		    "{" (emath-tenretu-loop "" "白丸を打つ点の指定")
		    "}%\n%\t広域で半径を指定するには\\SiromaruHankeiを利用する\n"))))
;\Kurosankaku<#1>#2
;    #1: key=val の形式
;         kaiten:正三角形を回転させます。
;         nuriiro:塗りの色を指定します。
;         size:外接する円の半径を指定します。
;    #2: 黒い正三角形を打つべき点列を与えます。
;\KurosankakuHankeiで広域指定
(defun emath-kurosankaku-option ()
  (let* ((option "")
	 (size (emath-setoption "" "size" "外接円の半径の指定"))
	 (paintcolor (emath-setoption "" "paintcolor" "色の指定"))
	 (kaiten (emath-setoption "" "kaiten" "回転角の指定")))
    (setq option (emath-option-combine "," `(,size ,paintcolor ,kaiten)))))
(defun YaTeX:Kurosankaku ()
  (let* ((option (emath-kurosankaku-option)))
    (insert (concat (if (> (length option) 0)
			(concat "<" option ">") "")
		    "{" (emath-tenretu-loop "" "黒三角を打つ点の指定")
		    "}%\n%\t広域で外接円の半径を指定するには\\KurosankakuHankeiを利用する\n"))))
(defun YaTeX:Kurosikaku ()
  (let* ((option (emath-kurosankaku-option)))
    (insert (concat (if (> (length option) 0)
			(concat "<" option ">") "")
		    "{" (emath-tenretu-loop "" "黒四角を打つ点の指定")
		    "}%\n%\t広域で外接円の半径を指定するには\\KurosikakuHankeiを利用する\n"))))
;\Sirosankaku<#1>#2
;    #1: key=val の形式
;         kaiten:正三角形を回転させます。
;         linethickness:周の太さを変更します。
;         size:外接する円の半径を指定します。
;    #2: 白い正三角形を打つべき点列を与えます。
;\SirosankakuHankeiで広域指定
(defun emath-sirosankaku-option ()
  (let* ((option "")
	 (size (emath-setoption "" "size" "外接円の半径の指定"))
	 (linethickness (emath-setoption "" "linethickness" "周の太さの指定"))
	 (color (emath-setoption "" "color" "周の色の指定"))
	 (kaiten (emath-setoption "" "kaiten" "回転角の指定")))
    (setq option (emath-option-combine "," `(,size ,linethickness ,color ,kaiten)))))
(defun YaTeX:Sirosankaku ()
  (let* ((option (emath-sirosankaku-option)))
    (insert (concat (if (> (length option) 0)
			(concat "<" option ">") "")
		    "{" (emath-tenretu-loop "" "白三角を打つ点の指定")
		    "}%\n%\t広域で外接円の半径を指定するには\\SirosankakuHankeiを利用する\n"))))
(defun YaTeX:Sirosikaku ()
  (let* ((option (emath-sirosankaku-option)))
    (insert (concat (if (> (length option) 0)
			(concat "<" option ">") "")
		    "{" (emath-tenretu-loop "" "白四角を打つ点の指定")
		    "}%\n%\t広域で外接円の半径を指定するには\\ShirosikakuHankeiを利用する\n"))))
;\Heikoukigou[#1]#2#3
;    #1: key=val
;         heikoukigouiti:平行記号を置く位置を指定します。(0～1 の数値，デフォルトは 0.5)
;         heikoukigoukankaku:複数の矢印の間隔を指定します。（単位を伴った長さで，デフォルト値は 1mm）
;         heikoukigoukosuu:矢印の個数を指定します。(1～4 の整数値，デフォルトは 1)
;         heikoukigousize:矢印の大きさを指定します。標準の矢印サイズの何倍にするかを実数値で指定します。（デフォルトは 2)
;         linethickness:矢印の太さ（デフォルトは 0.4pt）
;    #2: 端点1
;    #3: 端点2
(defun emath-heikoukigou-common ()
  (let* ((option (emath-setoption "" "heikoukigouiti" "記号を置く位置指定[0-1](.5)"))
	 (option (emath-setoption option "heikoukigoukosuu" "矢印の個数指定[1-4](1)"))
	 (option (emath-setoption option "heikoukigoukankaku" "矢印の間隔指定[要単位](1mm)"))
	 (option (emath-setoption option "heikoukigousize" "矢印の大きさ指定(2)"))
	 (option (emath-setoption option "linethickness" "矢印の太さ指定(.4pt)")))
    (concat option)))
(defun YaTeX:Heikoukigou ()
  (let* ((option (emath-heikoukigou-common)))
    (insert (concat (if (> (length option) 0)
			(concat "[" option "]") "")
		    "{" (read-string "端点1: ") "}"
		    "{" (read-string "端点2: ") "}"))))
(fset `YaTeX:Heikoukigou* `YaTeX:Heikoukigou)
;\heikoukigou[#1]#2
;    #1: key=val （\Heikoukigou と同じ）
;    #2: 線分を ; で区切って並べます。
(defun YaTeX:heikoukigou ()
  (let* ((option (emath-heikoukigou-common)))
    (insert (concat (if (> (length option) 0)
			(concat "[" option "]") "")
		    "{" (emath-tenretu-loop ";" "線分の指定") "}"))))
(fset 'YaTeX:heikoukigou* 'YaTeX:heikoukigou)
;\HenKo[#1]<#2>#3#4#5
; 辺#3#4の長さを表す辺弧を描画し，文字列#5を配置します。
;    #1: 弧を点線にする場合，点の個数（*を指定した場合は，一任）
;    #2: key=val をコンマ区切りで並べます。
;         linewidth:辺弧の太さを変更します。
;         dash:辺弧を破線で描画します。
;         hasenLG:円弧を破線で描画します。
;         henkocolor:辺弧に色を付けます。
;         yazirusi:辺弧に矢印をつけます。
;         henkoH:辺弧中点と辺の距離を変更します。
;                デフォルト値は 1.6ex
;         henkomoziH:文字列配置基準点を変更します。
;                    右辺値は単位を伴う長さで，辺弧中点からの距離（辺弧からの）を指定します。
;         putpos:文字列配置基準点を変更します。
;                右辺値は 0～1 の数値で，デフォルトは 0.5（円弧の中点）
;                0に近づけば端点#3に，1に近づけば端点#4に近づきます。
;         putoption:文字列位置の調整をします。
;                   右辺値は \Put コマンドの配置微調整オプションです。
;         henkomozikaiten:文字列を線分と平行となるように回転します。
;                         右辺値は 1 または -1 です。
;         sironuki:白抜きをするか否かを指定します。
;         henkosep:白抜き余白量を調整します。
;                  デフォルト値は 1pt
;         paintoption:弧と弦の間を塗りつぶすオプションです
;         agezoko:辺と垂直方向に端点を移動する分量を指定します。
;         agezokoA:辺と垂直方向に始点を移動する分量を指定します。
;         agezokoB:辺と垂直方向に終点を移動する分量を指定します。
;         Hamidasi:端点をはみ出させる分量を指定します。
;         HamidasiA:始点をはみ出させる分量を指定します。
;         HamidasiB:終点をはみ出させる分量を指定します。
;         henkotype:弧の形状を指定します。右辺値は
;                   0 (arc)	円：デフォルト
;                   1 (ellipse)	楕円
;                   2 (triangle)	折れ線（辺と併せて三角形）
;                   3 (parallel)	平行線
;                   4 (bracket)	大括弧（辺と併せて長方形）
;                   6 (trapezoid)	折れ線（辺と併せて等脚台形）
;                   7 (paren)	小括弧（両端の四分円を線分で結ぶ）
;                   8 (brace)	中括弧
;         henkosideb, henkosidet:henkotype=parallel の場合のみに有効です。
;         henkosideoption:henkoside の太さ・形状を変更します。
;         trapezoidangle:henkotype=trapezoid で描画される等脚台形の底角の大きさを指定します。
;    #3,#4 : 辺両端の点
;    #5 : 配置する文字列
; \HenKoTyuuten:\HenKoコマンドの実行後，円弧の中点の座標が保存されています。
; \HenKoP:\HenKoコマンドの実行後，文字列配置基準点の座標が保存されています。
;         デフォルトでは，\HenKoTyuuten と同一ですが，
;         オプション<putpos=.> をつけた場合はその限りではありません。
(defun emath-HenKo-option ()
  (let* ((option (emath-setoption "" "linewidth" "弧の太さ"))
	 (dash (emath-set-dash));dash & hasenLG
	 (option (emath-setoption option "henkocolor" "弧の色"))
	 (emnum (emath-get-number-from-list "[option] 矢印の種類"
						  `("終点のみ" "始点のみ" "両端" "設定しない")))
	 (yazirusi (cond ((= emnum 1) "yazirusi=a")
			 ((= emnum 2) "yazirusi=r")
			 ((= emnum 3) "yazirusi=b")
			 (t "")))
	 (option (emath-setoption option "henkoH" "弧の頂点と弦の距離(1.6ex)"))
	 (option (emath-setoption option "henkomoziH" "文字列と弦の距離"))
	 (option (emath-setoption option "putpos" "文字列の配置位置[0=端点1，1端点2](.5)"))
	 (putoption (if (y-or-n-p "[option] 文字列の配置位置を調整しますか？: ")
			(concat "putoption={"
				(emath-Put-HouiShitei)
				"}")))
	 (emnum (emath-get-number-from-list "[option] 文字列の回転"
						  `("始点が先頭" "終点が先頭" "設定しない")))
	 (henkomozikaiten (cond ((= emnum 1) "henkomozikaiten=-1")
				((= emnum 2) "henkomozikaiten=1")
				(t "")))
	 (emnum (emath-get-number-from-list "[option] 文字列の背景"
						  `("白抜き(default)" "白抜きをしない")))
	 (sironuki (cond ((= emnum 2) "sironuki=false")
			 (t "")))
	 (henkosep (if (= emnum 1)
		       (read-string "[option] 白抜き余白の設定(1pt): ") ""))
	 (henkosep (if (> (length henkosep) 0)
		       (concat "henkosep=" henkosep) ""))
	 (paintoption (emath-emPaint-option ""))
	 (paintoption (if (> (length paintoption) 0)
			  (concat "paintoption={" paintoption "}")))
	 (emnum (emath-get-number-from-list "[option] 端点の垂直方向への移動"
						  `("両端を同じだけ移動" "端点1・端点2それぞれ移動" "設定しない")))
	 (agezoko (cond ((= emnum 1) (concat "agezoko=" (read-string "[option] 両端の移動量[要単位]: ")))
			((= emnum 2) (concat "agezokoA=" (read-string "[option] 端点1の移動量[要単位]: ")
					     "agezokoB=" (read-string "[option] 端点2の移動量[要単位]: ")))
			(t "")))
	 (emnum (emath-get-number-from-list "[option] 端点の水平方向への移動"
						  `("両端を同じだけ移動" "端点1・端点2それぞれ移動" "設定しない")))
	 (Hamidasi (cond ((= emnum 1) (concat "Hamidasi=" (read-string "[optoin] 両端の移動量[要単位]: ")))
			 ((= emnum 2) (concat "HamidasiA=" (read-string "[option] 端点1の移動量[要単位]: ")
					      "HamidasiB=" (read-string "[option] 端点2の移動量[要単位]: ")))
			 (t "")))
	 (emnum (emath-get-number-from-list "[option] 弧の形状"
						  `("楕円" "折線[三角形]" "平行線" "大括弧"
						    "折線[等脚台形]" "小括弧" "中括弧")))
	 (henkotype (cond ((= emnum 1) "henkotype=ellipse")
			  ((= emnum 2) "henkotype=triangle")
			  ((= emnum 3) "henkotype=parallel")
			  ((= emnum 4) "henkotype=bracket")
			  ((= emnum 5) "henkotype=trapezoid")
			  ((= emnum 6) "henkotype=paren")
			  ((= emnum 7) "henkotype=brace")
			  (t "")))
	 (henkosidet (if (= emnum 3)
			 (read-string "弦と弧の端点を結ぶ線分の弧側の先端の位置[0:弦の端点，1:弧の端点]: ") ""))
	 (henkosidet (if (> (length henkosidet) 0)
			 (concat "henkosidet=" henkosidet) ""))
	 (henkosideb (if (= emnum 3)
			 (read-string "弦と弧の端点を結ぶ線分の弦側の先端の位置[0:弦の端点，1:弧の端点]: ") ""))
	 (henkosideb (if (> (length henkosideb) 0)
			 (concat "henkosidet=" henkosideb) ""))
	 (henkosideoption (if (= emnum 3)
			      (if (y-or-n-p "[option] 弦と弧を結ぶ線分を調整しますか？: ")
				  (concat "henkosideoption={"
					  (emath-Drawline-option)
					  "}") "") ""))
	 (trapezoidangle (if (= emnum 5)
			     (read-string "[option] 等脚台形の底角の指定[0<θ<90](45): ") ""))
	 (trapezoidangle (if (> (length trapezoidangle) 0)
			     (concat "trapezoidangle=" trapezoidangle) ""))
	 (option (emath-option-combine "," `(,option ,dash ,yazirusi ,putoption ,henkomozikaiten
							   ,sironuki ,henkosep ,paintoption ,agezoko
							   ,Hamidasi ,henkotype ,henkosidet ,henkosideb
							   ,henkosideoption ,trapezoidangle))))
    (concat option)))
(defun YaTeX:HenKo ()
  (let* ((op1 (read-string "[option] 点の個数[*で一任，0で弧を描画しない]: "))
	 (op2 (emath-HenKo-option)))
    (insert (concat (if (> (length op1) 0)
			(concat "[" op1 "]") "")
		    (if (> (length op2) 0)
			(concat "<" op2 ">") "")
		    "{" (read-string "端点1: ") "}"
		    "{" (read-string "端点2: ") "}"
		    "{" (read-string "配置文字列: ") "}%\n"
		    "\t%\\HenKoTyuuten=円弧の中点の座標，\\HenKoP=文字列は位置座標\n"))))
(defun YaTeX:HenKos ()
  (let* ((op1 (read-string "[optoin] 点の個数[*で一任，0で弧を描画しない]: "))
	 (op2 (emath-HenKo-option)))
    (insert (concat (if (> (length op1) 0)
			(concat "[" op1 "]") "")
		    (if (> (length op2) 0)
			(concat "<" op2 ">") "")
		    "{" (emath-tenretu-loop ";" "2つの端点と配置文字列の指定") "}"))))
;\HenToubun<#1>#2#3#4#5
; 辺#2#3の(#4)等分点を定義します。
;    #1: key=val, 有効なキーは
;         kuromaru:辺等分点に黒丸を描画します。
;                  -1で両端も
;         nahuda:辺等分点に名札をつけます。
;               :右辺に単位付き数値を設定すると辺からの距離を設定できる
;         tatebou:辺等分点に縦棒を描画します。
;    #2: 端点1
;    #3: 端点2
;    #4: 分割数
;    #5: 分点の名前（配列基幹名，または，コンマ区切り点列名）
;        #5 において，戻る分点の個数は両端を除く (n-1)個
(defun YaTeX:HenToubun ()
  (let* ((emnum 0)
	 (shirushi "")
	 (nahuda "")
	 (option ""))
    (progn (if (y-or-n-p "名札を設定しますか？: ")
	       (if (y-or-n-p "名札の位置を変更しますか？: ")
		   (setq nahuda (concat "nahuda=" (read-string "辺と名札との距離: ")))
		 (setq nahuda "nahuda")) "")
	   (setq emnum (emath-get-number-from-list "[option] 等分点の印"
							 `("黒丸" "縦棒" "印を付けない"))
		 shirushi (cond ((= emnum 1)(concat "kuromaru"
						    (if (y-or-n-p "両端にも配置しますか？: ") "=-1" "")))
				((= emnum 2)(concat "tatebou"))
				(t ""))
		 option (emath-option-combine "," `(,nahuda ,shirushi)))
	   (insert (concat (if (> (length option) 0)
			       (concat "<" option ">") "")
			   "{" (read-string "端点1: ") "}"
			   "{" (read-string "端点2: ") "}"
			   "{" (read-string "分割数: ") "}"
			   "{" (read-string "分点の名前: ") "}")))))
;\Gaisin<#1>#2#3#4#5
;    #1 : key=val 形式で，有効なキーは
;          setxyrange:外接円を内包する zahyou環境 x, y の範囲を .aux ファイルに書き出し，
;                     pszahyou環境の [getxyrange] オプションでそれを取得します。
;    #2, #3, #4 : 三角形の頂点
;    #5 : 外心を受け取る制御綴
;    コマンド実行後，外接円の半径が \lR に保存されています。
(defun YaTeX:Gaisin ()
  (let* ((option (if (y-or-n-p "[option] setxyrangeを設定しますか？: ")
		     "setxyrange" "")))
    (insert (concat (if (> (length option) 0)
			(concat "<" option ">") "")
		    "{" (read-string "頂点1: ") "}"
		    "{" (read-string "頂点2: ") "}"
		    "{" (read-string "頂点3: ") "}"
		    (read-string "外心を受け取る制御綴り: ")
		    "% 外接円の半径=\\lR"))))
(defun YaTeX:Gaisetuen ()
  (concat "{" (read-string "頂点1: ") "}{"
	  (read-string "頂点2: ") "}{"
	  (read-string "頂点3: ")
	  "}% 外接円の中心=\\vGaisin，半径=\\lR"))
;\Hamidasisenbun[#1]<#2>#3#4#5#6
;    #1 : key=val で，有効なキーは
;         hidariT:左にはみ出した点 (\hidariT) に名前をつけて保存
;         migiT:右にはみ出した点 (\migiT) に名前をつけて保存
;    #2 : \Drawline に引き渡されるオプション引数
;    #3 : 左端点
;    #4 : 右端点
;    #5 : 左のはみ出し量（単位つき寸法）
;    #6 : 右のはみ出し量（単位つき寸法）
;        はみ出し量に負の値を与えれば，縮みます。
;        このコマンドを実行した後
;        　　左にはみ出した点が \hidariT
;        　　右にはみ出した点が \migiT
;        に定義されています。
(defun emath-set-tanten-csname ()
  (let* ((option (emath-setoption "" "hidariT" "左端点の制御綴り名(\\hidariT)"))
	 (option (emath-setoption option "migiT" "右端点の制御綴り名(\\migiT)")))
    (concat option)))
(defun emath-hamidasisenbun-option ()
  (let* ((op1 (emath-set-tanten-csname))
	 (op2 (emath-Drawline-option)))
    (list op1 op2)))
(defun emath-hamidasisenbun-common ()
  (let* ((option (emath-hamidasisenbun-option))
	 (op1 (car option))
	 (op2 (car (cdr option))))
    (insert (concat (if (> (length op1) 0)
			(concat "[" op1 "]") "")
		    (if (> (length op2) 0)
			(concat "<" op2 ">"))
		    "{" (read-string "左端点: ") "}"
		    "{" (read-string "右端点: ") "}"))))
(defun YaTeX:Hamidasisenbun ()
  (progn (emath-hamidasisenbun-common)
	 (insert (concat "{" (read-string "左のはみ出し量[要単位]: ") "}"
			 "{" (read-string "右のはみ出し量[要単位]: ") "}"
			 "% \hidariT，\migiTが設定されている\n"))))
(fset `YaTeX:Hamidasisenbun* 'YaTeX:Hamidasisenbun)
;\hamidasisenbun[#1]<#2>#3#4#5#6
;    #5，#6以外は\Hamidasisenbunと同じ
;    #5 : 線分#3#4 の長さに対する左のはみ出し率
;    #6 : 線分#3#4 の長さに対する右のはみ出し率
;        はみ出し率に負の値を与えれば，縮みます。
(defun YaTeX:hamidasisenbun ()
  (progn (emath-hamidasisenbun-common)
	 (insert (concat "{" (read-string "左のはみ出す割合]: ") "}"
			 "{" (read-string "右のはみ出す割合: ") "}"
			 "% \hidariT，\migiTが設定されている\n"))))
(fset `YaTeX:hamidasisenbun* `YaTeX:hamidasisenbun)
;\Hamidasiten#1#2#3#4
;    #1 : 端点1
;    #2 : 端点2
;    #3 : 端点2に対するはみ出し量（単位つき長さ）
;    #4 : 結果を受け取る制御綴
;    はみ出し量に負の値を与えれば，縮みます。
(defun YaTeX:Hamidasiten ()
  (insert (concat "{" (read-string "端点1: ") "}"
		  "{" (read-string "端点2: ") "}"
		  "{" (read-string "端点2に対するはみ出し量[要単位]: ") "}"
		  (read-string "結果を受け取る制御綴り: "))))
;\Hamidasiten*#1#2#3#4#5#6
;    #1 : 端点1
;    #2 : 端点2
;    #3 : 端点1の方のはみ出し量（単位つき寸法）
;    #4 : 端点2の方のはみ出し量（単位つき寸法）
;    #5 : 端点1 からはみ出した点を受け取る制御綴
;    #6 : 端点2 からはみ出した点を受け取る制御綴
(defun YaTeX:Hamidasiten* ()
  (insert (concat "{" (read-string "端点1: ") "}"
		  "{" (read-string "端点2: ") "}"
		  "{" (read-string "端点1に対するはみ出し量[要単位]: ") "}"
		  "{" (read-string "端点2に対するはみ出し量[要単位]: ") "}"
		  (read-string "端点1に関する結果を受け取る制御綴り: ")
		  (read-string "端点2に関する結果を受け取る制御綴り: "))))
(defun YaTeX:Fsyndiv ()
  (let* ((emsoroe (if (y-or-n-p "[option] 右揃えにしますか？")
		      "soroe=R" ""))
	 (emsityuu (if (y-or-n-p "[option] 支柱を立てますか？")
		       (emath-select-key-value "" "[option] [支柱]"
						     `(("答え行のみ" "kotaegyousityuu=\\bsityuu")
						       ("すべての行" "gyousityuu=\\bsityuu")))
 ""))
	 (emop (emath-option-combine "," `(,emsoroe ,emsityuu))))
    (concat (if (string= emop "") ""
	      (concat "<" emop ">"))
	    "{" (read-string "多項式の係数(コンマ区切り): ") "}{"
	    (read-string "除式のゼロ点(分数): ") "}")))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; \EnGurafu[option]{rate1,rate2,...}                                     ;;;
;;;   option Hankei:円グラフの半径(要単位)(2cm)                            ;;;
;;;          fboxsep:ラベルの白抜き余白                                    ;;;
;;;          EnGurafuLabelpos:ラベルの位置係数[0のときラベルを非表示](.75) ;;;
;;;          EnGurafuMemoriNagasa:?(2mm)                                   ;;;
;;;          EnGurafuMemoriKizami:?(1)                                     ;;;
;;;          EnGurafuMemoriLabel:?(10)                                     ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun YaTeX:EnGurafu ()
  (let* ((emop (emath-setoption "" "Hankei" "円グラフの半径(2cm)"))
	 (emop (emath-setoption emop "fboxsep" "ラベルの白抜き余白(\\fboxsep)"))
	 (emop (emath-setoption emop "EnGurafuLabelpos"
				      "ラベルの位置係数[0のときラベルを非表示](.75)")))
    (concat (if (string= emop "") ""
	      (concat "[" emop "]"))
	    "{" (read-string "各々の割合を\",\"で区切って記述: ") "}%\n"
	    "%\t\\def\\NuriFi{}%濃度.5の塗りつぶし\n"
	    "%\t\\def\\NuriFii{*}%45度の斜線塗り\n"
	    "%\t\\def\\NuriFiii{[0]}%白塗り\n"
	    "%\t\\def\\NuriFiv{*[-45,45]}%45度と-45度の斜線塗り\n"
	    "%\t以上がデフォルトで設定されている5番目以降のアイテムがある場合は自分で設定する\n"
	    "%\t\\def\\NuriFv{[paintcolor=red]}などの色の指定も可能")))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; EMpsrectbox環境                                                                   ;;;
;;; [option] fboxsep:\fboxsepの設定(環境内の\fboxsepを利用するアイテムに影響を与える) ;;;
;;;          hsep:左右の余白の設定                                                    ;;;
;;;          vsep:上下の余白の設定                                                    ;;;
;;;          rectboxwidth:環境の横幅設定(\linewidth)                                  ;;;
;;;          item:見出し                                                              ;;;
;;;          itempos:見出しの位置の指定[lcr](l)                                       ;;;
;;;          rectboxoval:ovalboxにするときに設定する                                  ;;;
;;;                      数値を設定すると角の四分円の半径を設定(10pt)                 ;;;
;;; <option> 罫線の変更option内に\setdash{.2,.2}や\setlinewidth{8}のように記述する    ;;;
;;; ページをまたぐことは出来ない                                                      ;;;
;;; 傍注を付けることは出来ない                                                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun YaTeX:EMpsrectbox()
  (let* ((emitem (emath-setoption "" "item" "見出しの設定" "{" "}"))
	 (emitempos (if (string= emitem "") ""
		      (read-string "[option] [見出し] 見出しの位置設定[lcr](l)")))
	 (emitempos (if (string= emitempos "") ""
		      (concat "itempos=" emitempos)))
	 (embitem (emath-setoption "" "bitem" "下見出しの設定" "{" "}"))
	 (embitempos (if (string= embitem "") ""
		      (read-string "[option] [見出し] 下見出しの位置設定[lcr](r)")))
	 (embitempos (if (string= embitempos "") ""
		      (concat "bitempos=" embitempos)))
	 (emoval (if (y-or-n-p "[option] ovalboxにしますか？")
		     "rectboxoval" ""))
	 (emoval (if (string= emoval "") ""
		   (if (y-or-n-p "[option] [oval] 角の四分円の半径を設定しますか？")
		       (emath-setoption "" "rectboxoval" "[oval] 角の四分円の半径(10pt)")
		     "rectboxoval")))
	 (emoct (if (string= emoval "")
		  (if (y-or-n-p "[option] octboxにしますか？")
		      (concat "rectboxoct") "") ""))
	 (emoct (if (string= emoct "") ""
		   (if (y-or-n-p "[option] [oct] 角を切り取る辺の長さを設定しますか？")
		       (emath-setoption "" "rectboxoct" "[oct] 切り取る辺の長さ)")
		     "rectboxoct")))
	 (emop (emath-setoption "" "fboxsep"
				      "余白の設定(環境内の\\fboxsepを利用するアイテムに影響を与える)"))
	 (emop (emath-setoption emop "hsep" "左右の余白の設定"))
	 (emop (emath-setoption emop "vsep" "上下の余白の設定"))
	 (emop (emath-setoption emop "rectboxwidth" "環境の横幅の指定(\\linewidth)"))
	 (emop (emath-setoption emop "linewidth" "枠線の太さの指定"))
	 (emdash (if (y-or-n-p "枠線を破線にしますか？")
		     (let* ((temp (emath-setdash)))
		       (concat "dash={" temp "}")) ""))
	 (emop (emath-option-combine "," `(,emop ,emdash)))
	 (emop (emath-setoption emop "framecolor" "枠線の色の指定"))
	 (emop (emath-setoption emop "backgroundcolor" "背景色の指定"))
	 (emdis (emath-select-key-value "" "[option] 枠線を"
					      `(("左右のみ表示" "LRonly") ("左のみ表示" "Lonly")
						("右のみ表示" "Ronly"))))
	 (emop (emath-option-combine "," `(,emop ,emitem ,emitempos ,embitem
						       ,embitempos ,emoval ,emoct ,emdis)))
;; オプションで設定できるので第2引数の処理を削除
;;	 (emline (if (y-or-n-p "[option] 枠線の変更をしますか？")
;;		     (let* ((templine (if (y-or-n-p "[option] [line] 枠線の太さを変更しますか？")
;;					  (concat "\\setlinewidth{" (read-string "[option] [line] 線の太さの設定: ") "}") ""))
;;			    (tempdash (if (y-or-n-p "[option] [line] 破線にしますか？")
;;					  (concat "\\setdash"
;;						  (emath-setdash)) "")))
;;		       (emath-option-combine (list "," templine tempdash))) ""))
)
    (concat (if (string= emop "") ""
	      (concat "[" emop "]%\n"))
;;	    (if (string= emline "") ""
;;	      (concat "<" emline ">"))
	    (if (y-or-n-p "環境内の文字の大きさを指定しますか？")
		(let* ((emsize (emath-select-key-value "" "文字サイズの変更"
							     `(("\\small" "\\small") ("\\large" "\large")
							       ("\\scriptsize" "\\scriptsize")
							       ("\\Large" "\\Large")))))
		  (if (> (length emsize) 0) (concat emsize) "")) "")
	    (if (y-or-n-p "環境内でindentを設定しますか？")
		(let* ((emindent (read-string "indentの量は(要単位): ")))
		  (if (> (length emindent) 0)
		      (concat "\\parindent=" emindent "\\quad") "")) ""))))
(defun YaTeX:EMcallperl ()
  (let* ((emop (emath-setoption "" "scriptfile" "スクリプトファイル名の設定"))
	 (emop (emath-setoption emop "outputfile" "アウトプットファイル名の設定")))
    (concat (if (string= emop "") ""
	      (concat "[" emop "]%")))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; emath-Drawline-option                                      ;;;
;;;   color                                                          ;;;
;;;   linethickness                                                      ;;;
;;;   dash                                                           ;;;
;;;   hasenLG
;;;   yazirusi:矢印の付加 a:終点 r:始点 b:両端                       ;;;
;;;   arrowsize={<窪みの比率(省略可)>{}{鏃の太さ(25)}{鏃の長さ(50)}} ;;;
;;;   idou:調整ベクトル(x,y)                                         ;;;
;;;   linejoin:接続の調整 0:マイター(default) 1:ラウンド 2:ベベル    ;;;
;;;   oval                                                           ;;;
;;;   kuromaru
;;;   siromaru
;;;   vmark
;;;   linecap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun emath-Drawline-option ()
  (let* ((option (emath-setoption "" "color" "色の指定"))
	 (option (emath-setoption option "linethickness" "線の太さ"))
	 (emnum (emath-get-number-from-list "[option] 破線の設定"
						  `("hasenLG" "dash" "設定しない")))
	 (dash (cond ((= emnum 1) (concat "hasenLG={"
					  (read-string "描画部の長さ(1mm): ")
					  ","
					  (read-string "ギャップ部の長さ(.9mm): ")
					  "}"))
		     ((= emnum 2) (concat "dash={" (emath-setdash) "}"))
		     (t "")))
	 (emnum (emath-get-number-from-list "[option] 矢印の設定"
						  `("終点のみ" "始点のみ" "両端" "設定しない")))
	 (yazirusi (cond ((= emnum 1) "yazirusi=a")
			 ((= emnum 2) "yazirusi=r")
			 ((= emnum 3) "yazirusi=b")
			 (t "")))
	 (arrowsize (if (and (> emnum 0) (< emnum 4))
			(concat "arrowsize={" (emath-setarrow) "}") ""))
	 (idou (if (y-or-n-p "線分を移動しますか？: ")
		   (concat "idou={" (YaTeX:read-coordinates
				     "[option] 移動量の指定 (dx,dy)" "dx" "dy") "}") ""))
	 (emnum (emath-get-number-from-list "[option] コーナーの補正"
						  `("マイター(default)" "ラウンド"
						    "ベベル" "オーバル")))
	 (linejoin (cond ((and (> emnum 1) (< emnum 4))
			  (concat "linejoin=" (number-to-string (- emnum 1))))
			 ((= emnum 4) "oval")
			 (t "")))
	 (emnum (emath-get-number-from-list "[option] 折れ点のマークの種類"
						  `("黒丸" "白丸" "任意" "設定しない")))
	 (mark (cond ((= emnum 1) "kuromaru")
		     ((= emnum 2) "siromaru")
		     ((= emnum 3) (concat "vmark={"
					  (read-string "[option] 任意の記号: ") "}"))
		     (t "")))
	 (emnum (emath-get-number-from-list "[option] 端点の処理"
						  `("断ち切り型(default)" "丸型" "角型")))
	 (linecap (cond ((or (= emnum 2) (= emnum 3))
			 (concat "linecap=" (number-to-string (- emnum 1))))
			(t "")))
	 (option (emath-option-combine "," `(,option ,dash ,yazirusi ,arrowsize
							   ,idou ,linejoin ,mark ,linecap))))
    (concat option)))
(defun YaTeX:Drawline ()
  (let* ((emop (emath-Drawline-option)))
    (concat (if (string= emop "") ""
	      (concat "<" emop ">"))
	    "{" (read-string "折れ線を作る点列: ") "}%")))
(defun YaTeX:Drawlines ()
  (let* ((emop (emath-Drawline-option)))
    (concat (if (string= emop "") ""
	      (concat "<" emop ">"))
	    "{" (emath-tenretu-loop ";" "折れ線を作る点列") "}%")))
(defun YaTeX:Bousin ()
  (concat (read-string "頂点1: ")
	  (read-string "頂点2: ")
	  (read-string "頂点3: ")
	  (read-string "中心を保存する制御綴り: ")
	  "%半径が \\lr に保存されます"))
(defun YaTeX:Bousetuen ()
  (concat (read-string "頂点1: ")
	  (read-string "頂点2: ")
	  (read-string "頂点3: ")
	  "%\\vBousin に中心が\n%\\BousetuenHankei に傍心が保存されています"))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; emath-ArrowLine-option             ;;;
;;; allinethckness                           ;;;
;;; arrowsize                                ;;;
;;; putstr HouiShitei + strings              ;;;
;;; putpos:(.5)                              ;;;
;;; Henvi:始点をずらす変移ベクトル                 ;;;
;;; Henvii:終点をずらす変移ベクトル                ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun emath-ArrowLine-option ()
  (let* ((allinethickness (emath-setoption "" "allinethickness" "線分の太さ"))
	 (arrowsize (if (y-or-n-p "[option] 鏃の大きさを変更しますか？: ")
			(concat "arrowsize={" (emath-setarrow t) "}") ""))
	 (Henvi (if (y-or-n-p "[option] 始点の微調整をしますか？: ")
		    (concat "Henvi={"
			    (YaTeX:read-coordinates "[option] [始点の微調整] (x,y): ")
			    "}") ""))
	 (Henvii (if (y-or-n-p "[option] 終点の微調整をしますか？: ")
		     (concat "Henvii={"
			     (YaTeX:read-coordinates "[option] [終点の微調整] (x,y): ")
			     "}") ""))
	 (putstr "")
	 (putpos "")
	 (vecpos ""))
    (progn (if (y-or-n-p "[option] 文字列を配置しますか？: ")
	       (setq putstr (concat "putstr={"
				    (emath-Put-HouiShitei)
				    "{" (read-string "[option] 付加する文字列: ")
				    "}}")
		     putpos (read-string "[option] 文字列の配置位置[0-1](.5): ")) "")
	   (if (> (length putpos) 0)
	       (setq putpos (concat "putpos=" putpos)) "")
	   (setq option (emath-option-combine "," `(,allinethickness ,Henvi ,Henvii ,arrowsize ,putstr ,putpos)))
	   (if (> (length option) 0)
	       (insert (concat "<" option ">")) "")
	   (setq vecpos (read-string "[option] 鏃の位置指定(0-1)またはbで両端: "))
	   (if (> (length vecpos) 0)
	       (insert (concat "[" vecpos "]")) ""))))
(defun YaTeX:ArrowLine ()
  (concat (emath-ArrowLine-option)
	  (read-string "ベクトルの始点: ")
	  (read-string "ベクトルの終点: ")))
(defun YaTeX:ArrowLines ()
  (concat (emath-ArrowLine-option)
	  (emath-tenretu-loop ";" "ベクトルの始点と終点")))
;\emPaint<#1>#2
;多角形の頂点列を与えて，多角形を塗りつぶします。
;    #1: key=val
;         border:多角形の周も描画します。
;         bordercolor:周を塗る色を指定します。
;         borderthickness:周の太さを指定します。
;         paintcolor:塗りの色を指定します。
;         thickness:塗りつぶしの濃度を指定します。
;                   0～1 の無名数で，0 は白，1は黒で，デフォルト値は 0.5 となっています。
;    #2: 多角形の頂点列（閉じていなくても，終点と始点を結ぶパスが付加され，閉多角形となります）
(defun emath-emPaint-paintonly-option ()
  (let* ((emnum (emath-get-number-from-list "[option] 塗り方の指定"
						  `("白黒[濃度指定]" "カラー[色，濃度指定]"
						    "デフォルト(白黒.5)")))
	 (noudo "")
	 (color "")
	 (paint (cond ((= emnum 1) (emath-setoption "" "thickness" "白黒の濃度指定(.5)"))
		      ((= emnum 2) (progn (setq color (read-string "[option] 色の指定: ")
						noudo (read-string 
						       (format "[option] %sの濃度の指定(1): " color)))
					  (concat "paintcolor="
						  (if (> (length noudo) 0)
						      (concat "{<" noudo ">"))
						  color
						  (if (> (length noudo) 0) "}" ""))))
		      (t ""))))
    (concat paint)))
(defun emath-emPaint-option (op)
  (let* ((border (if (y-or-n-p "図形の周も描画しますか？: ")
		     "border" ""))
	 (option (if (> (length border) 0)
		     (emath-setoption "" "bordercolor" "周の色") ""))
	 (borderthickness (if (> (length border) 0)
			      (read-string "周の太さ: ") ""))
	 (borderthickness (if (> (length borderthickness) 0)
			      (concat "borderthickness=" borderthickness) ""))
	 (paintcolor (emath-emPaint-paintonly-option))
	 (option (emath-option-combine "," `(,border ,option ,borderthickness ,paintcolor))))
    (concat option)))
(defun YaTeX:emPaint ()
  (let* ((option (emath-emPaint-option "")))
    (insert (concat (if (> (length option) 0)
			(concat "<" option ">") "")
		    "{" (read-string "多角形を作る点列: ") "}"))))
(fset `YaTeX:Paint `YaTeX:emPaint)
;\emPaint*<#1>#2
;    #1: key=val の形式
;         border:多角形の周を描画します。
;         borderthickness:境界線の太さを指定します。
;        *slashcolor:斜線の色(Wikiには載っていない)
;         slashangle:斜線の角度を指定します。
;         slashspace:斜線の間隔を指定します。
;         slashthickness:斜線の太さを指定します。（デフォルトは 0.3pt）
;    #2: 多角形の頂点列
(defun emath-emPaint*-slashonly-option ()
  (let* ((option (emath-setoption "" "slashcolor" "斜線の色"))
	 (angle (emath-tenretu-loop "," "斜線の角度[入力終了:Enter]"))
	 (angle (if (> (length angle) 0)
		    (concat "slashangle={" angle "}") ""))
	 (option (emath-setoption option "slashspace" "斜線の間隔"))
	 (option (emath-setoption option "slashthickness" "斜線の太さ(.3pt)"))
	 (option (emath-option-combine "," `(,option ,angle))))
    (concat option)))
(defun emath-emPaint*-option (op)
  (let* ((border (if (y-or-n-p "境界を描画しますか？: ")
		     "border" ""))
	 (option (if (> (length border) 0)
		     (emath-setoption "" "borderthickness" "境界の線の太さ") ""))
	 (slash (emath-emPaint*-slashonly-option))
	 (option (emath-option-combine "," `(,op ,border ,option ,slash))))
    (concat option)))
(defun YaTeX:emPaint* ()
  (let* ((option (emath-emPaint*-option "")))
    (insert (concat (if (> (length option) 0)
			(concat "<" option ">") "")
		    "{" (read-string "多角形を作る点列: ") "}"))))
(fset `YaTeX:Paint* `YaTeX:emPaint)
;\DPkukan<#1>#2
;    #1: key=val 形式で有効なキーは
;         kukantakasa:区間の高さを，単位付きの寸法で指定します。
;                     単位が \unitlength の場合は，省略し無名数とすることが出来ます （デフォルト 0.5)。
;         paintoption:\emPaint のオプションを指定します。
;    #2: 区間を | で区切って並べます。
;    区間は
;    　　開区間 : (-3,5)
;    　　閉区間 : [-3,5]
;    　　半開区間 : (-3,5], [-3,5)
;    　　無限区間 : (,-3), (5,)
;    などと表す。
;    2つの区間の和集合は (,-3)|(5,) などのように，`|'を用いる
(defun YaTeX:DPkukan ()
  (let* ((kukantakasa (emath-setoption "" "kukantakasa" "区間の高さ[単位付き数値も可](.5)")))
    (progn (emath-emPaint-option kukantakasa)
	   (insert (concat "{" (emath-tenretu-loop "|" "区間の指定") "}")))))
(defun YaTeX:igenpou ()
  (concat (let ((option (read-string "[option] 変数がx以外のとき，文字を指定して下さい: ")))
	    (if (string= option "") ()
	      (concat "[" option "]")))
	  (if (y-or-n-p "[option] 問題のみを表示しますか?")
	      "<M>" "")
	  "{" (read-string "整式1の係数(コンマ区切り): ") "}"
	  "{" (read-string "整式2の係数(コンマ区切り): ") "}%"))
(fset 'YaTeX:ikahou 'YaTeX:igenpou)
(defun YaTeX:defcsvfunc ()
  (concat (if (y-or-n-p "[option] 降べきの順ですか?") "" "[r]")
	  (read-string "関数名: ")
	  "{" (read-string "関数の係数列(コンマ区切り)") "}"))
;\Taisyouten#1#2#3[#4]#5
;    #1 : 点
;    #2, #3 : 直線上の2点
;    #4 : 点対称の中心を受け取る制御綴
;    #5 : 求める対称点を受け取る制御綴
;\mTaisyouten#1#2#3[#4]#5
;    #1 : 点
;    #2 : 直線上の1点
;    #3 : 直線の方向ベクトル
;    #4 : 点対称の中心を受け取る制御綴
;    #5 : 求める対称点を受け取る制御綴
;\kTaisyouten#1#2#3[#4]#5
;    #1 : 点
;    #2 : 直線上の1点
;    #3 : 直線の方向角（度数法）
;    #4 : 点対称の中心を受け取る制御綴
;    #5 : 求める対称点を受け取る制御綴
(defun emath-Taisyouten-common (num)
  (let* ((pre (concat "{" (read-string "対称移動させる点: ") "}"
		      (cond ((= num 1) (concat "{" (read-string "直線の通過点1: ") "}"
					       "{" (read-string "直線の通過点2: ") "}"))
			    ((= num 2) (concat "{" (read-string "直線の通過点: ") "}"
					       "{" (read-string "直線の方向ベクトル: ") "}"))
			    ((= num 3) (concat "{" (read-string "直線の通過点: ") "}"
					       "{" (read-string "直線の方向角: ") "}"))
			    (t ""))))
	 (option (read-string "[option] 対称の中心の座標を受け取る制御綴り: "))
	 (option (if (> (length option) 0)
		     (concat "[" option "]") ""))
	 (post (read-string "対称点を受け取る制御綴り: ")))
    (concat pre option post)))
(defun emath-Taisyouten-common (num)
  (progn (insert (concat "{" (read-string "対象移動させる点: ") "}"
			 (cond ((= num 1) (concat "{" (read-string "直線の通過点1: ") "}"
						 "{" (read-string "直線の通過点2: ") "}"))
			       ((= num 2) (concat "{" (read-string "直線の通過点: ") "}"
						 "{" (read-string "直線の方向ベクトル: ") "}"))
			       ((= num 3) (concat "{" (read-string "直線の通過点: ") "}"
						 "{" (read-string "直線の方向角: ") "}"))
			       (t ""))))
	 (let* option (read-string "対称の中心の座標を受け取る制御綴り: ")
	       option (if (> (length option) 0)
			  (concat "[" option "]") ""))
	 (insert (concat option
			 (read-string "求める対称点を受け取る制御綴り: ")))))
(defun YaTeX:Taisyouten ()
  (insert (emath-Taisyouten-common 1)))
(defun YaTeX:mTaisyouten ()
  (insert (emath-Taisyouten-common 2)))
(defun YaTeX:kTaisyouten ()
  (insert (emath-Taisyouten-common 3)))
(defun YaTeX:mawarikomi ()
  (let* ((emstopline (read-string "[option] 段落当初の回り込みをしない行数の指定: "))
	 (emallline (read-string "[option] 回り込みをする行数[num,+num,-num](numの先頭に\"l\"を付加すると図を左に配置する): "))
	 (emnum (emath-get-number-from-list "[option] 図を移動させる修正ベクトル" `("設定しない(default)" "設定する")))
	 (emvec (cond ((= emnum 2) (YaTeX:read-coordinates "[option] 修正ベクトルの設定[要単位](dx,dy): " "dx" "dy"))
		      (t "")))
	 (emlength (read-string "図の横幅(省略可): ")))
    (concat (if (string= emstopline "") ""
	      (concat "<" emstopline ">"))
	    (if (string= emallline "") ""
	      (concat "[" emallline "]"))
	    emvec
	    "{" emlength "}{%\t環境or図の挿入部\n"
	    "\t\t\n\t}%\n"
	    "%\\EMWRlinewidth=テキスト部分の横幅\n"
	    "%\\mawarikomisep=テキストと図の間隔(2pt)")))
(fset 'YaTeX:Fmawarikomi 'YaTeX:mawarikomi)
(fset 'YaTeX:Tmawarikomi 'YaTeX:mawarikomi)
(fset 'YaTeX:Pmawarikomi 'YaTeX:mawarikomi)
(defun YaTeX:yakubun ()
  (concat (YaTeX:read-position "sr")
	  (let ((color (read-string "線の色 or [RET]: ")))
	    (if (string= color "") ""
	      (concat "(" color ")")))
	  (let ((position (read-string "位置指定(c:(default)中央上下,l:左肩,r:右肩) or [RET]: ")))
	    (if (string= position "") ""
	      (concat "<" position ">")))
	  "{" (read-string "約分前分子: ") "}{"
	  (read-string "約分前分母: ") "}{"
	  (read-string "約分後分子: ") "}{"
	  (read-string "約分後分母: ") "}"))
(defun YaTeX:teisei ()
  (concat (YaTeX:read-position "srhd")
	  (let ((color (read-string "線の色 or [RET]: ")))
	    (if (string= color "") ""
	      (concat "(" color ")")))
	  (read-string "対象: ")
	  (let ((after (read-string "訂正後 or [RET]: ")))
	    (if (string= after "") ""
	      (concat "[" after "]")))))
(defun YaTeX:Ifor ()
  (concat "{" (read-string "iに代わるコントロールシーケンス: ") "}"
	  "{" (read-string "iの初期値: ") "}"
	  "{" (read-string "iの制限値: ") "}"
	  (let ((skip (read-string "iの刻み値 or [RET](default:1): ")))
	    (if (string= skip "") ""
	      (concat "[" skip "]")))
	  "\\Do{%\n\t" (read-string "実行式: ") "}"))
(defun YaTeX:Cfor ()
  (concat "{" (read-string "初期条件: ") "}"
	  "{" (read-string "継続条件(\\ifthenelseの書式): ") "}"
	  "{" (read-string "再設定: ") "}"
	  "\\do{" (read-string "ループ本体: ") "}"))
(defun YaTeX:azahyou ()
  (concat (let ((genten (read-string "原点指定 or [RET](default (0,0)): ")))
	    (if (string= genten "") ""
	      (concat "[" genten "]")))
	  (read-string "e_x: ")
	  (read-string "e_y: ")))
(defun YaTeX:itembox ()
  (concat (let ((option (YaTeX:read-position "rcl")))
	    (if (string= option "") ""
	      (concat option)))
          "{" (read-string "Item heading string: ") "}"))
(defun YaTeX:itemtopmath ()
  (let* ((op2 (read-string "[option] big operatorがあればそれを設定する: "))
	 (op1 (read-string "[option] 微調整量の指定(要単位\"+\"で上\"-\"で下に移動する): ")))
    (concat (if (string= op1 "") ""
	      (concat "<" op1 ">"))
	    (if (string= op2 "") ""
	      (concat "[" op2 "]")))))
(defun YaTeX:nagarezu ()
  (concat (YaTeX:read-coordinates "流れ図の大きさ (width,height): ")
	  (if (y-or-n-p "原点の位置を修正しますか？")
	      (YaTeX:read-coordinates "[option] 環境左上からの原点の位置 (x,y): ") "")
	  "%"))
(defun YaTeX:termbox ()
  (let* ((emop (read-string "[option] 塗りつぶしの濃さ(0): ")))
    (concat (if (> (length emop) 0)
		(concat "[" emop "]") "")
	    "{" (read-string "記述文字列: ") "}%")))
(fset 'YaTeX:tansi 'YaTeX:termbox)
(defun YaTeX:downto ()
  (let* ((emlabel-default (mapconcat 'concat
				     (split-string (file-name-sans-extension
						    (file-name-nondirectory (buffer-file-name))) "-" t)
				     ":"))
	 (emnum (emath-get-number-from-list "[option]"
						  `("矢印をつける(default)" "矢印なし" "逆方向" "二重線")))
	 (emarrowop (cond ((= emnum 1) "a")
			  ((= emnum 2) "n")
			  ((= emnum 3) "r")
			  ((= emnum 4) "w")))
	 (emarrow-length (read-string "[option] 矢印の長さ(20pt): "))
	 (emlabel (if (y-or-n-p "ラベルの設定をしますか？")
		      (read-string "[option] 設定ラベル名: " emlabel-default) ""))
	 (emupstrings (read-string "[option] 矢線の上または左に置く文字列: "))
	 (emdowmstrings (read-string "[option] 矢線の下または右に置く文字列: "))
	 (emref (if (y-or-n-p "参照先のラベルの設定をしますか？")
		    (read-string "[option] 参照先のラベル名: " emlabel-default) "")))
    (concat (if (> (length emarrowop) 0)
		(concat "<" emarrowop ">") "")
	    (if (> (length emarrow-length) 0)
		(concat "(" emarrow-length ")") "")
	    (if (> (length emlabel) 0)
		(concat "[" emlabel "]") "")
	    (if (> (length emupstrings) 0)
		(concat "\"" emupstrings "\"") "")
	    (if (> (length emdowmstrings) 0)
		(concat "\"" emdowmstrings "\"") "")
	    (if (> (length emref) 0)
		(concat "`" emref "'") "")
	    "%")))
(fset 'YaTeX:shitahe 'YaTeX:downto)
(fset 'YaTeX:migihe 'YaTeX:downto)
(fset 'YaTeX:rightto 'YaTeX:downto)
(fset 'YaTeX:hidarihe 'YaTeX:downto)
(fset 'YaTeX:leftto 'YaTeX:downto)
(fset 'YaTeX:uehe 'YaTeX:downto)
(fset 'YaTeX:upto 'YaTeX:downto)
(defun YaTeX:ifbox ()
  (let* ((emnuri (read-string "[option] 塗りつぶしの濃さ(0): "))
	 (emwidth (read-string "[option] 横方向の伸縮率(1): "))
	 (emheight (read-string "[option] 縦方向の伸縮率(1): "))
	 (emnum (emath-get-number-from-list "" `("右に分岐" "左に分岐") "分岐方向の設定")))
    (concat (if (> (length emnuri) 0)
		(concat "[" emnuri "]") "")
	    (if (> (length emwidth) 0)
		(concat "<" emwidth ">") "")
	    (if (> (length emheight) 0)
		(concat "<" emheight ">") "")
	    "{" (read-string "判断記号内の文字列: " "\\strut") "}%\n"
	    "\t\\begin{branch}{"
	    (cond ((= emnum 1) "r")
		  ((= emnum 2) "l"))
	    "}\n"
	    "\t\\end{branch}\n"
	    "\t\\begin{branch}{d}\n"
	    "\t\\end{branch}")))
(fset 'YaTeX:handan 'YaTeX:ifbox)
(defun YaTeX:repbox ()
  (let* ((emnuri (read-string "[option] 塗りつぶしの濃さ(0): "))
	 (emwidth (read-string "[option] 横幅の設定: ")))
    (concat (if (> (length emnuri) 0)
		(concat "[" emnuri "]") "")
	    (if (> (length emwidth) 0)
		(concat "(" emwidth ")") "")
	    "{" (read-string "初めのボックス内の文字列: ") "}"
	    "{" (read-string "終わりのボックス内の文字列: ") "}%")))
(fset 'YaTeX:kurikaesi 'YaTeX:repbox)
(fset 'YaTeX:repbox* 'YaTeX:repbox)
(fset 'YaTeX:kurikaesi* 'YaTeX:repbox)
(defun YaTeX:jquote ()
  (let* ((emop (emath-setoption "" "tsep" "直前の段落との間隔調整量"))
	 (emop (emath-setoption emop "bsep" "直後の段落との間隔調整量"))
	 (emleft (read-string "右インデント量(2zw): "))
	 (emright (read-string "左インデント量(0pt): ")))
    (concat (if (> (length emop) 0)
		(concat "<" emop ">") "")
	    (if (> (length emright) 0)
		(if (= (length emleft) 0)
		    (concat "(2zw)(" emright ")")
		  (concat "(" emleft ")(" emright ")"))
	      (if (> (length emleft) 0)
		  (concat "(" emleft ")") "")))))
(fset 'YaTeX:jqoutation 'YaTeX:jquote)
;\Psyndiv<#1>#2#3
;    #1: key=val 形式
;         order:文字係数部における項の順序を指定します。
;         soroe:array環境の列配置 (l/c/r) を指定します。
;    #2: 被除式の係数を項べき順にコンマ区切りで並べます。
;    #3: 除式のゼロ点
(defun YaTeX:Psyndiv ()
  (let* ((option (emath-setoption "" "soroe" "項の揃え方[lcr](l)"))
	 (option (emath-setoption option "order" "余りの項の並べ方の指定")))
    (insert (concat (if (string= option "")
			"" (concat "<" option ">"))
		    "{" (emath-tenretu-loop "," "被除式の係数") "}"
		    "{" (read-string "除式のゼロ点: ") "}%"))))
;\begin{clipTakakkei}<#1>#2
;　　.....
;\end{clipTakakkei}
;    #1: key=val
;    #2: 多角形
(defun YaTeX:clipTakakkei ()
  (concat (if (y-or-n-p "描画領域を多角形の外部にしますか？: ")
	      "<hosyugo>" "")
	  "{" (read-string "多角形を表す点列: ") "}%"))
;\begin{clipLline}<#1>#2#3
;.....
;\end{clipLline}
;        #1: key=val
;             hosyugo:描画領域を，直線で二分された領域の下方（直線が鉛直の場合は左方）
;        #2, #3: 直線上の２点
(defun YaTeX:clipLline ()
  (concat (if (y-or-n-p "描画領域を直線の下方[直線がx=aの場合は左方]にしますか？: ")
	      "<hosyugo>" "")
	  "{" (read-string "通過点1: ") "}"
	  "{" (read-string "通過点2: ") "}%"))
;\begin{cliplline}<#1>#2#3
;  .....
;\end{cliplline}
;    #1: key=val
;    #2: 直線上の１点
;    #3: 直線の方向ベクトル
(defun YaTeX:cliplline ()
  (concat (if (y-or-n-p "描画領域を直線の下方[直線がx=aの場合は左方]にしますか？: ")
	      "<hosyugo>" "")
	  "{" (read-string "通過点: ") "}"
	  "{" (read-string "方向ベクトル: ") "}%"))
;\begin{clipkline}<#1>#2#3
;  .....
;\end{clipkline}
;    #1: key=val
;    #2: 直線上の１点
;    #3: 直線の方向角
(defun YaTeX:clipkline ()
  (concat (if (y-or-n-p "描画領域を直線の下方[直線がx=aの場合は左方]にしますか？: ")
	      "<hosyugo>" "")
	  "{" (read-string "通過点: ") "}"
	  "{" (read-string "方向角: ") "}%"))
;\begin{clipgline}<#1>#2#3
;  .....
;\end{clipgline}
;    #1: key=val
;    #2: 直線上の１点
;    #3: 直線の傾き
(defun YaTeX:clipgline ()
  (concat (if (y-or-n-p "描画領域を直線の下方[直線がx=aの場合は左方]にしますか？: ")
	      "<hosyugo>" "")
	  "{" (read-string "通過点: ") "}"
	  "{" (read-string "傾き: ") "}%"))
;\begin{clipxrange}<#1>#2
;  .....
;\end{clipxrange}
;    #1: key=val
;    #2: x の区間
(defun YaTeX:clipxrange ()
  (concat (if (y-or-n-p "描画領域を指定区間の外側にしますか？: ")
	      "<hosyugo>" "")
	  "{" (read-string "横軸の区間の指定: ") "}%"))
;\begin{clipyrange}<#1>#2
;  .....
;\end{clipyrange}
;    #1: key=val
;    #2: x の区間
(defun YaTeX:clipyrange ()
  (concat (if (y-or-n-p "描画領域を指定区間の外側にしますか？: ")
	      "<hosyugo>" "")
	  "{" (read-string "縦軸の区間の指定: ") "}%"))
;\begin{clipEn}<#1>#2#3
;　　.....
;\end{clipEn}
;    #1: key=val で，有効なキーは
;         hosyugo:描画領域を円の外部に限定します。
;    #2: 円の中心
;    #3: 円の半径
(defun YaTeX:clipEn ()
  (let* ((option (if (y-or-n-p "描画領域を円の外部にしますか？: ")
		     "<hosyugo>" "")))
    (concat option
	    (emath-En-body))))
;\begin{clipDaen}<#1>#2#3#4
;　　.....
;\end{clipDaen}
;    #1: key=val で，有効なキーは
;         hosyugo:描画領域を円の外部に限定します。
;    #2: 楕円の中心
;    #3: 楕円の x軸方向の半径
;    #4: 楕円の y軸方向の半径
(defun YaTeX:clipDaen ()
  (let* ((option (if (y-or-n-p "描画領域を楕円の外部にしますか？: ")
		     "<hosyugo>" "")))
    (concat option
	    (emath-Daen-body))))
;\clipQfunc<#1>#2
;    #1: key=val
;         hosyugo:デフォルトでは放物線の上方を指定しますが，このオプションをつけた場合は下方を指定します。
;    #2: 二次関数式
(defun YaTeX:clipQfunc ()
  (let* ((option (if (y-or-n-p "描画領域を2次関数の下方にしますか？: ")
		     "<hosyugo>" "")))
    (concat option
	    "{" (read-string "2次関数を表す式: ") "}%")))
(defun YaTeX:clipSyougen ()
  (concat "{" (read-string "描画する象限の指定: ") "}%"))
;\csvQandL#1#2[#3]#4[#5]#6
;    #1: 二次関数の係数csv列（降べき順）
;    #2: 一次関数の係数csv列（降べき順）
;    #3: 交点１のx座標を取得する制御綴
;    #4: 交点１を取得する制御綴
;    #5: 交点２のx座標を取得する制御綴
;    #6: 交点２を取得する制御綴
(defun YaTeX:csvQandL ()
  (let* ((option ""))
    (insert (concat "{" (read-string "2次関数の係数列[降べきの順]: ") "}"
		    "{" (read-string "1次関数の係数列[降べきの順]: ") "}")
	    (setq option (read-string "[option] 交点1のx座標を受け取る制御綴り: "))
	    (if (> (length option) 0)
		(concat "[" option "]") "")
	    (concat "{" (read-string "交点1を受け取る制御綴り: ") "}")
	    (setq option (read-string "[option] 交点2のx座標を受け取る制御綴り: "))
	    (if (> (length option) 0)
		(concat "[" option "]") "")
	    (concat "{" (read-string "交点2を受け取る制御綴り: ") "}%"))))
;\defcsvfunc[#1]<#2>#3#4
;    #1 : オプション引数で，#3の係数列の順序を
;    　　　　無指定の場合，降冪順
;    　　　　[r] とした場合，昇冪順
;    　　とみなします。
;    #2 : key=val
;    #3 : 関数名（制御綴）
;    #4 : コンマ区切り係数列
(defun YaTeX:defcsvfunc ()
  (let ((numrule (emath-get-number-from-list "[option] 係数列の順序" `("降べき(defalut)" "昇べき")))
	(numcsv (emath-get-number-from-list "[option] CSV列の取得" `("する" "しない"))))
    (insert (concat (cond ((= numrule 2) "[r]")
			  (t ""))
		    (cond ((= numcsv 1) "<csv>")
			  (t ""))
		    (read-string "定義する関数の制御綴り: ")
		    "{" (emath-tenretu-loop "," "各係数の設定[入力終了:Enter]") "}%"))))
;\emcancel<#1>#2
;    #1: key=val
;         linethickness: 取消線の太さ
;         color: 取消線の色（iro も同義）
;         direction : 取消線の方向を指定します。（houkou も同義）
;            s: 斜線（／）slash [デフォルト]
;            b: 斜線（＼）back slash （r も同義）
;            h: 水平線
;            x: クロス
;         correct: 訂正文字列を与えます。（teisei も同義）
;    #2: 線を引く対象
(defun YaTeX:emcancel ()
  (let* ((option (emath-setoption "" "linethickness" "取り消し線の太さの指定"))
	 (option (emath-setoption option "color" "色の指定"))
	 (emnum (emath-get-number-from-list "[option] 取り消し線の方向指定" `("斜線[／](defalut)" "斜線[＼]" "水平線" "クロス")))
	 (setline (cond ((= emnum 2) "direction=b")
			((= emnum 3) "direction=h")
			((= emnum 4) "direction=x")
			(t "")))
	 (option (emath-setoption option "correct" "訂正文字列の指定"))
	 (option (emath-option-combine "," `(,option ,setline))))
    (insert (concat (if (> (length option) 0)
			(concat "<" option ">") "")
		    "{" (read-string "取り消し線を引く文字列: ") "}"))))
;\edefiihairetu#1#2#3#4
;    配列#1 の[#2,#3]番目の要素を定義します。
;        #1: 配列名
;        #2: 要素番号1
;        #3: 要素番号2
;        #4: 要素
(defun YaTeX:edefiihairetu ()
  (let* ((name (read-string "配列名: "))
	 (rownum (read-string "行番号: "))
	 (colnum (read-string "列番号: "))
	 (item (read-string (format "%s行%s列のアイテム: " rownum colnum))))
    (insert (concat "{" name "}"
		    "{" rownum "}"
		    "{" colnum "}"
		    "{" item "}%"))))
;\iihairetu#1#2#3
;    配列#1 の[#2,#3]番目の要素を表します。
;        #1: 配列名
;        #2: 要素番号1
;        #3: 要素番号2
(defun YaTeX:iihairetu ()
  (insert (concat "{" (read-string "配列名: ") "}"
		  "{" (read-string "行番号: ") "}"
		  "{" (read-string "列番号: ") "}%")))
;\gyouretuiihairetu#1#2
;    配列#1 の要素を #2 に示す tabular環境と類似の書式で一括定義します。
(defun emath-make-matrix (rowsep colsep &optional addguide)
  (let* ((rowitem "")
	 (colitem "")
	 (item "")
	 (rownum 0)
	 (colnum 0)
	 (rowmax (read-number "最大行数: "))
	 (colmax (read-number "最大列数: ")))
    (progn (while (> rowmax rownum)
	     (setq rownum (+ rownum 1))
	     (while (> colmax colnum)
	       (setq colnum (+ colnum 1)
		     item (read-string (format "%s%d行%d列のアイテム: " (if addguide addguide "") rownum colnum))
		     colitem (emath-option-combine colsep `(,colitem ,item))))
	     (setq rowitem (emath-option-combine (concat rowsep "%\n\t") `(,rowitem ,colitem))
		   colnum 0
		   colitem ""))
	   (concat "{" rowitem "}%"))))
(defun YaTeX:gyouretuiihairetu ()
  (let* ((rowsep (read-string "[option] 行のセパレータ(;): "))
	 (colsep (read-string "[option] 列のセパレータ(,): "))
	 (item ""))
    (if (or (= (length rowsep) 0) (= (length colsep) 0))
	(concat "%%%%% セパレータを指定するときは両方指定してください %%%%%")
      (progn (if (> (length rowsep) 0)
		 (concat "[" rowsep "]")
	       (setq rowsep ";"))
	     (if (> (length colsep) 0)
		 (concat "[" colsep "]")
	       (setq colsep ","))
	     (setq item (emath-make-matrix rowsep colsep "配列要素の指定 "))
	     (concat item)))))
;\naikaku<#1>#2#3#4#5
;    #1: perl を指定したときは，計算に perl を用います。（要：emathPp）
;    #2,#3,#4: 三角形の3つの頂点
;    #5: △#2#3#4 の内角#3 の大きさ（度数法）を受け取る制御綴
(defun YaTeX:naikaku ()
  (insert (concat (if (y-or-n-p "Perlと連携しますか？: ")
		      "<perl>" "")
		  "{" (read-string "点1: ") "}"
		  "{" (read-string "点2: ") "}"
		  "{" (read-string "点3: ") "}"
		  (read-string "内角の大きさを受け取る制御綴り: "))))
(defun emath-teisuuretu-loop ()
  (let* ((item "")
	 (allitem "")
	 (csname ""))
    (concat (while
		(progn
		  (setq csname (read-string "制御綴り名: "))
		  (if (> (length csname) 0)
		      (progn (setq item (emath-setoption "" csname "定数値")
				   allitem (emath-option-combine ";" `(,allitem ,item))
				   item "")) nil)))
	    allitem)))
(defun YaTeX:teisuuretu ()
  (let* ((perl (if (y-or-n-p "Perlと連携しますか？: ")
		   "<perl>" "")))
    (insert (concat perl
		    "{" (emath-teisuuretu-loop) "}%"))))
(defun YaTeX:perlteisuuretu ()
  (insert (concat "{" (emath-teisuuretu-loop) "}%")))
(defun YaTeX:pscirc ()
  (let* ((option (emath-drawline-option))
	 (option (emath-setoption option "size" "円の半径(2pt)"))
	 (option (if (> (length option) 0)
		     (concat "<" option ">") "")))
    (insert option)))
(defun YaTeX:pscirc* ()
  (let* ((option (emath-emPaint-option ""))
	 (option (emath-setoption option "size" "円の半径(2pt)"))
	 (option (if (> (length option) 0)
		     (concat "<" option ">") "")))
    (insert option)))
(defun YaTeX:pssquare ()
  (let* ((option (emath-drawline-option))
	 (option (emath-setoption option "size" "正方形の外接円の半径"))
	 (option (if (> (length option) 0)
		     (concat "<" option ">") "")))
    (insert option)))
(defun YaTeX:pssquare* ()
  (let* ((option (emath-emPaint-option ""))
	 (option (emath-setoption option "size" "正方形の外接円の半径"))
	 (option (if (> (length option) 0)
		     (concat "<" option ">") "")))
    (insert option)))
(defun YaTeX:pstriangle ()
  (let* ((option (emath-drawline-option))
	 (option (emath-setoption option "size" "正三角形の外接円の半径"))
	 (option (if (> (length option) 0)
		     (concat "<" option ">") "")))
    (insert option)))
(defun YaTeX:pstriangle* ()
  (let* ((option (emath-emPaint-option ""))
	 (option (emath-setoption option "size" "正三角形の外接円の半径"))
	 (option (if (> (length option) 0)
		     (concat "<" option ">") "")))
    (insert option)))
;\pstouhenkigou<#1>#2
;    #1: key=val 形式で，有効なキーは
;         linethickness:記号を描画する線の太さを指定します。
;         kosuu:一つの辺に配置する記号の個数を指定します。
;         *kankaku:2つ以上の記号の間隔を指定(pstouhenkigouでは定義されていない)
;         size:記号の大きさを指定します。
;         kigou:配置する記号を出力するコマンド名を指定します。
;         kigouopt:記号を出力するコマンドに対するオプションを指定します。
;         *putpos:記号を配置する場所の指定
;    #2: 線分列（区切子は`;'）
(defun emath-pstouhen-option ()
  (let* ((kosuu "")
	 (kankaku "")
	 (emnum (emath-get-number-from-list "[option] 記号の設定"
						  `("\\pscirc" "\\pssquare" "\\pstriangle"
						    "\\pscirc*" "\\pssquare*" "\\pstriangle*"
						    "他の記号" "設定しない")))
	 (kigou (cond ((= emnum 1) "kigou=\\pscirc")
		      ((= emnum 2) "kigou=\\pssquare")
		      ((= emnum 3) "kigou=\\pstriangle")
		      ((= emnum 4) "kigou=\\pscirc*")
		      ((= emnum 5) "kigou=\\pssquare*")
		      ((= emnum 6) "kigou=\\pstriangle*")
		      ((= emnum 7) (read-string "出力記号: "))
		      (t "")))
	 (kigouopt (if (and (> emnum 0) (< emnum 8))
		       (if (y-or-n-p "オプションを設定しますか？: ")
			   (cond ((and (> emnum 0) (< emnum 4))
				  (concat "kigouopt={" (emath-drawline-option) "}"))
				 ((and (> emnum 3) (< emnum 7))
				  (concat "kigouopt={" (emath-emPaint-option "") "}"))
				 (t (concat "kigouopt={" (read-string "[option] 出力記号のオプション設定: ") "}"))) "")))
	 (option (emath-option-combine "," `(,kigou ,kigouopt))))
    (progn (if (> (length option) 0) ""
	     (setq option (emath-setoption "" "linethickness" "線の太さ")
		   emnum (read-number "[option] 記号の個数[1-3](1): ")
		   kosuu (if (and (> emnum 1) (< emnum 4))
				  (concat "kosuu=" (number-to-string emnum)) "")
;		   kankaku (if (and (> emnum 1) (< emnum 4))
;			       (read-string "[option] 記号同士の間隔: ") "")
;		   kankaku (if (> (length kankaku) 0)
;			       (concat "kankaku=" kankaku) "")
		   option (emath-setoption option "size" "記号のサイズ(3pt)")
		   option (emath-option-combine "," `(,option ,kosuu ,kankaku))))
	   (setq option (emath-setoption option "putpos" "記号の配置場所[0:始点 1:終点](.5)"))
	   (concat option))))
(defun YaTeX:pstouhenkigou ()
  (let* ((option (emath-pstouhen-option)))
    (insert (concat (if (> (length option) 0)
			(concat "<" option ">") "")
		    "{" (emath-tenretu-loop ";" "記号を配置する線分[入力終了:Enter]") "}%"))))
(defun YaTeX:pstouhenkokigou ()
  (let* ((option ()))))
(defun YaTeX:repeatstr ()
  (insert (concat "{" (read-string "文字列: ") "}"
		  "{" (read-string "繰り返し回数: ") "}%")))
(defun YaTeX:seitakakkei ()
  (let* ((option (emath-EnkoToubun-option)))
    (insert (concat (if (> (length option) 0)
			(concat "<" option ">"))
		    "{" (read-string "有向線分の始点: ") "}"
		    "{" (read-string "有向線分の終点: ") "}"
		    "{" (read-string "頂点数: ") "}"
		    "{" (read-string "頂点の名前: ") "}%"))))
;\xykaisasuuretu<#1>#2
;    #1: key=val 形式で，有効なキーは
;         midasi:各数列の左端につける見出しを指定します。
;         nextoption:\EMxymatrix に引き継ぐオプション引数を指定します。
;    #2: 原数列;第一階差数列;第二階差数列;......
;    と，数列をセミコロン(;)区切で列記し，各数列は
;    　　a,b,c,....
;    とコンマ(,)区切の csv列で与えます。
(defun YaTeX:xykaisasuuretu ()
  (let* ((emcnt 0)
	 (option (emath-EMxymatrix-option))
	 (sqmax (+ (read-number "第何階差まで表示しますか？: ") 1))
	 (item "")
	 (midasi "")
	 (sqs ""))
    (progn (while (> sqmax emcnt)
	     (setq item (read-string (format "%s数列の見出し指定: "
					     (if (= emcnt 0) "原"
					       (concat "第" (number-to-string emcnt) "階差"))))
		   midasi (emath-option-combine "," `(,midasi ,item))
		   emcnt (+ emcnt 1)))
	   (setq emcnt 0
		 midasi (if (> (length midasi) 0)
			    (concat "midasi={" midasi "}") "")
		 option (emath-option-combine "," `(,option ,midasi)))
	   (while (> sqmax emcnt)
	     (setq item (read-string (format "%s数列の指定: "
					     (if (= emcnt 0) "原"
					       (concat "第" (number-to-string emcnt) "階差"))))
		   sqs (emath-option-combine ";%\n\t" `(,sqs ,item))
		   emcnt (+ emcnt 1)))
	   (insert (concat (if (> (length option) 0)
			       (concat "<" option ">"))
			   "%\n\t{" sqs "}")))))
;\EMxymatrix<#1>#2
;    #1: key=val
;         wa?:矢線の横方向の長さ　（デフォルト値は 3em）
;         ws?:セルの横幅　　　　　（デフォルト値は 1em+\arraycolsep）
;         yul?:y軸方向の\unitlength　（デフォルト値は 2\baselineskip）
;    #2: array環境内の記述に加えて，\ar コマンドでセル間に矢線（複数可）を付加します。
(defun emath-EMxymatrix-option ()
  (let* ((option (emath-setoption "" "wa" "矢線の横方向の長さ(3em)"))
	 (option (emath-setoption option "ws" "セルの横幅(1em+\\arrowcolsep)"))
	 (option (emath-setoption option "yul" "y軸方向の\\unitlength(2\\baselineskip)")))
    (concat option)))
(provide 'for-emath-macro)
