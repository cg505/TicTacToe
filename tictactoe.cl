(defun game-over? (board symbol)
  (or (and (eq (aref board 0 0) symbol) (eq (aref board 0 1) symbol) (eq (aref board 0 2) symbol)) 
      (and (eq (aref board 1 0) symbol) (eq (aref board 1 1) symbol) (eq (aref board 1 2) symbol)) 
      (and (eq (aref board 2 0) symbol) (eq (aref board 2 1) symbol) (eq (aref board 2 2) symbol)) 
      (and (eq (aref board 0 0) symbol) (eq (aref board 1 0) symbol) (eq (aref board 2 0) symbol)) 
      (and (eq (aref board 0 1) symbol) (eq (aref board 1 1) symbol) (eq (aref board 2 1) symbol))
      (and (eq (aref board 0 2) symbol) (eq (aref board 1 2) symbol) (eq (aref board 2 2) symbol))
      (and (eq (aref board 0 0) symbol) (eq (aref board 1 1) symbol) (eq (aref board 2 2) symbol))
      (and (eq (aref board 0 2) symbol) (eq (aref board 1 1) symbol) (eq (aref board 2 0) symbol))))

(defun game-over-cats? (board)
  (and (or (eq (aref board 0 0) 'O) (eq (aref board 0 0) 'X))
       (or (eq (aref board 0 1) 'O) (eq (aref board 0 1) 'X))
       (or (eq (aref board 0 2) 'O) (eq (aref board 0 2) 'X))
       (or (eq (aref board 1 0) 'O) (eq (aref board 1 0) 'X))
       (or (eq (aref board 1 1) 'O) (eq (aref board 1 1) 'X))
       (or (eq (aref board 1 2) 'O) (eq (aref board 1 2) 'X))
       (or (eq (aref board 2 0) 'O) (eq (aref board 2 0) 'X))
       (or (eq (aref board 2 1) 'O) (eq (aref board 2 1) 'X))
       (or (eq (aref board 2 2) 'O) (eq (aref board 2 2) 'X))))

