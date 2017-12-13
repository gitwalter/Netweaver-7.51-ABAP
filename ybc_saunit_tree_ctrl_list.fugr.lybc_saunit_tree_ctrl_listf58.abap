**-----------------------------------------------------------------------
**
**  include:  LSAUNIT_TREE_CTRL_LISTENERF58
**
**-----------------------------------------------------------------------
**
**  purpose:  converts general result to the one used in the display
**
**  basically the deep structures are converted into flat ones which
**  refer to each other by indexes. there is are single catalogue like
**  tables for main programs, classes, methods and messages, each
**  referring to each other on index base.
**
**-----------------------------------------------------------------------
*
*define mac_Count_Alerts.
*  add 1 to &2-cnt_Alert.
*  case &1-kind.
*    when gc_Alert_Kind-error.
*      add 1 to &2-cnt_Error.
*    when gc_Alert_Kind-failure.
*      add 1 to &2-cnt_Failure.
*    when gc_Alert_Kind-warning.
*      add 1 to &2-cnt_Warning.
*    when gc_Alert_Kind-shortdump.
*      add 1 to &2-cnt_Shortdump.
*    when gc_Alert_Kind-execution_Event.
*      " do not count
*    when others.
*      assert 1 = 2. " yuk horrible
*  endcase.
*  case &1-level.
*    when gc_Alert_Level-information.
*      add 1 to &2-cnt_Info.
*    when gc_Alert_Level-critical.
*      add 1 to &2-cnt_Critical.
*    when gc_Alert_Level-fatal.
*      add 1 to &2-cnt_Fatal.
*    when others. " gc_Alert_Level-Tolerable.
*      add 1 to &2-cnt_Tolerable.
*  endcase.
*end-of-definition.
*
*define mac_Add_Extended_Info.
*
*  inf_Detail-ndx_Alert = &1.
*  inf_Detail-kind =      gc_Alert_Kind-extended_Info.
*  inf_Detail-level =     gc_Alert_Level-information.
*  inf_Detail-header =    f_Ext_Mediator->get_Title( <ext_Info> ).
*  insert inf_Detail into table result[].
*  inf_Detail-ndx_Alert = 0.
*
*end-of-definition.
*
*define mac_Add_Alerts.
*  inf_Detail-ndx_Alert = 0.
*  loop at &1 assigning <cur_Alert>.
*    add 1 to inf_Detail-ndx_Alert.
*    inf_Detail-kind =    <cur_Alert>-kind.
*    inf_Detail-level =   <cur_Alert>-level.
*    inf_Detail-header =  f_Text_Depot->get_String( <cur_Alert>-header ).
*    insert inf_Detail into table result[].
*  endloop.
*  inf_Detail-ndx_Alert = 0.
*end-of-definition.
*
*
*define mac_Sum_Counters.
*
*  add &1-cnt_Alert     to  &2-cnt_Alert.
*
*  add &1-cnt_Error     to  &2-cnt_Error.
*  add &1-cnt_Failure   to  &2-cnt_Failure.
*  add &1-cnt_Shortdump to  &2-cnt_Shortdump.
*  add &1-cnt_Warning   to  &2-cnt_Warning.
*  add &1-cnt_Extended  to  &2-cnt_Extended.
*
*  add &1-cnt_Critical  to  &2-cnt_Critical.
*  add &1-cnt_Fatal     to  &2-cnt_Fatal.
*  add &1-cnt_Tolerable to  &2-cnt_Tolerable.
*  add &1-cnt_Info      to  &2-cnt_Info.
*
*end-of-definition.
*
*
*
*class task_Data_Converter implementation.
*
*
*  method constructor.
**  ==================
*
*    super->constructor( ).
*    f_Text_Depot = cl_Aunit_Text_Description=>get_Instance( ).
*
*  endmethod.
*
*
*  method compute_Base_Data.
** ========================
*  " convert result to specific ui format
*  " this format is index driven due to the possibility to export
*  " the internal tables into spread sheet file format
*
*    field-symbols:
*      <cur_Tmpl_Info>  like line of result,
*      <cur_Task_Info>  like line of result,
*      <cur_This_Error> like line of result,
*      <cur_Prog_Info>  like line of result,
*      <cur_Clas_Info>  like line of result,
*      <cur_Meth_Info>  like line of result.
*    field-symbols:
*      <cur_Prog>       like line of task-programs,
*      <cur_Clas>       like line of <cur_Prog>-classes,
*      <cur_Meth>       like line of <cur_Clas>-methods,
*      <cur_Alert>      like line of <cur_Meth>-alerts.
*    data:
*      prog_Index       type i.                                    "#EC *
*
*    "
*    insert initial line into table result assigning <cur_Task_Info>.
*    <cur_Task_Info>-degree =      gc_Info_Degree-task.
*
*    if ( task-alerts is not initial ).
*      loop at task-alerts[] assigning <cur_Alert>.
*        mac_Count_Alerts <cur_Alert> <cur_Task_Info>.
*      endloop.
*      insert initial line into table result assigning <cur_This_Error>.
*      <cur_This_Error> = <cur_Task_Info>.
*      <cur_This_Error>-degree = gc_Info_Degree-task_Errors.
*    endif.
*
*    " add program, class and method info
*    insert initial line into table result assigning <cur_Tmpl_Info>.
*
*    loop at task-programs[] assigning <cur_Prog>.
*
*      " reports, etc.
*      clear:
*        <cur_Tmpl_Info>-ndx_Class,
*        <cur_Tmpl_Info>-ndx_Method.
*
*      add 1 to <cur_Tmpl_Info>-ndx_Program.
*      insert <cur_Tmpl_Info>
*        into table result assigning <cur_Prog_Info>.
*      <cur_Prog_Info>-degree = gc_Info_Degree-program.
*
*      if ( <cur_Prog>-alerts is not initial ).
*        loop at <cur_Prog>-alerts[] assigning <cur_Alert>.
*          mac_Count_Alerts <cur_Alert> <cur_Prog_Info>.
*        endloop.
*        insert initial line
*          into table result assigning <cur_This_Error>.
*        <cur_This_Error> = <cur_Prog_Info>.
*        <cur_This_Error>-degree = gc_Info_Degree-program_Errors.
*      endif.
*
*      " classes
*      loop at <cur_Prog>-classes assigning <cur_Clas>.
*
*        clear:
*          <cur_Tmpl_Info>-ndx_Method.
*
*        add 1 to <cur_Tmpl_Info>-ndx_Class.
*        insert <cur_Tmpl_Info>
*          into table result assigning <cur_Clas_Info>.
*        <cur_Clas_Info>-degree = gc_Info_Degree-class.
*
*        if ( <cur_Clas>-alerts is not initial ).
*          loop at <cur_Clas>-alerts[] assigning <cur_Alert>.
*            mac_Count_Alerts <cur_Alert> <cur_Clas_Info>.
*          endloop.
*          insert initial line
*            into table result assigning <cur_This_Error>.
*          <cur_This_Error> = <cur_Clas_Info>.
*          <cur_This_Error>-degree = gc_Info_Degree-class_Errors.
*        endif.
*
*        " methods
*        loop at <cur_Clas>-methods assigning <cur_Meth>.
*
*          add 1 to <cur_Tmpl_Info>-ndx_Method.
*          insert <cur_Tmpl_Info>
*            into table result assigning <cur_Meth_Info>.
*          <cur_Meth_Info>-degree = gc_Info_Degree-method.
*
*          loop at <cur_Meth>-alerts[] assigning <cur_Alert>.
*            mac_Count_Alerts <cur_Alert> <cur_Meth_Info>.
*          endloop.
*
*          if ( abap_True eq do_Summarize ).
*            mac_Sum_Counters <cur_Meth_Info> <cur_Clas_Info>.
*          endif.
*        endloop.
*
*        if ( abap_True eq do_Summarize ).
*          mac_Sum_Counters <cur_Clas_Info> <cur_Prog_Info>.
*        endif.
*
*      endloop.
*
*      if ( abap_True eq do_Summarize ).
*        mac_Sum_Counters <cur_Prog_Info> <cur_Task_Info>.
*      endif.
*
*    endloop.
*
*  endmethod.
*
*
*  method get_Details_For_Task.
** ===========================
*
*    data:
*      inf_Detail            like line of result.
*    field-symbols:
*      <cur_Program>         type ty_S_Prog_Data,
*      <cur_Class>           type ty_S_Clas_Data,
*      <cur_Method>          type ty_S_Meth_Data,
*      <cur_Alert>           type ty_S_Alert_Data.
*
*    " loop over task errors
*    if ( task-alerts[] is not initial ).
*      clear inf_Detail.
*      inf_Detail-degree =     gc_Info_Degree-task.
*      mac_Add_Alerts task-alerts[].
*    endif.
*    if ( abap_False eq include_Parts ).
*      return.
*    endif.
*
*    " loop over programs, classes & methods
*    clear inf_Detail.
*    loop at task-programs assigning <cur_Program>.
*
*      add 1 to inf_Detail-ndx_Program.
*      inf_Detail-degree =     gc_Info_Degree-program.
*      inf_Detail-ndx_Class =  0.
*      inf_Detail-ndx_Method = 0.
*      mac_Add_Alerts <cur_Program>-alerts[].
*
*      loop at <cur_Program>-classes assigning <cur_Class>.
*
*        add 1 to inf_Detail-ndx_Class.
*        inf_Detail-degree =     gc_Info_Degree-class.
*        inf_Detail-ndx_Method = 0.
*        mac_Add_Alerts <cur_Class>-alerts[].
*
*        loop at <cur_Class>-methods assigning <cur_Method>.
*
*          add 1 to inf_Detail-ndx_Method.
*          inf_Detail-degree =     gc_Info_Degree-method.
*          mac_Add_Alerts <cur_Method>-alerts[].
*
*        endloop. " methods
*
*      endloop. " classes
*
*    endloop. " programs
*
*  endmethod.
*
*
*  method get_Details_For_Program.
**  ==============================
*
*    data:
*      inf_Detail            like line of result.
*
*    field-symbols:
*      <cur_Program>         type ty_S_Prog_Data,
*      <cur_Class>           type ty_S_Clas_Data,
*      <cur_Method>          type ty_S_Meth_Data,
*      <cur_Alert>           type ty_S_Alert_Data.
*
*    " get program loop over classes & methods
*    read table task-programs[]
*      index ndx_Program
*      assigning <cur_Program>.
*    inf_Detail-ndx_Program = ndx_Program.
*    inf_Detail-degree =      gc_Info_Degree-program.
*    inf_Detail-ndx_Class =   0.
*    inf_Detail-ndx_Method =  0.
*    mac_Add_Alerts <cur_Program>-alerts[].
*
*    if ( abap_False eq include_Parts ).
*      return.
*    endif.
*
*    loop at <cur_Program>-classes assigning <cur_Class>.
*
*      add 1 to inf_Detail-ndx_Class.
*      inf_Detail-degree =     gc_Info_Degree-class.
*      inf_Detail-ndx_Method = 0.
*      mac_Add_Alerts <cur_Class>-alerts[].
*
*      loop at <cur_Class>-methods assigning <cur_Method>.
*        add 1 to inf_Detail-ndx_Method.
*        inf_Detail-degree =     gc_Info_Degree-method.
*        mac_Add_Alerts <cur_Method>-alerts[].
*      endloop. " methods
*
*    endloop. " classes
*
*  endmethod.
*
*
*  method get_Details_For_Class.
**  ============================
*
*    data:
*      inf_Detail            like line of result.
*    field-symbols:
*      <cur_Program>         type ty_S_Prog_Data,
*      <cur_Class>           type ty_S_Clas_Data,
*      <cur_Method>          type ty_S_Meth_Data,
*      <cur_Alert>           type ty_S_Alert_Data.
*
*    " get program & class, loop over methods
*    read table task-programs[]
*      index ndx_Program
*      assigning <cur_Program>.
*    read table <cur_Program>-classes
*      index ndx_Class
*      assigning <cur_Class>.
*
*    inf_Detail-ndx_Program = ndx_Program.
*    inf_Detail-ndx_Class =   ndx_Class.
*    inf_Detail-degree =      gc_Info_Degree-class.
*    inf_Detail-ndx_Method =  0.
*    mac_Add_Alerts <cur_Class>-alerts[].
*
*    if ( abap_False eq include_Parts ).
*      return.
*    endif.
*
*    loop at <cur_Class>-methods assigning <cur_Method>.
*      add 1 to inf_Detail-ndx_Method.
*      inf_Detail-degree =     gc_Info_Degree-method.
*      mac_Add_Alerts <cur_Method>-alerts[].
*    endloop. " methods
*
*  endmethod.
*
*
*  method get_Details_For_Method.
**  =============================
*
*    data:
*      inf_Detail            like line of result.
*    field-symbols:
*      <cur_Program>         type ty_S_Prog_Data,
*      <cur_Class>           type ty_S_Clas_Data,
*      <cur_Method>          type ty_S_Meth_Data,
*      <cur_Alert>           type ty_S_Alert_Data.
*
*    " get program, class & method
*    read table task-programs[]
*      index ndx_Program assigning <cur_Program>.
*    read table <cur_Program>-classes
*      index ndx_Class   assigning <cur_Class>.
*    read table <cur_Class>-methods
*      index ndx_Method  assigning <cur_Method>.
*
*    inf_Detail-ndx_Program = ndx_Program.
*    inf_Detail-ndx_Class =   ndx_Class.
*    inf_Detail-ndx_Method =  ndx_Method.
*    inf_Detail-degree =      gc_Info_Degree-method.
*    mac_Add_Alerts <cur_Method>-alerts[].
*
*  endmethod.
*
*
*  method get_Messages_For_Alert.
**  =============================
*
*    data:
*      txt_Temp    type string,
*      txt_String  type string,
*      inf_Result  type ty_S_Message_Info.
*    field-symbols:
*      <cur_Text>  type if_Aunit_Text_Description=>ty_S_Description.
*
*    " convert ordinary info
*    loop at alert-text_Infos[] assigning <cur_Text>.
*      inf_Result-indent = <cur_Text>-indent.
*      inf_Result-text =   f_Text_Depot->get_String( <cur_Text> ).
*      if ( 'AA99' eq <cur_Text>-id ).
*        read table <cur_Text>-params index 1 into txt_String.
*        read table <cur_Text>-params index 2 into txt_Temp.
*        if ( txt_Temp is not initial and txt_String is not initial ).
*          concatenate txt_String '.' txt_Temp into inf_Result-document.
*          inf_Result-is_Link = abap_True.
*        endif.
*      endif.
*      insert inf_Result into table text_Infos[].
*      clear inf_Result.
*    endloop.
*
*    " convert stack infos
*    loop at alert-stack_Lines[] assigning <cur_Text>.
*
*      clear inf_Result.
*
*      inf_Result-indent = <cur_Text>-indent.
*      inf_Result-text =   f_Text_Depot->get_String( <cur_Text> ).
*
*      if ( 2 le lines( <cur_Text>-params[] ) ).
*        read table <cur_Text>-params index 2 into txt_String.
*        try.
*          inf_Result-line = txt_String.
*          read table <cur_Text>-params index 1 into inf_Result-include.
*        catch cx_Root.  "#EC cATCH_ALL
*          clear inf_Result-include.
*        endtry.
*      endif.
*      if ( inf_Result-include is not initial ).
*        inf_Result-is_Link = abap_True.
*      endif.
*      insert inf_Result into table stack_Lines[].
*      clear inf_Result.
*    endloop.
*
*  endmethod.
*
*
*  method get_Messages_For_Extended_Info.
**  =====================================
*  " must not happen !
*
*    assert 1 = 2.
*
*  endmethod.
*
*
*endclass.
*
*
*
*class task_Data_Converter_Ext implementation.
*
*
*  method constructor.
**  ==================
*
*    super->constructor( ).
*    f_Ext_Mediator = ext_Mediator.
*
*  endmethod.
*
*
*  method compute_Base_Data.
**  ========================
*  " convert result to specific ui format
*  " this format is index driven due to the possibility to export
*  " the internal tables into spread sheet file format
*
*
*    field-symbols:
*      <cur_Tmpl_Info>  like line of result,
*      <cur_Task_Info>  like line of result,
*      <cur_This_Error> like line of result,
*      <cur_Prog_Info>  like line of result,
*      <cur_Clas_Info>  like line of result,
*      <cur_Meth_Info>  like line of result.
*    field-symbols:
*      <cur_Prog>       like line of task-programs,
*      <cur_Clas>       like line of <cur_Prog>-classes,
*      <cur_Meth>       like line of <cur_Clas>-methods,
*      <cur_Alert>      like line of <cur_Meth>-alerts.
*    data:
*      prog_Index       type i.                                    "#EC *
*
*
*    " create task entry
*    insert initial line into table result assigning <cur_Task_Info>.
*    if ( task-alerts is not initial ).
*      loop at task-alerts[] assigning <cur_Alert>.
*        mac_Count_Alerts <cur_Alert> <cur_Task_Info>.
*      endloop.
*    endif.
*
*    loop at task-extended_Infos transporting no fields
*      where program is initial.
*      add 1 to <cur_Task_Info>-cnt_Extended.
*      add 1 to <cur_Task_Info>-cnt_Info.
*    endloop.
*
*    if ( <cur_Task_Info> is not initial ).
*      insert initial line
*        into table result assigning <cur_This_Error>.
*      <cur_This_Error> =       <cur_Task_Info>.
*      <cur_This_Error>-degree = gc_Info_Degree-task_Errors.
*    endif.
*    <cur_Task_Info>-degree =      gc_Info_Degree-task.
*
*    " add program, class and method info
*    insert initial line
*      into table result assigning <cur_Tmpl_Info>.
*
*    loop at task-programs[] assigning <cur_Prog>.
*
*      " programs
*      clear:
*        <cur_Tmpl_Info>-ndx_Class,
*        <cur_Tmpl_Info>-ndx_Method.
*
*      add 1 to <cur_Tmpl_Info>-ndx_Program.
*      insert <cur_Tmpl_Info>
*        into table result assigning <cur_Prog_Info>.
*
*      if ( <cur_Prog>-alerts is not initial ).
*        loop at <cur_Prog>-alerts[] assigning <cur_Alert>.
*          mac_Count_Alerts <cur_Alert> <cur_Prog_Info>.
*        endloop.
*      endif.
*      loop at task-extended_Infos transporting no fields
*        where program =  <cur_Prog>-info-name and class is initial.
*        add 1 to <cur_Prog_Info>-cnt_Extended.
*        add 1 to <cur_Prog_Info>-cnt_Info.
*      endloop.
*
*      if ( <cur_Prog_Info> is not initial ).
*        insert initial line
*          into table result assigning <cur_This_Error>.
*        <cur_This_Error> = <cur_Prog_Info>.
*        <cur_This_Error>-degree = gc_Info_Degree-program_Errors.
*      endif.
*      <cur_Prog_Info>-degree = gc_Info_Degree-program.
*
*      " classes
*      loop at <cur_Prog>-classes assigning <cur_Clas>.
*
*        clear:
*          <cur_Tmpl_Info>-ndx_Method.
*
*        add 1 to <cur_Tmpl_Info>-ndx_Class.
*        insert <cur_Tmpl_Info>
*          into table result assigning <cur_Clas_Info>.
*
*        if ( <cur_Clas>-alerts is not initial ).
*          loop at <cur_Clas>-alerts[] assigning <cur_Alert>.
*            mac_Count_Alerts <cur_Alert> <cur_Clas_Info>.
*          endloop.
*        endif.
*
*        loop at task-extended_Infos transporting no fields
*          where
*            program =  <cur_Prog>-info-name and
*            class =    <cur_Clas>-info-name and
*            method =   ''.
*          add 1 to <cur_Clas_Info>-cnt_Extended.
*          add 1 to <cur_Clas_Info>-cnt_Info.
*        endloop.
*
*        if ( <cur_Clas_Info> is initial ).
*          insert initial line
*            into table result assigning <cur_This_Error>.
*          <cur_This_Error> = <cur_Clas_Info>.
*          <cur_This_Error>-degree = gc_Info_Degree-class_Errors.
*        endif.
*        <cur_Clas_Info>-degree = gc_Info_Degree-class.
*
*        "  methods
*        loop at <cur_Clas>-methods assigning <cur_Meth>.
*
*          add 1 to <cur_Tmpl_Info>-ndx_Method.
*          insert <cur_Tmpl_Info>
*            into table result assigning <cur_Meth_Info>.
*          <cur_Meth_Info>-degree = gc_Info_Degree-method.
*
*          loop at <cur_Meth>-alerts[] assigning <cur_Alert>.
*            mac_Count_Alerts <cur_Alert> <cur_Meth_Info>.
*          endloop.
*
*          loop at task-extended_Infos transporting no fields
*            where
*              program =  <cur_Prog>-info-name and
*              class =    <cur_Clas>-info-name and
*              method =   <cur_Meth>-info-name.
*            add 1 to <cur_Meth_Info>-cnt_Extended.
*            add 1 to <cur_Meth_Info>-cnt_Info.
*          endloop.
*
*          if ( abap_True eq do_Summarize ).
*            mac_Sum_Counters <cur_Meth_Info> <cur_Clas_Info>.
*          endif.
*        endloop.
*
*        if ( abap_True eq do_Summarize ).
*          mac_Sum_Counters <cur_Clas_Info> <cur_Prog_Info>.
*        endif.
*
*      endloop.
*
*      if ( abap_True eq do_Summarize ).
*        mac_Sum_Counters <cur_Prog_Info> <cur_Task_Info>.
*      endif.
*
*    endloop.
*
*  endmethod.
*
*
*  method get_Details_For_Task.
**  ===========================
*
*    data:
*      inf_Detail            like line of result.
*
*    field-symbols:
*      <cur_Program>         type ty_S_Prog_Data,
*      <cur_Class>           type ty_S_Clas_Data,
*      <cur_Method>          type ty_S_Meth_Data,
*      <cur_Alert>           type ty_S_Alert_Data,
*      <ext_Info>            type ty_S_Ext_Info.
*
*    " loop over task error
*    if ( task-alerts[] is not initial ).
*      clear inf_Detail.
*      inf_Detail-degree =     gc_Info_Degree-task.
*      mac_Add_Alerts task-alerts[].
*    endif.
*
*
*    if ( abap_True eq include_Parts ).
*      "  loop over programs, classes & methods
*      clear inf_Detail.
*      loop at task-programs assigning <cur_Program>.
*
*        add 1 to inf_Detail-ndx_Program.
*        inf_Detail-degree =     gc_Info_Degree-program.
*        inf_Detail-ndx_Class =  0.
*        inf_Detail-ndx_Method = 0.
*        mac_Add_Alerts <cur_Program>-alerts[].
*
*        loop at <cur_Program>-classes assigning <cur_Class>.
*
*          add 1 to inf_Detail-ndx_Class.
*          inf_Detail-degree =     gc_Info_Degree-class.
*          inf_Detail-ndx_Method = 0.
*          mac_Add_Alerts <cur_Class>-alerts[].
*
*          loop at <cur_Class>-methods assigning <cur_Method>.
*
*            add 1 to inf_Detail-ndx_Method.
*            inf_Detail-degree =     gc_Info_Degree-method.
*            mac_Add_Alerts <cur_Method>-alerts[].
*
*          endloop. " methods
*        endloop. " classes
*      endloop. " programs
*
*      loop at task-extended_Infos assigning <ext_Info>.
*        mac_Add_Extended_Info sy-tabix.
*      endloop.
*
*    else.
*      " add extended infos
*      loop at task-extended_Infos assigning <ext_Info>
*        where
*          program is initial.
*        mac_Add_Extended_Info sy-tabix.
*      endloop.
*    endif.
*
*  endmethod.
*
*
*  method get_Details_For_Program.
**  ==============================
*
*    data:
*      inf_Detail            like line of result.
*    field-symbols:
*      <cur_Program>         type ty_S_Prog_Data,
*      <cur_Class>           type ty_S_Clas_Data,
*      <cur_Method>          type ty_S_Meth_Data,
*      <cur_Alert>           type ty_S_Alert_Data,
*      <ext_Info>            type ty_S_Ext_Info.
*
*    " get program loop over classes & methods
*    read table task-programs[]
*      index ndx_Program assigning <cur_Program>.
*    inf_Detail-ndx_Program = ndx_Program.
*    inf_Detail-degree =      gc_Info_Degree-program.
*    inf_Detail-ndx_Class =   0.
*    inf_Detail-ndx_Method =  0.
*    mac_Add_Alerts <cur_Program>-alerts[].
*
*    if ( abap_True eq include_Parts ).
*
*      loop at <cur_Program>-classes assigning <cur_Class>.
*
*        add 1 to inf_Detail-ndx_Class.
*        inf_Detail-degree =     gc_Info_Degree-class.
*        inf_Detail-ndx_Method = 0.
*        mac_Add_Alerts <cur_Class>-alerts[].
*
*        loop at <cur_Class>-methods assigning <cur_Method>.
*
*          add 1 to inf_Detail-ndx_Method.
*          inf_Detail-degree =     gc_Info_Degree-method.
*          mac_Add_Alerts <cur_Method>-alerts[].
*
*        endloop. " methods
*
*      endloop. " classes
*
*      loop at task-extended_Infos assigning <ext_Info>
*        where
*          program = <cur_Program>-info-name.
*        mac_Add_Extended_Info sy-tabix.
*      endloop.
*
*    else.
*      " add extended infos
*      loop at task-extended_Infos assigning <ext_Info>
*        where
*          program = <cur_Program>-info-name  and
*          class     is initial.
*        mac_Add_Extended_Info sy-tabix.
*      endloop.
*    endif.
*
*  endmethod.
*
*
*  method get_Details_For_Class.
**  ============================
*
*    data:
*      inf_Detail            like line of result.
*    field-symbols:
*      <cur_Program>         type ty_S_Prog_Data,
*      <cur_Class>           type ty_S_Clas_Data,
*      <cur_Method>          type ty_S_Meth_Data,
*      <cur_Alert>           type ty_S_Alert_Data,
*      <ext_Info>            type ty_S_Ext_Info.
*
*    " get program & class, loop over methods
*    read table task-programs[]
*      index ndx_Program assigning <cur_Program>.
*    read table <cur_Program>-classes
*      index ndx_Class   assigning <cur_Class>.
*
*    inf_Detail-ndx_Program = ndx_Program.
*    inf_Detail-ndx_Class =   ndx_Class.
*    inf_Detail-degree =      gc_Info_Degree-class.
*    inf_Detail-ndx_Method =  0.
*    mac_Add_Alerts <cur_Class>-alerts[].
*
*
*    if ( abap_True eq include_Parts ).
*      loop at <cur_Class>-methods assigning <cur_Method>.
*        add 1 to inf_Detail-ndx_Method.
*        inf_Detail-degree =     gc_Info_Degree-method.
*        mac_Add_Alerts <cur_Method>-alerts[].
*      endloop. " methods
*      " add extended infos
*      loop at task-extended_Infos assigning <ext_Info>
*        where
*          program = <cur_Program>-info-name  and
*          class =   <cur_Class>-info-name.
*        mac_Add_Extended_Info sy-tabix.
*      endloop.
*    else.
*      " add extended infos
*      loop at task-extended_Infos assigning <ext_Info>
*        where
*          program = <cur_Program>-info-name  and
*          class =   <cur_Class>-info-name    and
*          method is initial.
*        mac_Add_Extended_Info sy-tabix.
*      endloop.
*    endif.
*
*  endmethod.
*
*
*  method get_Details_For_Method.
**  =============================
*
*    data:
*      inf_Detail            like line of result.
*
*    field-symbols:
*      <cur_Program>         type ty_S_Prog_Data,
*      <cur_Class>           type ty_S_Clas_Data,
*      <cur_Method>          type ty_S_Meth_Data,
*      <cur_Alert>           type ty_S_Alert_Data,
*      <ext_Info>            type ty_S_Ext_Info.
*
*    " get program, class & method
*    read table task-programs[]
*      index ndx_Program assigning <cur_Program>.
*    read table <cur_Program>-classes
*      index ndx_Class   assigning <cur_Class>.
*    read table <cur_Class>-methods
*      index ndx_Method  assigning <cur_Method>.
*
*    inf_Detail-ndx_Program = ndx_Program.
*    inf_Detail-ndx_Class =   ndx_Class.
*    inf_Detail-ndx_Method =  ndx_Method.
*    inf_Detail-degree =      gc_Info_Degree-method.
*    mac_Add_Alerts <cur_Method>-alerts[].
*
*    loop at task-extended_Infos assigning <ext_Info>
*      where
*        program = <cur_Program>-info-name  and
*        class =   <cur_Class>-info-name    and
*        method =  <cur_Method>-info-name.
*      mac_Add_Extended_Info sy-tabix.
*    endloop.
*
*  endmethod.
*
*
*  method get_Messages_For_Extended_Info.
**  =====================================
*  " extended info is computed by plug-in. Delegate computation and
*  " convert result afterwards to own format
*
*    field-symbols:
*      <cur_Ext_Message> type if_Saunit_Extended_Ui_Mediator=>ty_S_Message,
*      <cur_Message>     like line of result.
*    data:
*      xpt_Caugth        type ref to cx_Root,
*      ext_Messages      type if_Saunit_Extended_Ui_Mediator=>ty_T_Messages.
*
*    try.
*      ext_Messages = f_Ext_Mediator->get_Messages( ext_Info ).
*    catch cx_Root into xpt_Caugth.
*      insert initial line
*        into table ext_Messages assigning <cur_Ext_Message>.
*      <cur_Ext_Message>-text =
*        cl_Abap_Classdescr=>get_Class_Name( xpt_Caugth ).
*      insert initial line
*        into table ext_Messages assigning <cur_Ext_Message>.
*      <cur_Ext_Message>-text = xpt_Caugth->get_Text( ).
*    endtry.
*
*    loop at ext_Messages assigning <cur_Ext_Message>.
*      insert initial line into table result assigning <cur_Message>.
*      <cur_Message>-indent =     <cur_Ext_Message>-indent.
*      <cur_Message>-text =       <cur_Ext_Message>-text.
*      <cur_Message>-is_Link =    <cur_Ext_Message>-is_Link.
*      <cur_Message>-ndx_Info =   ndx_Info.
*    endloop.
*
*  endmethod.
*
*endclass.
