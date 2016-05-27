module GUIs.Cells.References
  ( ReferenceGraph
  , mkEmpty
  , addReferences
  , hasCycle
  , levelsAtVertex
  ) where

import           Data.Array ((//))
import           Data.Graph (Graph, Vertex, buildG, scc, dfs, transposeG)
import           Data.Tree  (Tree, flatten, levels)

type ToVertex a = a -> Vertex
type FromVertex a = Vertex -> a
type NCells = Int

data ReferenceGraph a = ReferenceGraph
  { rgGraph      :: Graph
  , rgToVertex   :: ToVertex a
  , rgFromVertex :: FromVertex a
  }

mkEmpty :: NCells -> ToVertex a -> FromVertex a -> ReferenceGraph a
mkEmpty n = ReferenceGraph (buildG (0, n) [])

addReferences :: a -> [a] -> ReferenceGraph a -> ReferenceGraph a
addReferences v refs (ReferenceGraph graph toVertex fromVertex) =
  ReferenceGraph (graph // [(toVertex v, toVertex `map` refs)]) toVertex fromVertex

hasCycle :: ReferenceGraph a -> Bool
hasCycle (ReferenceGraph graph _ _) = any (not . isFlat) $ scc graph
  where
    isFlat :: Tree a -> Bool
    isFlat tree = length (flatten tree) <= 1

levelsAtVertex :: ReferenceGraph a -> a -> Maybe [[a]]
levelsAtVertex (ReferenceGraph graph toVertex fromVertex) v =
    case dfs (transposeG graph) [toVertex v] of
        [tree] -> Just $ levels $ fromVertex <$> tree
        _      -> Nothing