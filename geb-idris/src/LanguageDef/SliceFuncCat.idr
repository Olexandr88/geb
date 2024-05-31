module LanguageDef.SliceFuncCat

import Library.IdrisUtils
import Library.IdrisCategories
import public LanguageDef.PolyCat
import public LanguageDef.InternalCat

---------------------
---------------------
---- Base change ----
---------------------
---------------------

-- This definition of `BaseChangeF` is the same as the one in `IdrisCategories`.
-- I'm duplicating it here just to make it explicit in the same module as the
-- adjunctions on either side of it.
%hide Library.IdrisCategories.BaseChangeF
public export
BaseChangeF : {c, d : Type} -> (d -> c) -> SliceFunctor c d
BaseChangeF {c} {d} f slc = slc . f

-- Because base change is in the middle of an adjoint triple between
-- dependent sum and dependent product, it can introduced and eliminated
-- from either side, by the adjuncts defined below with `Sigma` and `Pi`.

public export
bcMap : {0 c, d : Type} -> {f : d -> c} -> SliceFMap (BaseChangeF {c} {d} f)
bcMap {c} {d} {f} sa sb m ec = m (f ec)

-- This version of `BaseChangeF` uses a slice object rather than a morphism
-- between base objects, like the dependent-type-style definitions of
-- `SliceFibSigmaF` and `SlicePiF` below.
--
-- It could be viewed as pairing up each type of a type family with a type
-- family dependent upon _that_ type.
public export
SliceBCF : {c : Type} -> (sl : SliceObj c) -> SliceFunctor c (Sigma {a=c} sl)
SliceBCF {c} sl = BaseChangeF {c} {d=(Sigma {a=c} sl)} DPair.fst

public export
sbcMap : {0 c : Type} -> {sl : SliceObj c} -> SliceFMap (SliceBCF {c} sl)
sbcMap {c} {sl} sa sb = bcMap {c} {d=(Sigma {a=c} sl)} {f=DPair.fst} sa sb

--------------------------------
----- Base change as W-type ----
--------------------------------

public export
0 BCasWTF : {c, d : Type} -> (f : d -> c) -> WTypeFunc c d
BCasWTF {c} {d} f = MkWTF {dom=c} {cod=d} d d f id id

bcToWTF : {c, d : Type} -> (0 f : d -> c) ->
  SliceNatTrans (BaseChangeF {c} {d} f) (InterpWTF $ BCasWTF f)
