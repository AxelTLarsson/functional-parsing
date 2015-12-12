module Statement(T, parse, toString, fromString, exec) where
import qualified Dictionary
import qualified Expr
import           Parser     hiding (T)
import           Prelude    hiding (fail, return)
type T = Statement
data Statement =
    Assignment String Expr.T |
    Skip |
    Begin [Statement] |
    If Expr.T Statement Statement |
    While Expr.T Statement |
    Read String |
    Write Expr.T
    deriving Show

statement, assignment, skip, begin, if', while, read', write :: Parser Statement
statement = assignment ! skip ! begin ! if' ! while ! read' ! write

assignment = word #- accept ":=" # Expr.parse #- require ";" >-> buildAss where
    buildAss (v, e) = Assignment v e

skip = accept "skip" -# require ";" >-> (\_ -> Skip)

begin = accept "begin" -# iter statement #- require "end" >-> \stmts -> Begin stmts

if' = accept "if" -# Expr.parse #- require "then" #
    statement #- require "else" #
    statement >->
    buildIf where
        buildIf ((e, s1), s2) = If e s1 s2

while = accept "while" -# Expr.parse #- require "do" # statement >-> \(e, s) -> While e s

read' = accept "read" -# word #- require ";" >-> \var -> Read var

write = accept "write" -# Expr.parse #- require ";" >-> \e -> Write e

exec :: [T] -> Dictionary.T String Integer -> [Integer] -> [Integer]
exec (Assignment var expr : stmts) dict input = exec stmts modifiedDict input where
    modifiedDict = Dictionary.insert (var, val) dict
    val = Expr.value expr dict
exec (Skip : stmts) dict input = exec stmts dict input
exec (Begin bStmts : stmts) dict input = exec (bStmts ++ stmts) dict input
exec (If cond thenStmts elseStmts : stmts) dict input =
    if (Expr.value cond dict)>0
    then exec (thenStmts : stmts) dict input
    else exec (elseStmts : stmts) dict input
exec (While cond wStmt : stmts) dict input
    | Expr.value cond dict > 0 = exec (wStmt:stmts) dict input
    | otherwise = exec stmts dict input
exec (Read var : stmts) dict input = exec stmts modifiedDict input' where
    modifiedDict = Dictionary.insert (var, val) dict
    val = head input    -- value read is the first in the "input" list
    input' = tail input -- remove the value read for future "input"
exec (Write expr : stmts) dict input = val : (exec stmts dict input) where
    val = Expr.value expr dict

instance Parse Statement where
  parse = statement
  toString = error "Statement.toString not implemented"
