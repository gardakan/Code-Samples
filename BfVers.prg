#pragma ENABLEWARNINGS = OFF
// Base formula version processing.

// Include
#include "Inkey.ch"
#include "zAsd.ch"
#include "zGetSet.ch"
#include "zDList.ch"
#include "zSound.ch"
#include "zAsdGet.ch"
#include "zMemoEdi.ch"
#include "zdbTemp.ch"
#include "zdbGb.ch"

// Definitions
#xtranslate :lSaved              => \[ 1\]
#define SAVE_ARRAY_LENGTH        1



//
procedure BfVers

// Locals
local aWorkAreas  := {}
local nSaveSelect := select()
local aTmpVfLog   := nil
local aTmpDbf     := nil

// Header
zSaveEnv(.t.)
@7,0 say "È" + repl("Í",maxcol() - 1) + "¼"

// Dbfs
if zOpenShared({"BfVers","VfForm","BfFile","VfLog"},aWorkAreas) .and. TmpVfLogCreate(@aTmpVfLog) .and. CreateDbf(@aTmpDbf)

  // Add the initial version
  if AddVersion(BfFile->CodeNo,1)
    SaveVersionOne(BfFile->CodeNo)
  endif

  // Select the source version
  SourceVersion()
endif


// Maintenance
zdbRestore(aWorkAreas,nSaveSelect)
zRestEnv()
zdbDeleteTemp(aTmpVfLog)
zdbDeleteTemp(aTmpDbf)

// BfVers
return



// Add the initial formula version
static function AddVersion(cBfCodeNo,nVersion)

// Locals
local aBfVersLL := BfVers->(dbrlocklist())
local lAdded    := .f.

// If the active BfVers version is less than nVersion, or nVersion is not found in BfVers, add new record with nVersion as version number.
if (val(BfVers->Version) < nVersion .or. ! BfVers->(zdbSeek(cBfCodeNo + strzero(nVersion,3),"BfVersBF"))) .and. BfVers->(zRecAdd())
  BfVers->BfCodeNo  := cBfCodeNo
  BfVers->Version   := strzero(nVersion,3)
  BfVers->Active    := nVersion == 1
  BfVers->CreatedBy := zGetUserId()
  BfVers->CreatedOn := zToday()
  lAdded            := .t.
endif

// Maintenance
BfVers->(zdbUnLock(aBfVersLL))

// AddVersion
return lAdded



// Save version one base formula raw materials
static procedure SaveVersionOne(cBfCodeNo)

// Save the base formula r/ms
BfForm->(zdbSeek(cBfCodeNo,"BfFormCS",.t.))
while zExactMatch(BfForm->CodeNo,cBfCodeNo) .and. ! BfForm->(eof()) .and. zSpinBar()
  zCopyRecord("BfForm","VfForm")
  zQuickDbfUpdate("VfForm",{{"Version","001"}})
  BfForm->(dbskip())
enddo 

// SaveVersionFormula
return 



//
static function SourceVersion

// Parent columns
#define PARENT_COLUMNS {{{|| padc(BfVers->Version,7)}       ,"Version"   } ,;
                        {"CreatedBy"                        ,"Created By"} ,;
                        {"CreatedOn"                        ,"Date"      } ,;
                        {{|| bCheckColumn(BfVers->Active,6)},"Active"    }}

// Parent options
#define PARENT_OPTIONS {{"Select" ,"Select the highlighted version"       ,{|| SelectVersion()           ,0},K_ENTER   ,{|| zIsRecord("BfVers")}} ,;
                        {"Formula","Switch to the formula list <Ctrl-Tab>",{|| zDlSwitch(aBfVers,aVfForm),0},K_CTRL_TAB,{|| zIsRecord("BfVers")}} ,;
                        {"Delete" ,"Delete version?"                      ,{|| DeleteVersion(),0}           ,K_DEL                   } ,;
                        {"Return" ,Z_RETURN_MESSAGE                       ,K_ESC                            ,K_ESC                              }}

// Child columns
#define CHILD_COLUMNS {{"Sequence"                                                           ,"Seq"        } ,;
                       {{|| pad(VfForm->Code,6)}                                             ,"R/M"        } ,;
                       {{|| pad(bGetElementData(VfForm->Type,VfForm->Code,"Description"),30)},"Description"} ,;
                       {{|| val(str(VfForm->Qty,15,8))}                                      ,"Quantity"   } ,;
                       {"Units"                                                              ,"Um"         }}