(defun game-over-all? (board)
  (or (game-over? board 'X)
      (game-over? board 'O)
      (game-over-cats? board)))

(defun move (player symbol board formats)
  (format formats "~%~a's turn~%Enter horizontal cordinate: "
    player)
  (let ((horiz (- (read) 1)))
    (format t "Enter vertical cordinate: ")
    (let ((vert (- (read) 1)))
      (if (legal-move? horiz vert board)
          (set-board-after-move symbol board horiz vert formats)
        (progn (format formats "~%Illegal move.  Try again.")
          (move player symbol board formats))))))
        
        
(defun set-board-after-move (symbol board horiz vert formats) 
  (progn (setf (aref board vert horiz) symbol)
    (format formats "~a | ~a | ~a~%---------~%~a | ~a | ~a~%---------~%~a | ~a | ~a"
      (aref board 0 0)
      (aref board 0 1)
      (aref board 0 2)
      (aref board 1 0)
      (aref board 1 1)
      (aref board 1 2)
      (aref board 2 0)
      (aref board 2 1)
      (aref board 2 2))))
   
             
(defun play (&key (player1 "Player 1")
                  (player2 "Player 2")
                  (ai-p1? nil)
                  (ai-p2? nil)
		  (rand-p1? nil)
		  (rand-p2? nil)
                  (formats t))
  (if (and ai-p1? rand-p1?)
      (progn (format t "~%Fail. You can't have the same player (p1) be random and smart...~%Assuming you meant smart.")
	     (setq rand-p1? nil)))
  (if (and ai-p2? rand-p2?)
      (progn (format t "~%Fail. You can't have the same player (p2) be random and smart...~%Assuming you meant smart.")
	     (setq rand-p2? nil)))
  (let ((board (make-array '(3 3) :initial-element " ")))
    (loop until (game-over-all? board)
        do (if (or rand-p1? ai-p1?)
               (progn (format formats "~%I'm thinking...")
		      (if ai-p1?
			  (let ((ai-move (second (min-max-value board t))))
			    (move-ai player1 'X board ai-move formats)))
		      (if rand-p1?
			  (move-rand player1 'X board formats)))
             (move player1 'X board formats))
        until (game-over-all? board)
        do (if (or rand-p2? ai-p2?)
               (progn (format formats "~%I'm thinking...")
		      (let ((ai-move (second (min-max-value board nil))))
			(move-ai player2 'O board ai-move formats)))
             (move player2 'O board formats)))
    (if (game-over? board 'X)
        (progn (format t "~%~a wins!"
		       player1) 1)
      (if (game-over? board 'O)
          (progn (format t "~%~a wins!"
			 player2) 2)
        (if (game-over-cats? board)
            (progn (format t "~%It's a cat's game!  No one wins!") nil)
          (format t "~%What? The game's over? It doesn't seem like it!"))))))

(defun legal-move? (horiz vert board)
  (if (or (not (numberp vert))
          (not (numberp horiz))
          (> horiz 2)
          (> vert 2))
      (eq (aref board vert horiz) 'X)
    (eq (aref board vert horiz) 'O))
  nil
  t)
  
(DEFUN min-max-value (board max?)
  (if (game-over-all? board)
      (if (game-over-mm? board t)
          (list 1)
        (if (game-over-mm? board nil)
            (list -1)
          (list 0)))
    (let ((best-move nil)
          (best-value (if max? -2 2))
          (moves (get-moves board)))
      (dolist (move moves)
        (play-move board move (if max? 'X 'O))
        (let ((move-value (first (min-max-value board (not max?)))))
          (when (or (and (= move-value best-value) (= (random 2) 0))
                    (funcall (if max? #'> #'<) move-value best-value))
            (setf best-value move-value)
            (setf best-move move))
          (undo-move board move)))
      (list best-value best-move))))

(defun game-over-mm? (board max?)
  (if max?
      (game-over? board 'X)
    (game-over? board 'O)))

(defun move-ai (player symbol board move formats)
  (let ((horiz (first move))
        (vert (second move)))
  (format formats "~%~a (CPU) played (~a,~a).~%"
    player (+ 1 horiz) (+ 1 vert))
      (if (legal-move? horiz vert board)
          (set-board-after-move symbol board horiz vert formats)
        (progn (format formats "~%Illegal move.  Try again.")
          (move player symbol board formats)))))

(defun move-rand (player symbol board formats)
  (let ((horiz (random 3))
        (vert (random 3)))
    (format formats "~%~a plays (~a,~a)"
      player (+ 1 horiz) (+ 1 vert))
    (if (legal-move? horiz vert board)
        (set-board-after-move symbol board horiz vert formats)
      (progn (format formats "Illegal move.  Try again.")
        (mover player symbol board formats)))))

(defun play-move (board move symbol)
  (let ((horiz (first move))
        (vert (second move)))
    (setf (aref board vert horiz) symbol)))

(defun undo-move (board move)
  (let ((horiz (first move))
        (vert (second move)))
    (setf (aref board vert horiz) " ")))
  
(defun get-moves (board)
  (let ((possible-moves nil))
    (dotimes (horiz 3)
      (dotimes (vert 3)
        (if (not (or (eq (aref board vert horiz) 'O)
                     (eq (aref board vert horiz) 'X)))
            (push (list horiz vert) possible-moves))))
    possible-moves))

(defun move-value (move board)
  (aref board (second move) (first move)))

(defun lots-smart (num-games)
  (let ((p1-wins 0)
        (p2-wins 0)
        (cat-wins 0)
        (games-left num-games))
    (loop until (= games-left 0)
        do (let ((winner (play :ai-p1? t :ai-p2? t :formats nil)))
             (if (and (numberp winner) (= winner 1))
                 (incf p1-wins)
               (if (and (numberp winner) (= winner 2))
                   (incf p2-wins)
                 (incf cat-wins))))
          (decf games-left))
    (format t "~%Computer Player 1=~a%~%Computer Player 2=~a%~%Cat=~a%"
      (* 100.00 (/ p1-wins num-games)) (* 100.00 (/ p2-wins num-games)) (* 100.00 (/ cat-wins num-games)))))
