*******************************************************************
*   Intent                                                        *
*******************************************************************

" this function-pool is implementation of the ABAP Unit default
" display. It consists of various local classes, which are
" responsible to act as proxy to the ABAP Unit runtime, data conversion
" and forming the UI itself.
"
" the rough picture is that the listener inherits most functionality
" from a global class, the converters map the data to for a UI
" optimized format. The central class of the display is the UI master.
" Basically it is a sophiscated local variable. It represents the
" overall state of the display. The display itself consists of 3/4
" areas:
" - the base tree: on the left hand displays totals for programs etc
" - the mesg grid: on the upper right area displays a list of messages
" - the dtl tree:  on the lower right area display details of one msg
" - (header):      optionally some task information is shown on top
" Each control is represented by a own class

*******************************************************************
*   System-defined Include-files.                                 *
*******************************************************************

  include LYBC_SAUNIT_TREE_CTRL_LISTTOP.         " Global Data

* ---------------------------------------------------------------------
* class definitions
* ---------------------------------------------------------------------

* for sake of syntax check this includes are now located in the
* top include. Be careful when copying the function group
* includes in the top include are not copied !!


*******************************************************************
*   User-defined Include-files (if necessary).                    *
*******************************************************************

* ---------------------------------------------------------------------
* Fubas
* ---------------------------------------------------------------------

  include LYBC_SAUNIT_TREE_CTRL_LISTUXX.         " Function Modules

* ---------------------------------------------------------------------
* class implementations
* ---------------------------------------------------------------------

INCLUDE LYBC_SAUNIT_TREE_CTRL_LISTF51.
*  include lsaunit_Tree_Ctrl_Listenerf51.         " Master
INCLUDE LYBC_SAUNIT_TREE_CTRL_LISTF52.
*  include lsaunit_Tree_Ctrl_Listenerf52.         " Base Tree
INCLUDE LYBC_SAUNIT_TREE_CTRL_LISTF53.
*  include lsaunit_Tree_Ctrl_Listenerf53.         " Detail List
INCLUDE LYBC_SAUNIT_TREE_CTRL_LISTF54.
*  include lsaunit_Tree_Ctrl_Listenerf54.         " AU Listener
INCLUDE LYBC_SAUNIT_TREE_CTRL_LISTF55.
*  include lsaunit_Tree_Ctrl_Listenerf55.         " Message Tree
INCLUDE LYBC_SAUNIT_TREE_CTRL_LISTF56.
*  include lsaunit_Tree_Ctrl_Listenerf56.         " Html Title
INCLUDE LYBC_SAUNIT_TREE_CTRL_LISTF57.
*  include lsaunit_Tree_Ctrl_Listenerf57.         " File Manager
INCLUDE LYBC_SAUNIT_TREE_CTRL_LISTF58.
*  include lsaunit_Tree_Ctrl_Listenerf58.         " Converter Tool

INCLUDE LYBC_SAUNIT_TREE_CTRL_LISTF99.
*  include lsaunit_Tree_Ctrl_Listenerf99.         " Unit Test

* ---------------------------------------------------------------------
* dynpro event processing
* ---------------------------------------------------------------------

INCLUDE LYBC_SAUNIT_TREE_CTRL_LISTO01.
*  include lsaunit_Tree_Ctrl_Listenero01.         " PBO Modules
INCLUDE LYBC_SAUNIT_TREE_CTRL_LISTI01.
*  include lsaunit_Tree_Ctrl_Listeneri01.         " PAI Modules
