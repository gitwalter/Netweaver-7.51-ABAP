**-----------------------------------------------------------------------
**
**  Include:  LAUNIT_TREE_CTRL_LISTENERF99
**
**-----------------------------------------------------------------------
*
*
*
*class tc_Converter definition
*  final
*  for testing risk level dangerous duration medium.
*
*  public section.
*  "==============
*    interfaces: local_Unit_Test.
*
*  private section.
*  "===============
*    class-methods:
*      class_Setup.
*
*    methods:
*      " keep alphabetical order in mind
*      two_Messages_in_Task for testing.
*
*    methods:
*      __Create_Task_Data
*        returning
*          value(result) type ty_S_Task_Data.
*
*endclass.
*
*
*class tc_Converter implementation.
*
*  method class_Setup.
** ==================
*    cl_Sat_UI_Ctrl_Factory_Access=>set_Factory(
*      use_Test_Factory = abap_True ).
*
*  endmethod.
*
*
*  method two_Messages_in_Task.
** ============================
*    data:
*      converter       type ref to task_Data_Converter,
*      task_Data       type ty_S_Task_Data,
*      base_Infos      type ty_T_Base_Infos.
*
*    task_Data = __Create_Task_Data( ).
*    create object converter.
*    base_Infos = converter->compute_Base_Data( task_Data ).
*
*    read table base_Infos transporting no fields
*      with key
*        degree = gc_Info_Degree-task
*        cnt_tolerable  = 2.
*    cl_Abap_Unit_Assert=>assert_Subrc( sy-subRc ).
*
*  endmethod.
*
*
*  method __Create_Task_Data.
**==========================
*    field-symbols:
*      <prog_Data>   type ty_S_Prog_Data,
*      <clas_Data>   type ty_S_Clas_Data,
*      <meth_Data>   type ty_S_Meth_Data,
*      <alert_Data>  type ty_S_Alert_Data.
*
*    define mac_add_alert.
*      insert initial line into table &1 assigning <alert_Data>.
*      <alert_Data>-kind =      &2.
*      <alert_Data>-level =     &3.
*      <alert_Data>-header-id = &4.
*    end-of-definition.
*
*    result-info-name  =    'SELFTEST'.
*    result-info-system_Id = sy-sysId.
*    result-info-has_Error = abap_True.
*
*    insert initial line into table result-programs
*      assigning <prog_Data>.
*    <prog_Data>-info-has_Error = abap_True.
*    <prog_Data>-info-name =      sy-Repid.
*
*    insert initial line into table <prog_Data>-classes
*      assigning <clas_Data>.
*    <clas_Data>-info-has_Error = abap_True.
*    <clas_Data>-info-name =      'LCL_CLASS_1'.
*
*    insert initial line into table <clas_Data>-methods
*      assigning <meth_Data>.
*    <meth_Data>-info-name =      'METH_1'.
*
*    mac_add_alert result-alerts:
*      gc_Alert_Kind-warning     gc_Alert_Level-tolerable       'WT1'.
*
*    mac_add_alert <meth_Data>-alerts:
*      gc_Alert_Kind-warning     gc_Alert_Level-tolerable       'WM1',
*      gc_Alert_Kind-shortDump   gc_Alert_Level-critical        'SM1'.
*
*    " this sums up to 3 alerts on task with 2 warning and one shortdump
*
*  endmethod.
*
*endclass.
*
*
*class tc_Ui_Smoke definition
*  final
*  for testing risk level dangerous duration medium.
*
*  public section.
*  "==============
*    interfaces: local_Unit_Test.
*
*  private section.
*  "===============
*    class-methods:
*      class_Setup.
*
*    methods:
*      basic_Roundtrip      for testing.
*
*endclass.
*
*
*class tc_Ui_Smoke implementation.
*
*  method class_Setup.
** ==================
*    cl_Sat_UI_Ctrl_Factory_Access=>set_Factory(
*      use_Test_Factory = abap_True ).
*
*  endmethod.
*
*
*  method basic_Roundtrip.
** ======================
*    data:
*      ui_Master       type ref to ui_Master_Dynp,
*      task_Data       type ty_S_Task_Data.
*
*    create object ui_Master.
*    ui_Master->init( task_Data ).
*
*    cl_Abap_Unit_Assert=>assert_Bound(
*      ui_Master_Dynp=>_Fg_Display_Instance ).
*
*    ui_Master_Dynp=>ui_Master~handle_User_Command(
*      gc_Fcode-exit ).
*    cl_Abap_Unit_Assert=>assert_Initial(
*      ui_Master_Dynp=>_Fg_Display_Instance ).
*
*  endmethod.
*
*endclass.
