module Executable.Test.Main

import Test.TestLibrary
import Library.Test.IdrisUtilsTest
import Library.Test.IdrisCategoriesTest
import Library.Test.IdrisAlgebraTest
import Library.Test.CategoryTheoryTest
import LanguageDef.Test.IntBundleCatTest
import LanguageDef.Test.IntUFamCatTest
import LanguageDef.Test.IntEFamCatTest
import LanguageDef.Test.SpanCospanTest
import LanguageDef.Test.InternalCatTest
import LanguageDef.Test.SlicePolyCatTest
import LanguageDef.Test.DisliceCatTest
import LanguageDef.Test.MLBundleCatTest
import LanguageDef.Test.DislicePolyCatTest
import LanguageDef.Test.QuiverTest
import LanguageDef.Test.MLQuivCatTest
import LanguageDef.Test.MLQuivUnivTest
import LanguageDef.Test.PolyDifuncTest
import LanguageDef.Test.MLQuivPolyTest
import LanguageDef.Test.GenPolyFuncTest
import LanguageDef.Test.FinCatTest
import LanguageDef.Test.BinTreeTest
import LanguageDef.Test.GebTest
import LanguageDef.Test.RefinedADTTest
import LanguageDef.Test.FiguresTest
import LanguageDef.Test.TheoriesTest
import LanguageDef.Test.NatPrefixCatTest
import LanguageDef.Test.ADTCatTest
import LanguageDef.Test.ProgFinSetTest
import LanguageDef.Test.DiagramCatTest
import LanguageDef.Test.AdjunctionsTest
import LanguageDef.Test.GebToposTest
import LanguageDef.Test.PolyCatTest
import LanguageDef.Test.PolyProfunctorTest
import LanguageDef.Test.AtomTest
import LanguageDef.Test.UniversalCategoryTest
import LanguageDef.Test.InterpretationTest
import LanguageDef.Test.SyntaxTest
import LanguageDef.Test.ExpressionTest
import LanguageDef.Test.MetaprogrammingTest
import LanguageDef.Test.LogicTest
import LanguageDef.Test.ComputationalEffectsTest
import LanguageDef.Test.EmbeddedTest
import LanguageDef.Test.PolyIndTypesTest

%default total

export
totalTests : IO ()
totalTests = do
  Test.TestLibrary.testLibraryTest
  Library.Test.IdrisUtilsTest.idrisUtilsTest
  Library.Test.IdrisCategoriesTest.libraryIdrisCategoriesTest
  Library.Test.IdrisAlgebraTest.libraryIdrisAlgebraTest
  LanguageDef.Test.BinTreeTest.binTreeTest
  LanguageDef.Test.AtomTest.languageDefAtomTest
  LanguageDef.Test.UniversalCategoryTest.languageDefUniversalCategoryTest
  LanguageDef.Test.InterpretationTest.languageDefInterpretationTest
  LanguageDef.Test.ExpressionTest.languageDefExpressionTest
  LanguageDef.Test.MetaprogrammingTest.languageDefMetaprogrammingTest
  LanguageDef.Test.LogicTest.languageDefLogicTest
  LanguageDef.Test.ComputationalEffectsTest.languageDefComputationalEffectsTest
  LanguageDef.Test.EmbeddedTest.languageDefEmbeddedTest
  Library.Test.CategoryTheoryTest.libraryCategoryTheoryTest
  LanguageDef.Test.SpanCospanTest.spanCospanTest
  LanguageDef.Test.PolyCatTest.polyCatTest
  LanguageDef.Test.NatPrefixCatTest.natPrefixCatTest
  LanguageDef.Test.PolyProfunctorTest.polyProfunctorTest
  LanguageDef.Test.ADTCatTest.adtCatTest
  LanguageDef.Test.ProgFinSetTest.progFinSetTest
  LanguageDef.Test.DiagramCatTest.diagramCatTest
  LanguageDef.Test.AdjunctionsTest.adjunctionsTest
  LanguageDef.Test.GebToposTest.gebToposTest
  LanguageDef.Test.RefinedADTTest.languageDefRefinedADTTest
  LanguageDef.Test.SyntaxTest.languageDefSyntaxTest
  LanguageDef.Test.TheoriesTest.theoriesTest
  LanguageDef.Test.FiguresTest.figuresTest
  LanguageDef.Test.PolyIndTypesTest.polyIndTypesTest
  LanguageDef.Test.GebTest.gebTest
  LanguageDef.Test.FinCatTest.finCatTest
  LanguageDef.Test.QuiverTest.quiverTest
  LanguageDef.Test.MLQuivCatTest.mlQuivCatTest
  LanguageDef.Test.MLQuivUnivTest.mlQuivUnivTest
  LanguageDef.Test.PolyDifuncTest.polyDifuncTest
  LanguageDef.Test.MLQuivPolyTest.mlQuivPolyTest
  LanguageDef.Test.GenPolyFuncTest.genPolyFuncTest
  LanguageDef.Test.DisliceCatTest.disliceCatTest
  LanguageDef.Test.DislicePolyCatTest.dislicePolyCatTest
  LanguageDef.Test.InternalCatTest.internalCatTest
  LanguageDef.Test.SlicePolyCatTest.slicePolyCatTest
  LanguageDef.Test.MLBundleCatTest.mlBundleCatTest
  LanguageDef.Test.IntBundleCatTest.intBundleCatTest
  LanguageDef.Test.IntUFamCatTest.intUFamCatTest
  LanguageDef.Test.IntEFamCatTest.intEFamCatTest

export
partial potentiallyNonTerminatingTests : IO ()
potentiallyNonTerminatingTests = do
  LanguageDef.Test.GebTest.gebTestPotentiallyNonTerminating

export
partial main : IO ()
main = do
  totalTests
  potentiallyNonTerminatingTests
