FUNCTION Y_BC_AU___SHOW_TASK.
*"--------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(TASK_INFO) TYPE  DATA
*"--------------------------------------------------------------------
*data:
*    ui_Master      type ref to ui_Master_Dynp.
*  field-symbols:
*    <task_Info>    type if_SAunit_Internal_Result_Type=>ty_S_Task.
*
*  " the following cast helps to prevent unintended invocations by
*  " those wanna call anything gents
*
*  assign task_Info to <task_Info>.
*  assert <task_Info> is assigned.
*
*  create object ui_Master.                    " <= Singleton
*  ui_Master->init( <task_Info> ).
*
*  call screen 100.





ENDFUNCTION.
