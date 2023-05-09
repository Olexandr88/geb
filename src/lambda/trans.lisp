(in-package :geb.lambda.trans)

(named-readtables:in-readtable :fare-quasiquote)

(deftype stlc-context () `list)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Main Transformers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defmethod to-bitc ((obj <stlc>))
  "I convert a lambda term into a [GEB.BITC.SPEC:BITC] term

Note that [\\<STLC\\>] terms with free variables require a context,
and we do not supply them here to conform to the standard interface

If you want to give a context, please call [to-cat] before
calling me"
  (~>> obj
       (to-cat nil)
       geb.common:to-bitc))

(defmethod to-poly ((obj <stlc>))
  "I convert a lambda term into a [GEB.POLY.SPEC:POLY] term

Note that [\\<STLC\\>] terms with free variables require a context,
and we do not supply them here to conform to the standard interface

If you want to give a context, please call [to-cat] before
calling me"
  (~>> obj
       (to-cat nil)
       geb.common:to-poly))

(defmethod to-circuit ((obj <stlc>) name)
  "I convert a lambda term into a vampir term

Note that [\\<STLC\\>] terms with free variables require a context,
and we do not supply them here to conform to the standard interface

If you want to give a context, please call [to-cat] before
calling me"
  (assure list
    (~> (to-bitc obj)
        (geb.common:to-circuit name))))

(defmethod empty ((class (eql (find-class 'list)))) nil)

(defmethod to-cat (context (tterm <stlc>))
  "Compiles a checked term in an appropriate context into the
morphism of the GEB category. In detail, it takes a context and a term with
following restrictions: Terms come from [STLC][type]  with occurences of
[SO-HOM-OBJ][GEB.MAIN:SO-HOM-OBJ] replaced by [FUN-TYPE][class] and should
come without the slow of [TTYPE][generic-function] accessor filled for any of
the subterms. Context should be a list of [SUBSTOBJ][GEB.SPEC:SUBSTOBJ] with
the caveat that instead of [SO-HOM-OBJ][GEB.MAIN:SO-HOM-OBJ] we ought to use
[FUN-TYPE][class], a stand-in for the internal hom object with explicit
accessors to the domain and the codomain. Once again, note that it is important
for the context and term to be giving as per above description. While not
always, not doing so result in an error upon evaluation. As an example of a
valid entry we have

```lisp
 (to-cat (list so1 (fun-type so1 so1)) (app (index 1) (list (index 0))))
```

while

```lisp
(to-cat (list so1 (so-hom-obj so1 so1)) (app (index 1) (list (index 0))))
```

produces an error. Error of such kind mind pop up both on the level of evaluating
[WELL-DEFP][generic-function] and [ANN-TERM1][generic-function].

Moreover, note that for terms whose typing needs addition of new context
we append contexts on the left rather than on the right contra usual type
theoretic notation for the convenience of computation. That means, e.g. that
asking for a type of a lambda term as below produces:

```lisp
LAMBDA> (ttype (term (ann-term1 nil (lamb (list so1 so0) (index 0)))))
s-1
```

as we count indeces from the left of the context while appending new types to
the context on the left as well. For more info check [LAMB][class]"
  (labels ((rec (context tterm)
             (match-of stlc tterm
               ((absurd tcod term)
                (comp (init tcod)
                      (rec context term)))
               (unit
                (terminal (stlc-ctx-to-mu context)))
               ((left term)
                (let ((tott (ttype tterm)))
                  (comp (->left (mcar tott) (mcadr tott))
                        (rec context term))))
               ((right term)
                (let ((tott (ttype tterm)))
                  (comp (->right (mcar tott) (mcadr tott))
                        (rec context term))))
               ((case-on on ltm rtm)
                (let ((ctx  (stlc-ctx-to-mu context))
                      (mcr  (mcar (ttype on)))
                      (mcdr (mcadr (ttype on))))
                  (comp (comp (mcase (commutes-left (rec
                                                     (cons mcr context) ltm))
                                     (commutes-left (rec
                                                     (cons mcdr context) rtm)))
                              (commutes-left (distribute ctx
                                                         (fun-to-hom mcr)
                                                         (fun-to-hom mcdr))))
                        (geb:pair (rec context on)
                                  ctx))))
               ((pair ltm rtm)
                (geb:pair (rec context ltm)
                          (rec context rtm)))
               ((fst term)
                (let ((tottt (ttype term)))
                  (comp (<-left (mcar tottt) (mcadr tottt))
                        (rec context term))))
               ((snd term)
                (let ((tottt (ttype term)))
                  (comp (<-right (mcar tottt) (mcadr tottt))
                        (to-cat context term))))
               ((lamb tdom term)
                (rec (append tdom context) term))
               ((app fun term)
                (comp (rec context fun)
                      (reduce #'geb:pair
                              (mapcar (lambda (x) (rec context x))
                                      term)
                              :initial-value (stlc-ctx-to-mu context)
                              :from-end t)))
               ((index pos)
                (stlc-ctx-proj context pos)))))
    (if (well-defp context tterm)
        (rec context (ann-term1 context tterm))
        (error "not a well-defined ~A in said ~A" tterm context))))



(-> stlc-ctx-to-mu (stlc-context) substobj)
(defun stlc-ctx-to-mu (context)
  "Converts a generic [<STLC>][type] context into a
[SUBSTMORPH][GEB.SPEC:SUBSTMORPH]. Note that usually contexts can be interpreted
in a category as a $\Sigma$-type$, which in a non-dependent setting gives us a
usual [PROD][class]

```lisp
LAMBDA> (stlc-ctx-to-mu (list so1 (fun-to-hom (fun-type geb-bool:bool geb-bool:bool))))
(× s-1
   (× (+ GEB-BOOL:FALSE GEB-BOOL:TRUE) (+ GEB-BOOL:FALSE GEB-BOOL:TRUE))
   s-1)
```"
  (mvfoldr #'prod (mapcar #'fun-to-hom context) so1))

(-> so-hom (substobj substobj) (or t substobj))
(defun so-hom (dom cod)
  "Computes the hom-object of two [SUBSTMORPH]s"
  (geb:so-hom-obj dom cod))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Utility Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(defun stlc-ctx-proj (context depth)
  "Given a context, we interpret it as a [PROD][class] object of appropriate
length with fibrations given by [PROD][class] projections."
  (if (zerop depth)
      (<-left (fun-to-hom (car context))
              (stlc-ctx-to-mu (cdr context)))
      (comp (stlc-ctx-proj (cdr context) (1- depth))
            (<-right (fun-to-hom (car context))
                     (stlc-ctx-to-mu (cdr context))))))

(defun index-to-projection (depth typ-a typ-b prod)
  (if (zerop depth)
      (comp (<-left typ-a typ-b) prod)
      (comp (index-to-projection (1- depth) (mcar typ-b) (mcadr typ-b) prod)
            (<-right typ-a typ-b))))

(-> index-to-obj (fixnum t) t)
(defun index-to-obj (depth typ)
  (if (zerop depth)
      (mcar typ)
      (index-to-obj (1- depth) (mcadr typ))))

(-> call-objmap (functor t) t)
(defun call-objmap (functor-body arg)
  (funcall (obj functor-body) arg))

(-> call-morphmap (functor t t t) t)
(defun call-morphmap (functor-body typ-a typ-b arg)
  (funcall (func functor-body) typ-a typ-b arg))
