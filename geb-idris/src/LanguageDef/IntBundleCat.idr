module LanguageDef.IntBundleCat

import Library.IdrisUtils
import Library.IdrisCategories
import Library.IdrisAlgebra
import public LanguageDef.InternalCat
import public LanguageDef.IntUFamCat
import public LanguageDef.IntEFamCat
import public LanguageDef.IntUCofamCat
import public LanguageDef.IntECofamCat

-----------------
-----------------
---- Objects ----
-----------------
-----------------

public export
record IntBundleObj {c : Type} (mor : IntDifunctorSig c) where
  constructor IBO
  iboDom : c
  iboCod : c
  iboMor : mor iboDom iboCod