bcToWTF {c} {d} f sc ed efd =
  (Element0 ed Refl **
   \(Element0 ed' eq) => replace {p=(BaseChangeF f sc)} (sym eq) efd)

bcFromWTF : {c, d : Type} -> (0 f : d -> c) ->
  SliceNatTrans (InterpWTF $ BCasWTF f) (BaseChangeF {c} {d} f)
bcFromWTF {c} {d} f sc ed (Element0 ed' eq ** scfd) =
  replace {p=(BaseChangeF f sc)} eq $ scfd $ Element0 ed' Refl

-----------------------
-----------------------
---- Dependent sum ----
-----------------------
-----------------------

--------------------
---- Definition ----
--------------------

-- This is the left adjoint of the dependent-sum/base-change adjunction.
-- (The right adjoint is base change.)
--
-- For convenient expression within a dependently-typed metalanguage, we
-- express this by default in terms of dependent types rather than fibrations,
-- which are the more category-theoretic style.
public export
SliceSigmaF : {c : Type} ->
  (sl : SliceObj c) -> SliceFunctor (Sigma {a=c} sl) c
SliceSigmaF {c} sl sls ec =
  -- An explicit way of spelling this out would be:
  --  (esc : sl ec ** sls $ (ec ** esc))
  Sigma {a=(sl ec)} (BaseChangeF (MkDPair ec) sls)

public export
ssMap : {c : Type} -> {0 sl : SliceObj c} -> SliceFMap (SliceSigmaF {c} sl)
ssMap {c} {sl} slsa slsb mab ec esla =
  (fst esla ** mab (ec ** fst esla) $ snd esla)

-- This is the category-theory-style version of `SliceSigmaF`, based on
-- fibrations.
--
-- One way of viewing it is as the slice functor from `c` to `d` which takes a
-- subobject of `c` to the subobject of `d` whose terms consist of single
-- applications of `f` to terms of the given subobject.
--
-- When it is an endofunctor (i.e. `d` is `c`), its initial algebra
-- (least fixed point) is simply the initial object of `SliceObj c`
-- (`const Void`); that initial algebra (as with any functor that has a
-- free monad) is isomorphic to the application of its free monad to the
-- initial object of `SliceObj c`, which is hence also `const Void`.
public export
SliceFibSigmaF : {c, d : Type} -> (0 f : c -> d) -> SliceFunctor c d
SliceFibSigmaF {c} {d} f =
  -- An explicit way of spelling this out would be:
  -- \sc : SliceObj c, ed : d =>
  --  (ep : PreImage {a=c} {b=d} f ed ** sc $ fst0 ep)
  SliceSigmaF {c=d} (\ed => PreImage {a=c} {b=d} f ed)
  . BaseChangeF
      {c}
      {d=(Sigma {a=d} $ \ed => PreImage {a=c} {b=d} f ed)}
      (\ed => fst0 $ snd ed)

public export
sfsMap : {c, d : Type} -> {0 f : c -> d} ->
  SliceFMap (SliceFibSigmaF {c} {d} f)
sfsMap {c} {d} {f} sca scb =
  ssMap {c=d} {sl=(\ed => PreImage {a=c} {b=d} f ed)}
    (\edc => sca $ fst0 $ snd edc)
    (\edc => scb $ fst0 $ snd edc)
  . bcMap
    {c}
    {d=(Sigma {a=d} $ \ed => PreImage {a=c} {b=d} f ed)}
    {f=(\ed => fst0 $ snd ed)}
    sca
    scb

--------------------------
----- Sigma as W-type ----
--------------------------

public export
0 SFSasWTF : {c, d : Type} -> (f : c -> d) -> WTypeFunc c d
SFSasWTF {c} {d} f = MkWTF {dom=c} {cod=d} c c id id f

sfsToWTF : {c, d : Type} -> (0 f : c -> d) ->
  SliceNatTrans (SliceFibSigmaF {c} {d} f) (InterpWTF $ SFSasWTF f)
sfsToWTF {c} {d} f sc ed esc =
  (fst esc ** \ec' => replace {p=sc} (sym $ snd0 ec') $ snd esc)

sfsFromWTF : {c, d : Type} -> (0 f : c -> d) ->
  SliceNatTrans (InterpWTF $ SFSasWTF f) (SliceFibSigmaF {c} {d} f)
sfsFromWTF {c} {d} f sc ed (Element0 ec eq ** scd) =
  replace {p=(SliceFibSigmaF f sc)} eq
  $ (Element0 ec Refl ** scd $ Element0 ec Refl)

0 SSasWTF : {c : Type} -> (sl : SliceObj c) -> WTypeFunc (Sigma sl) c
SSasWTF {c} sl = SFSasWTF {c=(Sigma sl)} {d=c} DPair.fst

ssToWTF : {c : Type} -> (sl : SliceObj c) ->
  SliceNatTrans (SliceSigmaF {c} sl) (InterpWTF $ SSasWTF sl)
ssToWTF {c} sl sc ec esc =
  (Element0 (ec ** fst esc) Refl **
   \ec' => replace {p=sc} (sym $ snd0 ec') $ snd esc)

ssFromWTF : {c : Type} -> (sl : SliceObj c) ->
  SliceNatTrans (InterpWTF $ SSasWTF sl) (SliceSigmaF {c} sl)
ssFromWTF {c} sc ssc ec (Element0 esc eq ** pisc) =
  rewrite sym eq in
  (snd esc ** replace {p=ssc} dpEqPat $ pisc $ Element0 esc Refl)

-------------------------
---- Adjunction data ----
-------------------------

-- The monad of the dependent-sum/base-change adjunction.
public export
SSMonad : {c : Type} -> (sl : SliceObj c) -> SliceEndofunctor (Sigma sl)
SSMonad {c} sl = SliceBCF {c} sl . SliceSigmaF {c} sl

public export
ssMonadMap : {c : Type} -> (sl : SliceObj c) -> SliceFMap (SSMonad {c} sl)
ssMonadMap {c} sl x y =
  sbcMap (SliceSigmaF sl x) (SliceSigmaF sl y) . ssMap {c} {sl} x y

-- The comonad of the dependent-sum/base-change adjunction.
public export
SSComonad : {c : Type} -> (sl : SliceObj c) -> SliceEndofunctor c
SSComonad {c} sl = SliceSigmaF {c} sl . SliceBCF sl

public export
ssComonadMap : {c : Type} -> (sl : SliceObj c) -> SliceFMap (SSComonad {c} sl)
ssComonadMap {c} sl x y =
  ssMap {c} {sl} (SliceBCF sl x) (SliceBCF sl y) . sbcMap {c} {sl} x y

-- Rather than making the constructor `SS` explicit, we export an
-- alias for it viewed as a natural transformation.
--
-- This is the unit (AKA "pure" or "return") of the dependent-sum/base-change
-- adjunction.
public export
sSin : {0 c : Type} -> {0 sl : SliceObj c} ->
  SliceNatTrans {x=(Sigma sl)} {y=(Sigma sl)}
    (SliceIdF $ Sigma sl)
    (SSMonad {c} sl)
sSin {c} {sl} sc ecsl esc = case ecsl of (ec ** esl) => (esl ** esc)

-- The counit (AKA "erase" or "extract") of the dependent-sum/base-change
-- adjunction.
public export
sSout : {0 c : Type} -> {0 sl : SliceObj c} ->
  SliceNatTrans {x=c} {y=c} (SSComonad {c} sl) (SliceIdF c)
sSout {c} {sl} sc ec esc = snd esc

-- This is the right adjunct of the dependent-sum/base-change adjunction.
--
-- It constitutes the destructor for `SliceSigmaF f sc`.  As an adjunction,
-- it is parametrically polymorphic:  rather than receiving a witness to a
-- given `ec : c` being in the image of `f` applied to a given slice over
-- `c`, it passes in a handler for _any_ such witness.
public export
ssElim : {c : Type} -> {sl : SliceObj c} ->
  {sa : SliceObj (Sigma sl)} -> {sb : SliceObj c} ->
  SliceMorphism {a=(Sigma sl)} sa (SliceBCF sl sb) ->
  SliceMorphism {a=c} (SliceSigmaF {c} sl sa) sb
ssElim {c} {sl} {sa} {sb} m =
  sliceComp (sSout sb) (ssMap sa (SliceBCF {c} sl sb) m)

-- This is the left adjunct of the dependent-sum/base-change adjunction.
public export
ssLAdj : {c : Type} -> {sl : SliceObj c} ->
  {sa : SliceObj (Sigma sl)} -> {sb : SliceObj c} ->
  SliceMorphism {a=c} (SliceSigmaF {c} sl sa) sb ->
  SliceMorphism {a=(Sigma sl)} sa (SliceBCF sl sb)
ssLAdj {c} {sl} {sa} {sb} m =
  sliceComp (sbcMap (SliceSigmaF {c} sl sa) sb m) (sSin sa)

-- This is the multiplication (AKA "join") of the dependent-sum/base-change
-- adjunction.
--
-- The multiplication comes from whiskering the counit between the adjuncts.
public export
sSjoin : {c : Type} -> {sl : SliceObj c} ->
  SliceNatTrans {x=(Sigma sl)} {y=(Sigma sl)}
    (SSMonad {c} sl . SSMonad {c} sl)
    (SSMonad {c} sl)
sSjoin {c} {sl} =
  SliceWhiskerRight
    {f=(SSComonad sl . SliceSigmaF sl)}
    {g=(SliceSigmaF sl)}
    {h=(SliceBCF sl)}
    (sbcMap {sl})
  $ SliceWhiskerLeft
    {g=(SSComonad sl)}
    {h=(SliceIdF c)}
    (sSout {sl})
    (SliceSigmaF sl)

-- This is the comultiplication (AKA "duplicate") of the
-- dependent-sum/base-change adjunction.
--
-- The comultiplication comes from whiskering the unit between the adjuncts.
public export
sSdup : {c : Type} -> {sl : SliceObj c} ->
  SliceNatTrans {x=c} {y=c}
    (SSComonad {c} sl)
    (SSComonad {c} sl . SSComonad {c} sl)
sSdup {c} {sl} =
  SliceWhiskerRight
    {f=(SliceBCF sl)}
    {g=(SliceBCF sl . SSComonad sl)}
    {h=(SliceSigmaF sl)}
    (ssMap {sl})
  $ SliceWhiskerLeft
    {g=(SliceIdF $ Sigma sl)}
    {h=(SSMonad sl)}
    sSin
    (SliceBCF sl)

public export
SSAlg : {c : Type} -> (0 f : c -> c) -> (sc : SliceObj c) -> Type
SSAlg {c} {f} = SliceAlg {a=c} (SliceFibSigmaF {c} {d=c} f)

public export
SSVoidAlg : {c : Type} -> (0 f : c -> c) -> SSAlg {c} f (const Void)
SSVoidAlg {c} f ec evc = void $ snd evc

public export
SSCoalg : {c : Type} -> (0 f : c -> c) -> (sc : SliceObj c) -> Type
SSCoalg {c} {f} = SliceCoalg {a=c} (SliceFibSigmaF {c} {d=c} f)

---------------------------
---------------------------
---- Dependent product ----
---------------------------
---------------------------

--------------------
---- Definition ----
--------------------

-- This is the right adjoint of the dependent-product/base-change adjunction.
-- (The left adjoint is base change.)
--
-- For convenient expression within a dependently-typed metalanguage, we
-- express this by default in terms of dependent types rather than fibrations,
-- which are the more category-theoretic style.
public export
SlicePiF : {c : Type} -> (sl : SliceObj c) -> SliceFunctor (Sigma {a=c} sl) c
SlicePiF {c} sl sls ec =
  -- An explicit way of spelling this out would be:
  --  (esc : sl ec) -> sls $ (ec ** esc)
  Pi {a=(sl ec)} (BaseChangeF (MkDPair ec) sls)

public export
spMap : {c : Type} -> {0 sl : SliceObj c} -> SliceFMap (SlicePiF {c} sl)
spMap {c} {sl} slsa slsb mab ec pia eslc = mab (ec ** eslc) $ pia eslc

-- The slice functor from `c` to `d` which takes a type family indexed by `c`
-- to a type of sections indexed by `d`, where the type at a given term
-- of `d` is the type of sections indexed by terms of `c` in the preimage of
-- that term of `d` under the given morphism.
--
-- In particular, if `d` is `Unit`, then this takes a type family indexed by `c`
-- to the type of its sections indexed by `c` -- that is, a slice object `sc`
-- over `c` is mapped by this functor to the type of `Type` (equivalent to a
-- slice over `Unit`) of choices of terms, for each `ec : c`, of `sc ec`.
--
-- This is the category-theory-style version of `SlicePiF`, based on
-- fibrations.
public export
SliceFibPiF : {c, d : Type} -> (0 f : c -> d) -> SliceFunctor c d
SliceFibPiF {c} {d} f =
  -- An explicit way of spelling this out would be:
  --  (ep : PreImage {a=c} {b=d} f ed) -> sc $ fst0 ep
  SlicePiF {c=d} (\ed => PreImage {a=c} {b=d} f ed)
  . BaseChangeF
      {c}
      {d=(Sigma {a=d} $ \ed => PreImage {a=c} {b=d} f ed)}
      (\ed => fst0 $ snd ed)

public export
sfpMap : {c, d : Type} -> {0 f : c -> d} ->
  SliceFMap (SliceFibPiF {c} {d} f)
sfpMap {c} {d} {f} sca scb =
  spMap {c=d} {sl=(\ed => PreImage {a=c} {b=d} f ed)}
    (\edc => sca $ fst0 $ snd edc)
    (\edc => scb $ fst0 $ snd edc)
  . bcMap
    {c}
    {d=(Sigma {a=d} $ \ed => PreImage {a=c} {b=d} f ed)}
    {f=(\ed => fst0 $ snd ed)}
    sca
    scb

-----------------------
----- Pi as W-type ----
-----------------------

public export
0 SPSasWTF : {c, d : Type} -> (f : c -> d) -> WTypeFunc c d
SPSasWTF {c} {d} f = MkWTF {dom=c} {cod=d} d c id f id

spsToWTF : {c, d : Type} -> (0 f : c -> d) ->
  SliceNatTrans (SliceFibPiF {c} {d} f) (InterpWTF $ SPSasWTF f)
spsToWTF {c} {d} f sc ed pisc = (Element0 ed Refl ** pisc)

spsFromWTF : {c, d : Type} -> (0 f : c -> d) ->
  SliceNatTrans (InterpWTF $ SPSasWTF f) (SliceFibPiF {c} {d} f)
spsFromWTF {c} {d} f sc ed (Element0 ec eq ** scd) =
  replace {p=(SliceFibPiF f sc)} eq scd

0 SPasWTF : {c : Type} -> (sl : SliceObj c) -> WTypeFunc (Sigma sl) c
SPasWTF {c} sl = SPSasWTF {c=(Sigma sl)} {d=c} DPair.fst

spToWTF : {c : Type} -> (sl : SliceObj c) ->
  SliceNatTrans (SlicePiF {c} sl) (InterpWTF $ SPasWTF sl)
spToWTF {c} sc ssc ec pisc =
  (Element0 ec Refl **
   \(Element0 (ec' ** esc') eqc) =>
    rewrite eqc in pisc $ rewrite sym eqc in esc')

spFromWTF : {c : Type} -> (sl : SliceObj c) ->
  SliceNatTrans (InterpWTF $ SPasWTF sl) (SlicePiF {c} sl)
spFromWTF {c} sc ssc ec (Element0 ec' eqc ** pisc) esc =
  pisc $ Element0 (ec ** esc) $ sym eqc

-------------------------
---- Adjunction data ----
-------------------------

-- The monad of the dependent-product/base-change adjunction.
public export
SPMonad : {c : Type} -> (sl : SliceObj c) -> SliceEndofunctor c
SPMonad {c} sl = SlicePiF {c} sl . SliceBCF {c} sl

public export
spMonadMap : {c : Type} -> (sl : SliceObj c) -> SliceFMap (SPMonad {c} sl)
spMonadMap {c} sl x y =
  spMap {c} {sl} (SliceBCF sl x) (SliceBCF sl y) . sbcMap {c} {sl} x y

-- The comonad of the dependent-product/base-change adjunction.
public export
SPComonad : {c : Type} -> (sl : SliceObj c) -> SliceEndofunctor (Sigma sl)
SPComonad {c} sl = SliceBCF {c} sl . SlicePiF {c} sl

public export
spComonadMap : {c : Type} -> (sl : SliceObj c) -> SliceFMap (SPComonad {c} sl)
spComonadMap {c} sl x y =
  sbcMap (SlicePiF sl x) (SlicePiF sl y) . spMap {c} {sl} x y

-- This is the unit (AKA "pure" or "return") of the
-- dependent-product/base-change adjunction.
public export
spUnit : {0 c : Type} -> {0 sl : SliceObj c} ->
  SliceNatTrans {x=c} {y=c} (SliceIdF c) (SPMonad {c} sl)
spUnit {c} {sl} sc ec esc esl = esc

-- This is the counit (AKA "erase" or "extract") of the
-- dependent-product/base-change adjunction.
public export
spCounit : {0 c : Type} -> {0 sl : SliceObj c} ->
  SliceNatTrans {x=(Sigma sl)} {y=(Sigma sl)}
    (SPComonad {c} sl)
    (SliceIdF $ Sigma sl)
spCounit {c} {sl} sc ecsl pisc = case ecsl of (ec ** esl) => pisc esl

-- This is the left adjunct of the dependent-product/base-change adjunction.
--
-- It constitutes the constructor for `SlicePiF f sc`.  As an adjunction,
-- it is parametrically polymorphic:  rather than receiving a witness to a
-- given `ec : c` being in the image of `f` applied to a given slice over
-- `c`, it passes in a handler for _any_ such witness.
public export
spIntro : {c : Type} -> {sl : SliceObj c} ->
  {sa : SliceObj c} -> {sb : SliceObj (Sigma sl)} ->
  SliceMorphism {a=(Sigma sl)} (SliceBCF sl sa) sb ->
  SliceMorphism {a=c} sa (SlicePiF sl sb)
spIntro {c} {sl} {sa} {sb} m =
  sliceComp (spMap (SliceBCF sl sa) sb m) (spUnit sa)

-- This is the right adjunct of the dependent-product/base-change adjunction.
public export
spRAdj : {c : Type} -> {sl : SliceObj c} ->
  {sa : SliceObj c} -> {sb : SliceObj (Sigma sl)} ->
  SliceMorphism {a=c} sa (SlicePiF sl sb) ->
  SliceMorphism {a=(Sigma sl)} (SliceBCF sl sa) sb
spRAdj {c} {sl} {sa} {sb} m =
  sliceComp (spCounit sb) (sbcMap sa (SlicePiF sl sb) m)

-- This is the multiplication (AKA "join") of the dependent-product/base-change
-- adjunction.
--
-- The multiplication comes from whiskering the counit between the adjuncts.
public export
sPjoin : {c : Type} -> {sl : SliceObj c} ->
  SliceNatTrans {x=c} {y=c}
    (SPMonad {c} sl . SPMonad {c} sl)
    (SPMonad {c} sl)
sPjoin {c} {sl} =
  SliceWhiskerRight
    {f=(SPComonad sl . SliceBCF sl)}
    {g=(SliceBCF sl)}
    {h=(SlicePiF sl)}
    (spMap {sl})
  $ SliceWhiskerLeft
    {g=(SPComonad sl)}
    {h=(SliceIdF $ Sigma sl)}
    (spCounit {sl})
    (SliceBCF sl)

-- This is the comultiplication (AKA "duplicate") of the
-- dependent-product/base-change adjunction.
--
-- The comultiplication comes from whiskering the unit between the adjuncts.
public export
sPdup : {c : Type} -> {sl : SliceObj c} ->
  SliceNatTrans {x=(Sigma sl)} {y=(Sigma sl)}
    (SPComonad {c} sl)
    (SPComonad {c} sl . SPComonad {c} sl)
sPdup {c} {sl} =
  SliceWhiskerRight
    {f=(SlicePiF sl)}
    {g=(SlicePiF sl . SPComonad sl)}
    {h=(SliceBCF sl)}
    (sbcMap {sl})
  $ SliceWhiskerLeft
    {g=(SliceIdF c)}
    {h=(SPMonad sl)}
    spUnit
    (SlicePiF sl)

---------------------------------------------
---------------------------------------------
---- Sigma/base-change/pi adjoint triple ----
---------------------------------------------
---------------------------------------------

-- Dependent sum (sigma), base change, and dependent product (pi) form
-- an adjoint triple.  See for example:
--
--  - https://ncatlab.org/nlab/show/adjoint+triple
--
-- In the dependent-type formulation, the category on the right (the codomain
-- of the two outer adjoints, hence the domain of base change) is `SliceObj c`
-- for some `c : Type`, and the category on the left (the domain of the two
-- outer adjoints, hence the codomain of base change) is
-- `SliceObject (Sigma {a=c} sl)` for some `sl : SliceObj c`.
--
-- The adjoints of the left induced adjoint pair are therefore endofunctors on
-- `SliceObject (Sigma {a=c} sl)`, while the adjoints of the right induced
-- adjoint pair are endofunctors on `SliceObj c`.

-- This is the left adjoint of the left induced adjoint pair of the
-- dependent-sum/base-change/dependent-product adjoint triple.
public export
SliceSBCPlL : {c : Type} -> {sl : SliceObj c} ->
  SliceEndofunctor (Sigma {a=c} sl)
SliceSBCPlL {c} {sl} = SSMonad {c} sl

public export
sliceSBCPlLmap : {c : Type} -> {sl : SliceObj c} ->
  SliceFMap (SliceSBCPlL {c} {sl})
sliceSBCPlLmap {c} {sl} = ssMonadMap sl

-- This is the right adjoint of the left induced adjoint pair of the
-- dependent-sum/base-change/dependent-product adjoint triple.
public export
SliceSBCPlR : {c : Type} -> {sl : SliceObj c} ->
  SliceEndofunctor (Sigma {a=c} sl)
SliceSBCPlR {c} {sl} = SPComonad {c} sl

public export
sliceSBCPlRmap : {c : Type} -> {sl : SliceObj c} ->
  SliceFMap (SliceSBCPlR {c} {sl})
sliceSBCPlRmap {c} {sl} = spComonadMap sl

-- This is the left adjoint of the right induced adjoint pair of the
-- dependent-sum/base-change/dependent-product adjoint triple.
public export
SliceSBCPrL : {c : Type} -> {sl : SliceObj c} ->
  SliceEndofunctor c
SliceSBCPrL {c} {sl} = SSComonad {c} sl

public export
sliceSBCPrLmap : {c : Type} -> {sl : SliceObj c} ->
  SliceFMap (SliceSBCPrL {c} {sl})
sliceSBCPrLmap {c} {sl} = ssComonadMap sl

-- This is the right adjoint of the right induced adjoint pair of the
-- dependent-sum/base-change/dependent-product adjoint triple.
public export
SliceSBCPrR : {c : Type} -> {sl : SliceObj c} ->
  SliceEndofunctor c
SliceSBCPrR {c} {sl} = SPMonad {c} sl

public export
sliceSBCPrRmap : {c : Type} -> {sl : SliceObj c} ->
  SliceFMap (SliceSBCPrR {c} {sl})
sliceSBCPrRmap {c} {sl} = spMonadMap sl

-- This is the monad of the left induced adjoint pair of the
-- dependent-sum/base-change/dependent-product adjoint triple.
public export
SliceSBCPlMonad : {c : Type} -> {sl : SliceObj c} ->
  SliceEndofunctor (Sigma {a=c} sl)
SliceSBCPlMonad {c} {sl} = SliceSBCPlR {c} {sl} . SliceSBCPlL {c} {sl}

public export
sliceSBCPlMonadMap : {c : Type} -> {sl : SliceObj c} ->
  SliceFMap (SliceSBCPlMonad {c} {sl})
sliceSBCPlMonadMap {c} {sl} x y =
  spComonadMap sl (SSMonad sl x) (SSMonad sl y) . ssMonadMap sl x y

-- This is the comonad of the left induced adjoint pair of the
-- dependent-sum/base-change/dependent-product adjoint triple.
public export
SliceSBCPlComonad : {c : Type} -> {sl : SliceObj c} ->
  SliceEndofunctor (Sigma {a=c} sl)
SliceSBCPlComonad {c} {sl} = SliceSBCPlL {c} {sl} . SliceSBCPlR {c} {sl}

public export
sliceSBCPlComonadMap : {c : Type} -> {sl : SliceObj c} ->
  SliceFMap (SliceSBCPlComonad {c} {sl})
sliceSBCPlComonadMap {c} {sl} x y =
  ssMonadMap sl (SPComonad sl x) (SPComonad sl y) . spComonadMap sl x y

-- This is the monad of the right induced adjoint pair of the
-- dependent-sum/base-change/dependent-product adjoint triple.
public export
SliceSBCPrMonad : {c : Type} -> {sl : SliceObj c} ->
  SliceEndofunctor c
SliceSBCPrMonad {c} {sl} = SliceSBCPrR {c} {sl} . SliceSBCPrL {c} {sl}

public export
sliceSBCPrMonadMap : {c : Type} -> {sl : SliceObj c} ->
  SliceFMap (SliceSBCPrMonad {c} {sl})
sliceSBCPrMonadMap {c} {sl} x y =
  spMonadMap sl (SSComonad sl x) (SSComonad sl y) . ssComonadMap sl x y

-- This is the comonad of the right induced adjoint pair of the
-- dependent-sum/base-change/dependent-product adjoint triple.
public export
SliceSBCPrComonad : {c : Type} -> {sl : SliceObj c} ->
  SliceEndofunctor c
SliceSBCPrComonad {c} {sl} = SliceSBCPrL {c} {sl} . SliceSBCPrR {c} {sl}

public export
sliceSBCPrComonadMap : {c : Type} -> {sl : SliceObj c} ->
  SliceFMap (SliceSBCPrComonad {c} {sl})
sliceSBCPrComonadMap {c} {sl} x y =
  ssComonadMap sl (SPMonad sl x) (SPMonad sl y) . spMonadMap sl x y

-- This is the left adjunct of the left induced adjoint pair of the
-- dependent-sum/base-change/dependent-product adjoint triple.
--
-- The adjuncts of an adjoint pair which is induced by an adjoint triple can
-- be computed as a composition of adjuncts of the two separate
-- adjunctions which form the adjoint triple.
--
-- To spell out the hom-set isomorphism, of which the adjuncts are the
-- two directions, in this particular instance:
--
--     lL sa -> sb == (BC . Sigma) a -> sb
--  == BC (Sigma sa) -> sb
--  == Sigma sa -> Pi sb (BC/Pi left adjunct)
--  == sa -> BC (Pi sb) (Sigma/Pi left adjunct)
--  == sa -> (BC . Pi) sb == sa -> lR sb
public export
SliceSBCPlLAdj : {c : Type} -> {sl : SliceObj c} ->
  (sa, sb : SliceObj $ Sigma {a=c} sl) ->
  SliceMorphism {a=(Sigma {a=c} sl)} (SliceSBCPlL {c} {sl} sa) sb ->
  SliceMorphism {a=(Sigma {a=c} sl)} sa (SliceSBCPlR {c} {sl} sb)
SliceSBCPlLAdj {c} {sl} sa sb =
  ssLAdj {sl} {sa} {sb=(SlicePiF sl sb)}
  . spIntro {sl} {sa=(SliceSigmaF sl sa)} {sb}

-- This is the right adjunct of the left induced adjoint pair of the
-- dependent-sum/base-change/dependent-product adjoint triple.
public export
SliceSBCPlRAdj : {c : Type} -> {sl : SliceObj c} ->
  (sa, sb : SliceObj $ Sigma {a=c} sl) ->
  SliceMorphism {a=(Sigma {a=c} sl)} sa (SliceSBCPlR {c} {sl} sb) ->
  SliceMorphism {a=(Sigma {a=c} sl)} (SliceSBCPlL {c} {sl} sa) sb
SliceSBCPlRAdj {c} {sl} sa sb =
  spRAdj {sl} {sa=(SliceSigmaF sl sa)} {sb}
  . ssElim {sl} {sa} {sb=(SlicePiF sl sb)}

-- This is the left adjunct of the right induced adjoint pair of the
-- dependent-sum/base-change/dependent-product adjoint triple.
public export
SliceSBCPrLAdj : {c : Type} -> {sl : SliceObj c} ->
  (sa, sb : SliceObj c) ->
  SliceMorphism {a=c} (SliceSBCPrL {c} {sl} sa) sb ->
  SliceMorphism {a=c} sa (SliceSBCPrR {c} {sl} sb)
SliceSBCPrLAdj {c} {sl} sa sb =
  spIntro {sl} {sa} {sb=(SliceBCF sl sb)}
  . ssLAdj {sl} {sa=(SliceBCF sl sa)} {sb}

-- This is the right adjunct of the right induced adjoint pair of the
-- dependent-sum/base-change/dependent-product adjoint triple.
public export
SliceSBCPrRAdj : {c : Type} -> {sl : SliceObj c} ->
  (sa, sb : SliceObj c) ->
  SliceMorphism {a=c} sa (SliceSBCPrR {c} {sl} sb) ->
  SliceMorphism {a=c} (SliceSBCPrL {c} {sl} sa) sb
SliceSBCPrRAdj {c} {sl} sa sb =
  ssElim {sl} {sa=(SliceBCF sl sa)} {sb}
  . spRAdj {sl} {sa} {sb=(SliceBCF sl sb)}

-- This is the unit (AKA "pure" or "return") of the left induced adjoint pair
-- of the dependent-sum/base-change/dependent-product adjoint triple.
--
-- The unit can be computed by applying the left adjunct to the
-- identity morphism.
public export
SliceSBCPlUnit : {c : Type} -> {sl : SliceObj c} ->
  SliceNatTrans {x=(Sigma {a=c} sl)} {y=(Sigma {a=c} sl)}
    (SliceIdF $ Sigma {a=c} sl)
    (SliceSBCPlMonad {c} {sl})
SliceSBCPlUnit {c} {sl} sla =
  SliceSBCPlLAdj {c} {sl} sla (SliceSBCPlL {c} {sl} sla)
    (sliceId $ SliceSBCPlL {c} {sl} sla)

-- This is the counit (AKA "erase" or "extract") of the left induced adjoint
-- pair of the dependent-sum/base-change/dependent-product adjoint triple.
--
-- The counit can be computed by applying the right adjunct to the
-- identity morphism.
public export
SliceSBCPlCounit : {c : Type} -> {sl : SliceObj c} ->
  SliceNatTrans {x=(Sigma {a=c} sl)} {y=(Sigma {a=c} sl)}
    (SliceSBCPlComonad {c} {sl})
    (SliceIdF $ Sigma {a=c} sl)
SliceSBCPlCounit {c} {sl} sla =
  SliceSBCPlRAdj {c} {sl} (SliceSBCPlR {c} {sl} sla) sla
    (sliceId $ SliceSBCPlR {c} {sl} sla)

-- This is the unit (AKA "pure" or "return") of the right induced adjoint pair
-- of the dependent-sum/base-change/dependent-product adjoint triple.
public export
SliceSBCPrUnit : {c : Type} -> {sl : SliceObj c} ->
  SliceNatTrans {x=c} {y=c}
    (SliceIdF c)
    (SliceSBCPrMonad {c} {sl})
SliceSBCPrUnit {c} {sl} sla =
  SliceSBCPrLAdj {c} {sl} sla (SliceSBCPrL {c} {sl} sla)
    (sliceId $ SliceSBCPrL {c} {sl} sla)

-- This is the counit (AKA "erase" or "extract") of the right induced adjoint
-- pair of the dependent-sum/base-change/dependent-product adjoint triple.
public export
SliceSBCPrCounit : {c : Type} -> {sl : SliceObj c} ->
  SliceNatTrans {x=c} {y=c}
    (SliceSBCPrComonad {c} {sl})
    (SliceIdF c)
SliceSBCPrCounit {c} {sl} sla =
  SliceSBCPrRAdj {c} {sl} (SliceSBCPrR {c} {sl} sla) sla
    (sliceId $ SliceSBCPrR {c} {sl} sla)

-- This is the multiplication (AKA "join") of the left induced adjoint pair
-- of the dependent-sum/base-change/dependent-product adjoint triple.
public export
SliceSBCPlJoin : {c : Type} -> {sl : SliceObj c} ->
  SliceNatTrans {x=(Sigma {a=c} sl)} {y=(Sigma {a=c} sl)}
    (SliceSBCPlMonad {c} {sl} . SliceSBCPlMonad {c} {sl})
    (SliceSBCPlMonad {c} {sl})
SliceSBCPlJoin {c} {sl} =
  SliceWhiskerRight
    {f=(SliceSBCPlComonad {sl} . SliceSBCPlL {sl})}
    {g=(SliceSBCPlL {sl})}
    {h=(SliceSBCPlR {sl})}
    (sliceSBCPlRmap {c} {sl})
  $ SliceWhiskerLeft
    {g=(SliceSBCPlComonad {sl})}
    {h=(SliceIdF $ Sigma sl)}
    (SliceSBCPlCounit {c} {sl})
    (SliceSBCPlL {sl})

-- This is the comultiplication (AKA "duplicate") of the left induced adjoint
-- pair of the dependent-sum/base-change/dependent-product adjoint triple.
public export
SliceSBCPlDup : {c : Type} -> {sl : SliceObj c} ->
  SliceNatTrans {x=(Sigma {a=c} sl)} {y=(Sigma {a=c} sl)}
    (SliceSBCPlComonad {c} {sl})
    (SliceSBCPlComonad {c} {sl} . SliceSBCPlComonad {c} {sl})
SliceSBCPlDup {c} {sl} =
  SliceWhiskerRight
    {f=(SliceSBCPlR {sl})}
    {g=(SliceSBCPlR {sl} . SliceSBCPlComonad {sl})}
    {h=(SliceSBCPlL {sl})}
    (sliceSBCPlLmap {c} {sl})
  $ SliceWhiskerLeft
    {g=(SliceIdF $ Sigma sl)}
    {h=(SliceSBCPlMonad {sl})}
    (SliceSBCPlUnit {c} {sl})
    (SliceSBCPlR {sl})

-- This is the multiplication (AKA "join") of the right induced adjoint pair
-- of the dependent-sum/base-change/dependent-product adjoint triple.
public export
SliceSBCPrJoin : {c : Type} -> {sl : SliceObj c} ->
  SliceNatTrans {x=c} {y=c}
    (SliceSBCPrMonad {c} {sl} . SliceSBCPrMonad {c} {sl})
    (SliceSBCPrMonad {c} {sl})
SliceSBCPrJoin {c} {sl} =
  SliceWhiskerRight
    {f=(SliceSBCPrComonad {sl} . SliceSBCPrL {sl})}
    {g=(SliceSBCPrL {sl})}
    {h=(SliceSBCPrR {sl})}
    (sliceSBCPrRmap {c} {sl})
  $ SliceWhiskerLeft
    {g=(SliceSBCPrComonad {sl})}
    {h=(SliceIdF c)}
    (SliceSBCPrCounit {c} {sl})
    (SliceSBCPrL {sl})

-- This is the comultiplication (AKA "duplicate") of the right induced adjoint
-- pair of the dependent-sum/base-change/dependent-product adjoint triple.
public export
SliceSBCPrDup : {c : Type} -> {sl : SliceObj c} ->
  SliceNatTrans {x=c} {y=c}
    (SliceSBCPrComonad {c} {sl})
    (SliceSBCPrComonad {c} {sl} . SliceSBCPrComonad {c} {sl})
SliceSBCPrDup {c} {sl} =
  SliceWhiskerRight
    {f=(SliceSBCPrR {sl})}
    {g=(SliceSBCPrR {sl} . SliceSBCPrComonad {sl})}
    {h=(SliceSBCPrL {sl})}
    (sliceSBCPrLmap {c} {sl})
  $ SliceWhiskerLeft
    {g=(SliceIdF c)}
    {h=(SliceSBCPrMonad {sl})}
    (SliceSBCPrUnit {c} {sl})
    (SliceSBCPrR {sl})

------------------------------------------------------------------------
---- (Co)algebras of dependent-sum/dependent-product adjoint triple ----
------------------------------------------------------------------------

-- Adjoint (co)monads, such as those induced by adjoint triples (such as
-- the dependent-sum/base-change/dependent-product adjoint triple, which is
-- implemented in the previous section), have additional properties relating
-- their (co)algebras.  See for example:
--
--  - https://ncatlab.org/nlab/show/adjoint+monad

-- Specifically, the ("Eilenberg-Moore") category of algebras over the
-- monad is equivalent to the category of coalgebras over the comonad.

public export
SBCPlAlgToCoalg : {c : Type} -> {sl : SliceObj c} ->
  (sa : SliceObj $ Sigma {a=c} sl) ->
  SliceAlg (SliceSBCPlL {c} {sl}) sa -> -- `SliceSBCPlL` is `SSMonad`
  SliceCoalg (SliceSBCPlR {c} {sl}) sa -- `SliceSBCPlR` is `SPComonad`
SBCPlAlgToCoalg {c} {sl} sa = SliceSBCPlLAdj {c} {sl} sa sa

public export
SBCPlCoalgToAlg : {c : Type} -> {sl : SliceObj c} ->
  (sa : SliceObj $ Sigma {a=c} sl) ->
  SliceCoalg (SliceSBCPlR {c} {sl}) sa -> -- `SliceSBCPlR` is `SPComonad`
  SliceAlg (SliceSBCPlL {c} {sl}) sa -- `SliceSBCPlL` is `SSMonad`
SBCPlCoalgToAlg {c} {sl} sa = SliceSBCPlRAdj {c} {sl} sa sa

public export
SBCPrAlgToCoalg : {c : Type} -> {sl : SliceObj c} ->
  (sa : SliceObj c) ->
  SliceAlg (SliceSBCPrL {c} {sl}) sa -> -- `SliceSBCPrL` is `SSComonad`
  SliceCoalg (SliceSBCPrR {c} {sl}) sa -- `SliceSBCPrR` is `SPMonad`
SBCPrAlgToCoalg {c} {sl} sa = SliceSBCPrLAdj {c} {sl} sa sa

public export
SBCPrCoalgToAlg : {c : Type} -> {sl : SliceObj c} ->
  (sa : SliceObj c) ->
  SliceCoalg (SliceSBCPrR {c} {sl}) sa -> -- `SliceSBCPrR` is `SPMonad`
  SliceAlg (SliceSBCPrL {c} {sl}) sa -- `SliceSBCPrL` is `SSComonad`
SBCPrCoalgToAlg {c} {sl} sa = SliceSBCPrRAdj {c} {sl} sa sa

--------------------------------------------------
--------------------------------------------------
---- Sigma/base-change/pi composed adjunction ----
--------------------------------------------------
--------------------------------------------------

-- Besides forming an adjoint triple, dependent-sum/base-change and
-- base-change/dependent-product can be composed across three (potentially)
-- different slice categories.  See for example:
--
--  - https://en.wikipedia.org/wiki/Adjoint_functors#Composition

-- This is the left adjoint of the composed
-- dependent-sum/dependent-product adjunction, in category-theoretic style.
public export
SliceFibSigmaPiFL : {c, d, e : Type} -> (d -> c) -> (d -> e) ->
  SliceFunctor e c
SliceFibSigmaPiFL {c} {d} {e} g f =
  SliceFibSigmaF {c=d} {d=c} g . BaseChangeF {c=e} {d} f

public export
sfsplMap : {c, d, e : Type} -> (g : d -> c) -> (f : d -> e) ->
  SliceFMap (SliceFibSigmaPiFL {c} {d} {e} g f)
sfsplMap {c} {d} {e} g f x y =
  sfsMap {c=d} {d=c} {f=g} (BaseChangeF f x) (BaseChangeF f y)
  . bcMap {c=e} {d} {f} x y

-- This is the left adjoint of the composed
-- dependent-sum/dependent-product adjunction, in dependent-type style.
public export
SliceSigmaPiFL : {c, e : Type} ->
  (d : SliceObj (c, e)) -> SliceFunctor e c
SliceSigmaPiFL {c} {e} d =
  SliceSigmaF (Sigma {a=e} . curry d)
  . BaseChangeF {c=e} {d=(Sigma {a=c} $ Sigma {a=e} . curry d)}
    (\eced => fst $ snd eced)

public export
ssplMap : {c, e : Type} ->
  (d : SliceObj (c, e)) -> SliceFMap (SliceSigmaPiFL {c} {e} d)
ssplMap {c} {e} d x y =
  ssMap {sl=(Sigma {a=e} . curry d)}
    (\eced => x $ fst $ snd $ eced)
    (\eced => y $ fst $ snd $ eced)
  . bcMap x y

-- This is the right adjoint of the composed
-- dependent-sum/dependent-product adjunction, in category-theoretic style.
public export
SliceFibSigmaPiFR : {c, d, e : Type} -> (d -> e) -> (d -> c) ->
  SliceFunctor c e
SliceFibSigmaPiFR {c} {d} {e} g f =
  SliceFibPiF {c=d} {d=e} g . BaseChangeF {c} {d} f

public export
sfsprMap : {c, d, e : Type} -> (g : d -> e) -> (f : d -> c) ->
  SliceFMap (SliceFibSigmaPiFR {c} {d} {e} g f)
sfsprMap {c} {d} {e} g f x y =
  sfpMap {c=d} {d=e} {f=g} (BaseChangeF f x) (BaseChangeF f y)
  . bcMap {c} {d} {f} x y

-- This is the right adjoint of the composed
-- dependent-sum/dependent-product adjunction, in dependent-type style.
public export
SliceSigmaPiFR : {c, e : Type} ->
  (d : SliceObj (c, e)) -> SliceFunctor c e
SliceSigmaPiFR {c} {e} d =
  SlicePiF (Sigma {a=c} . flip (curry d))
  . BaseChangeF {c} {d=(Sigma {a=e} $ Sigma {a=c} . flip (curry d))}
    (\eecd => fst $ snd eecd)

public export
ssprMap : {c, e : Type} ->
  (d : SliceObj (c, e)) -> SliceFMap (SliceSigmaPiFR {c} {e} d)
ssprMap {c} {e} d x y =
  spMap {sl=(Sigma {a=c} . flip (curry d))}
    (\eecd => x $ fst $ snd $ eecd)
    (\eecd => y $ fst $ snd $ eecd)
  . bcMap x y

-- The monad of the composed dependent-sum/dependent-product adjunction.
public export
SSPMonad : {c, e : Type} -> (d : SliceObj (c, e)) -> SliceEndofunctor e
SSPMonad {c} {e} d = SliceSigmaPiFR {c} {e} d . SliceSigmaPiFL {c} {e} d

public export
sspMonadMap : {c, e : Type} -> (d : SliceObj (c, e)) ->
  SliceFMap (SSPMonad {c} {e} d)
sspMonadMap {c} {e} d x y =
  ssprMap {c} {e} d (SliceSigmaPiFL d x) (SliceSigmaPiFL d y)
  . ssplMap {c} {e} d x y

-- The comonad of the composed dependent-sum/dependent-product adjunction.
public export
SSPComonad : {c, e : Type} -> (d : SliceObj (c, e)) -> SliceEndofunctor c
SSPComonad {c} {e} d = SliceSigmaPiFL {c} {e} d . SliceSigmaPiFR {c} {e} d

public export
sspComonadMap : {c, e : Type} -> (d : SliceObj (c, e)) ->
  SliceFMap (SSPComonad {c} {e} d)
sspComonadMap {c} {e} d x y =
  ssplMap {c} {e} d (SliceSigmaPiFR d x) (SliceSigmaPiFR d y)
  . ssprMap {c} {e} d x y

-- The unit of the composed dependent-sum/dependent-product adjunction.
public export
sspUnit : {c, e : Type} -> (d : SliceObj (c, e)) ->
  SliceNatTrans {x=e} {y=e} (SliceIdF e) (SSPMonad {c} {e} d)
sspUnit {c} {e} d sc ee esc ecd = ((ee ** snd ecd) ** esc)

-- The counit of the composed dependent-sum/dependent-product adjunction.
public export
sspCounit : {c, e : Type} -> (d : SliceObj (c, e)) ->
  SliceNatTrans {x=c} {y=c} (SSPComonad {c} {e} d) (SliceIdF c)
sspCounit {c} {e} d sc ec pisc = snd pisc (ec ** snd $ fst pisc)

-- The left adjunct of the composed dependent-sum/dependent-product adjunction.
--
-- To spell out the hom-set isomorphism, of which the adjuncts are the
-- two directions, in this particular instance:
--
--     L sa -> sb == (Sigma . BC) a -> sb
--  == Sigma (BC sa) -> sb
--  == BC sa -> BC sb (Sigma/BC left adjunct)
--  == sa -> Pi (BC sb) (BC/Pi left adjunct)
--  == sa -> (Pi . BC) sb == sa -> R sb
public export
SliceSigmaPiFLAdj : {c, e : Type} -> (d : SliceObj (c, e)) ->
  (sa : SliceObj e) -> (sb : SliceObj c) ->
  SliceMorphism {a=c} (SliceSigmaPiFL d sa) sb ->
  SliceMorphism {a=e} sa (SliceSigmaPiFR d sb)
SliceSigmaPiFLAdj {c} {e} d sa sb m =
  sliceComp
    (ssprMap {c} {e} d (SliceSigmaPiFL {c} {e} d sa) sb m)
    (sspUnit {c} {e} d sa)

-- The right adjunct of the composed dependent-sum/dependent-product adjunction.
--
-- To spell out the hom-set isomorphism, of which the adjuncts are the
-- two directions, in this particular instance:
--
--     sa -> R sb == sa -> (Pi . BC)
--  == sa -> Pi (BC sb)
--  == BC sa -> BC sb (BC/Pi right adjunct)
--  == Sigma (BC sa) -> sb (Sigma/BC left adjunct)
--  == (Sigma . BC) sa -> sb == L sa -> sb
public export
SliceSigmaPiFRAdj : {c, e : Type} -> (d : SliceObj (c, e)) ->
  (sa : SliceObj e) -> (sb : SliceObj c) ->
  SliceMorphism {a=e} sa (SliceSigmaPiFR d sb) ->
  SliceMorphism {a=c} (SliceSigmaPiFL d sa) sb
SliceSigmaPiFRAdj {c} {e} d sa sb m =
  sliceComp
    (sspCounit {c} {e} d sb)
    (ssplMap {c} {e} d sa (SliceSigmaPiFR {c} {e} d sb) m)

-- The multiplication (AKA "join") of the composed
-- dependent-sum/dependent-product adjunction.
public export
SliceSigmaPiFJoin : {c, e : Type} -> {d : SliceObj (c, e)} ->
  SliceNatTrans {x=e} {y=e}
    (SSPMonad {c} {e} d . SSPMonad {c} {e} d)
    (SSPMonad {c} {e} d)
SliceSigmaPiFJoin {c} {e} {d} =
  SliceWhiskerRight
    {f=(SSPComonad {c} {e} d . SliceSigmaPiFL {c} {e} d)}
    {g=(SliceSigmaPiFL {c} {e} d)}
    {h=(SliceSigmaPiFR {c} {e} d)}
    (ssprMap {c} {e} d)
  $ SliceWhiskerLeft
    {g=(SSPComonad {c} {e} d)}
    {h=(SliceIdF c)}
    (sspCounit {c} {e} d)
    (SliceSigmaPiFL {c} {e} d)

-- The comultiplication (AKA "duplicate") of the composed
-- dependent-sum/dependent-product adjunction.
public export
SliceSigmaPiFDup : {c, e : Type} -> {d : SliceObj (c, e)} ->
  SliceNatTrans {x=c} {y=c}
    (SSPComonad {c} {e} d)
    (SSPComonad {c} {e} d . SSPComonad {c} {e} d)
SliceSigmaPiFDup {c} {e} {d} =
  SliceWhiskerRight
    {f=(SliceSigmaPiFR {c} {e} d)}
    {g=(SliceSigmaPiFR {c} {e} d . SSPComonad {c} {e} d)}
    {h=(SliceSigmaPiFL {c} {e} d)}
    (ssplMap {c} {e} d)
  $ SliceWhiskerLeft
    {g=(SliceIdF e)}
    {h=(SSPMonad {c} {e} d)}
    (sspUnit {c} {e} d)
    (SliceSigmaPiFR {c} {e} d)
