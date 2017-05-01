// F1 key handler.

// Include
#include "Inkey.ch"
#include "zSound.ch"
#include "zGetSet.ch"




procedure zF1Help

// Locals
local bSaveAltC  := setkey(K_F1,nil)
local aCallStack := {}
local i          := 0
local lDuplicate := .f.
local cUrl       := "\Jazz\HTML_Help\"
local j, k, aUnique
local lFound     := .f.
local aWorkAreas  := {}
local nSaveSelect := select()

// Header
zSaveEnv(.t.)
zHeader(SCREEN_TITLE)

// Open help Dbf
if zOpenShared({"HtmlHelp"},aWorkAreas)
  
endif

while ! empty(procfile(i))
  aadd(aCallStack, procfile(i))
  i ++
enddo

aUnique := {}

aadd(aUnique, aCallStack[1])

for i := 2 to len(aCallStack) step 1       
  for j := 1 to len(aUnique) step 1
    if ! lDuplicate .and. ! empty(aUnique) .and. aCallStack[i] == aUnique[j]
      lDuplicate := .t. 
    endif
  next
  if ! lDuplicate .and. ! aCallStack[i] has "^[zZ][a-zA-Z0-9]"
    aadd(aUnique, aCallStack[i])
  else
    lDuplicate := .f.
  endif
next

// remove .PRG file extension from files
for j := len(aUnique) to 1 step -1
  aUnique[j] := left(aUnique[j], rat(".PRG", upper(aUnique[j])) -1)

  // Check if help file exists for selected PRG, if match found create URL from filename and launch help file.
  if HtmlHelp->(zdbSeek(aUnique[j],"HTMLHESG"))
    cUrl := cUrl + aUnique[j] + "/"
    
    // Launch help file
    zGetHelp(cUrl)

    lFound := .t.
    exit
  endif
next

// If no help found, launch default help file
if ! lFound
  zGetHelp(cUrl + "JazzHome")
endif

// Maintenance
setkey(K_F1,bSaveAltC)
zdbRestore(aWorkAreas,nSaveSelect)
zRestEnv()

// zF1Help
return
