;; 個人用の設定
(defun YaTeX:問題()
  (concat "*"))
;;  (if (y-or-n-p "問題を表示状態しますか？(今は常に`*'を付加する)")
;;      "*" "*"))
(defun YaTeX:解説 ()
  (let* ((ast (if (y-or-n-p "解答・解説を表示状態にしますか？(今は常に`*'を付加する)")
                  "*" "*"))
         (emnum (emath-get-number-from-list "表示文字列" `("解説" "解答"))))
    (concat ast "\n\\noindent"
            (cond ((= emnum 1) "【解説】")
                  ((= emnum 2) "【解答】")
                  (()()))
            "\\par")))
(defun YaTeX:enumerate ()
  (setq enumop "")
  (if (y-or-n-p "レジュームオプションを利用しますか？")
      (if (y-or-n-p "固有名称を利用しますか？")
          (setq enumop (emath-setoption "" "resume" "固有名称の設定"))
        (setq enumop "resume"))
    (setq enumop (emath-setoption "" "start" "番号の初期値")))
  (setq enumop (emath-setoption enumop "series" "固有名称の設定"))
  (if (> (length enumop) 0)
      (concat "[" enumop "]")))
;;(defun YaTeX:enumerate ()
;;  (let* ((emop1 (emath-setoption "" "syokiti" "番号の初期値"))
;;	 (emop1 (emath-setoption emop1 "kizamiti" "番号の刻み値"))
;;	 (emop2 (read-string "[option] 番号のフォーマット: ")))
;;    (concat (if (string= emop1 "") ""
;;	      (concat "<" emop1 ">"))
;;	    (if (string= emop2 "") ""
;;	      (concat "[" emop2 "]")))))
(defun YaTeX:music ()
  (concat "\n \\startextract\n\n \\endextract"))
;;braces braceupper=()の上げ幅(default:0pt)
;;       bracemag=()の倍率(default:1)
;;       display=()をどこにつけるか[rl](default:)
;;       upper=全体の上げ幅(default:0pt)
(defun YaTeX:braces ()
  (if (y-or-n-p "オプションを設定しますか？")
      (let* ((emop (emath-setoption "" "braceupper" "括弧の上げ幅(0pt)"))
             (emop (emath-setoption emop "bracemag" "括弧の倍率(1)"))
             (emop (emath-setoption emop "display" "括弧の表示[rl]"))
             (emop (emath-setoption emop "upper" "全体の上げ幅(0pt)")))
        (if (string= emop "") ""
          (concat "[" emop "]")))
    ""))
(fset 'YaTeX:parentheses 'YaTeX:braces)
(fset 'YaTeX:brackets 'YaTeX:braces)
(fset 'YaTeX:paren 'YaTeX:braces)
(fset 'YaTeX:Ex 'YaTeX:enumerate)
(fset 'YaTeX:Renshu 'YaTeX:enumerate)
;; No thickness=罫線の太さ(1pt)
;;    widthmag=幅の倍率(1)
;;    hyphenwidth=ハイフンの長さ(2.5mm)
;;    boxwidth=章・問題番号の幅(1.375zw)
;; \No[option]{章番号}{問題番号}
(defun YaTeX:No ()
  (if (y-or-n-p "オプションを設定しますか？")
      (let* ((emop (emath-setoption "" "thickness" "罫線の太さ(1pt)"))
             (emop (emath-setoption emop "widthmag" "幅の倍率(1)"))
             (emop (emath-setoption emop "hyphenwidth" "ハイフンの長さ(2.5mm)"))
             (emop (emath-setoption emop "boxwidth" "章・問題番号の幅(1.375zw)")))
        (if (string= emop "") ""
          (insert (concat "[" emop "]")))) "")
  (concat "{" (read-string "章番号: ") "}{"
          (read-string "問題番号: ") "}"))
;; option は \No と同じ
;; Number は勝手にインクリメントして番号設定する
(defun YaTeX:Number ()
  (if (y-or-n-p "オプションを設定しますか？")
      (let* ((emop (emath-setoption "" "thickness" "罫線の太さ(1pt)"))
             (emop (emath-setoption emop "widthmag" "幅の倍率(1)"))
             (emop (emath-setoption emop "hyphenwidth" "ハイフンの長さ(2.5mm)"))
             (emop (emath-setoption emop "boxwidth" "章・問題番号の幅(1.375zw)")))
        (if (string= emop "") ""
          (concat "[" emop "]%"))) ""))
(fset 'YaTeX:Number* 'YaTeX:Number)
;; \Fbox[option]{}:section系コマンド
;; linewidth=線の幅(.4pt)
;; xspc=横方向の本文との空白(2pt)
;; yspc=縦方向の本文との空白(2pt)
;; display=[lr]縦線の表示()
;; width=箱の横幅()
;; pos=[rcl]文字列の配置()
;; strutheight=支柱の高さ(0pt)
;; strutdepth=支柱の深さ(0pt)
;; strutwidth=支柱の幅(0pt)
(defun YaTeX:Fbox ()
  (if (y-or-n-p "オプションを設定しますか？")
      (let* ((emop (emath-setoption "" "linewidth" "線の太さ(.4pt)"))
             (emop (emath-setoption emop "xspc" "縦罫と本文との空白(2pt)"))
             (emop (emath-setoption emop "yspc" "横罫と本文との空白(2pt)"))
             (emop (emath-setoption emop "display" "縦罫の表示位置[lr]"))
             (emop (emath-setoption emop "width" "箱の横幅"))
             (emop (emath-setoption emop "pos" "文字列の配置[lcr]"))
             (emop (emath-setoption emop "strutheight" "支柱の高さ(0pt)"))
             (emop (emath-setoption emop "strutdepth" "支柱の深さ(0pt)"))
             (emop (emath-setoption emop "strutwidth" "支柱の幅(0pt)"))
             (temp (read-string "支柱の幅(0pt): ")))
        (if (string= emop "") ""
          (concat "[" emop "]"))) ""))
;;% \FboxLine : 線の幅 .4pt
;;% \FboxXSpc : 線と文字の間隔(横方向) 2pt
;;% \FboxYSpc : 線と文字の間隔(縦方向) 2pt
;;% \SpcFbox[#1]{#2}
;;% #1:options
;;% options:linewidth=線の幅(.4pt),xspc=横方向の空白(2pt),
;;%        :yspc=縦方向の空白(2pt),display=縦線の表示・非表示[rl],
;;%        :width=箱の横幅,pos=width指定時の文字の位置[rcl](c),
;;%        :upperspace=文字の上部の空白(8pt),lowerspace=文字の下部の空白(8pt)
(defun YaTeX:SpcFbox ()
  (if (y-or-n-p "オプションを設定しますか？")
      (let* ((emop (emath-setoption "" "linewidth" "線の太さ(.4pt)"))
             (emop (emath-setoption emop "xspc" "縦罫と本文との空白(2pt)"))
             (emop (emath-setoption emop "yspc" "横罫と本文との空白(2pt)"))
             (emop (emath-setoption emop "width" "箱の横幅"))
             (emop (emath-setoption emop "display" "縦罫の表示[lr]"))
             (emop (emath-setoption emop "pos" "文字列の配置[lcr]"))
             (emop (emath-setoption emop "upperspace" "文字の上部の空白(8pt)"))
             (emop (emath-setoption emop "lowerspace" "文字の下部の空白(8pt)")))
        (if (string= emop "") ""
          (concat "[" emop "]%広域での設定\n%\\FboxLine:線の幅\n"
                  "%\\FboxXSpc:縦罫と文字列との幅\n%\\FboxYSpc:横罫と文字列との幅\n\t"))) ""))
;;\Integers[option]%
;; options:alph=文字(n),first=開始番号(1),end=終了番号(3),space=「,」と「数字」の空白(\ )
;;         dots=点々の種類(ldots),nodots(dotsなし)
(defun YaTeX:Integers ()
  (if (y-or-n-p "オプションを設定しますか？")
      (let* ((emop (emath-setoption "" "alph" "文字の指定(n)"))
             (emop (emath-setoption emop "begin" "開始番号(1)"))
             (emop (emath-setoption emop "end" "終了番号(3)"))
             (emop (emath-setoption emop "space" "`,'と`数字'の間の空白(\\ )"))
             (emop (emath-setoption emop "dots" "dotsの指定(\\ldots)")))
        (if (y-or-n-p "nodotsを指定しますか？")
            (setq emop (concat emop
                               (if (> (length emop) 0) "," "")
                               "nodots")) "")
        (if (string= emop "") ""
          (concat "[" emop "]%"))) ""))
;; \Tree[option]{繰り返し数}
;;% options:angle=開き角,length=初期枝長さ,
;;%         leftretio=左枝比,rightretio=右枝比
;;(defun YaTeX:Tree ()
;;  (concat (if (y-or-n-p "オプションを設定しますか？")
;;	      (let* ((emop (emath-setoption "" "angle" "開き角(20)"))
;;		     (emop (emath-setoption emop "length" "初期の枝の長さ(3)"))
;;		     (emop (emath-setoption emop "leftretio" "左枝の比(.75)"))
;;		     (emop (emath-setoption emop "rightretio" "右枝の比(.75)")))
;;		(if (string= emop "") "" (concat "[" emop "]"))) "")
;;	  "{" (read-string "繰り返し数: ") "}"))
(defun YaTeX:Mark ()
  (let* ((prerefstrings (mapconcat 'concat
                                   (split-string (file-name-sans-extension
                                                  (file-name-nondirectory (buffer-file-name))) "-" t)
                                   ":"))
         (refstrings (read-string "[option] 参照用ラベル(`mark:'が内部で先頭に付加される): " (concat prerefstrings "-")))
         (sublabel-y-or-n (if (> (length refstrings) 0)
                              (if (y-or-n-p "個別ラベルを設定しますか？") t nil)
                            nil))
         (sublabel "")
         (answer (read-string "解答の設定: "))
         (loop-no 0))
    (while (> (length answer) loop-no)
      (progn (setq loop-no (+ loop-no 1))
             (setq sublabel (format "%s%s%s:%s" sublabel (if (> (length sublabel) 0) "," "") refstrings loop-no))))
    (concat (if (> (length refstrings) 0)
                (concat "[" refstrings "]"
                        (if sublabel-y-or-n
                            (concat "[" sublabel "]") "")) "")
            "{" answer "}")))
(fset 'YaTeX:Mark* 'YaTeX:Mark)
(fset 'YaTeX:MarkBox 'YaTeX:Mark)
(fset 'YaTeX:MarkBox* 'YaTeX:Mark)
(defun YaTeX:refMark ()
  (let* ((option (read-string "node に対するオプションを指定してください: " "MarkBoxNode"))
         (default-refstrings (mapconcat 'concat
                                        (split-string (file-name-sans-extension
                                                       (file-name-nondirectory (buffer-file-name))) "-" t)
                                        ":")))
    (concat (if (> (length option) 0)
                (concat "[" option "]"))
            "{" (read-string " 参照用ラベルの指定: " (concat default-refstrings "-")) "}")))
(fset 'YaTeX:refMark* 'YaTeX:refMark)
(fset 'YaTeX:RefMark 'YaTeX:refMark)
(fset 'YaTeX:RefMark* 'YaTeX:refMark)
(defun YaTeX:multicols ()
  (concat "{" (read-string "段数: ") "}"))
(defun YaTeX:numcases ()
  (concat "{" (read-string "`{'の前置引数: ") "}"))
;%%space:座標間のスペース(\ )
;%%sign:座標間の区切り(,)
;%%pspace:括弧と座標のスペース(\,)
;%%paren:括弧の種類({(,)}) paren={\{,\}}などと指定する
;%%      paren={.,.}で括弧をなくする
(defun YaTeX:Zahyo ()
  (let* ((opstring ""))
    (if (y-or-n-p "オプションを設定しますか?")
        (setq opstring (emath-setoption opstring "space" "座標間の距離(\\ )")
              opstring (emath-setoption opstring "sign" "座標間の区切り(,)")
              opstring (emath-setoption opstring "pspace" "括弧と座標のスペース(\\,)")
              opstring (emath-setoption opstring "paren" "括弧の種類((,))" "{" "}")) "")
    (if (> (length opstring) 0)
        (concat "<" opstring ">") "")))
;year:年
;term:前後期
;university:大学
;faculty:学部
;department:学科
;no:問題番号
;matter:出題内容
;level:難易度
(defun YaTeX:Shutten ()
  (let* ((option (emath-setoption "" "year" "出題年度"))
         (option (emath-setoption option "term" "前・後期"))
         (option (emath-setoption option "university" "大学名"))
         (option (emath-setoption option "faculty" "学部名"))
         (option (emath-setoption option "department" "学科名"))
         (option (emath-setoption option "no" "問題番号"))
         (option (emath-setoption option "matter" "出題内容" "{" "}"))
         (option (emath-setoption option "level" "難易度")))
    (concat "{" option "}" )))
(defun YaTeX:unitcirc ()
  (let* ((option (emath-setoption "" "hankei" "単位円の半径(1)"))
         (option (emath-setoption option "ewputstring" "横軸に表示する半径(1)"))
         (option (emath-setoption option "nsputstring" "縦軸に表示する半径(1)"))
         (epos (emath-Put-HouiShitei))
         (wpos (emath-Put-HouiShitei))
         (npos (emath-Put-HouiShitei))
         (spos (emath-Put-HouiShitei))
         (epos (if (> (length epos) 0)
                   (concat "epos={" epos "}") ""))
         (wpos (if (> (length wpos) 0)
                   (concat "wpos={" wpos "}") ""))
         (npos (if (> (length npos) 0)
                   (concat "npos={" npos "}") ""))
         (spos (if (> (length spos) 0)
                   (concat "spos={" spos "}") ""))
         (option (emath-option-combine "," `(,option ,epos ,wpos ,npos ,spos))))
    (if (> (length option) 0)
        (insert (concat "[" option "]")))))
;\define@key{mytikzpicture}{fontsize}{\def\@MTPfontsize{#1}}
;\define@key{mytikzpicture}{margin}{\def\@MTPmargin{#1}}%
;\define@key{mytikzpicture}{left margin}{\def\@MTPleftmargin{#1}}%
;\define@key{mytikzpicture}{right margin}{\def\@MTPrightmargin{#1}}%
;\define@key{mytikzpicture}{above margin}{\def\@MTPabovemargin{#1}}%
;\define@key{mytikzpicture}{below margin}{\def\@MTPbelowmargin{#1}}%
;\define@key{mytikzpicture}{grid}[true]{\def\@MTPgrid{1}}%
;\define@key{mytikzpicture}{grid option}{\def\@MTPgridoption{#1}}%
;\define@key{mytikzpicture}{o string}{\def\@MTPostring{#1}}%
;\define@key{mytikzpicture}{o string pos}{\def\@MTPostringpos{#1}}%
;\define@key{mytikzpicture}{x string}{\def\@MTPxstring{#1}}%
;\define@key{mytikzpicture}{y string}{\def\@MTPystring{#1}}%
;\define@key{mytikzpicture}{x string pos}{\def\@MTPxstringpos{#1}}%
;\define@key{mytikzpicture}{y string pos}{\def\@MTPystringpos{#1}}%
(defun YaTeX:mytikzpicture ()
  (concat (if (y-or-n-p "座標軸を描画しますか?: ")
              "" "*")
          "<grid>"
          (let* ((xscale (read-string "[option] x軸方向の拡大率: "))
                 (xscale (if (> (length xscale) 0)
                             (concat "xscale=" xscale) ""))
                 (yscale (read-string "[option] y軸方向の拡大率: "))
                 (yscale (if (> (length yscale) 0)
                             (concat "yscale=" yscale) ""))
                 (scale (if (and (= (length xscale) 0)(= (length yscale) 0))
                            (read-string "[option] 全体の拡大率: ") ""))
                 (scale (if (> (length scale) 0)
                            (concat "scale=" scale) ""))
                 (opnum (emath-get-number-from-list "[option] baselineの設定" `("Top" "Center" "Bottom" "None")))
                 (baseline (cond ((= opnum 1) "baseline=current bounding box.north")
                                 ((= opnum 2) "baseline=current bounding box.center")
                                 ((= opnum 3) "baseline=current bounding box.south")
                                 (t "")))
                 (option (emath-option-combine "," `(,xscale ,yscale ,scale ,baseline))))
            (concat (if (> (length option) 0)
                        (concat "[" option "]") "")))
          (YaTeX:read-coordinates "xの定義域の指定: " "xmin" "xmax")
          (YaTeX:read-coordinates "yの定義域の指定: " "ymin" "ymax")
          "\n\\draw(trueLB)rectangle(trueRT);"))
;; \mytikzarc<オプション1>[オプション2]{中心}{半径}{開始角}{終了角}
;; \mytikzarc*[option]{中心}{半径}{開始角}{終了角}
;; 中心・半径・開始角・終了角を指定して弧を描く
;; *をつけると弧と中心を結び扇形を描く
;; オプション1
;;  number of line segment:線分の個数defalut=0
;;   1以上のときは等弧記号を指定された個数だけ弧上に配置する
;;   等弧記号の設定は\tikzset{MTAstyle/.style={line width=1pt,blue}}
;;   などと指定する
;;   \tikzset{MTAstyle/.default={line width=.4pt}}である
;; オプション2:fillなどTikZのオプションをいれる．
;;(defun YaTeX:mytikzarc ()
;;  (let ((option (emath-setoption "" "number of line segment" "等弧記号の個数(0)")))
;;    (concat (if (y-or-n-p "弧と中心を結び扇形にしますか?: ")
;;		"*" "")
;;	    (if (> (length option) 0)
;;		(concat "<" option ">") "")
;;	    "{" (read-string "中心: ") "}"
;;	    "{" (read-string "半径: ") "}"
;;	    "{" (read-string "開始角: ") "}"
;;	    "{" (read-string "終了角: ") "}%\n"
;;	    "%\t[#2]には弧に対するオプションを指定できる\n"
;;	    "%\t等弧記号の設定は\\tikzset{MTAstyle={red}}などとする")))
;; \mytikzbunten<オプション1>[オプション2]{端点1端点2}{分割数}
;; 2点{端点1}{端点2}を結ぶ線分を<分割数>等分しこの線分と垂直な線分を各点に配置する
;; オプション1
;;  length:配置する線分の長さ
;;  both ends:両端にも線分を配置する
;;(defun YaTeX:mytikzbunten ()
;;  (let* ((endsflag (if (y-or-n-p "[option] 両端にも線分を配置しますか?: ") 1 0))
;;	 (option (if (= endsflag 1) "both ends" ""))
;;	 (option (emath-setoption option "length" "配置する線分の長さ")))
;;    (concat (if (> (length option) 0)
;;		(concat "<" option ">"))
;;	    "{" (read-string "2端点の指定: ") "}"
;;	    "{" (read-string "分割数: ") "}%\n")))
;; \mytikztouhenkigou<オプション1>[オプション2]{線分列}
;; オプション1
;;  space:複数の線分の間隔default=3pt
;;  length:配置する線分の長さdefault=4pt
;;  number of line segment:配置する線分の個数defalut=2
;; オプション2:TikZのオプション
;; 線分列は(端点1)(端点2)を;で区切る
;;(defun YaTeX:mytikztouhenkigou ()
;;  (let* ((option (emath-setoption "" "number of line segment" "等辺記号の個数(2)"))
;;	 (option (emath-setoption option "length" "等辺記号の長さ(4pt)"))
;;	 (option (emath-setoption option "space" "等辺記号間の距離(3pt)")))
;;    (concat (if (> (length option) 0)
;;		(concat "<" option ">") "")
;;	    "{" (emath-tenretu-loop ";" "線分の指定(Enterで終了)") "}%\n"
;;	    "%\t[#2]は等辺記号の色などの設定")))
;; \mytikzkakukigouput<オプション1>[オプション2]{座標1座標2座標3}{配置文字列}
;; オプション1
;;  radius:半径
;;  fontsize:配置文字列のサイズdefault=\scriptsize
;;  arc:弧も描画する
;;(defun YaTeX:mytikzkakukigou ()
;;  (let* ((arcflag (if (y-or-n-p "弧も描画しますか?: ") 1 0))
;;	 (option (if (= arcflag 1) "arc" ""))
;;	 (option (emath-setoption option "arc radius" "弧に対する半径(7.5pt)"))
;;	 (option (emath-setoption option "string radius" "文字列に対する半径(7.5pt)"))
;;	 (option (emath-setoption option "fontsize" "配置文字列の文字サイズ(\\scriptsize)")))
;;    (concat (if (> (length option) 0)
;;		(concat "<" option ">") "")
;;	    "{" (read-string "角を表す点列: ") "}"
;;	    "{" (read-string "配置文字列: ") "}%\n"
;;	    "%\t[#2]オプションはarcを指定したときの弧に対するオプション")))
;; \mytikztoukakukigou<オプション1>[オプション2]{座標1座標2座標3}{配置文字列}
;; オプション1
;;  radius:半径
;;  fontsize:配置文字列のサイズdefault=\scriptsize
;;  arc:弧も描画する
;;(defun YaTeX:mytikztoukakukigou ()
;;  (let* ((arcflag (if (y-or-n-p "弧も描画しますか?: ") 1 0))
;;	 (option (if (= arcflag 1) "arc" ""))
;;	 (option (emath-setoption option "arc radius" "弧に対する半径(7.5pt)"))
;;	 (option (emath-setoption option "string radius" "文字列に対する半径(15pt)"))
;;	 (option (emath-setoption option "fontsize" "配置文字列の文字サイズ(\\scriptsize)")))
;;    (concat (if (> (length option) 0)
;;		(concat "<" option ">") "")
;;	    "{" (emath-tenretu-loop ";" "角を表す点列の指定(Enterで終了)") "}"
;;	    "{" (read-string "配置文字列: ") "}%\n"
;;	    "%\t[#2]オプションはarcを指定したときの弧に対するオプション")))
;; \mytikzhenko<オプション1>[オプション2]{端点1端点2}{配置文字列}
;; オプション1
;;  distance:辺と配置文字列との距離default=10pt
;;  angle:辺から出る弧の角度default=20
;;  ratio:配置文字列の配置位置default=.5
;;  inner sep:配置文字列と白塗り背景の間隔default=1pt
;;  fontsize:配置文字列の文字サイズdefault=\scriptsize
;;  rotate:配置文字列の回転
;;    0(default):回転なし
;;    1:弦と平行(文字列の並びは端点1から端点2へ)
;;   -1:弦と平行(文字列の並びは端点2から端点1へ)
;;  \tikzset{MTHstyle={line width=1pt,dash pattern=on 1pt off 1pt}}
;;   のように波線を変更することもできる．
;;(defun YaTeX:mytikzhenko ()
;;  (let* ((option (emath-setoption "" "distance" "辺と配置文字列との距離(10pt)"))
;;;	 (option (emath-setoption option "angle" "辺から出る弧の角度(20)"))
;;;	 (option (emath-setoption option "ratio" "配置文字列の位置の調整(.5)"))
;;	 (option (emath-setoption option "inner sep" "配置文字列と白塗り背景の間隔(1pt)"))
;;	 (option (emath-setoption option "fontsize" "配置文字列の文字サイズ(\\scriptsize)"))
;;	 (option (emath-setoption option "rotate" "配置文字列の回転[0:回転なし 1:弦と平行(端点1から端点2) -1:弦と平行(端点2から端点1)](0)")))
;;    (concat (if (> (length option) 0)
;;		(concat "<" option ">") "")
;;	    "{" (read-string "辺の2端点: ") "}"
;;	    "{" (read-string "配置文字列: ") "}%\n"
;;	    "%\t[#2]は\\drawに対するオプション\n"
;;	    "%\t破線の形状は\tikzset{MTHstyle/.default={line width=.4pt,dash pattern=on 2pt off 2pt}}で%\n"
;;	    "%\tグローバルに設定されている")))
; \mytikztyokkakukigou<#1>[#2]#3
;  #1:オプション1
;   size:記号の１辺の長さdefalut=5pt
;  #2:オプション2
;   tikzのオプション
;  #3:記号を置く角の列';'で区切って並べる
;; 角#3を共有する1辺がsizeの菱形を描く
;;(defun YaTeX:mytikztyokkakukigou ()
;;  (let* ((option (emath-setoption "" "size" "直角記号のサイズ(5pt)")))
;;    (concat (if (> (length option) 0)
;;		(concat "<" option ">") "")
;;	    "{" (emath-tenretu-loop ";" "角を表す点列の指定(Enterで終了)") "}%\n"
;;	    "%\t[#2]オプションで塗りつぶしたり色を付けたりできる")))
;; \mytikzmaru(*)<#1>[#2]{#3};
;;  #1:オプション1
;;   radius=丸の半径default=2.5pt
;;  #2:オプション2
;;   tikzのオプション
;;  #3:点列(,区切り)
(defun YaTeX:mytikzmaru ()
  (let* ((option (emath-setoption "" "radius" "(白|黒)丸の半径(2.5pt)"))
         (option (emath-setoption option "x radius" "x軸方向の半径"))
         (option (emath-setoption option "y radius" "y軸方向の半径"))
         (blackflag (if (y-or-n-p "黒丸にしますか?: ") 1 0)))
    (concat (if (= blackflag 1) "*" "")
            (if (> (length option) 0)
                (concat "<" option ">") "")
            "{" (emath-tenretu-loop "," "(白|黒)丸を打つ点の指定(Enterで終了)") "}%")))
;; \mytikzmakeintersection<#1>[#2]#3#4#5
;; #1:オプション
;;  sort:Sortの基準を設定(#3or#5)default=#3
;; #2:今のところ使う予定はない
;; #3:name pathで定められたpath1
;; #4:name pathで定められたpath2
;; #5:交点の前置文字列
;;  hogeとすると交点の名前がhoge-1，hoge-2，...と設定される
;; \mytikzsetintersection*<#1>[#2]#3#4#5で交点とその名前が表示される
;; また，#5Xi，#5Xii，...にはそれぞれ(#5-1)，(#5-2)，...のx座標が
;; #5Yi，#5Yii，...にはそれぞれ(#5-1)，(#5-2)，...のy座標が格納される
;;(defun YaTeX:mytikzsetintersections ()
;;  (let* ((option (emath-setoption "" "sort" "どちらのpathでソートするか決める(最初のpath)")))
;;    (concat (if (y-or-n-p "交点とその名前を表示させますか?: ") "*" "")
;;	    (if (> (length option) 0)
;;		(concat "<" option ">") "")
;;	    "{" (read-string "path1: ") "}"
;;	    "{" (read-string "path2: ") "}"
;;	    "{" (read-string "交点の名前の前置文字列: ") "}%\n"
;;	    "%\t\\mytikzsetintersection{line1}{line2}{P}とすると\n"
;;	    "%\t交点の名前がP-1,P-2,...と設定され\n"
;;	    "%\tそれぞれのx座標が\\PXi,\\PXii,...\n"
;;	    "%\ty座標が\\PYi,\\PYii,...に格納される\n"
;;	    "%\t交点の個数が\\MTSImaxnumに格納されている")))
;; mytikzfunction<#1>[#2]#3#4#5
;; #1:オプション1
;;  leftP:左端点(x or y座標が最小)の名前default=leftP
;;  rightP:右端点(x or y座標が最大)の名前default=rightP
;; #2:オプション2
;;  \drawに対するオプション
;;  defaultはsmooth
;; #3:x座標を表す式
;; #4:y座標を表す式
;; #5:この関数のパスの名前(交点を求めるときに使える)
(defun YaTeX:mytikzfunction ()
  (let* ((option (emath-setoption "" "leftP" "左端点の名前(leftP)"))
         (option (emath-setoption option "rightP" "右端点の名前(rightP)")))
    (concat (if (> (length option) 0)
                (concat "<" option ">"))
            "{" (read-string "x座標を表す式: " "\\x") "}"
            "{" (read-string "y座標を表す式: " "\\Fx") "}"
            "{" (read-string "パス名: ") "}%\n"
            "%\t[#2]はplotのオプション．\n"
            "%\tデフォルトはsmooth．samples=200などで変更できる")))
;; \mytikzfillFandF<#1>[#2]|#3|#4#5#6#7
;; #1:オプション1
;;  \fillのオプション指定(色や透明度など)
;; #2:オプション2
;;  関数1のplotのオプション指定(smooth，samples,domainなど)
;;  domainを指定すると#6，#7で指定した定義域が無視される
;; #3:オプション3
;;  関数2のplotのオプション指定(smooth，samples,domainなど)
;;  domainを指定すると#6，#7で指定した定義域が無視される
;; #4:関数1のx，y座標を表す式を指定y=x^2は\x,{pow(\x,2)}となる
;; #5:関数2のx，y座標を表す式を指定y=x^2は\x,{pow(\x,2)}となる
;; #6，#7:塗りつぶす領域の定義域を指定
;; 関数1は#6->#7の方向で塗りつぶされ，
;; 関数2は#7->#6の方向で塗りつぶされる
;;(defun YaTeX:mytikzfillFandF ()
;;  (concat "{" (read-string "関数1: " "\\x,{\\Fx}") "}"
;;	  "{" (read-string "関数2: " "\\x,{\\Gx}") "}"
;;	  "{" (read-string "定義域の最小値: ") "}"
;;	  "{" (read-string "定義域の最大値: ") "}%\n"
;;	  "%\t<#1>塗りつぶしなどの設定\n"
;;	  "%\t[#2]関数1のplotのオプション(smooth,samples,domainなど)\n"
;;	  "%\t|#3|関数2のplotのオプション(smooth,samples,domainなど)\n"
;;	  "%\tplotのオプションでdomainが指定されると#6,#7の定義域が無視される\n"
;;	  "%\t関数1は#6->#7，関数2は#7->#6の向きにパスが設定される"))
;; \mytikzteisei<#1>[#2]#3
;; #1:オプション1
;;  right up:右上がりの斜線(default)
;;  right down:右下がりの斜線
;; #2:\drawのオプション(線の太さ・色・破線などを設定)
;; #3:斜線を引きアイテム
;;(defun YaTeX:mytikzteisei ()
;;  (let* ((num (emath-get-number-from-list "[option] 斜線の設定" `("right up(default)" "right down")))
;;	 (option (cond ((= num 1) (concat "right up"))
;;		       ((= num 2) (concat "right down"))
;;		       (t ""))))
;;    (concat (if (> (length option) 0)
;;		(concat "<" option ">"))
;;	    "{" (read-string "斜線を引くアイテム: ") "}")))
;; \mytikzputsyaei<#1>[#2]#3
;; #1:オプション1
;;  x direction:x軸と配置文字列との距離
;;  y direction:y軸と配置文字列との距離
;;  x string:x軸に配置する文字の指定
;;  y string:y軸に配置する文字の指定
;;  syeai:x,y,xy
;; #2:オプション2
;;  \drawに対するオプション
;; #3:点の指定
;;(defun YaTeX:mytikzputsyaei ()
;;  (let* ((posnum (emath-get-number-from-list "[option]軸への垂線の設定" `("x軸のみ" "y軸のみ" "xy軸両方(default)")))
;;	 (option (cond ((or (= posnum 0) (= posnum 3)) "")
;;;		       ((= posnum 3) "")
;;		       (t (concat "syaei=" (number-to-string posnum))))))
;;    (progn (if (or (= posnum 0) (= posnum 1) (= posnum 3))
;;	       (setq option (emath-setoption option "x string" "x軸に配置する文字列")
;;		     option (emath-setoption option "x direction" "x軸と文字列との距離(.2)")) "")
;;	   (if (or (= posnum 0) (= posnum 2) (= posnum 3))
;;	       (setq option (emath-setoption option "y string" "y軸に配置する文字列")
;;		     option (emath-setoption option "y direction" "y軸と文字列との距離(.2)")) "")
;;	   (concat (if (> (length option) 0)
;;		       (concat "<" option ">") "")
;;		   "{" (read-string "点の指定: ") "}"))))
;; \mytikzfuncval<#1>#2#3#4#5
;;  #1:オプション
;;   precision:小数点以下第何位まで表示するか設定するdefault=2
;;  #2:plotのy座標を表す関数
;;  #3:y座標を求めるためのx座標
;;  #4:y座標を格納するための制御綴
;;  #5:求めた点の名前
;;(defun YaTeX:mytikzfuncval ()
;;  (let* ((option (emath-setoption "" "precision" "小数第何位まで表示するかの設定(2)")))
;;    (concat (if (> (length option) 0)
;;		(concat "<" option ">"))
;;	    "{" (read-string "plotのy座標を表す関数: " "\\Fx") "}"
;;	    "{" (read-string "x座標: ") "}"
;;	    (read-string "y座標を格納するための制御綴: ")
;;	    "{" (read-string "求めた点の名前: ") "}%")))
;; \mytikztoukokigou<#1>[#2]#3#4
;; #1:等弧記号のオプション
;;  width:等弧記号を描画する幅
;;  length:等弧記号の長さ
;;  num:等弧記号の数
;; #2:等弧記号を描く\drawのオプション
;; #3:円の中心
;; #4:弧を表す端点(時計回りに指定)
;;    ;で区切って複数指定可能
;;(defun YaTeX:mytikztoukokigou ()
;; (let* ((option (emath-setoption "" "num" "等弧記号の個数(2)"))
;;	(option (emath-setoption option "width" "等弧記号を描画する幅(2pt)"))
;;	(option (emath-setoption option "length" "等弧記号の長さ(5pt)")))
;;   (concat (if (> (length option) 0)
;;	       (concat "<" option ">") "")
;;	   "{" (read-string "円弧の中心: ") "}"
;;	   "{" (emath-tenretu-loop ";" "弧の端点の指定[反時計回りに2点ずつ指定する](Enterで終了)") "}")))
;; \mytikzHenko*<#1>[#2]{#3}{#4};
;; *:弧を表示しないときに指定する
;; #1:オプション1
;;   angle:弦から出る角度の指定
;;   fboxsep:表示文字列の周りのマージン
;;   rotate:文字列の回転指定(0:回転させない，1:始点から終点，-1:終点から始点)
;;(defun YaTeX:mytikzHenko ()
;;  (let* ((num (emath-get-number-from-list "[option]文字列の回転指定"
;;					  '("回転させない[default]" "弦と平行[始点から終点へ]" "弦と平行[終点から始点へ]")))
;;	 (option (cond ((= num 2) "rotate=1")
;;		       ((= num 3) "rotate=-1")
;;		       (t "")))
;;	 (option (emath-setoption option "angle" "弦から出る角度の指定"))
;;	 (option (emath-setoption option "fboxsep" "文字列の周りのマージン(1pt)"))
;;	 (option (emath-setoption option "pos" "文字列の配置位置(.5)")))
;;    (concat (if (y-or-n-p "文字列だけ表示しますか？: ")
;;		"*" "")
;;	    (if (> (length option) 0)
;;		(concat "<" option ">") "")
;;	    "{" (read-string "弦を表す2点: ") "}"
;;	    "{" (read-string "表示文字列: ") "}%")))
;; \ASector<#1>[#2]{#3}{#4}%
;; A(ngle)Sector:開始点と終了点の角度を指定する扇形
;; ex:\ASector{O}{2}{30,90}%
;; #1:固有オプション
;;   arc only:弧のみを描画
;;   arc radius:#4の半径と関係なく半径を指定する
;; #2:Tikzオプション
;; #3:扇形の中心
;; #4:扇形の半径
;; #5:この開始点と終了点の角度をカンマ(,)区切りで指定
(defun YaTeX:ASector ()
  (let* ((option (if (y-or-n-p "弧のみを描画しますか？: ") "arc only" ""))
         (option (emath-setoption option "arc radius" "引数の半径を無視する場合の半径")))
    (concat (if (> (length option) 0)
                (concat "<" option ">") "")
            "{" (read-string "扇形の中心: ") "}"
            "{" (read-string "扇形の半径: ") "}"
            "{" (read-string "開始角度: ") "," (read-string "終了角度: ") "}%")))
;; \PSector<#1>[#2]{#3}{#4}%
;; P(oint)Sector:開始点と終了点を指定する扇形
;; ex:\PSector{O}{A,B}%
;; #1:固有オプション
;;   arc only:弧のみを描画
;;   arc radius:実際の半径と関係なく半径を指定する
;; #2:Tikzオプション
;; #3:扇形の中心
;; #4:弧の開始点と終了点をカンマ(,)区切りで指定
(defun YaTeX:PSector ()
  (let* ((option (if (y-or-n-p "弧のみを描画しますか？: ") "arc only" ""))
         (option (emath-setoption option "arc radius" "引数の半径を無視する場合の半径")))
    (concat (if (> (length option) 0)
                (concat "<" option ">") "")
            "{" (read-string "扇形の中心: ") "}"
            "{" (read-string "開始点: ") "," (read-string "終了点: ") "}%")))
;; \DSector<#1>[#2]{#3}{#4}{#5}%
;; D(elta)Sector:開始点と中心角を指定する扇形
;; ex:\DSector{O}{A}{150}%
;; #1:固有オプション
;;   arc only:弧のみを描画
;;   arc radius:実際の半径と関係なく半径を指定する
;; #2:Tikzオプション
;; #3:扇形の中心
;; #4:開始点
;; #5:中心角
(defun YaTeX:DSector ()
  (let* ((option (if (y-or-n-p "弧のみを描画しますか？: ") "arc only" ""))
         (option (emath-setoption option "arc radius" "引数の半径を無視する場合の半径")))
    (concat (if (> (length option) 0)
                (concat "<" option ">") "")
            "{" (read-string "扇形の中心: ") "}"
            "{" (read-string "開始点: ") "}"
            "{" (read-string "中心角: ") "}%")))
;; \Bunten<#1>[#2]{#3}{#4}%
;; ex:\Bunten{A,B}{4}%
;; #1:固有オプション
;;   both ends:2端点にも線分を付加する
;;   length:付加する線分の長さを指定
;; #2:Tikzオプション
;; #3:2端点をカンマ(,)区切りで指定
;; #4:何等分するか指定
(defun YaTeX:Bunten ()
  (let* ((option (if (y-or-n-p "両端にも線分を負荷しますか？: ") "both ends" ""))
         (option (emath-setoption option "length" "付加する線分の長さ(7.5pt)")))
    (concat (if (> (length option) 0)
                (concat "<" option ">") "")
            "{" (read-string "端点1: ") "," (read-string "端点2: ") "}"
            "{" (read-string "何等分するか指定: ") "}")))
;; \ToukakuKigou<#1>[#2]{#3}{#4}%
;; ex:\ToukakuKigou{A,B,C;B,C,D;D,A,B}{$\circ$}%
;; #1:固有オプション
;;   arc:弧を描画する
;;   arc radius:弧に対する半径(12.5pt)
;;   string radius:文字列に対する半径(7.5pt)
;;   string size:文字列の大きさ(scriptsize)
;;   sign num:弧上に配置する等弧記号の数(0)
;;   sign length:弧上に配置する等弧記号の長さ(7.5pt)
;;   sign space:弧上に配置する等弧記号間の間隔(1pt)
;; #2:Tikzオプション
;; #3:∠ABCなどをカンマ(,)区切りでセミコロン(;)で複数指定する
;; #4:使用する記号を指定する
(defun YaTeX:ToukakuKigou ()
  (let* ((option (if (y-or-n-p "弧を描画しますか？: ") "arc" ""))
         (option (if (> (length option) 0)
                     (emath-setoption option "arc radius" "弧に対する半径(12.5pt)") ""))
         (option (emath-setoption option "string radius" "文字列に対する半径(7.5pt)"))
         (option (emath-setoption option "string size" "文字列の大きさ(\\scriptsize)"))
         (num (read-number "弧上に配置する等弧記号の数(0): "))
         (signnum (if (> num 0)
                      (concat "sing num=" (number-to-string num)) ""))
         (signlength (if (> num 0)
                         (emath-setoption "" "sign length" "弧上に配置する等弧記号の長さ(7.5pt)") ""))
         (signspace (if (> num 1)
                        (emath-setoption "" "sign space" "弧上に配置する等弧記号間の間隔(1pt)") ""))
         (option (emath-option-combine "," `(,option ,signnum ,signlength ,signspace))))
    (concat (if (> (length option) 0)
                (concat "<" option ">") "")
            "{" (emath-tenretu-loop ";" "角度をカンマ(,)区切りで3点指定する") "}"
            "{" (read-string "記号の指定: ") "}")))
;; \TouhenKigou<#1>[#2]{#3}
;; #1:固有オプション
;;   length:記号の長さ(7.5pt)
;;   space:記号の間隔(3pt)
;;   sign num:記号の個数(2)
;; #2:Tikzオプション
;; #3:2端点をカンマ(,)区切りで指定したものをセミコロン(;)区切りで複数指定する
(defun YaTeX:TouhenKigou ()
  (let* ((num (read-number "等辺記号の個数(2): "))
         (signnum (if (not (= num 2))
                      (concat "sign num=" (number-to-string num)) ""))
         (option (if (> num 1)
                     (emath-setoption "" "space" "等辺記号間の間隔(3pt)") ""))
         (option (emath-setoption option "length" "等辺記号の長さ(7.5pt)"))
         (option (emath-option-combine "," `(,signnum ,option))))
    (concat (if (> (length option) 0)
                (concat "<" option ">") "")
            "{" (emath-tenretu-loop ";" "辺の端点をカンマ(,)区切りで指定する") "}")))
;; \Henko<#1>[#2]{#3,#4}{#5}%
;; #1:固有オプション
;;    fboxsep:文字列の周りのスペース(1pt)
;;    fontsize:文字列のサイズ(\scriptsize)
;;    angle:弦から出る角度
;;    rotate:文字列の回転指定(0:回転させない 1:始点から終点 -1:終点から始点)
;;    pos:文字列の配置位置(.5)
;;    background color:文字列の背景色の指定(white)[transparentで塗りつぶしなし]
;; #2:Tikzオプション
;; #3,#4:2端点をカンマ区切りで指定
;; #5:配置文字列の指定
(defun YaTeX:Henko ()
  (let* ((option (emath-setoption "" "angle" "弦から出る角度(空文字列)"))
         (option (emath-setoption option "pos" "文字列の配置位置(.5)"))
         (option (emath-setoption option "rotate" "文字列の回転(0)[0:回転なし 1:始点から終点 -1:終点から始点]"))
         (option (emath-setoption option "fboxsep" "文字列の周りの余白(1pt)"))
         (option (emath-setoption option "fontsize" "文字列のサイズ(\\scriptsize)"))
         (option (emath-setoption option "background color" "文字列の背景色(white)[transparentで塗り潰しなし]")))
    (concat (if (> (length option) 0)
                (concat "<" option ">") "")
            "{" (read-string "端点1: ") "," (read-string "端点2: ") "}"
            "{" (read-string "配置文字列: ") "}%")))
;; \RightAngle<#1>[#2]{#3}%
;; #1:固有オプション
;;    size:直角記号の1辺の長さ(10pt)
;;    cycle:正方形(ひし形)を作るときに宣言する
;;          記号の内部を塗りつぶすときなどに使用する
;; #2:TikZオプション
;; #3:直角をなす角をカンマ(,)区切りで指定したものをセミコロン(;)で区切り複数指定する
(defun YaTeX:RightAngle ()
  (let* ((option (if (y-or-n-p "記号をひし形(正方形)にしますか？: ")
                     "cycle" ""))
         (option (emath-setoption option "size" "記号の1辺の長さ(10pt)")))
    (concat (if (> (length option) 0)
                (concat "<" option ">") "")
            "{" (emath-tenretu-loop ";" "直角を作る3点をカンマ(,)区切りで指定") "}%")))
;; \Maru*<#1>[#2]{#3}%
;; *:負荷すると黒丸，負荷しないと白丸
;; #1:半径オプション
;;   radius,x radius,y radius
;; #2:描画オプション
;; #3:点を打つポイントをカンマ(,)区切りで複数指定
(fset 'YaTeX:Maru 'YaTeX:mytikzmaru)
;; \Function<#1>[#2]#3#4#5
;; #1:オプション1
;;  leftP:左端点(x or y座標が最小)の名前default=leftP
;;  rightP:右端点(x or y座標が最大)の名前default=rightP
;; #2:オプション2
;;  \drawに対するオプション
;;  defaultはsmooth
;; #3:x座標を表す式
;; #4:y座標を表す式
;; #5:この関数のパスの名前(交点を求めるときに使える)
(fset 'YaTeX:Function 'YaTeX:mytikzfunction)
;; \Vline<#1>[#2]{#3}{#4}{#5}%
;; V(ector)line
;; ex:\Vline{A}{1,2}{line1}%
;; #1:固有オプション
;;   leftP:左端点の名前を指定(leftP)
;;   rightP:右端点の名前を指定(rightP)
;;   noline:直線を引かない
;;   left:半直線で通過点の左側のみ描画
;;   right:半直線で通過点の右側のみ描画
;; #2:TikZオプション
;; #3:通過点
;; #4:方向ベクトル
;; #5:パスの名前
(defun YaTeX:Vline ()
  (let* ((num (if (y-or-n-p "直線を描画しますか？: ")
                  (if (y-or-n-p "半直線にしますか？: ")
                      (if (y-or-n-p "指定点の左側を描画しますか？: ")
                          1 2) 0) 3))
         (option (cond ((= num 1) "left")
                       ((= num 2) "right")
                       ((= num 3) "noline")
                       (t "")))
         (option (emath-setoption option "leftP" "左端点の名前(leftP)"))
         (option (emath-setoption option "rightP" "右端点の名前(rightP)")))
    (concat (if (> (length option) 0)
                (concat "<" option ">") "")
            "{" (read-string "通過点: ") "}"
            "{" (read-string "方向ベクトル[ex. 1,2]: ") "}"
            "{" (read-string "直線の名前: ") "}")))
;; \Pline<#1>[#2]{#3}{#4}%
;; P(ector)line
;; ex:\Pline{A,B}{line1}%
;; #1:固有オプション
;;   leftP:左端点の名前を指定(leftP)
;;   rightP:右端点の名前を指定(rightP)
;;   noline:直線を描画しない
;;   left:半直線で通過点の左側のみ描画
;;   right:半直線で通過点の右側のみ描画
;; #2:TikZオプション
;; #3:2つの通過点をカンマ区切りで指定
;; #4:パスの名前
(defun YaTeX:Pline ()
  (let* ((num (if (y-or-n-p "直線を描画しますか？: ")
                  (if (y-or-n-p "半直線にしますか？: ")
                      (if (y-or-n-p "指定点の左側を描画しますか？: ")
                          1 2) 0) 3))
         (option (cond ((= num 1) "left")
                       ((= num 2) "right")
                       ((= num 3) "noline")
                       (t "")))
         (option (emath-setoption option "leftP" "左端点の名前(leftP)"))
         (option (emath-setoption option "rightP" "右端点の名前(rightP)")))
    (concat (if (> (length option) 0)
                (concat "<" option ">") "")
            "{" (read-string "通過点1: ") "," (read-string "通過点2: ") "}"
            "{" (read-string "パスの名前: ") "}%")))
;; \Sline<#1>[#2]#3#4#5
;; S(lope)line:1点と傾き指定
;; #1:オプション1
;;   leftP:左端点の名前を指定(leftP)
;;   rightP:右端点の名前を指定(rightP)
;;   noline:直線を描画しない
;;   left:半直線で通過点の左側のみ描画
;;   right:半直線で通過点の右側のみ描画
;; #2:TikZオプション
;; #3:直線を通る1点を指定
;; #4:この直線の傾きを指定
;; #5:パスの名前
(defun YaTeX:Sline ()
  (let* ((num (if (y-or-n-p "直線を描画しますか？: ")
                  (if (y-or-n-p "半直線にしますか？: ")
                      (if (y-or-n-p "指定点の左側を描画しますか？: ")
                          1 2) 0) 3))
         (option (cond ((= num 1) "left")
                       ((= num 2) "right")
                       ((= num 3) "noline")
                       (t "")))
         (option (emath-setoption option "leftP" "左端点の名前(leftP)"))
         (option (emath-setoption option "rightP" "右端点の名前(rightP)")))
    (concat (if (> (length option) 0)
                (concat "<" option ">") "")
            "{" (read-string "通過点: ") "}"
            "{" (read-string "傾き: ") "}"
            "{" (read-string "パスの名前: ") "}%")))
;; \Aline<#1>[#2]#3#4#5
;; A(ngle)line:1点と角度指定
;; #1:オプション1
;;   leftP:左端点の名前を指定(leftP)
;;   rightP:右端点の名前を指定(rightP)
;;   noline:直線を描画しない
;;   left:半直線で通過点の左側のみ描画
;;   right:半直線で通過点の右側のみ描画
;; #2:TikZオプション
;; #3:直線を通る1点を指定
;; #4:x軸とのなす角度を指定(60分法)
;; #5:パスの名前
(defun YaTeX:Aline ()
  (let* ((num (if (y-or-n-p "直線を描画しますか？: ")
                  (if (y-or-n-p "半直線にしますか？: ")
                      (if (y-or-n-p "指定点の左側を描画しますか？: ")
                          1 2) 0) 3))
         (option (cond ((= num 1) "left")
                       ((= num 2) "right")
                       ((= num 3) "noline")
                       (t "")))
         (option (emath-setoption option "leftP" "左端点の名前(leftP)"))
         (option (emath-setoption option "rightP" "右端点の名前(rightP)")))
    (concat (if (> (length option) 0)
                (concat "<" option ">") "")
            "{" (read-string "通過点: ") "}"
            "{" (read-string "x軸とのなす角度: ") "}"
            "{" (read-string "パスの名前: ") "}%")))
;; \Nline:1点と法線ベクトル指定
;; N(ormalVector)line
;; #1:オプション1
;;   leftP:左端点の名前を指定(leftP)
;;   rightP:右端点の名前を指定(rightP)
;;   noline:直線を描画しない
;;   left:半直線で通過点の左側のみ描画
;;   right:半直線で通過点の右側のみ描画
;; #2:TikZオプション
;; #3:直線を通る1点を指定
;; #4:法線ベクトルの成分を指定
;; #5:パスの名前
(defun YaTeX:Nline ()
  (let* ((num (if (y-or-n-p "直線を描画しますか？: ")
                  (if (y-or-n-p "半直線にしますか？: ")
                      (if (y-or-n-p "指定点の左側を描画しますか？: ")
                          1 2) 0) 3))
         (option (cond ((= num 1) "left")
                       ((= num 2) "right")
                       ((= num 3) "noline")
                       (t "")))
         (option (emath-setoption option "leftP" "左端点の名前(leftP)"))
         (option (emath-setoption option "rightP" "右端点の名前(rightP)")))
    (concat (if (> (length option) 0)
                (concat "<" option ">") "")
            "{" (read-string "通過点: ") "}"
            "{" (read-string "法線ベクトル: ") "}"
            "{" (read-string "パスの名前: ") "}%")))
;; \CTangent<#1>[#2]{#3}{#4}{#5}{#6}%
;; 円外の点#3から中心#4半径#5へ接線を引く時の接点を#6に格納する
;; #1:固有オプション
;;   drawline:円外の点から2つの接点を通る半直線を引く
;; #2:TizZオプション
;;   #1でdrawlineが指定された時のみ有効
;; #3:円外の点
;; #4:円の中心
;; #5:円の半径
;; #6:2つの接点の名前をカンマ(,)区切りで指定する
(defun YaTeX:CTangent ()
  (let* ((option (if (y-or-n-p "drawlineオプションを使用しますか？: ")
                     "drawline" "")))
    (concat (if (> (length option) 0)
                (concat "<" option ">"))
            "{" (read-string "円外の点: ") "}"
            "{" (read-string "円の中心: ") "}"
            "{" (read-string "円の半径: ") "}"
            "{" (read-string "接点の指定(2点をカンマ区切りで): ") "}")))
;; Attention環境
;;(defun YaTeX:Attention ()
;;  (let* ((op1 (emath-setoption "" "fill" "[Title]塗りつぶし色(red!30)"))
;;	 (op1 (emath-setoption op1 "rounded corners" "[Title]コーナー(5pt)"))
;;	 (op2 (emath-setoption "" "userdefinedwidth" "[環境]幅の指定(\\linewidth)"))
;;	 (op2 (emath-setoption op2 "skipabove" "[環境]上部マージン(0pt)"))
;;	 (op2 (emath-setoption op2 "skipbelow" "[環境]下部マージン(0pt)"))
;;	 (op2 (emath-setoption op2 "leftmargin" "[環境]右マージン(0pt)"))
;;	 (op2 (emath-setoption op2 "rightmargin" "[環境]左マージン(0pt)"))
;;	 (op2 (emath-setoption op2 "innertopmargin" "[環境]上部パディング(0pt)"))
;;	 (op2 (emath-setoption op2 "innerbottommargin" "[環境]下部パディング(0pt)"))
;;	 (op2 (emath-setoption op2 "innerleftmargin" "[環境]左パディング(5pt)"))
;;	 (op2 (emath-setoption op2 "innerrightmargin" "[環境]右パディング(5pt)"))
;;	 (op2 (emath-setoption op2 "linewidth" "[環境]囲み線の幅(2pt)"))
;;	 (op2 (emath-setoption op2 "linecolor" "[環境]囲み線の色(red!30)"))
;;	 (op2 (emath-setoption op2 "roundcorner" "[環境]囲み線のコーナー(10pt)"))
;;	 (op2 (emath-setoption op2 "backgroundcolor" "[環境]背景色(red!5)")))
;;    (concat (if (> (length op1) 0)
;;		(concat "<" op1 ">") "")
;;	    (if (> (length op2) 0)
;;		(concat "[" op2 "]") "")
;;	    "\n\\small\\parindent=1zw\\quad")))
;; \GetMin{#1}{#2}{#3}
;; #1:カンマ区切りの数字の列
;; #2:最小値を格納する命令
;; #3:最小値を除いた数字の列を格納する命令
(defun YaTeX:GetMin ()
  (insert (concat "{" (emath-tenretu-loop "," "データを入力(Enterで終了)") "}"
                  (read-string "最小値を格納する命令: ")
                  (read-string "最小値を除いたデータ列を格納する命令: "))))
;; \Sort{#1}{#2}{#3}{#4}%
;; #1:配列の名称
;; #2:配列
;; #3:配列の個数を格納する命令
;; #4:並べ直した配列を格納する命令
(defun YaTeX:Sort ()
  (insert (concat "{" (read-string "配列の名称: " "array") "}"
                  "{" (emath-tenretu-loop "," "データを入力(Enterで終了)") "}"
                  (read-string "配列の個数を格納する命令: ")
                  (read-string "並べ直した配列を格納する命令: "))))
;; \HakoHige<#1>[#2](#3){#4}
;; #1:original option
;;  width:箱の横幅
;;  higewidth:ひげの横幅
;;  data:最小値,第1四分位数,第2四分位数,第3四分位数,最大値を順に与えてデータを使わない
;;  showmed:平均値を表示する
;;  medmark:平均値のマークの設定($+$)
;; #2:箱のオプション指定
;; #3:ひげのオプション指定
;; #4:箱ひげを作るためのデータをカンマ区切りで指定
(defun YaTeX:HakoHige ()
  (let* ((op1 (emath-setoption "" "width" "箱の横幅(0,1)で指定(.5)"))
         (op1 (emath-setoption op1 "higewidth" "ひげの横幅(0,1)で指定(.5)"))
         (op1 (emath-setoption op1 "medmark" "平均値のマークの指定($+$)"))
         (showmed (if (y-or-n-p "平均値を表示させますか？: ")
                      "showmed" ""))
         (data (if (y-or-n-p "条件のみ与えますか？: ")
                   (concat "data={" (read-string "最小値: ")
                           "," (read-string "第1四分位数: ")
                           "," (read-string "第2四分位数: ")
                           "," (read-string "第3四分位数: ")
                           "," (read-string "最大値") "}") ""))
         (op1 (emath-option-combine "," `(,op1 ,showmed ,data)))
         (op2 (read-string "箱のオプション指定[fill,opacity=.5など]: "))
         (op3 (read-string "ひげのオプション指定[line width=2ptなど]: ")))
    (insert (concat (if (> (length op1) 0)
                        (concat "<" op1 ">"))
                    (if (> (length op2) 0)
                        (concat "[" op2 "]"))
                    (if (> (length op3) 0)
                        (concat "(" op3 ")"))
                    "{" (emath-tenretu-loop "," "データの入力(Enterで終了)") "}"))))
;; \SetAngles<#1>[#2]{#3}[#4]{#5}%
;; #1:オリジナルオプション
;;  strings only:弧を描かない
;; #2:#3に対するオプション
;; #3:角におくテキスト
;; #4:picのオプション
;; #5:「始点,中心,終点」のセットを ; 区切りで記述
(defun YaTeX:SetAngles ()
  (let* ((picop (emath-setoption "" "angle radius" "弧の半径(5mm)"))
         (picop (emath-setoption picop "angle eccentricity" "テキストの位置[0で中心1で弧上](.6)")))
    (insert (concat "{" (read-string "テキスト: ") "}"
                    (if (> (length picop) 0)
                        (concat "[" picop "]"))
                    "{" (emath-tenretu-loop ";" "始点,中心,終点を入力(Enterで終了)") "}%"))))
;; Framebox 環境 (枠で囲む，ページで分割可能)
;; \begin{Framebox}<#1>(#2)[#3]{#4}
;;  ほげほげふがふが
;; \end{Framebox}
;; #4:文字列が含まれるときこれをタイトルとする
;;    #4は\tikz\node{#4};となる．
;; #1:#4を含む\nodeのオプション
;; #2:#4を含む\tikzのオプション
;; #3:mdframed 環境のオプション
;; #4:タイトル
(defun YaTeX:Framebox ()
  (let ((title (read-string "Title: ")))
    (concat "\n\t<>% Titleの\\node option\n"
            "\t()% Titleの\\tikz option\n"
            "\t[]% mdframed環境のoption\n"
            (if (> (length title) 0)
                (concat "\t{" title "}%")
              "\t{}%"))))
;; \SetParallels<#1>[#2]{#3}
;; 平行記号を配置するコマンド
;; #1:オリジナルオプション
;;  num:平行記号の数(2)
;;  angle:辺と平行記号のなす角(25)
;;  space:平行記号間の距離(1.5mm)
;;  scale:平行記号のサイズ指定(1)
;;  length:平行記号の線分の長さ(2mm)
;;  pos:平行記号を置く位置(.5)
;; #2:TikZのオプション
;; #3:平行記号を置く辺を指定
;;  A,B;C,D;E,F のように複数指定する
(defun YaTeX:SetParallels ()
  (let* ((op1 (emath-setoption "" "num" "平行記号の数(2)"))
         (op1 (emath-setoption op1 "angle" "辺と平行記号のなす角(25)"))
         (op1 (emath-setoption op1 "space" "平行記号間の距離(1.5mm)"))
         (op1 (emath-setoption op1 "scale" "平行記号のサイズ指定(1)"))
         (op1 (emath-setoption op1 "length" "平行記号の線分の長さ(2mm)"))
         (op1 (emath-setoption op1 "pos" "平行記号を置く位置(.5)")))
    (insert (concat (if (> (length op1) 0)
                        (concat "<" op1 ">"))
                    "{"
                    (emath-tenretu-loop ";" "記号を置く線分をカンマ(,)区切りで指定(Enterで終了)")
                    "}%"))))
;; \SetEquilaterals<#1>[#2]{#3}
;; 等辺記号を配置するコマンド
;; #1:オリジナルオプション
;;  num:等辺記号の数(2)
;;  space:等辺記号間の距離(.75mm)
;;  scale:等辺記号のサイズ指定(1)
;;  length:等辺記号の線分の長さ(2mm)
;;  pos:等辺記号を置く位置(.5)
;; #2:TikZのオプション
;; #3:平行記号を置く辺を指定
;;  A,B;C,D;E,F のように複数指定する
(defun YaTeX:SetEquilaterals ()
  (let* ((op1 (emath-setoption "" "num" "等辺記号の数(2)"))
         (op1 (emath-setoption op1 "space" "等辺記号間の距離(.75mm)"))
         (op1 (emath-setoption op1 "scale" "等辺記号のサイズ指定(1)"))
         (op1 (emath-setoption op1 "length" "等辺記号の線分の長さ(2mm)"))
         (op1 (emath-setoption op1 "pos" "等辺記号を置く位置(.5)")))
    (insert (concat (if (> (length op1) 0)
                        (concat "<" op1 ">"))
                    "{"
                    (emath-tenretu-loop ";" "記号を置く線分をカンマ(,)区切りで指定(Enterで終了)")
                    "}%"))))
;; \DrawSegments<#1>[#2]{#3}
(defun YaTeX:DrawSegments ()
  (let* ((op1 (emath-setoption "" "shift" "原点をシフトさせる点を指定(0,0)"))
         (op1 (emath-setoption op1 "overratio" "線分をはみ出させる割合[無名数は線分の長さの割合,単位付きは実際の長さ](0)")))
    (insert (concat (if (> (length op1) 0)
                        (concat "<" op1 ">"))
                    "{"
                    (emath-tenretu-loop ";" "線分の両端をカンマ(,)区切りで指定(Enterで終了)")
                    "}%"))))
;; \DrawPolygons<#1>[#2]{#3}
(defun YaTeX:DrawPolygons ()
  (let*((op1 (emath-setoption "" "shift" "原点をシフトさせる点を指定(0,0)")))
    (insert (concat (if (> (length op1) 0)
                        (concat "<" op1 ">"))
                    "{"
                    (emath-tenretu-loop ";" "多角形をつくる点列をカンマ(,)区切りで指定(Enterで終了)")
                    "}%"))))
(defun my-tex-mark-setting ()
  (interactive)
  (insert (concat "\\MarkReset\n"
                  "\\HeadNumber\n"
                  "\\SetPrePath{}%\n"
                  "\\SetPath{}%\n"
                  "\\PutMarkAsnwer{試験名}%")))
(defun YaTeX:scope ()
  (concat "\n\t\\clip(LB)rectangle(RT);"))
(defun YaTeX:EqualSidesMarks ()
  (let*((num (read-string "等辺記号の数(2): ")))
    (insert (concat (if (> (length num) 0)
                        (concat "<" num ">"))
                    "{"
                    (emath-tenretu-loop ";" "記号を置く線分をカンマ(,)区切りで指定(Enterで終了)")
                    "}%"))))
(defun YaTeX:EqualArcsMarks ()
  (let*((num (read-string "等弧記号の数(2): ")))
    (insert (concat (if (> (length num) 0)
                        (concat "<" num ">"))
                    "{"
                    (read-string "円弧の中心: ")
                    "}{"
                    (emath-tenretu-loop ";" "記号を置く円弧をカンマ(,)区切りで指定[偏角が小さい順](Enterで終了)")
                    "}%"))))
(defun YaTeX:tikzpicture ()
  (concat "[" "font=\\scriptsize,scale=.5"  "]"))
(eval-after-load 'yatexadd
  `(progn
     (setq YaTeX::ref-mathenv-regexp (concat YaTeX::ref-mathenv-regexp "\\|\\(sub\\)?numcases")
           YaTeX-ref-generate-label-function 'my-yatex-generate-label)
     (defun my-yatex-generate-label (command value)
       (and (string= command "caption")
            (re-search-backward "\\\\begin{\\(figure\\|table\\)}" nil t)
            (setq command (match-string 1)))
       (let ((alist '(("chapter" . "chap")
                      ("section" . "sec")
                      ("subsection" . "subsec")
                      ("figure" . "fig")
                      ("table" . "tbl")
                      ("align" . "eq")
                      ("gather" . "eq")
                      ("numcases" . "eq")
                      ("subnumcases" . "eq")
                      ("equation" . "eq")
                      ("eqnarray" . "eq")
                      ("item" . "enu")))
             (labelname (replace-regexp-in-string
                         "\\(：\\|-\\)" ":"
                         (concat (read-string "問題の出題年度を入力してください: ") ">"
                                  (if (> (length YaTeX-parent-file) 0)
                                     (concat (file-name-sans-extension
                                              (file-name-nondirectory
                                               YaTeX-parent-file)) ">"))
                                 (file-name-sans-extension
                                  (file-name-nondirectory
                                   (buffer-name)))))))
         (if (setq command (cdr (assoc command alist)))
             (concat command ":"
                     (read-string "ユニークになるように番号などを入力してください: "
                                  (concat labelname ":" value)))
           (YaTeX::ref-generate-label nil nil))))
     ))
;; tcbFramebox 環境
(defun YaTeX:tcbFramebox ()
  (let ((title (read-string "タイトルを入力(不要のときは省略): ")))
    (concat "{" title "}")))
;; hlist 環境
(defun YaTeX:hlist ()
  (insert "\\nouseparheadparenindent\n")
  (let ((option (read-string "番号の形式指定: " "\\arabic")))
    (concat "[pre label={},"
            (if (y-or-n-p "括弧を付けますか?: ")
                (concat "label={(" option "{hlisti})}")
              (concat "label={" option "{hlisti}}"))
            "]"
            (read-string "列数の指定: " "3"))))
(provide 'for-original-macro)
