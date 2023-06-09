module LanguageDef.Figures

import Library.IdrisUtils
import Library.IdrisCategories
import public LanguageDef.Atom
import public LanguageDef.RefinedADT
import public LanguageDef.PolyCat

%default total

------------------------------
------------------------------
---- Metalanguage quivers ----
------------------------------
------------------------------

-- A quiver (see https://ncatlab.org/nlab/show/quiver and
-- https://en.wikipedia.org/wiki/Quiver_(mathematics) ) internal to the
-- metalanguage -- in this case, Idris's `Type`.
--
-- A quiver may be viewed as a functor from the walking quiver (see again the
-- ncatlab page) to `Set`, or in general any category, or in this specific
-- case, Idris's `Type`.  When viewed as such, quivers may be treated as the
-- objects of the category of functors from the walking quiver to Idris's
-- `Type`, where the morphisms of the category are, as usual in functor
-- categories, the natural transformations.
--
-- Note that we are not (yet) defining the walking quiver itself -- we're
-- jumping straight to defining what a functor _from_ the walking quiver to
-- the metalanguage looks like.  This is because we will later define quivers,
-- including the walking quiver, in terms of quivers themselves (via either
-- of the notions of diagram or figure, which are dual to each other and which
-- we will define as quivers).
public export
record MLQuiver where
  constructor MLQuiv
  -- The object-map component of a quiver takes each object of the walking
  -- quiver -- of which there are precisely two -- to an object of the
  -- category `Type`, i.e. to a metalanguage type.
  mlqVert : Type
  mlqEdge : Type

  -- Because a quiver may be viewed as a functor, it has a morphism-map
  -- component.  There are only two non-identity morphisms in the walking
  -- quiver, and morphisms in `Type` are simply functions, so the morphism-map
  -- component of a quiver is determined by a pair of functions.  Because of
  -- the particular structure of the walking quiver (there's no way to get
  -- via morphisms from the vertex object to the edge object), there are no
  -- compositions of either of the two non-identity morphisms with each other
  -- (and hence no compositions of either of the two non-identity morphisms
  -- with any non-identity morphisms), so the morphism-map component does not
  -- need any explicit identity-preserving or composition-preserving conditions;
  -- a correct morphism map is precisely determined by any two functions with
  -- the signatures below.
  mlqSrc : mlqEdge -> mlqVert
  mlqTgt : mlqEdge -> mlqVert

-- The morphisms of the (functor) category `Quiv` are natural transformations.
-- The walking quiver has two objects, so a natural transformation has two
-- components.  The target category is `Type`, so each component is simply a
-- function between the targets of the object-map components of the functors
-- (in general, each component of a natural transformation between functors is
-- a morphism in the target category of the functors).
public export
record MLQMorph (dom, cod : MLQuiver) where
  constructor MLQM
  mlqmVert : mlqVert dom -> mlqVert cod
  mlqmEdge : mlqEdge dom -> mlqEdge cod

  0 mlqSrcNaturality : ExtEq (mlqmVert . mlqSrc dom) (mlqSrc cod . mlqmEdge)
  0 mlqTgtNaturality : ExtEq (mlqmVert . mlqTgt dom) (mlqTgt cod . mlqmEdge)

------------------------------------------------------------
------------------------------------------------------------
---- Presheaf/figure-style diagram/category definitions ----
------------------------------------------------------------
------------------------------------------------------------

------------------
---- Diagrams ----
------------------

-- The vertices of the diagram, which, when interpreted as an index
-- category for presheaves or copreasheaves (depending on the directions
-- of the edges), defines the category of diagrams.
public export
data DiagDiagVert : Type where
  DDVvert : DiagDiagVert
  DDVedge : DiagDiagVert

-- The edges of the diagram which, when interpreted as an index category
-- for (co)presheaves, defines the category of diagrams.
public export
data DiagDiagEdge : Type where
  DDEsrc : DiagDiagEdge
  DDEtgt : DiagDiagEdge

-- The sources of the edges of the diagram which, when interpreted as an
-- index category for copresheaves, defines the category of diagrams.
public export
CoprshfDiagSrc : DiagDiagEdge -> DiagDiagVert
CoprshfDiagSrc DDEsrc = DDVedge
CoprshfDiagSrc DDEtgt = DDVedge

public export
CDSbc : CSliceObj DiagDiagVert -> CSliceObj DiagDiagEdge
CDSbc = CSBaseChange CoprshfDiagSrc

-- The targets of the edges of the diagram which, when interpreted as an
-- index category for copresheaves, defines the category of diagrams.
public export
CoprshfDiagTgt : DiagDiagEdge -> DiagDiagVert
CoprshfDiagTgt DDEsrc = DDVvert
CoprshfDiagTgt DDEtgt = DDVvert

public export
CDTbc : CSliceObj DiagDiagVert -> CSliceObj DiagDiagEdge
CDTbc = CSBaseChange CoprshfDiagTgt

-- The sources of the edges of the diagram which, when interpreted as an
-- index category for presheaves, defines the category of diagrams.
-- (Such an index category is sometimes called a "generic figure").
public export
PrshfDiagSrc : DiagDiagEdge -> DiagDiagVert
PrshfDiagSrc = CoprshfDiagTgt

{- XXXX
public export
PDSbc : CSliceObj DiagDiagVert -> CSliceObj DiagDiagEdge
PDSbc = CSBaseChange PrshfDiagSrc
-}

-- The targets of the edges of the diagram which, when interpreted as an
-- index category for presheaves, defines the category of diagrams.
public export
PrshfDiagTgt : DiagDiagEdge -> DiagDiagVert
PrshfDiagTgt = CoprshfDiagSrc

{- XXX
public export
PDTbc : CSliceObj DiagDiagVert -> CSliceObj (CSliceObj DiagDiagEdge
PDTbc = CSBaseChange PrshfDiagTgt
-}

------------------------
---- (Co)presheaves ----
------------------------

-- The objects of the category of diagrams, when that category is defined
-- as the copresheaf category on the diagram (interpreted as an index
-- category) of diagrams themselves (DiagDiagVert/DiagDiagEdge).
--
-- A copresheaf is a (covariant) functor, so the _objects_ are
-- (covariant) functors from the `DiagDiag` index category to `Type`.
public export
record DiagCoprshfObj where
  constructor DCObj
  -- If we wrote it in dependent-type-with-universes style rather than
  -- category-theoretic style, DCObj would have type `DiagDiagVert -> Type` --
  -- although there are only two objects, so this is also equivalent to
  -- simply two `Type`s.
  DCObj : CSliceObj DiagDiagVert

  -- If we wrote it in dependent-type-with-universes style rather than
  -- category-theoretic style, DCMorph would look something like this:
  --  DCMorph : (e : DiagDiagEdge) ->
  --    DCObj (coprshfDiagSrc e) -> DCObj (coprshfDiagTgt e)
  -- (There are only two edges, so this is equivalent to simply two functions,
  -- both from the `Type` to which we map `DDVedge` to the type to which
  -- we map `DDVvert`, representing the source and target maps.)
  DCMorph : CSliceMorphism {c=DiagDiagEdge} (CDSbc DCObj) (CDTbc DCObj)

-- The objects of the category of diagrams, when that category is defined
-- as the presheaf category on the diagram (interpreted as an index
-- category) of diagrams themselves (DiagDiagVert/DiagDiagEdge).
--
-- A presheaf is a (contravariant) functor, so the _objects_ are
-- (contravariant) functors from the `DiagDiag` index category to `Type`.
public export
record DiagPrshfObj where
  constructor DPObj
  -- If we wrote it in dependent-type-with-universes style rather than
  -- category-theoretic style, DPObj would have type `DiagDiagVert -> Type`.
  -- That's the same type as `DCObj`, but when we interpret diagrams as
  -- presheaves rather than copresheaves, we interpret the edge type
  -- differently; see `DPMorph`.
  DPObj : CSliceObj DiagDiagVert

  DPEdgeTot : Type

  -- This is `DPMorph`'s signature backwards, reflecting that we are
  -- now interpreting the diagram as a "generic figure", meaning as a
  -- presheaf (contravariant functor), rather than the usual interpretation
  -- of "diagram" as "(covariant) functor", AKA copresheaf.
  --
  -- That's the same signature as `DPMorph`, but when we interpret diagrams
  -- as presheaves rather than copresheaves, we interpret the source and
  -- target mappings differently (as we must, since they point in opposite
  -- directions).  In this interpretation, rather than mapping each edge
  -- to its source or target respectively, the source mapping maps each
  -- vertex to the set of edges with that vertex as source, and the target
  -- mapping maps each vertex to the set of edges with that vertex as target.
  --
  -- This also means that, while we interpret the vertex type the same way
  -- in both the copresheaf and presheaf interpretations, we interpret the
  -- edge type differently.  In the copresheaf interpretation, it was just
  -- the type of edges.  In the presheaf interpretation, however, because the
  -- source and target mappings produce _sets_ of edges, the edge type in
  -- the presheaf interpretation must be a collection of subobjects of some
  -- type of edges.
  DPMorph : DiagDiagEdge -> (DPEdgeTot -> Type)

---------------------
---------------------
---- Prafunctors ----
---------------------
---------------------

-- We should start using `DiagCoprshfObj` instead of the record type below,
-- but we begin with a more explicit but less reflective representation.
-- (IndexCat = DiagCoprshfObj)
public export
record IndexCat where
  constructor IC
  icVert : Type
  icEdge : icVert -> icVert -> Type

-- A copresheaf on `j`, a category (which in this formulation is defined via a
-- diagram in `Type`), is a covariant functor from `j` to `Type`.  As such it
-- is a choice of a type for each vertex and a function for each edge (with
-- domain and codomain matching source and target, respectively).
--
-- (The copresheaves on a given index category `j` themselves form the objects
-- of a functor category, whose morphisms are natural transformations).
public export
record Copresheaf (j : IndexCat) where
  constructor Coprshf
  coprshfObj : icVert j -> Type
  coprshfMorph : (x, y : icVert j) ->
    icEdge j x y -> coprshfObj x -> coprshfObj y

-- A polyomial functor can be given the structure of a prafunctor by assigning
-- a copresheaf to each position and direction.
public export
record PrafunctorData (p : PolyFunc) (dom, cod : IndexCat) where
  constructor PRAF
  praPos : pfPos p -> Copresheaf cod
  praDir : (i : pfPos p) -> pfDir {p} i -> Copresheaf dom

public export
InterpPRAFobj : {p : PolyFunc} -> {dom, cod : IndexCat} ->
  PrafunctorData p dom cod -> Copresheaf dom -> icVert cod -> Type
InterpPRAFobj {p=(pos ** dir)}
  {dom=(IC dvert dedge)} {cod=(IC cvert cedge)} (PRAF prap prad)
  (Coprshf obj morph) cv =
    (i : pos **
     (coprshfObj (prap i) cv,
      (d : dir i) -> (dv : dvert) -> (coprshfObj (prad i d) dv, obj dv)))

public export
InterpPRAFmorph : {p : PolyFunc} -> {dom, cod : IndexCat} ->
  (prad : PrafunctorData p dom cod) -> (domc : Copresheaf dom) ->
  (x, y : icVert cod) -> icEdge cod x y ->
  InterpPRAFobj prad domc x -> InterpPRAFobj prad domc y
InterpPRAFmorph {p=(pos ** dir)}
  {dom=(IC dvert dedge)} {cod=(IC cvert cedge)} (PRAF prap prad)
  (Coprshf obj morph) x y e (i ** (co, m)) =
    (i ** (coprshfMorph (prap i) x y e co, m))

public export
InterpPRAF : {p : PolyFunc} -> {dom, cod : IndexCat} ->
  PrafunctorData p dom cod -> Copresheaf dom -> Copresheaf cod
InterpPRAF prad codc =
  Coprshf (InterpPRAFobj prad codc) (InterpPRAFmorph prad codc)
