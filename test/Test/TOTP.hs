module Test.TOTP where

import Chronos
import Data.Maybe (fromJust)
import Sel.HMAC.SHA256 qualified as SHA256
import Sel.HMAC.SHA512 qualified as SHA512
import Test.Tasty
import Test.Tasty.HUnit
import Test.Utils
import Torsor (scale)

import Data.Text.Display (display)
import OTP.Commons
import OTP.TOTP

spec :: TestTree
spec =
  testGroup
    "TOTP"
    [ testCase "TOTP counter from time" testTOTPCounterFromTime
    , testCase "HMAC-SHA-1 TOTP codes" testSHA1TOTPCodes
    , testCase "HMAC-SHA-256 TOTP codes" testSHA256TOTPCodes
    , testCase "HMAC-SHA-512 TOTP codes" testSHA512TOTPCodes
    ]

testTOTPCounterFromTime :: Assertion
testTOTPCounterFromTime = do
  let dtf = DatetimeFormat (Just '-') (Just ' ') (Just ':')
  let decode txt = datetimeToTime $ fromJust $ Chronos.decode_YmdHMS dtf txt
  assertEqual
    "Correct counter from date"
    (totpCounter (decode "2010-10-10 00:00:00") (scale 30 second))
    42888960

  assertEqual
    "Correct counter from date"
    (totpCounter (decode "2010-10-10 00:00:30") (scale 30 second))
    42888961

  assertEqual
    "Correct counter from date"
    (totpCounter (decode "2010-10-10 00:01:00") (scale 30 second))
    42888962

testSHA1TOTPCodes :: Assertion
testSHA1TOTPCodes = do
  timestamp <- now
  let timeStep = scale 30 second
  digits <- assertJust $ mkDigits 6
  key <- assertRight $ SHA256.authenticationKeyFromHexByteString "e90cbae2d7d187f614806347cfd75002bd0db847451109599da507e8da88bf43"
  let code = totpSHA1 key timestamp timeStep digits
  let result = totpSHA1Check key (0, 1) timestamp timeStep digits (display code)
  assertBool
    "Code is checked"
    result

testSHA256TOTPCodes :: Assertion
testSHA256TOTPCodes = do
  timestamp <- now
  let timeStep = scale 30 second
  digits <- assertJust $ mkDigits 6
  key <- assertRight $ SHA256.authenticationKeyFromHexByteString "e90cbae2d7d187f614806347cfd75002bd0db847451109599da507e8da88bf43"
  let code = totpSHA256 key timestamp timeStep digits
  let result = totpSHA256Check key (0, 1) timestamp timeStep digits (display code)
  assertBool
    "Code is checked"
    result

testSHA512TOTPCodes :: Assertion
testSHA512TOTPCodes = do
  timestamp <- now
  let timeStep = scale 30 second
  digits <- assertJust $ mkDigits 6
  key <- assertRight $ SHA512.authenticationKeyFromHexByteString "e90cbae2d7d187f614806347cfd75002bd0db847451109599da507e8da88bf43"
  let code = totpSHA512 key timestamp timeStep digits
  let result = totpSHA512Check key (0, 1) timestamp timeStep digits (display code)
  assertBool
    "Code is checked"
    result
