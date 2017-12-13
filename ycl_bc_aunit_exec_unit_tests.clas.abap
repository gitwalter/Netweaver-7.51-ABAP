class YCL_BC_AUNIT_EXEC_UNIT_TESTS definition
  public
  final
  create public .

public section.
  type-pools ICON .

  methods CONSTRUCTOR .
  methods DETERMINE_CLASSES_NO_LOC_CLASS
    returning
      value(RT_EXECUTE_UNIT_TESTS) type YBC_T_EXECUTE_UNIT_TESTS .
  methods DETERMINE_GLOBAL_TEST_CLASSES
    importing
      !IT_SO_CLASSES type STANDARD TABLE optional
      !IT_SO_METHODS type STANDARD TABLE optional
    returning
      value(RT_CLASSNAMES) type SEO_CLASS_NAMES .
  methods DETERMINE_TEST_CLASS_HANDLES
    importing
      !IT_CLASSNAMES type SEO_CLASS_NAMES optional .
  methods DETERMINE_TEST_METHODS
    importing
      !IT_SO_METHODS type STANDARD TABLE optional
      !IT_SO_STATUS type STANDARD TABLE optional
    returning
      value(RT_EXECUTE_UNIT_TESTS) type YBC_T_EXECUTE_UNIT_TESTS .
  methods DISPLAY_TEST_METHODS .
  methods EXECUTE_TEST_METHODS
    importing
      !IT_TEST_METHODS type YBC_T_TEST_METHODS optional .
  methods ON_ADDED_FUNCTION
    for event ADDED_FUNCTION of CL_SALV_EVENTS_TABLE
    importing
      !E_SALV_FUNCTION .
  methods ON_DOUBLE_CLICK
    for event DOUBLE_CLICK of CL_SALV_EVENTS_TABLE
    importing
      !ROW
      !COLUMN .
protected section.
private section.

  data MO_AUNIT_FACTORY type ref to CL_AUNIT_FACTORY .
  data MT_CLASSNAMES type SEO_CLASS_NAMES .
  data MT_EXECUTE_UNIT_TESTS type YBC_T_EXECUTE_UNIT_TESTS .
  data MT_TESTCLASS_HANDLES type YBC_T_TESTCLASS_HANDLE .
  data MO_TABLE type ref to CL_SALV_TABLE .
  data MO_SEL type ref to CL_SALV_SELECTIONS .
  data MO_COLUMNS type ref to CL_SALV_COLUMNS_TABLE .
  data MO_EVENTS type ref to CL_SALV_EVENTS_TABLE .
  constants GC_NO_LOCAL_TESTCLASS_TXT type STRING value 'Lokale Testklasse Syntaxfehler' ##NO_TEXT.

  methods GET_SELECTED_TEST_METHODS
    returning
      value(RT_TEST_METHODS) type YBC_T_TEST_METHODS .
  methods IS_TESTCLASS_TO_PROCESS
    importing
      !IO_AUNIT_TEST_CLASS_HANDLE type ref to IF_AUNIT_TEST_CLASS_HANDLE
    returning
      value(RV_TESTCLASS_IS_TO_PROCESS) type ABAP_BOOL .
  methods SET_STATUS_ICON
    importing
      !IV_AUNIT_STATUS type YBC_E_AUNIT_STATUS
    returning
      value(RV_AUNIT_STATUS_ICON) type YBC_E_AUNIT_STATUS_ICON .
  methods UPDATE_DISPLAYED_TABLE_FROM_DB .
ENDCLASS.



CLASS YCL_BC_AUNIT_EXEC_UNIT_TESTS IMPLEMENTATION.


method constructor.
    create object mo_aunit_factory.
  endmethod.


method DETERMINE_CLASSES_NO_LOC_CLASS.
*{   INSERT         ED1K907875                                        1
FIELD-SYMBOLS: <ls_execute_unit_tests> type YBC_S_EXECUTE_UNIT_TESTS.
loop at mt_execute_unit_tests
     ASSIGNING <ls_execute_unit_tests>
     where METHODNAME = gc_no_local_testclass_txt.
  insert <ls_execute_unit_tests> into table rt_execute_unit_tests.
endloop.
*}   INSERT
endmethod.


