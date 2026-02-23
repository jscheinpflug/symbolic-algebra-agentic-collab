module Main (main) where

import Integration.Symbolic.ContractsIntegrationTest qualified as SymbolicIntegration
import Integration.Workflow.ReviewLoopIntegrationTest qualified as WorkflowIntegration
import Test.Hspec
import Unit.SymbolicAlgebraAgenticCollab.ConfigTest qualified as ConfigTest
import Unit.SymbolicAlgebraAgenticCollab.LoggingTest qualified as LoggingTest
import Unit.SymbolicAlgebraAgenticCollab.Symbolic.CorpusTest qualified as CorpusTest
import Unit.SymbolicAlgebraAgenticCollab.Symbolic.Dsl.AstTest qualified as DslAstTest
import Unit.SymbolicAlgebraAgenticCollab.Symbolic.Dsl.ParserTest qualified as DslParserTest
import Unit.SymbolicAlgebraAgenticCollab.Symbolic.Dsl.PrettyTest qualified as DslPrettyTest
import Unit.SymbolicAlgebraAgenticCollab.Symbolic.Engine.ApplyTest qualified as EngineApplyTest
import Unit.SymbolicAlgebraAgenticCollab.Symbolic.Engine.EGraph.BuildTest qualified as EGraphBuildTest
import Unit.SymbolicAlgebraAgenticCollab.Symbolic.Engine.EGraph.RewriteTest qualified as EGraphRewriteTest
import Unit.SymbolicAlgebraAgenticCollab.Symbolic.Engine.EGraph.SaturateTest qualified as EGraphSaturateTest
import Unit.SymbolicAlgebraAgenticCollab.Symbolic.Engine.EGraph.TranslateTest qualified as EGraphTranslateTest
import Unit.SymbolicAlgebraAgenticCollab.Symbolic.Engine.SearchTest qualified as EngineSearchTest
import Unit.SymbolicAlgebraAgenticCollab.Symbolic.PatternTest qualified as PatternTest
import Unit.SymbolicAlgebraAgenticCollab.Symbolic.RuleTest qualified as RuleTest
import Unit.SymbolicAlgebraAgenticCollab.Symbolic.StrategyTest qualified as StrategyTest
import Unit.SymbolicAlgebraAgenticCollab.Symbolic.SymbolTest qualified as SymbolTest
import Unit.SymbolicAlgebraAgenticCollab.Symbolic.TermTest qualified as TermTest
import Unit.SymbolicAlgebraAgenticCollab.Symbolic.TraceTest qualified as TraceTest
import Unit.SymbolicAlgebraAgenticCollab.WorkflowTest qualified as WorkflowTest
import Unit.SymbolicAlgebraAgenticCollabTest qualified as TopLevelTest

main :: IO ()
main =
    hspec $ do
        describe "Unit" $ do
            TopLevelTest.spec
            ConfigTest.spec
            LoggingTest.spec
            WorkflowTest.spec
            TermTest.spec
            SymbolTest.spec
            PatternTest.spec
            RuleTest.spec
            StrategyTest.spec
            TraceTest.spec
            EngineApplyTest.spec
            EGraphBuildTest.spec
            EGraphRewriteTest.spec
            EGraphSaturateTest.spec
            EGraphTranslateTest.spec
            EngineSearchTest.spec
            DslAstTest.spec
            DslParserTest.spec
            DslPrettyTest.spec
            CorpusTest.spec

        describe "Integration" $ do
            WorkflowIntegration.spec
            SymbolicIntegration.spec
