class YCL_BC_AUNIT_PROTOCOL definition
  public
  final
  create public .

public section.

  methods WRITE_PROTOCOL_METHOD_START
    importing
      !IV_METHODNAME type CLIKE .
  methods WRITE_PROTOCOL_METHOD_END
    importing
      !IV_METHODNAME type CLIKE
      !IO_AUNIT_INFO_STEP_END type ref to IF_AUNIT_INFO_STEP_END .
  class-methods WRITE_PROTOCOL_NOT_EXECUTABLE
    importing
      !IS_UNITTESTS_KEY type YBC_S_UNITTESTS_KEY .
  class-methods WRITE_PROTOCOL_NOT_EXECUTED
    importing
      !IS_UNITTESTS_KEY type YBC_S_UNITTESTS_KEY .
  methods SET_CLASSNAME
    importing
      !IV_CLASSNAME type STRING .
  class-methods GET_PROTOCOL_ENTRY
    importing
      !IS_UNITTESTS_KEY type YBC_S_UNITTESTS_KEY
    returning
      value(RS_UNITTESTS_DATA) type YBC_S_UNITTESTS_DATA .
protected section.
private section.

  data MV_METHOD_START type RUNTIME .
  data MV_METHOD_END type RUNTIME .
  data MV_CLASSNAME type SEOCLSNAME .
  constants GC_MSGV1_CLASSNAME type SY-MSGV1 value 'YCL_BC_AUNIT_PROTOCOL' ##NO_TEXT.

  class-methods GET_PROTOCOL_RECORD
    importing
      !IS_UNITTESTS_KEY type YBC_S_UNITTESTS_KEY
    returning
      value(RS_TD_UNITTESTS) type YBC_TD_UNITTESTS .
ENDCLASS.



CLASS YCL_BC_AUNIT_PROTOCOL IMPLEMENTATION.


method get_protocol_entry.
*-----------------------------------------------------------------------
* Description:
*    Select protocol entry
*-----------------------------------------------------------------------
* Change-Log
*-----------------------------------------------------------------------
* Date      Name        Description
*-----------------------------------------------------------------------
*
*-----------------------------------------------------------------------
    clear rs_unittests_data.
    select single * from  ybc_td_unittests
           into corresponding fields of rs_unittests_data
           where  classname   = is_unittests_key-classname
           and    methodname  = is_unittests_key-methodname.
  endmethod.


method get_protocol_record.
    select single * from  ybc_td_unittests
           into rs_td_unittests
           where  classname   = is_unittests_key-classname
           and    methodname  = is_unittests_key-methodname.
  endmethod.


method set_classname.
*-----------------------------------------------------------------------
* Description:
*    Set classname
*-----------------------------------------------------------------------
* Change-Log
*-----------------------------------------------------------------------
* Date      Name        Description
*-----------------------------------------------------------------------
*
*-----------------------------------------------------------------------
    data: lv_length type i,
          lv_string type string.
    find regex '=' in iv_classname match offset lv_length.
    if sy-subrc <> 0.
      lv_string = iv_classname.
      lv_length = strlen( lv_string ) - 2.
      mv_classname = lv_string(lv_length).
    else.
      mv_classname = iv_classname(lv_length).
    endif.
  endmethod.


method write_protocol_method_end.
*-----------------------------------------------------------------------
* Description:
*    Write protocl for method end
*-----------------------------------------------------------------------
* Change-Log
*-----------------------------------------------------------------------
* Date      Name        Description
*-----------------------------------------------------------------------
*
*-----------------------------------------------------------------------
    data: ls_unittests     type ybc_td_unittests,
          ls_unittests_key type ybc_s_unittests_key.

    get run time field mv_method_end.

    ls_unittests_key-classname  = mv_classname.
    ls_unittests_key-methodname = iv_methodname.

    ls_unittests = get_protocol_record( ls_unittests_key ).

