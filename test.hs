import Prelude hiding (fail, return)
type Parser a = String -> Maybe (a, String)

semicolon :: Parser Char
semicolon (';':r) = Just (';', r)
semicolon _ = Nothing

becomes :: Parser String
becomes (':':'=':r) = Just (":=", r)
becomes _ = Nothing

char :: Parser Char
char [] = Nothing
char (c:cs) = Just (c, cs)

fail :: Parser a
fail cs = Nothing

return :: a -> Parser a
return a cs = Just (a, cs)