method determine_global_test_classes.
*-----------------------------------------------------------------------
* Description:
*    Find the global testclasses
*-----------------------------------------------------------------------
* Change-Log
*-----------------------------------------------------------------------
* Date      Name        Description
*-----------------------------------------------------------------------
*
*-----------------------------------------------------------------------
    select distinct clsname
           from  ybc_vd_test_meth
           into table mt_classnames
           where  clsname in it_so_classes
           and    cmpname in it_so_methods.

    if rt_classnames is supplied.
      rt_classnames = mt_classnames.
    endif.
  endmethod.


method determine_test_class_handles.
*-----------------------------------------------------------------------
* Description:
*    Determine the testclass handles
*-----------------------------------------------------------------------
* Change-Log
*-----------------------------------------------------------------------
* Date      Name        Description
*-----------------------------------------------------------------------
*
*-----------------------------------------------------------------------
    data: lv_sobj_name         type sobj_name,
          ls_testclass_handle  type ybc_s_testclass_handle,
          lt_testclass_handles type if_aunit_test_class_handle=>ty_t_testclass_handles.

    field-symbols: <lv_classname>        type seoclsname,
                   <lo_testclass_handle> type ref to if_aunit_test_class_handle.

    if it_classnames is supplied.
      mt_classnames = it_classnames.
    endif.

* build table with class handles
    loop at mt_classnames assigning <lv_classname>.
      lv_sobj_name = <lv_classname>.

      clear lt_testclass_handles.
      lt_testclass_handles = mo_aunit_factory->get_test_class_handles( obj_type = 'CLAS'
                                                                       obj_name = lv_sobj_name ).

      loop at lt_testclass_handles assigning <lo_testclass_handle>.
        ls_testclass_handle-classname    = <lv_classname>.
        ls_testclass_handle-class_handle = <lo_testclass_handle>.
        insert ls_testclass_handle into table mt_testclass_handles.
      endloop.
    endloop.
  endmethod.


method determine_test_methods.
*-----------------------------------------------------------------------
* Description:
*    Determine the test methods
*-----------------------------------------------------------------------
* Change-Log
*-----------------------------------------------------------------------
* Date      Name        Description
*-----------------------------------------------------------------------
*
*-----------------------------------------------------------------------
    data: lt_test_methods            type saunit_t_methods,
          ls_execute_unit_tests      type ybc_s_execute_unit_tests,
          lv_testclass_is_to_process type abap_bool.

    field-symbols: <ls_testclass_handle> type ybc_s_testclass_handle,
                   <lv_test_method>      type saunit_d_method,
                   <lv_classname>        type seoclsname.

* loop at classnames
    loop at mt_classnames assigning <lv_classname>.
      loop at mt_testclass_handles
           assigning <ls_testclass_handle>
           where classname = <lv_classname>.
        lt_test_methods = <ls_testclass_handle>-class_handle->get_test_methods( ).

* check if testclass should be executed in the current client
        lv_testclass_is_to_process = is_testclass_to_process( <ls_testclass_handle>-class_handle ).

        loop at lt_test_methods
             assigning <lv_test_method>
             where table_line in it_so_methods.
          ls_execute_unit_tests-classname  = <lv_classname>.
          ls_execute_unit_tests-methodname = <lv_test_method>.
