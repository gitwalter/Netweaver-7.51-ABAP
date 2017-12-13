FUNCTION Y_BC_AU___SHOW_TREE.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(LISTENER_INSTANCE) TYPE REF TO  IF_AUNIT_LISTENER
*"----------------------------------------------------------------------
*data:
*    cnt_Prog        type i,
*    cnt_Clas        type i,
*    cnt_Meth        type i,
*    temp_Counter    type i,
*    local_Listener  type ref to listener_With_Ui_Trigger,
*    ui_Master       type ref to ui_Master_Dynp,
*    cur_Task        type if_Saunit_Internal_Result_Type=>ty_S_Task.
*
*  field-symbols:
*    <cur_Prog>    type if_Saunit_Internal_Result_Type=>ty_S_Program,
*    <cur_Clas>    type if_Saunit_Internal_Result_Type=>ty_S_Class.
*
*  try.
*    local_Listener ?= listener_Instance.       " <= call only possible
*                                               "    from within the
*                                               "    internal listener
*                                               "    works as designed
*  catch cx_Sy_Move_Cast_Error.
*    assert 1 = 2.                              " param type was illegal
*                                               " caller is to blame
*  endtry.
*
*  cur_Task = local_Listener->get_Task( p_Do_Reset = abap_True ).
*
*  if ( abap_False eq local_Listener->f_Show_Success_Also  and
*       cur_Task-extd_Infos_By_Indicies is initial ).
*
*    if ( abap_False eq cur_Task-info-has_Error and
*         abap_False eq cur_Task-info-has_Skipped ).
*
*      cnt_Prog = lines( cur_Task-programs ).
*      loop at cur_Task-programs assigning <cur_Prog>.
*        temp_Counter = lines( <cur_Prog>-classes ).
*        add temp_Counter to cnt_Clas.
*        loop at <cur_Prog>-classes assigning <cur_Clas>.
*          temp_Counter = lines( <cur_Clas>-methods ).
*          add temp_Counter to cnt_Meth.
*        endloop.
*      endloop.
*      if ( abap_True eq cur_Task-info-has_Skipped and 0 eq cnt_Meth ).
*        message s111 display like 'I'.
*      else.
*        message s110 with cnt_Prog cnt_Clas cnt_Meth.
*      endif.
*      return.
*    endif.
*  elseif ( cur_Task-programs is not initial ).
*
*    cnt_Prog = lines( cur_Task-programs ).
*    loop at cur_Task-programs assigning <cur_Prog>.
*      temp_Counter = lines( <cur_Prog>-classes ).
*      add temp_Counter to cnt_Clas.
*      loop at <cur_Prog>-classes assigning <cur_Clas>.
*        temp_Counter = lines( <cur_Clas>-methods ).
*        add temp_Counter to cnt_Meth.
*      endloop.
*    endloop.
*    message s112 with cnt_Prog cnt_Clas cnt_Meth.
*
*  endif.
*
*  create object ui_Master.                   " <= Singleton.
*  ui_Master->init( cur_Task ).
*
*  " and there we go up up to the sky
*  call screen 100.
*  if ( abap_True eq cur_Task-info-has_Skipped ).
*    message s111 display like 'I'.
*  endif.
*
*
*
*

ENDFUNCTION.
