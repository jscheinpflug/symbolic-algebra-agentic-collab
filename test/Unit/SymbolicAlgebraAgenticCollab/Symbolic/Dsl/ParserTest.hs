module Unit.SymbolicAlgebraAgenticCollab.Symbolic.Dsl.ParserTest (spec) where

import SymbolicAlgebraAgenticCollab.Symbolic.Dsl.Parser
import Test.Hspec

spec :: Spec
spec =
    describe "Symbolic.Dsl.Parser" $ do
        it "preserves parse diagnostics fields" $ do
            let parseDiag =
                    ParseError
                        { parseErrorLine = 3
                        , parseErrorColumn = 7
                        , parseErrorMessage = "unexpected token"
                        }
            parseErrorLine parseDiag `shouldBe` 3
            parseErrorColumn parseDiag `shouldBe` 7
            parseErrorMessage parseDiag `shouldBe` "unexpected token"

        it "exposes parser contract constructor" $ do
            ParserContract `shouldBe` ParserContract
