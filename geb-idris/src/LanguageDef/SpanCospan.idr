module LanguageDef.SpanCospan

import Library.IdrisUtils
import Library.IdrisCategories
import Library.IdrisAlgebra

-----------------------------------------------------------------------
-----------------------------------------------------------------------
---- Objects of span and cospan categories in dependent-type style ----
-----------------------------------------------------------------------
-----------------------------------------------------------------------

-- A span is a diagram with three objects and two non-identity arrows, both of
-- which emanate from a common domain, each to one of the other two objects.
-- (The index category underlying such a diagram we call the "span index
-- category".)
--
-- Because that constitutes a DAG (ignoring the identity self-loops), we can
-- equivalently express it as one object (the domain) fibered over two
-- (the codomains).
--
-- The colimit of a span is a pushout, so a span is sometimes called a
-- "pushout diagram".
public export
record SpanObj where
  constructor Span
  spCodL : Type
  spCodR : Type
  spDom : spCodL -> spCodR -> Type

-- A cospan is a diagram with three objects and two non-identity arrows, each
-- of which emanates from a different domain, both to a common domain.
-- (The index category underlying such a diagram we call the "cospan index
-- category".)
--
-- Because that constitutes a DAG (ignoring the identity self-loops), we can
-- equivalently express it as two objects (the domains) each fibered over a
-- single object (the codomain).
--
-- The limit of a span is a pullback, so a cospan is sometimes called a
-- "pullback diagram".
public export
record CospanObj where
  constructor Cospan
  cospCod : Type
  cospDomL : cospCod -> Type
  cospDomR : cospCod -> Type

-------------------------------------------------------------------------
-------------------------------------------------------------------------
---- Morphisms of span and cospan categories in dependent-type style ----
-------------------------------------------------------------------------
-------------------------------------------------------------------------

-- A span is a functor (from the span index category), so a morphism
-- of spans is a natural transformation.  A morphism of spans in `Type` (the
-- base category of the metalanguage), when the spans themselves are
-- represented in dependent-type style as above, can be expressed as
-- metalanguage functions (which are the morphisms of `Type`) between
-- corresponding objects in the diagram, with the commutativity conditions
-- being represented by the functions' respecting the dependent-type
-- relationships.
public export
record SpanMorph (dom, cod : SpanObj) where
  constructor SpanM
  spmCodL : spCodL dom -> spCodL cod
  spmCodR : spCodR dom -> spCodR cod
  spmDom : (l : spCodL dom) -> (r : spCodR dom) ->
    spDom dom l r -> spDom cod (spmCodL l) (spmCodR r)

-- A cospan is a functor (from the cospan index category), so a morphism
-- of cospans is a natural transformation.  A morphism of cospans in `Type` (the
-- base category of the metalanguage), when the cospans themselves are
-- represented in dependent-type style as above, can be expressed as
-- metalanguage functions (which are the morphisms of `Type`) between
-- corresponding objects in the diagram, with the commutativity conditions
-- being represented by the functions' respecting the dependent-type
-- relationships.
public export
record CospanMorph (dom, cod : CospanObj) where
  constructor CospanM
  cospmCod : cospCod dom -> cospCod cod
  cospmDomL : (ed : cospCod dom) ->
    cospDomL dom ed -> cospDomL cod (cospmCod ed)
  cospmDomR : (ed : cospCod dom) ->
    cospDomR dom ed -> cospDomR cod (cospmCod ed)

---------------------------------------------------------------
---------------------------------------------------------------
---- Adjunctions defining pullbacks and pushouts in `Type` ----
---------------------------------------------------------------
---------------------------------------------------------------

---------------------------
---- Diagonal functors ----
---------------------------

-- The object-map component of the diagonal functor from `Type` to the category
-- of spans in `Type` (which is the functor category from the span index
-- category to `Type`).
--
-- The diagonal functor sends an object `x` of `Type` to the object of the
-- functor category `SpanObj` whose objects are all `x`.  Because we have
-- expressed `SpanObj` in a dependent-type style, we have to represent the
-- common domain as a type which depends upon pairs of terms of `x` yet is
-- equivalent to just `x` itself.  We must pare an input of cardinality
-- `|x|^2` down to one of cardinality `|x|`.
--
-- This is possible, in one straightforward way:  treat the type family as
-- `Void` for all non-diagonal inputs, and `Unit` for all diagonal inputs.
--
-- The effect of this on the implicit morphisms which we have represented in
-- `SpanObj` as type dependencies is to make each morphism the equivalent of the
-- identity morphism (which makes sense because we have mapped each object of
-- the span index category to the same object), as required by the definition
-- of the diagonal functor.
export
SpanDiagObj : Type -> SpanObj
SpanDiagObj x = Span x x (\ex, ex' => ex = ex')

-- The object-map component of the diagonal functor from `Type` to the category
-- of cospans in `Type` (which is the functor category from the cospan index
-- category to `Type`).
--
-- In this case, dually for what we had to do with `SpanDiagObj`, we must make
-- the common codomain simply `x`, and make each of the common domains a type
-- (family) which depends upon terms of `x` yet is equivalent to simply `x`.
-- This we can do by making each type of the family `Unit`.
export
CospanDiagObj : Type -> CospanObj
CospanDiagObj x = Cospan x (\_ => Unit) (\_ => Unit)

-- The morphism-map component of the diagonal functor from `Type` to the
-- category of spans in `Type`.
--
-- The diagonal functor takes each morphism of `Type` to the identity morphism
-- in the category of spans (which is sensible because it takes each object of
-- the span index category to the same object).
export
SpanDiagMorph : (0 x, y : Type) ->
  (x -> y) -> SpanMorph (SpanDiagObj x) (SpanDiagObj y)
SpanDiagMorph x y f = SpanM f f (\l, r, eqlr => cong f eqlr)

-- The morphism-map component of the diagonal functor from `Type` to the
-- category of cospans in `Type`, defined dually to `SpanDiagMorph`.
export
CospanDiagMorph : (0 x, y : Type) ->
  (x -> y) -> CospanMorph (CospanDiagObj x) (CospanDiagObj y)
CospanDiagMorph x y f = CospanM f (\_, _ => ()) (\_, _ => ())
