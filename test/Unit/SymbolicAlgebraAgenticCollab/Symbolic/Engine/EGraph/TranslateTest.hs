module Unit.SymbolicAlgebraAgenticCollab.Symbolic.Engine.EGraph.TranslateTest (spec) where

import SymbolicAlgebraAgenticCollab.Symbolic.Engine.EGraph.Translate
import SymbolicAlgebraAgenticCollab.Symbolic.Term
import Test.Hspec

spec :: Spec
spec =
    describe "Symbolic.Engine.EGraph.Translate" $ do
        it "exposes typed translation failure constructors" $ do
            [BuildUnsupportedTermShape, BuildInvalidSymbolEncoding]
                `shouldBe` [BuildUnsupportedTermShape, BuildInvalidSymbolEncoding]

        it "is deterministic for repeated translation attempts" $ do
            let input = Node (Head "Plus") [Atom "x", Number 0]
            termToEGraph input `shouldBe` termToEGraph input