// Child options
#define CHILD_OPTIONS  {{"Version","Switch to the version list <Ctrl-Tab>"   ,K_ESC                        ,K_CTRL_TAB                                                } ,;
                        {"Return" ,Z_RETURN_MESSAGE                          ,K_ESC                        ,K_ESC                                                     }}

// Child top and while blocks
#define CHILD_TOP     {|| upper(BfVers->BfCodeNo + BfVers->Version)}
#define CHILD_WHILE   {|| zExactMatch(VfForm->CodeNo + VfForm->Version,BfVers->BfCodeNo + BfVers->Version)}

// Locals
local cCodeNo := BfVers->BfCodeNo
local aBfVers,aVfForm

// Create the child list
zSaveEnv(.t.)
aVfForm  := VfForm->(zDlChildCreate("Ingredients","VfForm","VfFormCs",CHILD_TOP,CHILD_WHILE,CHILD_COLUMNS,CHILD_OPTIONS,8,40,maxrow()-2,maxcol(),,zBOX_SS))

// Create the parent list
aBfVers   := BfVers->(zDlParentCreate("Versions",aVfForm,PARENT_COLUMNS,PARENT_OPTIONS,,8,0,maxrow()-2,39,,,,zBOX_SS))

// Browse the parent list
BfVers->(zOrdsetfocus("BfVersBF",.t.))
BfVers->(zdbBForWhile(aBfVers:PlBrowse,upper(BfFile->CodeNo),upper(BfFile->CodeNo),,{|| zExactMatch(BfVers->BfCodeNo,BfFile->CodeNo)}))
VfForm->(zDlChildRefresh(aVfForm))
BfVers->(zTBrowse(aBfVers:PlBrowse))
zRestEnv()

// SourceVersion
return .t.



static function TmpVfLogCreate(aTmpVfLog)

// Locals
local aStructure := {{"BfCodeNo"  ,"C",15,0} ,;    
                     {"RmCodeNo"  ,"C",15,0} ,;
                     {"Version"   ,"C", 3,0}}

// Create the temporary dbf and index
ZCREATE TEMP aTmpVfLog ALIAS "TmpVfLog" STRUCTURE aStructure

// Indexes
ZINDEX TEMP aTmpVfLog ON TmpVfLog->RmCodeNo TAG "TmpVfLog"

// TmpVfLogCreate
return zdbCreateTemp(aTmpVfLog)



// Create temporary dbf
static function CreateDbf(aTmpDbf)

// Locals
local aStructure := VfForm->(DbStruct())

// Create the temporary dbf and index
ZCREATE TEMP aTmpDbf ALIAS "VfTmp" STRUCTURE aStructure

// Indexes
ZINDEX TEMP aTmpDbf ON VfTmp->CodeNo TAG "VfTmp"
ZINDEX TEMP aTmpDbf ON VfTmp->CodeNo + VfTmp->Version + VfTmp->Sequence TAG "VfTmpCVS"

// CreateDbf
return zdbCreateTemp(aTmpDbf)



//
static procedure SelectVersion

// Locals

// (removed unused variable) - 10/26

local aWorkAreas  := {}
local nSaveSelect := select()

zSaveEnv(.t.)

// Create and init temp dbf
if zOpenShared({"BfForm"},aWorkAreas) // Removed VfForm and BfVers databases from zOpenShared - 10/26
  
  BfVFind()

endif

// Maintenance
zdbRestore(aWorkAreas,nSaveSelect)
zRestEnv()

// SelectVersion
return 



//
static procedure BfVFind()

// removed local lFind - 10/26

// Create the search list object
local oSearch           := zdbGBNew()
oSearch:dbgbTitle       := "Version: " + BfVers->Version // Resolved fp issue with BfVers, cleaned up title code - 10/26
oSearch:dbgbAlias       := "VfForm"
oSearch:dbgbIndex       := "VfFormCS"
oSearch:dbgbAliasArray  := {"VfForm"}
oSearch:dbgbReturnField := "Version"
oSearch:dbgbBoxType     := zBOX_SS
oSearch:dbgbWhile       := {|| zExactMatch(BfVers->BfCodeNo + BfVers->Version,VfForm->CodeNo + VfForm->Version)} // Now a while loop - 10/26
oSearch:dbgbTop         := 8
oSearch:dbgbLeft        := 0
oSearch:dbgbBottom      := maxrow()-2
oSearch:dbgbRight       := 39

