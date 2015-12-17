module ShortId (generate) where

import Native.ShortId


generate : () -> String
generate =
    Native.ShortId.generate
