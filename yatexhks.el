;;; -*- Emacs-Lisp -*-
;;; Hooks for YaTeX

;;; �쒹�Ɋ֘A����L�q(���Ƃ��΃A�h�C���֐�)�� yatexhks.el �Ƃ������O��
;;; �t�@�C���ɓ���Ă��������B�N�����Ɏ����I�Ƀ��[�h���܂��B

;;; All the private definitions for YaTeX can be stuffed into the file
;;; named `yatexhks.el'.  The file `yatexhks.el' will be automatically
;;; loaded at the end of loading `yatex.el'.

;Private definitions begin from here.

;;97/1/27
(define-key YaTeX-user-extensional-map "v" 'YaTeX-section-overview)
;;initial version
(let ((map YaTeX-user-extensional-map))
  (define-key map "0"
    (function (lambda () (interactive)
		(YaTeX-make-section nil nil nil "part"))))
  (define-key map "1"
    (function (lambda () (interactive)
		(YaTeX-make-section nil nil nil "chapter"))))
  (define-key map "2"
    (function (lambda () (interactive)
		(YaTeX-make-section nil nil nil "section"))))
  (define-key map "3"
    (function (lambda () (interactive)
		(YaTeX-make-section nil nil nil "subsection"))))
  (define-key map "4"
    (function (lambda () (interactive)
		(YaTeX-make-section nil nil nil "subsubsection"))))
  (define-key map "5"
    (function (lambda () (interactive)
		(YaTeX-make-section nil nil nil "paragraph"))))
  (define-key map "6"
    (function (lambda () (interactive)
		(YaTeX-make-section nil nil nil "subparagraph"))))
  (define-key map "r"
    (function (lambda () (interactive)
		(YaTeX-make-section nil nil nil "ref"))))
  (define-key map "i"
    (function (lambda () (interactive)
		(YaTeX-make-singlecmd "item"))))
  (define-key map "\C-b"
    (function (lambda () (interactive)
		(YaTeX-make-singlecmd "leftarrow"))))
  (define-key map "l"
    (function (lambda () (interactive)
		(YaTeX-make-section nil nil nil "label"))))
  (define-key map "f"
    (function (lambda () (interactive)
		(YaTeX-make-section nil nil nil "frac"))))
  (define-key map "S"
    (function (lambda () (interactive)
		(YaTeX-make-section nil nil nil "setlength"))))
  (define-key map "b"
    (function (lambda () (interactive)
		(YaTeX-make-fontsize nil "bf"))))
  (define-key map "I" 'YaTeX-browse-info))

(defun YaTeX-browse-info ()
 "Browse YaTeX's info"
 (interactive)
 (require 'info)
 (Info-goto-node (if YaTeX-japan "(yatexj)Top" "(yatexe)Top")))



(require 'for-emath-macro)
(require 'for-original-macro)

(fset 'YaTeX::eqref 'YaTeX::ref)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; YaTeX:read-position "htbp" --> [ht] �Ȃǂ��쐬
;; YaTeX:read-coordinates "(x,y) x,y�Ƃ��P�ʕt�����l --> (1pt,2pt) �Ȃǂ��쐬"
;; (YaTeX:func arg) --> arg�������ɂ���YaTeX:func ���Ăяo��
;; (apply 'YaTeX:func arg) --> arg�������ɂ���YaTeX:func ���Ăяo����������ԍŌ�̈�����list�łȂ���΂����Ȃ�
;; (fset 'func1 'func2) --> func1 �� func2 �Ɠ����ݒ�ɂ���
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; YaTeX-my-dviout-search-and-jump
;;;
;;; dviout �̃W�����v�@�\�� Meadow ����g����悤�ɂ��鎎�݁D
;;;
;;; [prefix] j �Ŏg�p���� `j' ��jump�̈ӁDYaTeX-define-key���g���Ċe�X�̊��ɉ����ĕύX�\�D
;;; �|�C���g�̑��̕�����`strings'�Ƃ��̕����񂪂���s�̃t�@�C���擪����̍s��`lineno'�����
;;; ���͂��Ă���t�@�C����`texfile'�Ƃ���dvi�t�@�C����`dvifile'��
;;; ``dvi2-command'' ��2�̈��� ``dvifile'' ``# lineno/strings texfile'' ��n���D
;;; `dvi2-command'��YaTeX�̕ϐ��Ŋe�X�̊��ɍ��킹�Đݒ肷��D�ʏ��``c:/dviout/dviout''�ȂǂƂȂ��Ă���D
;;; �����dviout�Ƀp�X���ʂ��Ă����``dviout''�ō\��Ȃ��͂��ł���D
;;;
;;; �ʏ��`dvifile'�C`texfile'�̓J�����g�o�b�t�@�Ɋւ���t�@�C�����ł��邪�C
;;; `YaTeX-my-dvifile'��`YaTeX-my-sourcefile'��`nil'�ȊO�̂Ƃ��͂���ɏ]���D
;;; �Ⴆ�΁C�\�[�X�t�@�C����`main.tex'�Ƃ�������ǂݍ��܂��`sub.tex'�̂Ƃ��́C`sub.tex'�ҏW����
;;; ``dviout sub.dvi "# lineno/search_strings sub.tex"''��dviout���N�����Ă��v���悤�Ȍ��ʂɂȂ�Ȃ��D
;;; ``dviout main.tex "# lineno/search_strings ./sub.tex"''�Ƃ��Ȃ���΂Ȃ�Ȃ����C
;;; ���̍ۂ�`YaTeX-my-dvifile'��`main.dvi'�C`YaTeX-my-sourcefile'��`./sub.tex'���Z�b�g���Ă�����
;;; ��҂̂悤��dviout�Ɉ�����������D�ڂ�����YaTeX-my-menu�̐�����...
;;; ���̕�����̃Z�b�g��YaTeX-my-menu�ōs�Ȃ��D
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
;; cmd ��ł� ``c:/dviout/dviout dvifilename "# lineno/search_strings texfilename"'' �ł��邪
;; start-process �ł� ``c:/dviout/dviout'' �� ``dvifilename'' �� ``# lineno/search_strings texfilename''
;; ��n���Ă���D����� ``"dvifilename"'' �� ``"# lineno/search_strings texfilename"'' ��n���Ă���̂��ȁH
;; ����œ��삷��̂�����^��Ɏv��Ȃ����Ƃɂ���:-)
;; �b��}�[�N���[�h���ۂ��œ���܂��͎g�p����֐���ύX����H
;; ��芸�����C�b��}�[�N���[�h���� region �����݂���Ƃ����� region �𗘗p���āC
;; ����ȊO�̂Ƃ��� thing-at-point �𗘗p���邱�Ƃɂ���D
;; �v���؂��āCthing-at-point ���g�킸�� (interactive "r") �ɂ��������g�����肪�����̂��ȁH
;; ����Ƃ��C��� region ��ݒ肵�Ă��� dviout ���N������͎̂�Ԃ��ȁH
;; �t�ɁC��� thing-at-point �ɂ����Ⴄ�H
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
;; ���Y�^
;;  (elt (member 'shift_jis (coding-system-list)) 1)
;;  set-terminal-coding-system CODING-SYSTEM
;;  encode-coding-string STRING CODING-SYSTEM
;;  detect-coding-string STRING HIGHEST
;;  find-coding-systems-string STRING
;;  shell-quote-argument
;;  file-name-nondirectory
;;  file-name-sans-extension
;;  dvi2-command �� .emacs �ɂĒ�`�ς� "c:/dviout/dviout"
;;  texput�ɂ͑Ή����Ă��Ȃ�...�Ƃ������Ή�����K�v�͂Ȃ����
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; YaTeX-my-insert-paren
;;;
;;; region�����ʂň͂�
;;; ���ʂƂ�����\left,\right�����
;;; ���łɐ��������ł���悤�ɂ�������...
;;; YaTeX-insert-parens ���� YaTeX �̊֐��ƏՓ˂��Ă�����Ȃ���Ȃ�^^;
;;; �Ƃ������Ƃ� my ��t��
(YaTeX-define-key "p" 'YaTeX-my-insert-paren)
(defun YaTeX-my-insert-paren (beg end)
  (interactive "r")
  (message (concat "(g)rouping:`{}' (b)race:`\\{\\}' (p)aren:`()' b(r)acket:`[]' less (t)han:`<>'\n"
		   "(m)ath:`$$' (d)isplay:`\\[\\]' (l)eft:`\\left\\right' "
		   "(s)elf:�����Őݒ� ���ʗނ͑啶����\\left\\right�t��"))
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
		       ((= emchar ?s) (read-string "�����ʂ��w��: "))
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
			((= emchar ?s) (read-string "�E���ʂ��w��: "))
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
;;; p �� YaTeX-my-insert-paren ���Ăяo��(region��ݒ肵�Ă��Ȃ���΂Ȃ�Ȃ�)�D
;;; j �� YaTeX-my-dviout-search-and-jump ���Ăяo���D
;;; t �� �����f�B���N�g���ɂ��� texput.tex ���J�� %#!�̍s���̃t�@�C������ texput �ɒu��������D
;;;   �����BEGIN-END�̌Œ�̈�̃^�C�v�Z�b�g���s�Ȃ��Ƃ��C���̗̈����Perl�̌Ăяo���Ɋւ��
;;;   �}�N��������Ǝv���悤�ȕ\��������Ȃ����߁Ctexput.tex�Ɉꎞ�I�Ɉړ�����
;;;   �t�@�C������`texput.tex'�ƕҏW��2�x�قǃR���p�C�����s�Ȃ��Ă��猳�̃\�[�X�t�@�C���ɖ߂��
;;;   ���܂����ƌŒ�̈�̃^�C�v�Z�b�g�𑱂�����̂ŁC�t�@�C����������������̂��������������́D
;;;   �ύX�������Ȃ��Ƃ���`q'�Ŕ�����΂悢�D
;;; s �� �\�[�X�t�@�C������\include�܂���\input����Ă���\�[�X��ҏW����ۂ�
;;;   \include��\input�̂���s�Ƀ|�C���g��u����������s���Ă����D
;;;   �������C\include��\input��1�s��1�����̃R�}���h����������Ă��Ȃ����̂Ƃ���D
;;;   main.tex��\include{./sub.tex}�ɂ����Ă�������s����ƁC
;;;   �ϐ�`YaTeX-my-dvifile'��`main.dvi'�C�ϐ�`YaTeX-my-sourcefile'��`./sub.tex'���������C
;;;   YaTeX-my-dviout-search-and-jump�����s�����dviout��
;;;   ``main.dvi "# lineno/search_strings ./sub.tex"''���n�����D
;;;   �܂��C\include{./hoge/sub.tex}�̏ꍇ�ɂ�`YaTeX-my-dvifile'��`../main.dvi'�C
;;;   `YaTeX-my-sourcefile'��`./hoge/sub.tex'���������Cdviout��
;;;   ``../main.dvi "# lineno/search_strings ./hoge/sub.tex"''���n�����D
;;;   �����`./hoge/sub.tex'�ҏW����`main.dvi'���Ăяo���Ƃ����l����ƁC
;;;   ���̂Ƃ��̃J�����g�f�B���N�g����`./hoge/'�ł��肱������`./main.dvi'��
;;;   �Ăяo�����Ƃ���ƈ��̃f�B���N�g����`main.dvi'���Ăяo�����ƂɂȂ�̂�dviout�ɂ�
;;;   �f�B���N�g��`./hoge/'����`../main.dvi'��ǂݍ��߂Ɩ��߂���K�v������D
;;;   ����ɁC����`./main.dvi'����݂�ƃ\�[�X�t�@�C����`./hoge/sub.tex'�ł��邩��T�[�`&�W�����v�̍ۂ�
;;;   TeX�t�@�C�����Ƃ���`./hoge/sub.tex'��n���K�v�����邩��ł���D
;;;   �܂��C\include�C\input�̈����̓J�����g�f�B���N�g����\��`./'���擪�ɕK��������̂Ƃ��Ă���D
;;;   �擪��\include{sub.tex}�̂悤��`./'���Ȃ��ꍇ�́C"`YaTeX-my-sourcefile'�̐ݒ�: sub.tex"
;;;   �ƃf�t�H���g�l��`sub.tex'�Ƃ��Đݒ肷��t�@�C�����𕷂��Ă���̂ŁC
;;;   �擪��`./'��t������`./sub.tex'�Ƃ��ē��͂�����D
;;; i �� s �Őݒ肵���t�@�C���������ׂ�nil�ɂ���D
(YaTeX-define-key "r" 'YaTeX-my-menu)
(defun YaTeX-my-menu ()
  (interactive)
  (message (concat "p)���ʕt�� j)dviout�ւ̕�����T�[�`&�W�����v t)texput.tex�ֈړ�\n"
		   "s)`YaTeX-my-dvifile'�����`YaTeX-my-sourcefile'�̐ݒ� "
		   "i)`YaTeX-my-dvifile'�����`YaTeX-my-sourcefile'�̏�����"))
  (let* ((emchar (read-char)))
    (cond ((= emchar ?p)(YaTeX-my-insert-paren (region-beginning) (region-end)))
	  ((= emchar ?j)(YaTeX-my-dviout-search-and-jump))
	  ((= emchar ?t)(progn (find-file "./texput.tex")
			       (perform-replace "[-0-9a-zA-Z]+$" "texput" t t nil)))
	  ((= emchar ?s)(save-excursion;;cond �� save-excursion �ł���ނ� insert-paren �I����̃J�[�\���ʒu�����ɖ߂�
			  (setq-default
			   YaTeX-my-dvifile
			   (read-string
			    (format "%s: " "`YaTeX-my-dvifile'�̐ݒ�")
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
			   (read-string (format "%s: " "`YaTeX-my-sourcefile'�̐ݒ�")
					(concat (buffer-substring-no-properties
						 (- (re-search-forward "\\(}\\| \\|$\\)") 1)
						 (+ (re-search-backward "\\({\\| \\)") 1))
						".tex")))))
	  ((= emchar ?i)(setq-default YaTeX-my-dvifile nil
				      YaTeX-my-sourcefile nil)))))
;
;;; End of yatexhks.el
(provide 'yatexhks)
;
;;; End of yatexhks.el
(provide 'yatexhks)