* update protocol entry with measured runtime
    ls_unittests-runtime      = mv_method_end - mv_method_start.

    if io_aunit_info_step_end->get_alert_summary( )-is_okay = abap_true.
      ls_unittests-status = yif_bc_aunit_constants=>gc_aunit_status_successful.
    else.
      ls_unittests-status = yif_bc_aunit_constants=>gc_aunit_status_erroneous.
    endif.

    update ybc_td_unittests from ls_unittests.
    if sy-subrc <> 0.
      message e007(ybc) with gc_msgv1_classname.
    else.
      commit work.
    endif.
  endmethod.


method write_protocol_method_start.
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
    data: ls_unittests     type ybc_td_unittests,
          ls_unittests_key type ybc_s_unittests_key.

    get run time field mv_method_start.

    ls_unittests_key-classname  = mv_classname.
    ls_unittests_key-methodname = iv_methodname.

    ls_unittests = get_protocol_record( ls_unittests_key ).

* write protocol entries
    if ls_unittests is initial.
      ls_unittests-classname    = mv_classname.
      ls_unittests-methodname   = iv_methodname.
      ls_unittests-last_user    = sy-uname.
      ls_unittests-last_ex_date = sy-datum.
      ls_unittests-last_ex_time = sy-uzeit.
      clear ls_unittests-status.
      insert into ybc_td_unittests values ls_unittests.
      if sy-subrc <> 0.
        message e006(ybc) with gc_msgv1_classname.
      endif.
    else.
      ls_unittests-last_ex_date = sy-datum.
      ls_unittests-last_ex_time = sy-uzeit.
      ls_unittests-last_user    = sy-uname.
      ls_unittests-status       = yif_bc_aunit_constants=>gc_aunit_status_not_executed.
      clear ls_unittests-runtime.
      update ybc_td_unittests from ls_unittests.
      if sy-subrc <> 0.
        message e007(ybc) with gc_msgv1_classname.
      endif.
    endif.

    commit work.

  endmethod.


method write_protocol_not_executable.
*-----------------------------------------------------------------------
* Description:
*    Write protocol for methods not executable in the current client
*-----------------------------------------------------------------------
* Change-Log
*-----------------------------------------------------------------------
* Date      Name        Description
*-----------------------------------------------------------------------
*
*-----------------------------------------------------------------------
    data: ls_unittests type ybc_td_unittests.

    ls_unittests = get_protocol_record( is_unittests_key ).
    ls_unittests-status = yif_bc_aunit_constants=>gc_aunit_status_not_executable.

    if ls_unittests-key is initial.
      ls_unittests-key = is_unittests_key.
      insert into ybc_td_unittests values ls_unittests.
      if sy-subrc <> 0.
        message e006(ybc) with gc_msgv1_classname.
      endif.
    else.
      update ybc_td_unittests from ls_unittests.
      if sy-subrc <> 0.
        message e007(ybc) with gc_msgv1_classname.
      endif.
    endif.

    commit work.
  endmethod.


method write_protocol_not_executed.
*-----------------------------------------------------------------------
* Description:
*    Write protocl if method has not been executed
*-----------------------------------------------------------------------
* Change-Log
*-----------------------------------------------------------------------
* Date      Name        Description
*-----------------------------------------------------------------------
*
*-----------------------------------------------------------------------
    data: ls_unittests type ybc_td_unittests.

    ls_unittests = get_protocol_record( is_unittests_key ).
    ls_unittests-status = yif_bc_aunit_constants=>gc_aunit_status_not_executed.

    if ls_unittests-key is initial.
      ls_unittests-key = is_unittests_key.
      insert into ybc_td_unittests values ls_unittests.
      if sy-subrc <> 0.
        message e006(ybc) with gc_msgv1_classname.
      endif.
    else.
      update ybc_td_unittests from ls_unittests.
      if sy-subrc <> 0.
        message e007(ybc) with gc_msgv1_classname.
      endif.
    endif.

    commit work.
  endmethod.
ENDCLASS.
