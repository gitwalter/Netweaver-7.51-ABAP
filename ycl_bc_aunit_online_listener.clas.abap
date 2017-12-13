class YCL_BC_AUNIT_ONLINE_LISTENER definition
  public
  inheriting from CL_SAUNIT_A_LISTENER_COMPLETE
  final
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !SHOW_PROGRESS type ABAP_BOOL default ABAP_TRUE .

  methods IF_AUNIT_LISTENER~METHOD_END
    redefinition .
  methods IF_AUNIT_LISTENER~METHOD_START
    redefinition .
  methods IF_AUNIT_LISTENER~PROGRAM_START
    redefinition .
  methods IF_AUNIT_LISTENER~TASK_END
    redefinition .
protected section.

  methods DO_FINAL_EVALUATION
    redefinition .
private section.

  data MO_AUNIT_PROTOCOL type ref to YCL_BC_AUNIT_PROTOCOL .
ENDCLASS.



CLASS YCL_BC_AUNIT_ONLINE_LISTENER IMPLEMENTATION.


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
    super->constructor( show_progress = abap_true ).
    create object mo_aunit_protocol.
  endmethod.


method do_final_evaluation.
    return.
  endmethod.


method if_aunit_listener~method_end.
*-----------------------------------------------------------------------
* Description:
*    Handle method end
*-----------------------------------------------------------------------
* Change-Log
*-----------------------------------------------------------------------
* Date      Name        Description
*-----------------------------------------------------------------------
*
*-----------------------------------------------------------------------
    mo_aunit_protocol->write_protocol_method_end(
        iv_methodname          = info->name
        io_aunit_info_step_end = info ).

    super->if_aunit_listener~method_end( info ).
  endmethod.


method if_aunit_listener~method_start.
*-----------------------------------------------------------------------
* Description:
*    Handle method start
*-----------------------------------------------------------------------
* Change-Log
*-----------------------------------------------------------------------
* Date      Name        Description
*-----------------------------------------------------------------------
*
*-----------------------------------------------------------------------
    mo_aunit_protocol->write_protocol_method_start(
        iv_methodname = info->name ).

    super->if_aunit_listener~method_start( info ).
  endmethod.


method if_aunit_listener~program_start.
*-----------------------------------------------------------------------
* Description:
*    Handle program start
*-----------------------------------------------------------------------
* Change-Log
*-----------------------------------------------------------------------
* Date      Name        Description
*-----------------------------------------------------------------------
*
*-----------------------------------------------------------------------
    mo_aunit_protocol->set_classname( info->name ).
    super->if_aunit_listener~program_start( info ).
  endmethod.


method if_aunit_listener~task_end.
*-----------------------------------------------------------------------
* Description:
*    Handle task end
*-----------------------------------------------------------------------
* Change-Log
*-----------------------------------------------------------------------
* Date      Name        Description
*-----------------------------------------------------------------------
*
*-----------------------------------------------------------------------
  super->if_aunit_listener~task_end( info ).
  call function 'SABP_AU___SHOW_TASK'
    exporting
      task_info = f_result->f_task_data
*     MESSAGE_ON_SUCCESS_ONLY       = ABAP_FALSE
    .

*  call function 'Y_BC_AU___SHOW_TASK'
*    exporting
*      task_info = f_result->f_task_data.
endmethod.
ENDCLASS.