* read protocl
          ls_execute_unit_tests-data       = ycl_bc_aunit_protocol=>get_protocol_entry( ls_execute_unit_tests-key ).
          if lv_testclass_is_to_process = abap_false.
            ls_execute_unit_tests-status = yif_bc_aunit_constants=>gc_aunit_status_not_executable.
            ycl_bc_aunit_protocol=>write_protocol_not_executable( ls_execute_unit_tests-key ).
          else.
            if ls_execute_unit_tests-status = yif_bc_aunit_constants=>gc_aunit_status_not_executable or
               ycl_bc_aunit_protocol=>get_protocol_entry( ls_execute_unit_tests-key ) is initial.
              ycl_bc_aunit_protocol=>write_protocol_not_executed( ls_execute_unit_tests-key ).
              ls_execute_unit_tests-status = yif_bc_aunit_constants=>gc_aunit_status_not_executed.
            endif.
          endif.

          ls_execute_unit_tests-icon = set_status_icon( ls_execute_unit_tests-status ).

          if ls_execute_unit_tests-status in it_so_status[].
            insert ls_execute_unit_tests into table mt_execute_unit_tests.
          endif.
          clear ls_execute_unit_tests.
        endloop.
      endloop.

* no local testclass
      if sy-subrc <> 0.
        ls_execute_unit_tests-classname  = <lv_classname>.
        ls_execute_unit_tests-methodname = gc_no_local_testclass_txt.
        insert ls_execute_unit_tests into table mt_execute_unit_tests.
      endif.

    endloop.

    if rt_execute_unit_tests is supplied.
      rt_execute_unit_tests = mt_execute_unit_tests.
    endif.
  endmethod.


method display_test_methods.
*-----------------------------------------------------------------------
* Description:
*    Display the test methods
*-----------------------------------------------------------------------
* Change-Log
*-----------------------------------------------------------------------
* Date      Name        Description
*-----------------------------------------------------------------------
*
*-----------------------------------------------------------------------
  constants: lc_column_name_status type lvc_fname value 'STATUS'.

  data: lo_salv_column type ref to cl_salv_column,
        lx_root        type ref to cx_root.

  try.
      call method cl_salv_table=>factory
        importing
          r_salv_table = mo_table
        changing
          t_table      = mt_execute_unit_tests.

* set pf-status
      mo_table->set_screen_status(
         pfstatus      = 'YBC_EXECUTE_UNIT_TST'
         report        = 'YBC_EXECUTE_UNIT_TESTS'
         set_functions = mo_table->c_functions_all ).

      mo_sel = mo_table->get_selections( ).
      mo_sel->set_selection_mode( if_salv_c_selection_mode=>multiple ).

      mo_columns = mo_table->get_columns( ).
      mo_columns->set_optimize( ).

* set column to invisible
      lo_salv_column = mo_columns->get_column( lc_column_name_status ).

      lo_salv_column->set_visible( if_salv_c_bool_sap=>false ).


* register event handler
      mo_events = mo_table->get_event( ).

      set handler me->on_added_function for mo_events.
      set handler me->on_double_click   for mo_events.

      mo_table->display( ).

    catch  cx_salv_msg
           cx_salv_not_found
           cx_salv_object_not_found
           cx_salv_method_not_supported
           cx_ai_system_fault into lx_root.

      message lx_root type 'E'.
  endtry.
endmethod.


method execute_test_methods.
*-----------------------------------------------------------------------
* Description:
*    Execute the selected testmethods
*-----------------------------------------------------------------------
* Change-Log
*-----------------------------------------------------------------------
* Date      Name        Description
*-----------------------------------------------------------------------
*
*-----------------------------------------------------------------------
    data: lt_test_methods             type ybc_t_test_methods,
          lt_test_methods_cls         type ybc_t_test_methods,
          lo_bc_aunit_test_class_deco type ref to ycl_bc_aunit_test_class_deco,
          lo_aunit_task               type ref to if_aunit_task,
          lo_aunit_listener           type ref to if_aunit_listener.

    field-symbols: <ls_test_method>        type ybc_s_test_method,
                   <ls_testclass_handle>   type ybc_s_testclass_handle,
                   <ls_execute_unit_tests> type ybc_s_execute_unit_tests.

* only call in online mode
    if sy-batch is initial.
      call function 'Y_BC_AU___CREATE_TREE_LISTENER'
        importing
          result = lo_aunit_listener.
    else.
      create object lo_aunit_listener
        type ycl_bc_aunit_batch_listener
        exporting
          io_aunit_exec_unit_tests = me.
    endif.

