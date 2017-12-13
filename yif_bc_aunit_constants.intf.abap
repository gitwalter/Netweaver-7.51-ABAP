interface YIF_BC_AUNIT_CONSTANTS
  public .


  interfaces IF_AUNIT_CONSTANTS .

  constants GC_X type CHAR1 value 'X' ##NO_TEXT.
  constants GC_AUNIT_STATUS_NOT_EXECUTED type YBC_E_AUNIT_STATUS value SPACE ##NO_TEXT.
  constants GC_AUNIT_STATUS_ERRONEOUS type YBC_E_AUNIT_STATUS value 'E' ##NO_TEXT.
  constants GC_AUNIT_STATUS_SUCCESSFUL type YBC_E_AUNIT_STATUS value 'S' ##NO_TEXT.
  constants GC_AUNIT_STATUS_NOT_EXECUTABLE type YBC_E_AUNIT_STATUS value 'N' ##NO_TEXT.
endinterface.