// Define the search columns
oSearch:dbgbColumns     := {{"Sequence"                                                           ,"Seq"        } ,;
                            {{|| pad(VfForm->Code,6)}                                             ,"R/M"        } ,;
                            {{|| pad(bGetElementData(VfForm->Type,VfForm->Code,"Description"),20)},"Description"} ,;
                            {{|| val(str(VfForm->Qty,15,8))}                                      ,"Quantity"   } ,;
                            {"Units"                                                              ,"Um"         }}

// Define the search options
oSearch:dbgbBounceBar   := {{"Switch" ,"Switch to the formula list <Ctrl-Tab>",{|| BfVFind2(),0}   ,K_CTRL_TAB  ,{|| zIsRecord("BfVers")}} ,;
                            {"Return" ,Z_RETURN_MESSAGE                       ,{|| RefrExit()}     ,K_ESC                                }}

zdbGBrowse(oSearch)

// BfVFind
return



// Delete version
static procedure DeleteVersion

// Delete
if zdbDelete("Do you want to delete " + alltrim(BfVers->BfCodeNo) + " version " + alltrim(BfVers->Version) + "?",;
  {|| zdbRelDelete({{"VfForm","VfFormCS" ,{|| VfForm->CodeNo + VfForm->Version              }  },;
                    {"BfVers" ,"BfVersBF",{|| BfVers->BfCodeNo + BfVers->Version            } }},BfVers->BfCodeNo + BfVers->Version)})
  zDialog(trim(BfVers->BfCodeNo) + " version " + alltrim(BfVers->Version) + " deleted.",,,Z_INFORMATIONAL_BEEP)
  
  // removed redundant delete - 10/26
  
  keyboard chr(K_CTRL_PGUP)
endif

// DeleteVersion
return



//
static procedure BfVFind2

// Locals
local nSaveSelect       := select()
local aWorkAreas        := {}
local aTmpDbf           := nil
local aSave

// Create the search list object
local oSearch           := zdbGBNew()
oSearch:dbgbTitle       := "New version"
oSearch:dbgbAlias       := oSearch:dbgbIndex := "VfTmp"
oSearch:dbgbAliasArray  := {"VfTmp"}
oSearch:dbgbReturnField := "Version"
oSearch:dbgbBoxType     := zBOX_SS
oSearch:dbgbTop         := 8
oSearch:dbgbLeft        := 40
oSearch:dbgbBottom      := maxrow()-2
oSearch:dbgbRight       := maxcol()

// Define the search columns
oSearch:dbgbColumns     := {{"Sequence"                                               ,"Seq"        } ,;
                            {"Code"                                                   ,"R/M"        } ,;
                            {{|| pad(bGetElementData(Type,Code,"Description"),30)}    ,"Description"} ,;
                            {{|| str(VfTmp->Qty,15,8)}                                ,"Quantity"   } ,;
                            {"Units"                                                  ,"Um"         }}

// Define the search options
oSearch:dbgbBounceBar   := {{"Version","Switch to the version list <Ctrl-Tab>"   ,K_ESC                             ,K_CTRL_TAB                             } ,;
                            {"Import" ,"Import highlighted version formula"      ,{|| ImportVersion(@aSave),0}      ,                                       } ,;
                            {"Modify" ,"Modify formula."                         ,{|| NewVersion(aSave),0}          ,           ,{|| ! empty(VfTmp->CodeNo)}} ,;
                            {"Save"   ,"Save new version?"                       ,{|| SaveNewVersion(aSave),0}      ,                                       } ,;
                            {"Return" ,Z_RETURN_MESSAGE                          ,{|| SaveChanges(aSave:lSaved)}    ,K_ESC                                  }}

// Create the save state array
aSave := array(SAVE_ARRAY_LENGTH)

if zOpenShared({"VfForm","BfForm","BfVers"},aWorkAreas)
  VfTmp->(__dbZap())
  zdbGBrowse(oSearch)
endif

// Maintenance
zdbRestore(aWorkAreas,nSaveSelect)
zdbDeleteTemp(aTmpDbf)
keyboard chr(K_CTRL_PGUP)

// BfVFind2
return



// Exit and refresh
static procedure RefrExit

keyboard chr(K_ESC)

keyboard chr(K_CTRL_PGUP)

// RefrExit
return
