{-# LANGUAGE BangPatterns #-}
module Main where

import ByteCodeLink
import CoreMonad
import Data.Array
import DataCon
import GHC
import HscTypes
import Linker
import RtClosureInspect
import TcEnv
import Type
import TcRnMonad
import TcType
import Control.Applicative
import Name (getOccString)
import Unsafe.Coerce
import Control.Monad
import Data.Maybe
import Bag
import PrelNames (iNTERACTIVE)
import Outputable
import GhcMonad
import X

main :: IO ()
main = runGhc (Just "/home/ian/ghc/git/ghc/inplace/lib") $ do
  dflags' <- getSessionDynFlags
  primPackages <- setSessionDynFlags dflags'
  dflags <- getSessionDynFlags
  defaultCleanupHandler dflags $ do
    target <- guessTarget "X.hs" Nothing
    setTargets [target]
    load LoadAllTargets

    () <- chaseConstructor (unsafeCoerce False)
    () <- chaseConstructor (unsafeCoerce [1,2,3])
    () <- chaseConstructor (unsafeCoerce (3 :-> 2))
    () <- chaseConstructor (unsafeCoerce (4 :->. 4))
    () <- chaseConstructor (unsafeCoerce (4 :->.+ 4))
    return ()

chaseConstructor :: (GhcMonad m) => HValue -> m ()
chaseConstructor !hv = do
  liftIO $ putStrLn "====="
  closure <- liftIO $ getClosureData hv
  case tipe closure  of
    Indirection _ -> chaseConstructor (ptrs closure ! 0)
    Constr -> do
      withSession $ \hscEnv -> liftIO $ initTcForLookup hscEnv $ do
        eDcname <- dataConInfoPtrToName (infoPtr closure)
        case eDcname of
          Left _       -> return ()
          Right dcName -> do
            liftIO $ putStrLn $ "Name: "      ++ showPpr dcName
            liftIO $ putStrLn $ "OccString: " ++ "'" ++ getOccString dcName ++ "'"
            dc <- tcLookupDataCon dcName
            liftIO $ putStrLn $ "DataCon: "   ++ showPpr dc
    _ -> return ()

initTcForLookup :: HscEnv -> TcM a -> IO a
initTcForLookup hsc_env = liftM (\(msg, mValue) -> fromMaybe (error . show . bagToList . snd $ msg) mValue) . initTc hsc_env HsSrcFile False iNTERACTIVE