* create taskhandler
    lo_aunit_task = mo_aunit_factory->create_task( lo_aunit_listener ).

    if it_test_methods is supplied.
      loop at it_test_methods assigning <ls_test_method>.
        read table mt_execute_unit_tests
             with key test_method = <ls_test_method>
             assigning <ls_execute_unit_tests>.
        if <ls_execute_unit_tests>-status = yif_bc_aunit_constants=>gc_aunit_status_not_executable.
          message e001(ybc_aunit)
                  with <ls_test_method>-methodname
                       <ls_test_method>-classname.
        else.
          insert <ls_test_method> into table lt_test_methods.
        endif.
      endloop.
    else.
      loop at mt_execute_unit_tests assigning <ls_execute_unit_tests>.
        if <ls_execute_unit_tests>-status <> yif_bc_aunit_constants=>gc_aunit_status_not_executable.
          insert <ls_execute_unit_tests>-test_method into table lt_test_methods.
        endif.
      endloop.
    endif.

* add class handles to task
    loop at lt_test_methods assigning <ls_test_method>.

      if <ls_test_method>-methodname = gc_no_local_testclass_txt.
        continue.
      endif.

      insert <ls_test_method> into table lt_test_methods_cls.

      at end of classname.

        if lt_test_methods_cls is not initial.
          read table mt_testclass_handles
               with key classname = <ls_test_method>-classname
               assigning <ls_testclass_handle>.

          create object lo_bc_aunit_test_class_deco
            exporting
              test_instance   = <ls_testclass_handle>-class_handle
              it_test_methods = lt_test_methods_cls.

          lo_aunit_task->add_test_class_handle( lo_bc_aunit_test_class_deco ).
          clear lt_test_methods_cls.
        endif.
      endat.

    endloop.

    " execute - due to the decorator only get_ for testing methods.
    if lo_bc_aunit_test_class_deco is bound.
      lo_aunit_task->run( ).
    endif.

* refresh the display
    if sy-batch is initial.
      update_displayed_table_from_db( ).
      mo_table->refresh( ).
    endif.
  endmethod.


method get_selected_test_methods.
*-----------------------------------------------------------------------
* Description:
*    Determine the selected testmethods
*-----------------------------------------------------------------------
* Change-Log
*-----------------------------------------------------------------------
* Date      Name        Description
*-----------------------------------------------------------------------
*
*-----------------------------------------------------------------------
    data: lt_selected_rows type salv_t_row.

    field-symbols: <lv_selected_row>       type line of salv_t_row,
                   <ls_execute_unit_tests> type ybc_s_execute_unit_tests.

    lt_selected_rows = mo_sel->get_selected_rows( ).
    loop at lt_selected_rows assigning <lv_selected_row>.
      read table mt_execute_unit_tests index <lv_selected_row>
           assigning <ls_execute_unit_tests>.
      insert <ls_execute_unit_tests>-test_method into table rt_test_methods.
    endloop.

    sort rt_test_methods by classname methodname.
  endmethod.


method is_testclass_to_process.
*-----------------------------------------------------------------------
* Description:
*    Check if the testclass to process
*-----------------------------------------------------------------------
* Change-Log
*-----------------------------------------------------------------------
* Date      Name        Description
*-----------------------------------------------------------------------
*
*-----------------------------------------------------------------------
  data: lo_aunit_test_class   type ref to cl_aunit_test_class,
        lo_testclass          type ref to object,
        ls_info_structure     type if_aunit_prog_info_types=>ty_s_testclass,
        lv_absolute_classname type string.

  try.
      lv_absolute_classname = io_aunit_test_class_handle->get_absolute_class_name( ).

      lo_aunit_test_class = cl_aunit_test_class=>create_by_info_structure( ls_info_structure ).

      cl_aunit_classtest=>get_janitor( lo_aunit_test_class )->allow_access( ).

      create object lo_testclass
        type (lv_absolute_classname).

      call method lo_testclass->('IS_TO_PROCESS')
        receiving
          rv_is_to_process = rv_testclass_is_to_process.

      cl_aunit_classtest=>get_janitor( lo_aunit_test_class )->deny_access( ).
    catch cx_sy_dyn_call_illegal_method.
      cl_aunit_classtest=>get_janitor( lo_aunit_test_class )->deny_access( ).
  endtry.
