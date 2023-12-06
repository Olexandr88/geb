module LanguageDef.Test.DiagramCatTest

import Test.TestLibrary
import LanguageDef.Test.ProgFinSetTest
import LanguageDef.DiagramCat

%default total

----------------------------------
----------------------------------
---- Dependent-pair induction ----
----------------------------------
----------------------------------

T0Starter' : Type
T0Starter' = ()

T0Maker' : Type -> Type
T0Maker' = ProductMonad

T0DepMaker' : (Type, Type) -> Type
T0DepMaker' (a, b) = (a, b, b)

Test0' : (Type, Type) -> Type
Test0' (a, b) = Either T0Starter' (Either (T0Maker' a) (T0DepMaker' (a, b)))

mutual
  public export
  data Test0 : Type where
    T0Starter : Test0
    T0Maker : Test0 -> Test0 -> Test0
    T0DepMaker : (a : Test0) -> Test1 a -> Test1 a -> Test0

  public export
  data Test1 : Test0 -> Type where
    T1Starter : Test1 T0Starter
    T1Id : (a : Test0) -> Test1 a
    T1Maker : (a, b : Test0) -> Test1 a -> Test1 b -> Test1 (T0Maker a b)
    T1Composer : (a, b, c : Test0) ->
      Test1 (T0Maker b c) -> Test1 (T0Maker a b) -> Test1 (T0Maker a c)
    T1Distrib : (a, b, c : Test0) ->
      Test1 (T0Maker a (T0Maker b c)) ->
      Test1 (T0Maker (T0Maker a b) (T0Maker a c))
    T1DepComposer :
      (a : Test0) -> (f, g, h : Test1 a) ->
      Test1 (T0DepMaker a g h) ->
      Test1 (T0DepMaker a f g) ->
      Test1 (T0DepMaker a f h)
    T1Telescope : (a : Test0) -> (f, g : Test1 a) ->
      (t, t' : Test1 (T0DepMaker a f g)) ->
      (dt, dt' : Test1 (T0DepMaker (T0DepMaker a f g) t t')) ->
      Test1 (T0DepMaker (T0DepMaker (T0DepMaker a f g) t t') dt dt')

--------------------
--------------------
---- Telescopes ----
--------------------
--------------------

data TelObj : TelN 0 where
  T1 : TelObj
  TP : TelObj -> TelObj -> TelObj

data TelMorphD : (TelObj, TelObj) -> Type where
  TM1 : (a : TelObj) -> TelMorphD (a, T1)
  TMp1 : (a, b : TelObj) -> TelMorphD (TP a b, a)
  TMp2 : (a, b : TelObj) -> TelMorphD (TP a b, b)
  TMpi : {a, b, c :  TelObj} ->
    TelMorphD (a, b) -> TelMorphD (a, c) -> TelMorphD (a, TP b c)

data TelMorphEqD : {a, b : TelObj} ->
    (TelMorphD (a, b), TelMorphD (a, b)) -> Type where
  TM1Sym : {a, b : TelObj} -> {f, g : TelMorphD (a, b)} ->
    TelMorphEqD (f, g) -> TelMorphEqD (g, f)
  TM1Eq : {a : TelObj} -> (f : TelMorphD (a, T1)) -> TelMorphEqD (f, TM1 a)

TelMorph : TelN 1
TelMorph = ((TelObj, TelObj) ** TelMorphD)

TelMorphEq : TelN 2
TelMorphEq =
  (TelMorph ** \((a, b) ** f) => (g : TelMorphD (a, b)) -> TelMorphEqD (f, g))

---------------
---------------
---- Paths ----
---------------
---------------

data TPDvert : Type where
  TPDm : TPDvert
  TPDo : TPDvert
  TPDeqm : TPDvert
  TPDi : TPDvert

data TPDedge : SliceObj (TPDvert, TPDvert) where
  TPDm1 : TPDedge (TPDm, TPDo)
  TPDm2 : TPDedge (TPDm, TPDo)
  TPDeq1 : TPDedge (TPDeqm, TPDm)
  TPDeq2 : TPDedge (TPDeqm, TPDm)

testPreDiag : PreDiagram
testPreDiag = MkPreDiag TPDvert TPDedge

TPDPath : SliceObj (TPDvert, TPDvert)
TPDPath = PDPath testPreDiag

tpdiId : TPDPath (TPDi, TPDi)
tpdiId = InSPFM ((TPDi, TPDi) ** Left Refl) $ \((v, w) ** d) => void d

tpdeqo : TPDPath (TPDeqm, TPDo)
tpdeqo = InSPFM ((TPDeqm, TPDo) ** Right (TPDm ** TPDeq2)) $
  \((v, w) ** d) => rewrite fst d in rewrite snd d in
    InSPFM ((TPDm, TPDo) ** Right (TPDo ** TPDm1)) $ \((v', w') ** d') =>
      rewrite fst d' in rewrite snd d' in InSPFM ((TPDo, TPDo) ** Left Refl) $
        \((v', w'') ** d'') => void d''

----------------------------------
----------------------------------
----- Exported test function -----
----------------------------------
----------------------------------

export
diagramCatTest : IO ()
diagramCatTest = do
  putStrLn ""
  putStrLn "====================="
  putStrLn "Begin DiagramCatTest:"
  putStrLn "---------------------"
  putStrLn ""
  putStrLn "--------------------"
  putStrLn "End DiagramCatTest."
  putStrLn "===================="
  pure ()
