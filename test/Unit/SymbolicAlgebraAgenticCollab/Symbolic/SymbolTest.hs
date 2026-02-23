module Unit.SymbolicAlgebraAgenticCollab.Symbolic.SymbolTest (spec) where

import SymbolicAlgebraAgenticCollab.Symbolic.Symbol
import SymbolicAlgebraAgenticCollab.Symbolic.Term (Head (..))
import Test.Hspec

spec :: Spec
spec =
    describe "Symbolic.Symbol" $ do
        it "preserves symbol metadata" $ do
            let symbolDef =
                    SymbolDef
                        { symbolHead = Head "Plus"
                        , symbolAttributes = [Associative, Commutative, Flat, Orderless]
                        }
            symbolHead symbolDef `shouldBe` Head "Plus"
            symbolAttributes symbolDef `shouldBe` [Associative, Commutative, Flat, Orderless]

        it "allows empty attributes" $ do
            let symbolDef = SymbolDef{symbolHead = Head "x", symbolAttributes = []}
            symbolAttributes symbolDef `shouldBe` []