endmethod.


method on_added_function.
*-----------------------------------------------------------------------
* Description:
*    Handle function
*-----------------------------------------------------------------------
* Change-Log
*-----------------------------------------------------------------------
* Date      Name        Description
*-----------------------------------------------------------------------
*
*-----------------------------------------------------------------------
    case e_salv_function.
      when 'EXEC_TESTS'.
        execute_test_methods( get_selected_test_methods( ) ).
      when others.
        return.
    endcase.
  endmethod.


method on_double_click.
*-----------------------------------------------------------------------
* Description:
*    Handle doule click
*-----------------------------------------------------------------------
* Change-Log
*-----------------------------------------------------------------------
* Date      Name        Description
*-----------------------------------------------------------------------
*
*-----------------------------------------------------------------------
    class cl_oo_include_naming definition load.

    data: lo_oo_class_incl_naming type ref to if_oo_class_incl_naming,
          lv_program              type programm,
          lv_seocpdname           type seocpdname.

    field-symbols: <ls_execute_unit_tests> type ybc_s_execute_unit_tests.

* get clicked line
    read table mt_execute_unit_tests
         index row assigning <ls_execute_unit_tests>.

    if <ls_execute_unit_tests> is assigned.

      if <ls_execute_unit_tests>-methodname = gc_no_local_testclass_txt.
        lo_oo_class_incl_naming ?= cl_oo_include_naming=>get_instance_by_name( <ls_execute_unit_tests>-classname ).
        lv_program = lo_oo_class_incl_naming->if_oo_clif_incl_naming~pool.
      else.
        lo_oo_class_incl_naming ?= cl_oo_include_naming=>get_instance_by_name( <ls_execute_unit_tests>-classname ).
        lv_seocpdname = <ls_execute_unit_tests>-methodname.
        lv_program = lo_oo_class_incl_naming->get_include_by_mtdname( lv_seocpdname ).
      endif.
* call editor
      call function 'EDITOR_PROGRAM'
        exporting
          display     = abap_true
          program     = lv_program
        exceptions
          application = 1
          others      = 2.
      if sy-subrc <> 0.
        return.
      endif.
    endif.
  endmethod.


method set_status_icon.
*-----------------------------------------------------------------------
* Description:
*    Set statusicon
*-----------------------------------------------------------------------
* Change-Log
*-----------------------------------------------------------------------
* Date      Name        Description
*-----------------------------------------------------------------------
*
*-----------------------------------------------------------------------
    case iv_aunit_status.
      when yif_bc_aunit_constants=>gc_aunit_status_not_executed.
        rv_aunit_status_icon = icon_led_yellow.
      when yif_bc_aunit_constants=>gc_aunit_status_not_executable.
        rv_aunit_status_icon = icon_led_inactive.
      when yif_bc_aunit_constants=>gc_aunit_status_erroneous.
        rv_aunit_status_icon = icon_led_red.
      when yif_bc_aunit_constants=>gc_aunit_status_successful.
        rv_aunit_status_icon = icon_led_green.
    endcase.
  endmethod.


method update_displayed_table_from_db.
*-----------------------------------------------------------------------
* Description:
*    Read protocol from db
*-----------------------------------------------------------------------
* Change-Log
*-----------------------------------------------------------------------
* Date      Name        Description
*-----------------------------------------------------------------------
*
*-----------------------------------------------------------------------
    field-symbols: <ls_execute_unit_tests> type ybc_s_execute_unit_tests.
    loop at mt_execute_unit_tests assigning <ls_execute_unit_tests>.
      <ls_execute_unit_tests>-data = ycl_bc_aunit_protocol=>get_protocol_entry( <ls_execute_unit_tests>-key ).
      <ls_execute_unit_tests>-icon = set_status_icon( <ls_execute_unit_tests>-status ).
    endloop.
  endmethod.
ENDCLASS.
