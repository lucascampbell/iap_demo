
if "%RHO_PLATFORM%" == "android" (

cd iap\platform\android
rake --trace

)

if "%RHO_PLATFORM%" == "iphone" (

cd iap\platform\phone
rake --trace

)

if "%RHO_PLATFORM%" == "wm" (

cd iap\platform\wm
rake --trace

)

if "%RHO_PLATFORM%" == "win32" (

cd iap\platform\wm
rake --trace

)

if "%RHO_PLATFORM%" == "bb" (

cd iap\platform\bb
rake --trace

)

