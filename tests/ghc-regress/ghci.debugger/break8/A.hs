import GHC.Base (breakpoint, breakpointCond)

f i = breakpointCond (i>3) ()