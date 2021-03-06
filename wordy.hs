module Wordy where
import Data.Char
--
-- * Syntax of Wordy
--

-- Grammar for Wordy:

--    prog       ::= cmd*


--    value     ::= string
--                | int
--                | bool
--                | error

--    cmd        ::= sentence
--                 |  number
--                 |  `bind` expr
--                 |  `count` expr
--                 |  `reverse` expr
--                 |  `insert` expr
--                 |  `remove` expr
--                 |  `if` expr expr `else` expr
--



type Prog = [Expr]


data Expr = Sentence String
         | Num Int
        --  | Bind Expr Expr (WIP)
         | Count Expr
         | Split Expr
         | Reverse Expr
         | Insert Expr Expr Expr
         | Remove Expr Expr
         | Equ Expr Expr
         | IfElse Expr Expr Expr
        --  | While Expr Expr (WIP)
        | Cap Expr
        | Low Expr
  deriving (Eq,Show)

data Value
   = S String
   | L [String]
   | I Int
   | B Bool
   | Error
  deriving (Eq,Show)


listString :: Expr -> [String]
listString (Sentence givenString) = words givenString

split :: Expr -> Value
split (Sentence givenString) = L (words givenString)

countWords :: Expr -> Value
countWords (Sentence sentence) = I (length (listString (Sentence sentence)))


reverseSentence :: Expr -> Value
reverseSentence (Sentence sentence) = S (unwords (reverse (listString (Sentence sentence))))

insertWord :: Expr -> Expr -> Expr -> Value
insertWord (Num pos) (Sentence word) (Sentence sentence) = S (unwords (atPos ++ (word:list)))
                  where (atPos,list) = splitAt pos (listString (Sentence sentence))

removeWord :: Expr -> Expr -> Value
removeWord (Num pos) (Sentence sentence) = S (unwords (_removeWord pos (listString (Sentence sentence))))

_removeWord :: Int -> [a] -> [a]
_removeWord 0 (x:xs) = xs
_removeWord num (x:xs) | num >= 0 = x : (_removeWord (num - 1) xs)





--f :: [a] -> [a]
--f [] = []
--f xs = let (h, t) = splitAt 5 xs in h ++ f (drop 3 t)


-- capitalize :: Expr -> Expr
-- capitalize [] = []
-- capitalize sentence = capWord (single) ++ " " ++ (capitalize (unwords list)) -- remove space at the end?
--                 where (single:list) = listString (Sentence sentence)
-- 
-- allCap:: String -> Expr
-- allCap sentence = map toUpper (Sentence sentence)
-- 
-- allLow:: String -> Expr
-- allLow sentence = map toLower (Sentence sentence)

capWord :: Expr -> Value
capWord (Sentence []) = S []
capWord (Sentence (x:xs)) = S (toUpper x : map toLower xs)

lowWord :: Expr -> Value
lowWord (Sentence []) = S []
lowWord (Sentence (x:xs)) = S (toLower x : map toLower xs)

cmd :: Expr -> Value
cmd (Sentence x) = S x
cmd (Num x) = I x
--cmd (Bind x y) =
cmd (Count x)      = case cmd x of
                          S x' -> countWords (Sentence x')
                          _    -> Error
cmd (Reverse x)    = case cmd x of
                          S x' -> reverseSentence (Sentence x')
                          _    -> Error
cmd (Insert z y x) = case (cmd z, cmd y, cmd x) of 
                          (I z', S y', S x') -> insertWord (Num z') (Sentence y') (Sentence x')
                          _                  -> Error
cmd (Remove x y)   = case (cmd x, cmd y) of
                          (I x', S y') -> removeWord (Num x') (Sentence y')     
                          _ -> Error
cmd (Equ y z)      = case (cmd y, cmd z) of
                          (I a, I b) -> B (a == b)
                          (B a, B b) -> B (a == b)
                          (S i, S j) -> B (i == j)
                          _          -> Error
cmd (IfElse z y x) = case cmd z of
                          B True  -> cmd y
                          B False -> cmd x
                          _       -> Error
cmd (Split x)      = case cmd x of 
                          S x' -> split (Sentence x')
                          _       -> Error
cmd (Cap x)        = case cmd x of 
                          S x' -> capWord (Sentence x')
                          _       -> Error
cmd (Low x)        = case cmd x of 
                          S x' -> lowWord (Sentence x')
                          _       -> Error


--capitalize :: Expr
--capitalize (Sentence x) = Cap (Sentence (Split (Sentence x)))

-- Syntactic Sugar

true :: Expr
true = Equ (Sentence "x y") (Sentence "x y")

false :: Expr
false = Equ (Sentence "x y") (Sentence "x y z")

and :: Expr -> Expr -> Expr
and x y = IfElse x y false

or :: Expr -> Expr -> Expr
or x y = IfElse x true y



--------------------------
-- Command Examples:

--cmd (IfElse (Equ (Sentence "Hello") (Sentence "Hello")) (Reverse (Sentence "Hello")) (Count (Sentence "Hello")))

-- Wordy Programs:

-- a program that is still under development with the later implimentation of Bind
--p1 :: Prog
--p1 = P [(Bind (Var "x") (Sentence "Hello World")), (Bind (Var "y") (Sentence "Bye World")), (IfElse (Equ (Count (Var "x") (Count (Var "y")))) 
      --(Insert (Num 0) (Sentence "Hello") (Var "x")) (Capitalize (Var "y")))]

----------------------------


-----------------Working Programs-------------


-- a program to insert a period after every word of the sentence

p2 :: Expr
p2 = Insert (Count (Sentence "Today is a ")) (Sentence "good day") (Sentence "Today is a ")

-- Same but bad program where Insert is taking the String instead of Num

p3 :: Expr
p3 = Insert (Reverse (Sentence "Today is a ")) (Sentence "good day") (Sentence "Today is a ")

-- a program that compares two string word counts to see if they are equal

p4 :: Expr 
p4 = IfElse (Equ (Count (Sentence "Good day John")) (Count (Sentence "Good day John"))) (true) (false)

-- Same but bad program, where Equ is comparing String and Num

p5 :: Expr 
p5 = IfElse (Equ (Count (Sentence "Good day John")) (Reverse (Sentence "Good day John"))) (true) (false)