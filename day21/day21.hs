import Debug.Trace (traceShow)
import Data.List (sort, group)
import Data.Map (Map, empty, member, insert, (!))

type Point = (Int, Int)
type StateMap = Map (Point, Point) Point

main = do
    input <- readFile "input.txt" >>= return . (\[a,b]->(a, b)) . map (read . last . words) . lines
    putStrLn $ (++) "Part 1: " $ show $ part1 input
    putStrLn $ (++) "Part 2: " $ show $ part2 input

part1 = sim dice 0 (0, 0)
part2 = uncurry max . getScore

getScore :: Point -> Point
getScore ab = let sm = sim2 empty ((0, 0), ab)
    in sm ! ((0, 0), ab)

sim2 :: StateMap -> (Point, Point) -> StateMap
sim2 sm st@((as, bs), (ap, bp))
    | st `member` sm = sm
    | bs >= 21       = insert st (0, 1) sm
    | otherwise      = insert st pt sm'
    where
        sts = nextStates st
        sm' = foldl sim2 sm $ map fst sts
        pt = swap $ foldl1 tAdd $ map (\(st', c) -> (tMul (c, c) $ sm' ! st')) sts

nextStates :: (Point, Point) -> [((Point, Point), Int)]
nextStates = flip map next3 . nextState
nextState ((as, bs), (ap, bp)) (v, c) = (((bs, as'), (bp, ap')), c) where
    ap' = (ap + v) % 10
    as' = as + ap'

swap (a, b) = (b, a)
tAdd (a, b) (c, d) = (a + c, b + d)
tMul (a, b) (c, d) = (a * c, b * d)

next3 :: [(Int, Int)]
next3 = map (\a@(b:_) -> (b, length a)) $ group $ sort $
    [sum [a, b, c] | let t = [1..3], a <- t, b <- t, c <- t]

sim :: [Int] -> Int -> (Int, Int) -> (Int, Int) -> Int
sim xs s (as, bs) (ap, bp)
    | as' >= 1000 = bs * s'
    | otherwise = sim xs' s' (bs, as') (bp, ap')
    where
        (val, xs') = getStep xs
        ap' = (ap + val) % 10
        as' = as + ap'
        s' = s + 3

getStep :: [Int] -> (Int, [Int])
getStep xs = let (a, b) = splitAt 3 xs in (sum a % 10, b)

dice = cycle [1..100] :: [Int]

a % b = (a - 1) `mod` b + 1