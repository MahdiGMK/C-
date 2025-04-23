#lang racket

(require parser-tools/yacc "lexer.rkt")

(define (node tag . children) (cons tag children))

(define full-parser
  (parser
   (start program)
   (end   EOF)
   (error (lambda (tok? name val)
            (error 'parser (format "syntax error near ~a (~a)" name val))))
   (tokens literals syms)

   (grammar

    (program      ((items) (node 'program $1)))
    (items        (()            '())
                  ((items item)  (append $1 (list $2))))
    (item         ((statement SEMI) $1)
                  ((func-def)       $1)
                  ((struct-def)     $1))


    (statement
     ((vardef)        $1)
     ((vardef-assign) $1)
     ((assign)        $1)
     ((if-stmt)       $1)
     ((for-stmt)      $1)
     ((while-stmt)    $1)
     ((break)         $1)
     ((continue)      $1)
     ((return-stmt)   $1)
     ((expr)          $1))

    (break          ((BREAK)             (node 'break)))
    (continue       ((CONTINUE)          (node 'continue)))
    (return-stmt    ((RETURN)            (node 'return-void))
                    ((RETURN expr)       (node 'return $2)))
    (vardef         ((type ID)           (node 'vardecl $1 $2)))
    (vardef-assign ((type ID ASSIGN expr) (node 'vardecl-assign $1 $2 $4)))
    (assign         ((expr ASSIGN expr)  (node 'assign $1 $3)))

    (if-stmt
     ((IF OP expr CP then-body)                      (node 'if $3 $5 '()))
     ((IF OP expr CP then-body ELSE else-body)       (node 'if $3 $5 $7)))
    (then-body      ((statement)         $1)
                    ((OCB items CCB)     (node 'block $2)))
    (else-body      ((statement)         $1)
                    ((OCB items CCB)     (node 'block $2)))
    (while-stmt     ((WHILE OP expr CP body) (node 'while $3 $5)))
    (body           ((statement)         $1)
                    ((OCB items CCB)     (node 'block $2)))
    (for-stmt
     ((FOR OP expr SEMI expr SEMI expr CP body)
      (node 'for $3 $5 $7 $9)))

    (struct-def
     ((STRUCT ID OCB struct-fields CCB) (node 'struct $2 $4)))
    (struct-fields
     (()                          '())
     ((struct-fields type ID COMMA) (append $1 (list (node 'field $2 $3))))
     ((struct-fields type ID)     (append $1 (list (node 'field $2 $3)))))

    (func-def
     ((type ID OP CP function-body)              (node 'func $2 '() $1 $5))
     ((type ID OP params CP function-body)       (node 'func $2 $4  $1 $6)))
    (params
     ((param)                 (list $1))
     ((params COMMA param)    (append $1 (list $3))))
    (param           ((type ID)         (node 'param $1 $2)))
    (function-body   ((OCB items CCB)   (node 'block $2)))

    (type
     ((ID)                   (node 'type-id $1))
     ((OB CB type)           (node 'array $3))
     ((STRUCT)               (node 'type-struct))
     ((VOID)                 (node 'type-void)))

    (expr         ((assign) $1)
                  ((or-expr) $1))
    (or-expr      ((or-expr OROR and-expr)  (node '|| $1 $3))
                  ((and-expr)               $1))
    (and-expr     ((and-expr ANDAND rel-expr) (node '&& $1 $3))
                  ((rel-expr)                $1))
    (rel-expr     ((rel-expr LT sum)   (node '< $1 $3))
                  ((rel-expr GT sum)   (node '> $1 $3))
                  ((rel-expr LTE sum)  (node '<= $1 $3))
                  ((rel-expr GTE sum)  (node '>= $1 $3))
                  ((rel-expr EQEQ sum) (node '== $1 $3))
                  ((rel-expr NEQ sum)  (node '!= $1 $3))
                  ((sum)                $1))
    (sum          ((sum PLUS term)     (node '+ $1 $3))
                  ((sum MINUS term)    (node '- $1 $3))
                  ((term)              $1))
    (term         ((term MUL unary)    (node '* $1 $3))
                  ((term DIV unary)    (node '/ $1 $3))
                  ((term MOD unary)    (node '% $1 $3))
                  ((unary)             $1))
    (unary        ((NOT unary)         (node 'not $2))
                  ((BITNOT unary)      (node '~ $2))
                  ((MINUS unary)       (node 'neg $2))
                  ((postfix)           $1))

    (postfix       ((primary)                   $1)
                   ((postfix DOT ID)            (node 'field $1 $3))
                   ((postfix OB expr CB)        (node 'index $1 $3))
                   ((postfix OP CP)             (node 'call $1 '()))
                   ((postfix OP arg-list CP)    (node 'call $1 $3)))
    (arg-list      ((expr)                 (list $1))
                   ((arg-list COMMA expr)  (append $1 (list $3))))

    (primary
     ((INT)       (node 'int    $1))
     ((FLOAT)     (node 'float  $1))
     ((CHAR)      (node 'char   $1))
     ((STRING)    (node 'string $1))
     ((TRUE)      (node 'bool   #t))
     ((FALSE)     (node 'bool   #f))
     ((ID)        (node 'id     $1))
     ((OP expr CP)                  $2)
     ((STRUCT OCB CCB)              (node 'struct-lit '()))
     ((ID OCB CCB)                  (node 'struct-lit $1 '()))
     ((ID OCB struct-literal-fields CCB) (node 'struct-lit $1 $3))
     ((OB CB type OCB CCB)          (node 'array-lit $3 '()))
     ((OB CB type OCB array-elems CCB) (node 'array-lit $3 $5))
     ((OCB items CCB)               (node 'block $2)))

(struct-literal-fields
 ((field-assign)                             (list $1))
 ((field-assign COMMA struct-literal-fields) (cons $1 $3)))


    (field-assign
     ((ID ASSIGN expr) (node 'field-assign $1 $3)))

    (array-elems
     ((expr)                         (list $1))
     ((array-elems COMMA expr)       (append $1 (list $3)))
     ((array-elems COMMA)            $1))
    )))

(provide full-parser)
