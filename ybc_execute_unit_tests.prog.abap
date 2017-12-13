*&---------------------------------------------------------------------*
*& Report  YBC_EXECUTE_UNIT_TESTS
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
* Author          : W. Pogantsch
* Company         : Hermes Fulfilment
* Development-ID  : ETBC506_01
* Create date     : 12.03.2015
*-----------------------------------------------------------------------
* Description:
*   This programs starts selected ABAP-unittests.
*-----------------------------------------------------------------------
* Change-Log
*-----------------------------------------------------------------------
* Date        Name        Description
*-----------------------------------------------------------------------
* 12.03.2015  Pogantsch   Initial creation
*-----------------------------------------------------------------------
report ybc_execute_unit_tests.


tables: ybc_s_execute_unit_tests.

select-options: so_clas for ybc_s_execute_unit_tests-classname,
                so_meth for ybc_s_execute_unit_tests-methodname,
                so_stat for ybc_s_execute_unit_tests-status.

*----------------------------------------------------------------------*
*       CLASS lcl_application DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
class lcl_application definition final.
  public section.
    class-methods: run.
endclass.                    "lcl_application DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcl_application IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
class lcl_application implementation.
  method run.
    data: lo_bc_aunit_exec_unit_tests type ref to ycl_bc_aunit_exec_unit_tests.

    create object lo_bc_aunit_exec_unit_tests.

    lo_bc_aunit_exec_unit_tests->determine_global_test_classes( it_so_classes = so_clas[]
                                                                it_so_methods = so_meth[] ).

    lo_bc_aunit_exec_unit_tests->determine_test_class_handles( ).

    lo_bc_aunit_exec_unit_tests->determine_test_methods( it_so_methods = so_meth[]
                                                         it_so_status  = so_stat[] ).

    if sy-batch is initial.
      lo_bc_aunit_exec_unit_tests->display_test_methods( ).
    else.
      lo_bc_aunit_exec_unit_tests->execute_test_methods( ).
    endif.
  endmethod.                    "run
endclass.                    "lcl_application IMPLEMENTATION

start-of-selection.
  lcl_application=>run( ).
