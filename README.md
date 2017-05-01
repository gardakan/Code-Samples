# Sample Code
Code examples

*****************

The files included in this repository are examples of work using the xHarbour language.  My work experience revolves heavily around integration with FoxPro ('DBFCDX') databases - indexing, storing, retrieving and deleting data.  While the code here is mine, they rely on pre-existing libraries and modules in order to function.  The HTML_Help repository contains examples of the Jazz help environment - a locally-hosted HTML help system accessed by pressing the F1 key from any location in Jazz.  If a specific help file exists for the currently open Jazz module, the help system is designed to detect the origin location and open the related help file.  If no specific help page exists, the help pages open to the general navigation description pages.

BFVers.prg is a module whose purpose is to display the alternate versions of a base formula (a base formula is essentially the 'recipe' for a product, or 'Finished Good' in company terminology).  When the BfVers function is called, a screen displays the alternate versions (sorted by an auto-incrementing version number) in the left-hand list window, while the right-hand list window shows the ingredients and proportions associated with the selected formula.

The zF1Help and zJazzHelp files contain the functions used to launch the HTML help file system.  The zF1Help function checks through the call stack for a matching help file (stored in a database) and launches the related help file using the zJazzHelp function.  If no match is found, the default navigation help page is launched.
