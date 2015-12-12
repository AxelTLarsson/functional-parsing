module Program(T, parse, fromString, toString, exec) where
import qualified Dictionary
import           Parser     hiding (T)
import           Prelude    hiding (fail, return)
import qualified Statement

newtype T = Program [Statement.T] -- to be defined

program = iter Statement.parse >-> \stmts -> Program stmts

instance Parse T where
  parse = program
  toString = error "Program.toString not implemented"

exec :: T -> [Integer] -> [Integer]
exec (Program stmts) input = Statement.exec stmts Dictionary.empty input
