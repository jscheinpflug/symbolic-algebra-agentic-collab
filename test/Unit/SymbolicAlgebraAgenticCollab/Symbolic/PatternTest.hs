module Unit.SymbolicAlgebraAgenticCollab.Symbolic.PatternTest (
    prop_patternDepthWithinGeneratorBound,
    spec,
) where

import Support.Generators.Symbolic.Core (genPatternWithDepth, patternDepth)
import SymbolicAlgebraAgenticCollab.Symbolic.Pattern
import SymbolicAlgebraAgenticCollab.Symbolic.Term (Head (..))
import Test.Hspec
import Test.Hspec.QuickCheck (prop)
import Test.QuickCheck (Property, chooseInt, counterexample, forAll)

spec :: Spec
spec =
    describe "Symbolic.Pattern" $ do
        it "preserves nested structure" $ do
            let x = Name "x"
            let patternNode = PNode (Head "Plus") [PVar x, PNumber 0]
            patternNode `shouldBe` PNode (Head "Plus") [PVar x, PNumber 0]

        prop "prop_patternDepthWithinGeneratorBound" prop_patternDepthWithinGeneratorBound

prop_patternDepthWithinGeneratorBound :: Property
prop_patternDepthWithinGeneratorBound =
    forAll (chooseInt (0, 6)) $ \bound ->
        forAll (genPatternWithDepth bound) $ \patternNode ->
            let actualDepth = patternDepth patternNode
             in counterexample
                    ("expected depth <= " <> show bound <> ", observed " <> show actualDepth)
                    (actualDepth <= bound)
