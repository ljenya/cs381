module Wordy where
import Data.Char
--
-- * Syntax of Wordy
--

-- Grammar for Wordy:
--
--    word       ::= (any string)
--    letter     ::= (any char)
--    num        ::= (any integer)
--    bool       ::= `true`  |  `false`
--    prog       ::= cmd*
--    cmd        ::= sentence
--                 |  bool
--                 |  `count`
--                 |  `reverse`
--                 |  `inWord`
--                 |  `if` prog `else` prog `end`
--


-- Program Examples

-- 1. Reverse a sentence
-- 2. Insert into a sentence
-- 3. Add/Remove from sentence
-- 4. Create a valid sentence out of words
-- 5. Check if two words are the same


data Prog = P [Expr]
  deriving (Eq,Show)

type Var = String

{-- data Wordy = Verb String
          | Adj String
          | Noun String
          | Adverb String
          | Pronoun String
          | Prepisition String
          | Conjunction String
          | Interjection String
          | Determiner String
  deriving (Eq,Show)
--}

data Expr = Sentence String
         | Num Int
         | Bind Expr Expr
         | Count Expr
         | Reverse Expr
         | Insert Expr Expr Expr
         | Remove Expr Expr
         | Capitalize Expr
         | Lowercase Expr
         | IfElse Expr Expr Expr
         | Equ Expr Expr
         -- | Compare String Sentence
         -- | Contains Wordy Char
         -- | IfElse Prog Prog
  deriving (Eq,Show)

data Value
   = S String
   | I Int
   | B Bool
   | Error
  deriving (Eq,Show)


listString :: Expr -> [String]
listString (Sentence givenString) = words givenString

countWords :: Expr -> Value
countWords (Sentence sentence) = I (length (listString (Sentence sentence)))


reverseSentence :: Expr -> Value
reverseSentence (Sentence sentence) = S (unwords (reverse (listString (Sentence sentence))))

insertWord :: Expr -> Expr -> Expr -> Value
insertWord (Num pos) (Sentence word) (Sentence sentence) = S (unwords (atPos ++ (word:list)))
                  where (atPos,list) = splitAt pos (listString (Sentence sentence))


--insertWord (Num 2) (Sentence "good") (Sentence "Today is a")
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

capWord :: Expr -> Expr
capWord (Sentence []) = Sentence []
capWord (Sentence (x:xs)) = Sentence (toUpper x : map toLower xs)

lowWord :: Expr -> Expr
lowWord (Sentence []) = Sentence []
lowWord (Sentence (x:xs)) = Sentence (toLower x : map toLower xs)

sem :: Expr -> Value
sem (Sentence x) = S x
sem (Num x) = I x
--sem (Bind x y) =
sem (Count x) = countWords x
sem (Reverse x) = reverseSentence x
sem (Insert z y x) = insertWord z y x
sem (Equ y z)  = case (sem y, sem z) of
                   (B a, B b) -> B (a == b)
                   (S i, S j) -> B (i == j)
                   _ -> Error
sem (IfElse z y x) = case sem z of
                   B True  -> sem y
                   B False -> sem x
                   _ -> Error


--sem (IfElse (Equ (Sentence "Hello") (Sentence "Hello")) (Reverse (Sentence "Hello")) (Count (Sentence "Hello")))





-- Wordy Programs 

-- a program to compare the number of words of one sentence to another, if same return True, if not return false

--compareWordCount :: String -> String -> Bool 
--compareWordCount sentence sentence2 = (countWords sentence) == (countWords sentence2) 

--p1 :: Prog
--p1 = P [(Bind (Var "x") (Sentence "Hello World")), (Bind (Var "y") (Sentence "Bye World")), (IfElse (Equ (Count (Var "x") (Count (Var "y")))) 
      --(Insert (Num 0) (Sentence "Hello") (Var "x")) (Capitalize (Var "y")))]


-- a program to insert a period after every word of the sentence

p2 :: Prog
p2 = P [(Insert (Count (Sentence "Today is a ")) (Sentence "good day") (Sentence "Today is a "))]

-- Same but bad program

p3 :: Prog
p3 = P [(Insert (Reverse (Sentence "Today is a ")) (Sentence "good day") (Sentence "Today is a "))]