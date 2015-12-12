module Program(T, parse, fromString, toString, exec) where
import qualified Dictionary
import           Parser     hiding (T)
import           Prelude    hiding (fail, return)
import qualified Statement

newtype T = Program [Statement.T] -- to be defined

program = iter Statement.parse >-> \stmts -> Program stmts

instance Parse T where
  parse = program
  toString (Program (stmt:stmts)) = (Statement.toString stmt) ++ "\n" ++ toString' stmts where
    toString' (stmt:stmts) = Statement.toString stmt ++ "\n" ++ toString' stmts
    toString' [] = ""

exec :: T -> [Integer] -> [Integer]
exec (Program stmts) input = Statement.exec stmts Dictionary.empty input
