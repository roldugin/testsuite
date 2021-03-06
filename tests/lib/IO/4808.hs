import System.IO
import GHC.IO.Handle
import GHC.IO.FD as FD

main = do
  (fd, _) <- FD.openFile "4808.hs" ReadWriteMode False
  hdl <- mkDuplexHandle fd "4808.hs" Nothing nativeNewlineMode
  hClose hdl
  (fd2, _) <- FD.openFile "4808.hs" ReadWriteMode False
  print (fdFD fd == fdFD fd2) -- should be True
  hGetLine hdl >>= print -- should fail with an exception

