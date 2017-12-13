**-----------------------------------------------------------------------
**
**  Include:  LAUNIT_TREE_CTRL_LISTENERF54
**
**-----------------------------------------------------------------------
*
*
*class listener_With_Ui_Trigger implementation.
*
*method constructor.
**==================
*  super->constructor( ).
*  f_Show_Success_Also = show_Success_Also.
*
*endmethod.
*
*
*method do_Final_Evaluation.
**==========================
** evaluation of the collected results
*  call function 'SABP_AU___SHOW_TREE'
*    exporting
*      Listener_Instance       = Me.
*
*endmethod.
*
*
*method get_Task.
**===============
*" tell it all over the world
*
*" be kind to my private parts
*  p_Task = f_Task.
*
*" reset collector ressources
*  if ( abap_True eq p_Do_Reset ).
*    reset_Result( ).
*  endif.
*
*endmethod.
*
*
*method is_Error_Free.
**====================
*" are there alerts present ?
*  if ( abap_True eq f_Task-Info-has_Error ).
*   result = abap_False.
*  else.
*    result = abap_True.
*  endif.
*endmethod.
*
*
*endclass.
