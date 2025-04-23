#lang racket

(require parser-tools/lex
         (prefix-in : parser-tools/lex-sre))

(define-lex-abbrev DIG      (:+ (char-range #\0 #\9)))
(define-lex-abbrev LETTER   (:or (char-range #\a #\z) (char-range #\A #\Z) #\_))
(define-lex-abbrev ID-TAIL  (:* (:or LETTER DIG)))
(define-lex-abbrev ID       (:: LETTER ID-TAIL))
(define-lex-abbrev SIGNED   (:+ (:or "+" "-")))
(define-lex-abbrev ESC      (:: #\\ (:or "\"" "'" "\\" "n" "t")))
(define-lex-abbrev NON-NEWLINE-CHAR
  (:or (char-range #\u0000 #\u0009)
       (char-range #\u000B #\uFFFF)))

(define-lex-abbrev CHAR-ESCAPE
  (:: #\\ (:or "\"" "'" "\\" "n" "t")))

(define-lex-abbrev SAFE-CHAR
  (:or (char-range #\u0000 #\u0021)
       (char-range #\u0023 #\u005B)
       (char-range #\u005D #\uFFFF)))

(define-lex-abbrev SAFE-STR-CHAR
  (:or (char-range #\u0000 #\u0021)
       (char-range #\u0023 #\u005B)
       (char-range #\u005D #\uFFFF)))





(define full-lexer
  (lexer
   (whitespace (full-lexer input-port))
((:: "//" (:* NON-NEWLINE-CHAR)) (full-lexer input-port))

   ((:or (:: SIGNED DIG #\. DIG)
         (:: DIG #\. DIG))
    (token-FLOAT (string->number lexeme)))
   ((:or (:: SIGNED DIG) DIG)
    (token-INT (string->number lexeme)))
((:: #\' (:or SAFE-CHAR CHAR-ESCAPE) #\') (token-CHAR lexeme))
((:: #\" (:* (:or SAFE-STR-CHAR CHAR-ESCAPE)) #\") (token-STRING lexeme))

   ("struct"    (token-STRUCT))
   ("if"        (token-IF))
   ("else"      (token-ELSE))
   ("for"       (token-FOR))
   ("while"     (token-WHILE))
   ("break"     (token-BREAK))
   ("continue"  (token-CONTINUE))
   ("return"    (token-RETURN))
   ("void"      (token-VOID))
   ("true"      (token-TRUE))
   ("false"     (token-FALSE))

   ("||" (token-OROR))   ("&&" (token-ANDAND))
   ("<=" (token-LTE))    (">=" (token-GTE))
   ("==" (token-EQEQ))   ("!=" (token-NEQ))
   ("<"  (token-LT))     (">"  (token-GT))
   ("|"  (token-BITOR))  ("&"  (token-BITAND))
   ("~"  (token-BITNOT)) ("^"  (token-BITXOR))
   ("!"  (token-NOT))
   ("*"  (token-MUL))    ("/"  (token-DIV))   ("%" (token-MOD))
   ("+"  (token-PLUS))   ("-"  (token-MINUS))
   ("="  (token-ASSIGN))
   ("."  (token-DOT))
   ("["  (token-OB))     ("]"  (token-CB))
   ("{"  (token-OCB))    ("}"  (token-CCB))
   ("("  (token-OP))     (")"  (token-CP))
   (";"  (token-SEMI))   (","  (token-COMMA))

   (ID (token-ID lexeme))

   ((eof) (token-EOF))))

(define-tokens literals (INT FLOAT CHAR STRING ID))
(define-empty-tokens syms
  (EOF
   STRUCT IF ELSE FOR WHILE BREAK CONTINUE RETURN VOID TRUE FALSE
   OROR ANDAND LTE GTE EQEQ NEQ LT GT BITOR BITAND BITNOT BITXOR NOT
   MUL DIV MOD PLUS MINUS ASSIGN DOT OB CB OCB CCB OP CP SEMI COMMA))

(provide (all-defined-out))
