module Unit.SymbolicAlgebraAgenticCollab.Symbolic.TermTest (
    prop_termDepthWithinGeneratorBound,
    spec,
) where

import Support.Generators.Symbolic.Core (genTermWithDepth, termDepth)
import SymbolicAlgebraAgenticCollab.Symbolic.Term
import Test.Hspec
import Test.Hspec.QuickCheck (prop)
import Test.QuickCheck (Property, chooseInt, counterexample, forAll)

spec :: Spec
spec =
    describe "Symbolic.Term" $ do
        it "constructors preserve tree structure" $ do
            let term = Node (Head "Plus") [Atom "x", Number 2, TextLit "hello"]
            term `shouldBe` Node (Head "Plus") [Atom "x", Number 2, TextLit "hello"]

        prop "prop_termDepthWithinGeneratorBound" prop_termDepthWithinGeneratorBound

prop_termDepthWithinGeneratorBound :: Property
prop_termDepthWithinGeneratorBound =
    forAll (chooseInt (0, 6)) $ \bound ->
        forAll (genTermWithDepth bound) $ \term ->
            let actualDepth = termDepth term
             in counterexample
                    ("expected depth <= " <> show bound <> ", observed " <> show actualDepth)
                    (actualDepth <= bound)
