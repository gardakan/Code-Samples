/*
ZGETHELP - Jazz help system launcher
*/

procedure zGetHelp(cUrl)

// Launch help page
zSaveEnv(.t.)
run ('start /max ' + cUrl)
zRestEnv()

// zGetHelp
return
