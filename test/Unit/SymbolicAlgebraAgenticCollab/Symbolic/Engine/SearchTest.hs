module Unit.SymbolicAlgebraAgenticCollab.Symbolic.Engine.SearchTest (spec) where

import SymbolicAlgebraAgenticCollab.Symbolic.Engine.EGraph.Saturate (
    SaturationConfig (..),
    SaturationError (SaturationNoRootEClass),
 )
import SymbolicAlgebraAgenticCollab.Symbolic.Engine.Search
import SymbolicAlgebraAgenticCollab.Symbolic.Strategy (Strategy (TopDown))
import SymbolicAlgebraAgenticCollab.Symbolic.Term (Head (..), Term (..))
import Test.Hspec

spec :: Spec
spec =
    describe "Symbolic.Engine.Search" $ do
        it "stores deterministic search configuration" $ do
            let cfg =
                    SearchConfig
                        { searchMode = Deterministic
                        , maxDepth = 32
                        , maxFrontier = 512
                        , beamWidth = 16
                        }
            searchMode cfg `shouldBe` Deterministic
            maxDepth cfg `shouldBe` 32

        it "stores search statistics" $ do
            let stats = SearchStats{expandedNodes = 100, prunedNodes = 12, maxFrontierSeen = 40}
            expandedNodes stats `shouldBe` 100
            prunedNodes stats `shouldBe` 12
            maxFrontierSeen stats `shouldBe` 40

        it "exposes typed strategy-run placeholder failures" $ do
            let cfg = SaturationConfig{maxIterations = 8, maxENodes = 128, maxEClasses = 64}
            let input = Node (Head "Plus") [Atom "x", Number 0]
            runStrategy TopDown cfg [] input `shouldBe` Left SaturationNoRootEClass
