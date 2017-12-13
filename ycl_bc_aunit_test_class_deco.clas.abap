class YCL_BC_AUNIT_TEST_CLASS_DECO definition
  public
  inheriting from CL_AUNIT_TEST_CLASS_DECORATOR
  final
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !TEST_INSTANCE type ref to IF_AUNIT_TEST_CLASS_HANDLE
      !IT_TEST_METHODS type YBC_T_TEST_METHODS .

  methods IF_AUNIT_TEST_CLASS~GET_TEST_METHODS
    redefinition .
protected section.
private section.

  aliases GET_ABSOLUTE_CLASS_NAME
    for IF_AUNIT_TEST_CLASS~GET_ABSOLUTE_CLASS_NAME .
  aliases GET_PROGRAM_NAME
    for IF_AUNIT_TEST_CLASS~GET_PROGRAM_NAME .

  data MT_TEST_METHODS type YBC_T_TEST_METHODS .
ENDCLASS.



CLASS YCL_BC_AUNIT_TEST_CLASS_DECO IMPLEMENTATION.


method constructor.
*-----------------------------------------------------------------------
* Description:
*    Constructor
*-----------------------------------------------------------------------
* Change-Log
*-----------------------------------------------------------------------
* Date      Name        Description
*-----------------------------------------------------------------------
*
*-----------------------------------------------------------------------
    super->constructor( test_instance ).
    mt_test_methods = it_test_methods.
  endmethod.


method if_aunit_test_class~get_test_methods.
*-----------------------------------------------------------------------
* Description:
*    Get the test methods
*-----------------------------------------------------------------------
* Change-Log
*-----------------------------------------------------------------------
* Date      Name        Description
*-----------------------------------------------------------------------
*
*-----------------------------------------------------------------------
    field-symbols: <lv_method> type saunit_d_method.

    result = super->if_aunit_test_class~get_test_methods( ).

    loop at result assigning <lv_method>.
      read table mt_test_methods
           with key methodname = <lv_method>
           transporting no fields.
      if sy-subrc <> 0.
        delete table result from <lv_method>.
      endif.
    endloop.
  endmethod.
ENDCLASS.
