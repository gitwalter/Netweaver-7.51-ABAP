**-----------------------------------------------------------------------
**
**  include:  LAUNIT_TREE_CTRl_LISTENERF52
**
**-----------------------------------------------------------------------
**
**  implementation of the navigation tree which is displayed on the left
**  hand side
**  on level of task, program, test class, test methods various totals
**  are displayed. There can be 2 different kinds of totals which can
**  be switch. A click on a total shall toggle the display of the msgs
**  to be updated accordingly.
**
**-----------------------------------------------------------------------
*
*class base_Tree_Ctrl implementation.
*
*  method constructor.
** ==================
*    data:
*      alv_Buttons        type        string,
*      evt_Handler        type        string,
*      ctrl_Header        type        treev_Hhdr,
*      lines_Ref          like ref to f_Lines.
*
*    super->constructor( ).
*    f_Master = master.
*
*    " lazy class data initialization
*    if ( abap_False eq fg_Icon-init_Done ).
*      " the title can not be a constant due the language dependencies
*      " therefore it is created in the class constructor
*      call function 'ICON_CREATE'
*        exporting
*          name =    fg_Icon-task
*          info =    'Task'(ttk)
*        importing
*          result =  fg_Icon-task
*        exceptions
*          others  = 0.
*
*      call function 'ICON_CREATE'
*        exporting
*          name =    fg_Icon-task_Error
*          info =    'Messages at Task Level'(ter)
*        importing
*          result =  fg_Icon-task_Error
*        exceptions
*          others  = 0.
*
*      call function 'ICON_CREATE'
*        exporting
*          name =    fg_Icon-program
*          info =    'Main program'(tpg)
*        importing
*          result =  fg_Icon-program
*        exceptions
*          others  = 0.
*
*      call function 'ICON_CREATE'
*        exporting
*          name =    fg_Icon-prog_Error
*          info =    'Program related'(tpx)
*        importing
*          result =  fg_Icon-prog_Error
*        exceptions
*          others  = 0.
*
*      call function 'ICON_CREATE'
*        exporting
*          name =    fg_Icon-class
*          info =    'Test Class'(tcl)
*        importing
*          result =  fg_Icon-class
*        exceptions
*          others  = 0.
*
*      call function 'ICON_CREATE'
*        exporting
*          name =    fg_Icon-class_Error
*          info =    'Test class related'(tce)
*        importing
*          result =  fg_Icon-class_Error
*        exceptions
*          others  = 0.
*
*      call function 'ICON_CREATE'
*        exporting
*          name =    fg_Icon-method
*          info =    'Test Method'(tmt)
*        importing
*          result =  fg_Icon-method
*        exceptions
*          others  = 0.
*
*      call function 'ICON_CREATE'
*        exporting
*          name =       fg_Icon-state-good
*          info =      'Passed'(tgd)
*        importing
*          result =     fg_Icon-state-good
*        exceptions
*          others  = 0.
*
*      call function 'ICON_CREATE'
*        exporting
*          name =       fg_Icon-state-bad
*          info =       'Not Passed'(tnp)
*        importing
*          result =     fg_Icon-state-bad
*        exceptions
*          others  = 0.
*
*      call function 'ICON_CREATE'
*        exporting
*          name =       fg_Icon-state-reservations
*          info =       'Passed With Reservations'(trp)
*        importing
*          result =     fg_Icon-state-reservations
*        exceptions
*          others  = 0.
*
*      fg_Icon-init_Done = abap_True.
*
*    endif.
*
*    " build header information and construct alv control
*    ctrl_Header-heading = 'Task/Program/Class/Method'(300).
*    ctrl_Header-tooltip = 'Statistics for the Test Task of the Compilation Units'(301).
*    ctrl_Header-width = 45.
*    ctrl_Header-width_Pix = ' '.
*
*    concatenate
*      ''
*      if_Sat_Ui_Tree=>c_Menu_Hierachy
*      into alv_Buttons.
*
*    concatenate
*      if_Sat_Ui_Tree=>c_Handle_Double_Click
*      if_Sat_Ui_Tree=>c_Handle_Expand_Node
*      if_Sat_Ui_Tree=>c_Handle_User_Command
*      if_Sat_Ui_Tree=>c_Handle_Menu
*      into evt_Handler.
*    get reference of f_Lines into lines_Ref.
*    _Init_Instance(
*      container =                container
*      header =                   ctrl_Header
*      toolbar_Options =          alv_Buttons
*      handler_Options =          evt_Handler
*      content_Table_Reference =  lines_Ref ).
*
*    __Init_Buttons( ).
*    __Set_Field_Layout( ).
*
*  endmethod.
*
*
*  method __Set_Field_Layout.
** =========================
*    data:
*      field_Layout_Info  type lvc_S_Layi.
*
*    clear f_Field_Layout_Infos[].
*
*    field_Layout_Info-class = cl_Gui_Column_Tree=>item_Class_Link.
*    field_Layout_Info-fieldname = c_Field_Name-icon.
*    append Field_Layout_Info to f_Field_Layout_Infos.
*    field_Layout_Info-fieldname = c_Field_Name-cnt_Fatal.
*    append Field_Layout_Info to f_Field_Layout_Infos.
*    field_Layout_Info-fieldname = c_Field_Name-cnt_Critical.
*    append field_Layout_Info to f_Field_Layout_Infos.
*    field_Layout_Info-fieldname = c_Field_Name-cnt_Tolerable.
*    append field_Layout_Info to f_Field_Layout_Infos.
*    field_Layout_Info-fieldname = c_Field_Name-cnt_Failure.
*    append field_Layout_Info to f_Field_Layout_Infos.
*    field_Layout_Info-fieldname = c_Field_Name-cnt_Error.
*    append field_Layout_Info to f_Field_Layout_Infos.
*    field_Layout_Info-fieldname = c_Field_Name-cnt_Shortdump.
*    append field_Layout_Info to f_Field_Layout_Infos.
*    field_Layout_Info-fieldname = c_Field_Name-cnt_warning.
*    append field_Layout_Info to f_Field_Layout_Infos.
*
*    if ( f_Master->task-extended_Infos is not initial ).
*      field_Layout_Info-fieldname = c_Field_Name-cnt_Extended.
*      append field_Layout_Info to f_Field_Layout_Infos.
*    endif.
*
*  endmethod.
*
*  method _Get_Field_Catalogue.
** ==========================
*    data:
*      cnt_Field        type i,
*      lyt_Field        like line of result,
*      mediator_Setting type
*                        if_Saunit_Extended_Ui_Mediator=>ty_S_Ui_Setting.
*
*    " keep in sync with the type definition of ty_S_Base_Info.
*    " scan for #BASE_INFO# to find related source code
*    data:
*      comment_Keep_In_Sync    type ty_S_Base_Info.          "#EC *
*
*    " just the leading icon
*    clear lyt_Field.
*    add 1 to cnt_Field.
*    lyt_Field-col_Pos =            cnt_Field.
*    lyt_Field-fieldname =          c_Field_Name-icon.
*    lyt_Field-inttype =            'C'.
*    lyt_Field-seltext =
*      lyt_Field-coltext =          'Status'(sta).
*    lyt_Field-outputlen =          6.
*    lyt_Field-icon =               abap_True.
*    insert lyt_Field into table result[].
*
*    " counters for severity (initially on screen)
*    clear lyt_Field.
*    lyt_Field-inttype =            'I'.
*    lyt_Field-just =               'R'. "ight
*    if ( f_Master->mediator is initial ).
*      lyt_Field-outputlen =          9.
*    else.
*      lyt_Field-outputlen =          7.
*    endif.
*
*    if ( abap_True eq f_Master->style_Prio ).
*      lyt_Field-no_Out =             abap_False.
*    else.
*      lyt_Field-no_Out =             abap_True.
*    endif.
*
*    add 1 to cnt_Field.
*    lyt_Field-col_Pos =            cnt_Field.
*    lyt_Field-fieldname =          c_Field_Name-cnt_Fatal.
*    lyt_Field-seltext =
*      lyt_Field-coltext =          'Fatal'.                  "#EC NOTEXT
*    insert lyt_Field into table result[].
*
*    add 1 to cnt_Field.
*    lyt_Field-col_Pos =            cnt_Field.
*    lyt_Field-fieldname =          c_Field_Name-cnt_Critical.
*    lyt_Field-seltext =
*      lyt_Field-coltext =          'Critical'.               "#EC NOTEXT
*    insert lyt_Field into table result[].
*
*    add 1 to cnt_Field.
*    lyt_Field-col_Pos =            cnt_Field.
*    lyt_Field-fieldname =          c_Field_Name-cnt_Tolerable.
*    lyt_Field-seltext =
*      lyt_Field-coltext =          'Tolerable'.              "#EC NOTEXT
*    insert lyt_Field into table result[].
*
*
*    if ( f_Master->mediator is not initial ).
*      add 1 to cnt_Field.
*      lyt_Field-col_Pos =            cnt_Field.
*      lyt_Field-fieldname =          c_Field_Name-cnt_Info.
*      lyt_Field-coltext =
*        lyt_Field-seltext =          'Information'.          "#EC NOTEXT
*      insert lyt_Field into table result[].
*    endif.
*
*
*    " counters for various failure kinds (initially hidden)
*    clear lyt_Field.
*    lyt_Field-inttype =            'I'.
*    lyt_Field-outputlen =          7.
*    lyt_Field-just =               'R'. "ight
*
*    if ( f_Master->mediator is initial ).
*      lyt_Field-outputlen =          7.
*    else.
*      lyt_Field-outputlen =          6.
*      mediator_Setting = f_Master->mediator->get_Display_Setting( ).
*
*      if ( mediator_Setting-column_Title is initial ).
*        mediator_Setting-column_Title = 'Extended info'(inx).
*      endif.
*      if ( mediator_Setting-column_Tooltip is initial ).
*        mediator_Setting-column_Tooltip = mediator_Setting-column_Title.
*      endif.
*    endif.
*
*    if ( abap_True eq f_Master->style_Prio ).
*      lyt_Field-no_Out =             abap_True.
*    else.
*      lyt_Field-no_Out =             abap_False.
*    endif.
*
*    add 1 to cnt_Field.
*    lyt_Field-col_Pos =            cnt_Field.
*    lyt_Field-fieldname =          c_Field_Name-cnt_Failure.
*    lyt_Field-seltext =
*      lyt_Field-coltext =          'Failed assertion'(fai).
*    insert lyt_Field into table result[].
*
*    add 1 to cnt_Field.
*    lyt_Field-col_Pos =            cnt_Field.
*    lyt_Field-fieldname =          c_Field_Name-cnt_Error.
*    lyt_Field-seltext =
*      lyt_Field-coltext =          'Exception error'(exp).
*    insert lyt_Field into table result[].
*
*    add 1 to cnt_Field.
*    lyt_Field-col_Pos =            cnt_Field.
*    lyt_Field-fieldname =          c_Field_Name-cnt_Shortdump.
*    lyt_Field-seltext =
*      lyt_Field-coltext =          'Runtime abortion'(rab).
*    insert lyt_Field into table result[].
*
*    add 1 to cnt_Field.
*    lyt_Field-col_Pos =            cnt_Field.
*    lyt_Field-fieldname =          c_Field_Name-cnt_warning.
*    lyt_Field-seltext =
*      lyt_Field-coltext =          'Warning'(wrn).
*    insert lyt_Field into table result[].
*
*    if ( f_Master->mediator is not initial ).
*      add 1 to cnt_Field.
*      lyt_Field-col_Pos =            cnt_Field.
*      lyt_Field-fieldname =          c_Field_Name-cnt_Extended.
*      lyt_Field-coltext =            mediator_Setting-column_Title.
*      lyt_Field-seltext =            mediator_Setting-column_Tooltip.
*      insert lyt_Field into table result[].
*    endif.
*
*  endmethod.
*
*
*  method build_Content.
** ====================
*  " compute the tree content from the shared data of the master ref
*    data:
*      key_Base             type         lvc_Nkey,
*      is_Child_Node        type         abap_Bool   value abap_True,
*      key_Root             type         lvc_Nkey,
*      key_Prog             type         lvc_Nkey,                 "#EC *
*      key_Open             type         lvc_Nkey,
*      key_Open_Ext         type         lvc_Nkey.
*    data:
*      txt_Buffer           type         lvc_value,
*      task_Info            type         ty_S_Base_Info.
*    field-symbols:
*      <prog_Data>          type         ty_S_Prog_Data,
*      <prog_Node_Info>     type         ty_S_Base_Info.
*
*    _Clear_Content( ).
*
*    " for empty data set create a notice then go for good
*    read table f_Master->data
*      into task_Info
*      with key degree =  gc_Info_Degree-task.
*
*    if ( 0 ne sy-subrc ).
*
*      txt_Buffer = f_Master->task-info-name.
*
*      key_Root = f_Tree_Ctrl->append_Child_Folder(
*        parent_Key   = ``
*        title        = txt_Buffer ).
*
*      clear task_Info.
*      task_Info-ndx_Program = c_Ndx-other.
*
*      key_Prog = f_Tree_Ctrl->append_Child_Node(
*        parent_Key =    key_Root
*        data =          task_Info
*        title  =        'No data'(nod)
*        field_Layout =  f_Field_Layout_Infos ).
*
*      return.
*    endif.
*
*    " build summary for the task
*    task_Info-ndx_Program = c_Ndx-summary.
*    txt_Buffer = f_Master->task-info-name.
*
*    key_Root = __Append_Base_Node(
*      parent_Key =     key_Root
*      base_Data =      task_Info
*      title =          txt_Buffer
*      icon =           fg_Icon-task ).
*
*    " add errors on task level
*    read table f_Master->data[]
*      assigning <prog_Node_Info>
*      with key degree = gc_Info_Degree-task_Errors.
*
*    if ( 0 eq sy-subrc ).
*      txt_Buffer = 'At task level'(mts).
*      __Append_Base_Node(
*        parent_Key = key_Root
*        is_Child =   abap_True
*        base_Data =  <prog_Node_Info>
*        title =      txt_Buffer
*        icon =       fg_Icon-task_Error ).
*    endif.
*
*    " build the tree lazy ( only program level ) -
*    " get key of first     alert
*    key_Base = key_Root.
*    is_Child_Node = abap_True.
*
*    if ( f_Master->mediator is initial ).
*      loop at f_Master->data[] assigning <prog_Node_Info>
*        where degree eq gc_Info_Degree-program.
*
*        read table f_Master->task-programs
*          index <prog_Node_Info>-ndx_Program
*          assigning <prog_Data>.
*        txt_Buffer = <prog_Data>-info-name.
*
*        if ( key_Open is initial and 0 ne <prog_Node_Info>-cnt_Alert ).
*          key_Prog =  __Append_Base_Node(
*            parent_Key = key_Base
*            is_Child =   is_Child_Node
*            base_Data =  <prog_Node_Info>
*            title =      txt_Buffer
*            icon =       fg_Icon-program ).
*          key_Open = key_Prog.
*          " checking for testclasses prooved to be a wrong thing here
*          " there can be alerts on program level e.g. bad ressource
*          " which is very like for alert without classes :)=
*          " but well in this cases the tree control dumps awfully
*          " in handling of the automation queue
*          "  => if ( <prog_Data>-classes is not initial ).
*          "  => endif.
*          __Expand_Prog_Branch(
*            prog_Key =   key_Open
*            prog_Info =  <prog_Node_Info> ).
*
*        else.
*          key_Prog = __Append_Lazy_Node(
*            parent_Key = key_Base
*            is_Child =   is_Child_Node
*            base_Data =  <prog_Node_Info>
*            title =      txt_Buffer
*            icon =       fg_Icon-program ).
*        endif.
*
*        " adding sibling is faster than adding child !!
*        key_Base = key_Prog.
*        is_Child_Node = abap_False.
*
*      endloop.
*
*    else.
*      loop at f_Master->data[] assigning <prog_Node_Info>
*        where degree eq gc_Info_Degree-program.
*
*        read table f_Master->task-programs
*          index <prog_Node_Info>-ndx_Program
*          assigning <prog_Data>.
*        txt_Buffer = <prog_Data>-info-name.
*
*        if ( key_Open is initial ).
*          if ( 0 ne <prog_Node_Info>-cnt_Alert ).
*            " alert
*            key_Prog =  __Append_Base_Node(
*              parent_Key = key_Base
*              is_Child =   is_Child_Node
*              base_Data =  <prog_Node_Info>
*              title =      txt_Buffer
*              icon =       fg_Icon-program ).
*            key_Open_Ext = key_Open = key_Prog.
*            if ( <prog_Data>-classes is not initial ).
*              __Expand_Prog_Branch(
*                prog_Key =   key_Open
*                prog_Info =  <prog_Node_Info> ).
*            endif.
*          elseif ( 0 ne <prog_Node_Info>-cnt_Info ).
*            " extended data
*            key_Prog =  __Append_Base_Node(
*              parent_Key = key_Base
*              is_Child =   is_Child_Node
*              base_Data =  <prog_Node_Info>
*              title =      txt_Buffer
*              icon =       fg_Icon-program ).
*            key_Open_Ext = key_Prog.
*            if ( <prog_Data>-classes is not initial ).
*              __Expand_Prog_Branch(
*                prog_Key =   key_Open_Ext
*                prog_Info =  <prog_Node_Info> ).
*            endif.
*          else.
*            " nothing of interest
*            key_Prog = __Append_Lazy_Node(
*              parent_Key = key_Base
*              is_Child =   is_Child_Node
*              base_Data =  <prog_Node_Info>
*              title =      txt_Buffer
*              icon =       fg_Icon-program ).
*          endif.
*        else.
*          " well the to expand node is already chosen
*          key_Prog = __Append_Lazy_Node(
*            parent_Key = key_Base
*            is_Child =   is_Child_Node
*            base_Data =  <prog_Node_Info>
*            title =      txt_Buffer
*            icon =       fg_Icon-program ).
*        endif.
*
*        " adding sibling is faster than adding child !!
*        key_Base = key_Prog.
*        is_Child_Node = abap_False.
*
*      endloop.
*    endif.
*
*    " expand first program with errors / extended infos
*    if ( key_Open is not initial ).
*      f_Tree_Ctrl->expand_Node(
*        i_Node_Key =       key_Open
*        i_Expand_Subtree = abap_True ).
*      _Handle_Double_Click( key_Open ).
*    elseif ( key_Open_Ext is not initial ).
*      f_Tree_Ctrl->expand_Node(
*        i_Node_Key =       key_Open_Ext
*        i_Expand_Subtree = abap_True ).
*      _Handle_Double_Click( key_Open_Ext ).
*    endif.
*
*    if ( abap_True eq do_Refresh ).
*      refresh_Display( ).
*    endif.
*
*  endmethod.
*
*
*  method _Handle_Double_Click.
** ==========================
*  " trigger display of a new detail list content
*    data:
*      include_Parts       type abap_Bool value abap_True,
*      base_Info           type ty_S_Base_Info,
*      detail_Infos        type ty_T_Detail_Infos.
*    field-symbols:
*      <program_Data>      type ty_S_Prog_Data,
*      <class_Data>        type ty_S_Clas_Data,
*      <method_Data>       type ty_S_Meth_Data.
*
*    " get base info and check if navigation is supported
*    base_Info = __Get_Info_By_Node_Key( node_Key ).
*    if ( base_Info is initial ).
*      f_Master->detail_List->set_List_Data( detail_Infos ).
*      return.
*    elseif ( 1 > base_Info-ndx_Program ).
*      case base_Info-degree.
*        when gc_Info_Degree-task.
*          detail_Infos = f_Master->converter->get_Details_For_Task(
*            task = f_Master->task ).
*        when gc_Info_Degree-task_Errors.
*          detail_Infos = f_Master->converter->get_Details_For_Task(
*            task = f_Master->task
*            include_Parts = abap_False ).
*        when others.
*          " hmmm what
*          return.
*      endcase.
*    else.
*      read table f_Master->task-programs[]
*        index base_Info-ndx_Program
*        assigning <program_Data>.
*    endif.
*
*    " check wether details are requested on method, class, program
*    " or task level
*    if ( <program_Data> is assigned ).
*      read table <program_Data>-classes
*        index base_Info-ndx_Class
*        assigning <class_Data>.
*      if ( <class_Data> is assigned ).
*        read table <class_Data>-methods
*          index base_Info-ndx_Method
*          assigning <method_Data>.
*        if ( <method_Data> is assigned ).
*          detail_Infos = f_Master->converter->get_Details_For_Method(
*            task =         f_Master->task
*            ndx_Program =  base_Info-ndx_Program
*            ndx_Class =    base_Info-ndx_Class
*            ndx_Method =   base_Info-ndx_Method ).
*        else.
*          if ( base_Info-degree eq gc_Info_Degree-class_Errors ).
*            include_Parts = abap_False.
*          endif.
*          detail_Infos = f_Master->converter->get_Details_For_Class(
*            task =          f_Master->task
*            include_Parts = include_Parts
*            ndx_Program =   base_Info-ndx_Program
*            ndx_Class =     base_Info-ndx_Class ).
*        endif.
*      else.
*        if ( base_Info-degree eq gc_Info_Degree-program_Errors ).
*          include_Parts = abap_False.
*        endif.
*        detail_Infos = f_Master->converter->get_Details_For_Program(
*          task =         f_Master->task
*          include_Parts = include_Parts
*          ndx_Program =  base_Info-ndx_Program ).
*      endif.
*    endif.
*
*    " if double click on specific column limit result to details of type
*    if ( field_Name(3) eq 'CNT' ).
*      case field_Name.
*
*        when c_Field_Name-cnt_Fatal.
*          delete detail_Infos where level ne gc_Alert_Level-fatal.
*
*        when c_Field_Name-cnt_Critical.
*          delete detail_Infos where level ne gc_Alert_Level-critical.
*
*        when c_Field_Name-cnt_Info.
*          delete detail_Infos where level ne gc_Alert_Level-information.
*
*        when c_Field_Name-cnt_Tolerable.
*          delete detail_Infos where level ne gc_Alert_Level-tolerable.
*
*        when c_Field_Name-cnt_Failure.
*          delete detail_Infos where kind  ne gc_Alert_Kind-failure.
*
*        when c_Field_Name-cnt_Error.
*          delete detail_Infos where kind  ne gc_Alert_Kind-error.
*
*        when c_Field_Name-cnt_Shortdump.
*          delete detail_Infos where kind  ne gc_Alert_Kind-shortdump.
*
*        when c_Field_Name-cnt_warning.
*          delete detail_Infos where kind  ne gc_Alert_Kind-warning.
*
*        when c_Field_Name-cnt_Extended.
*          delete detail_Infos where kind  ne gc_Alert_Kind-extended_Info.
*
*      endcase.
*    endif.
*
*    if ( lines( detail_Infos ) > 50 and
*         base_Info-degree eq gc_Info_Degree-task ).
*      delete detail_Infos[] from 51.
*      message s600 display like 'W'.
*    endif.
*
*    f_Master->detail_List->set_List_Data( detail_Infos ).
*
*  endmethod.
*
*
*  method _Handle_Menu_Requested.
** =============================
*    data:
*      base_Data            type ty_S_Base_Info,
*      can_Execute          type abap_Bool,
*      can_Debug            type abap_Bool,
*      obj_Type             type tadir-object,
*      obj_Name             type tadir-obj_Name,
*      prog_Name            type progName,
*      class_Name           type string,
*      method_Name          type string.
*    data:
*      positions        type cl_Saunit_Source_Info_Svc=>ty_T_Positions.
*    field-symbols:
*      <prog_Data>          type ty_S_Prog_Data,
*      <clas_Data>          type ty_S_Clas_Data,
*      <meth_Data>          type ty_S_Meth_Data.
*
*    " erase standard entries
*    menu->clear( ).
*    base_Data = __Get_Info_By_Node_Key( node_Key ).
*
*    case base_Data-degree.
*      when gc_Info_Degree-task.
*        menu->add_Function(
*          fcode = c_Command-show_Task
*          text = 'Data for Test Task'(cst) ).
*
*      when gc_Info_Degree-program.
*        can_Execute = abap_True.
*        menu->add_Function(
*          fcode = c_Command-show_Program
*          text = 'Display Source Code'(css) ).
*
*      when gc_Info_Degree-class.
*        can_Execute = abap_True.
*        menu->add_Function(
*          fcode = c_Command-show_Class
*          text = 'Display Source Code'(css) ).
*
*      when gc_Info_Degree-method.
*        can_Execute = abap_True.
*    endcase.
*
*    if ( abap_False eq can_Execute ).
*      return.
*    endif.
*
*    " get program name check authorization
*    read table f_Master->task-programs
*      index base_Data-ndx_Program
*      assigning <prog_Data>.
*    if ( 0 eq sy-subrc ).
*      prog_Name = <prog_Data>-info-name.
*      read table <prog_Data>-classes
*        index base_Data-ndx_Class
*        assigning <clas_Data>.
*      if ( 0 eq sy-subrc ).
*        class_Name = <clas_Data>-info-name.
*        read table <clas_Data>-methods
*          index base_Data-ndx_Method
*          assigning <meth_Data>.
*        if ( 0 eq sy-subrc ).
*          method_Name = <meth_Data>-info-name.
*        endif.
*      endif.
*    endif.
*
*    can_Execute = abap_False.
*    if ( prog_Name is not initial ).
*      cl_Aunit_Prog_Info=>progname_To_Tadir(
*        exporting
*          progname =  prog_Name
*        importing
*          obj_Name =  obj_Name
*          obj_Type =  obj_Type ).
*      can_Execute =
*        cl_Aunit_Permission_Control=>is_Authorized_To_Use_In_Ide(
*          obj_Type = obj_Type
*          obj_Name = obj_Name ).
*    endif.
*    if ( abap_False eq can_Execute ).
*      return.
*    endif.
*    if ( f_Master->task-extended_Infos is not initial ).
*      menu->add_Function(
*        fcode = c_Command-do_Execute
*        text = 'Execute without Extension'(ex2) ).
*    else.
*      menu->add_Function(
*        fcode = c_Command-do_Execute
*        text = 'Execute'(exe) ).
*    endif.
*
*    can_Debug = abap_False.
*    if ( method_Name is not initial ).
*      positions = cl_Saunit_Source_Info_Svc=>get_Method_Positions(
*        prog_Name = prog_Name
*        class_Name = class_Name
*        options = 'W' ).
*      read table positions
*        transporting no fields
*        with key method_Name = method_Name.
*      if ( 0 eq sy-subrc ).
*        can_Debug = abap_True.
*      endif.
*    endif.
*    if ( if_Aunit_Task=>c_Run_Mode-external eq
*         f_Master->task-info-run_Mode ).
*      " external breakpoints are toooooo lazy
*      can_Debug = abap_False.
*    endif.
*    if ( can_Debug eq abap_False ).
*      return.
*    endif.
*
*    " build the menu
*    if ( f_Master->task-extended_Infos is not initial ).
*        menu->add_Function(
*          fcode = c_Command-do_Execute_Debug
*          text = 'Debug without Extension'(db2) ).
*    else.
*      menu->add_Function(
*        fcode = c_Command-do_Execute_Debug
*        text = 'Debug'(dbg) ).
*    endif.
*
*  endmethod.
*
*
*  method _Handle_Menu_Selected.
** ===========================
*  " trigger to handle a contextmenu
*  " importing node_Key, fcode
*    data:
*      base_Data            type ty_S_Base_Info.
*
*    " dispatch FCode
*    case user_Command.
*      when c_Command-show_Program or c_Command-show_Class.
*        base_Data =  __Get_Info_By_Node_Key( node_Key ).
*        __navigate_To_Source( base_Data ).
*
*      when c_Command-do_Execute.
*        base_Data =  __Get_Info_By_Node_Key( node_Key ).
*        __Execute_Test_Again( base_Data ).
*
*      when c_Command-do_Execute_Debug.
*        base_Data =  __Get_Info_By_Node_Key( node_Key ).
*        __Execute_Test_Again(
*          base_Data = base_Data
*          set_Break = abap_True ).
*
*      when c_Command-show_Task.
*        f_Master->show_Header( ).
*
*    endcase.
*
*  endmethod.
*
*
*  method __Execute_Test_Again.
** ============================
*    data:
*      external_Break       type abap_Bool,
*      success              type abap_Bool,
*      obj_Type             type tadir-object,
*      obj_Name             type tadir-obj_Name,
*      prog_Name            type progName,
*      au_Factory           type ref to cl_Aunit_Factory,
*      au_Task              type ref to if_Aunit_Task,
*      au_Listener          type ref to listener_With_Ui_Trigger,
*      test_Class_Handles
*        type if_Aunit_Test_Class_Handle=>ty_T_Testclass_Handles,
*      test_Class_Handle    type ref to if_Aunit_Test_Class_Handle,
*      selected_Handle      type ref to if_Aunit_Test_Class_Handle,
*      decorated_Handle     type ref to cl_Saunit_Tcd_Method_Filter,
*      class_Name           type string,
*      method_Names         type string_Table,
*      methods              type saunit_T_Methods.
*
*    field-symbols:
*      <prog_Data>          type ty_S_Prog_Data,
*      <class_Data>         type ty_S_Clas_Data,
*      <method_Data>        type ty_S_Meth_Data.
*
*    if ( 0 ne base_Data-ndx_Program ).
*      read table f_Master->task-programs
*        index base_Data-ndx_Program
*        assigning <prog_Data>.
*    endif.
*
*    if ( <prog_Data> is not assigned ).
*      return.
*    endif.
*    prog_Name = <prog_Data>-info-name.
*    cl_Aunit_Prog_Info=>progname_To_Tadir(
*      exporting
*        progname =  prog_Name
*      importing
*        obj_Name =  obj_Name
*        obj_Type =  obj_Type ).
*
*    if ( 0 ne base_Data-ndx_Class ).
*      read table <prog_Data>-classes
*        index base_Data-ndx_Class
*        assigning <class_Data>.
*    endif.
*
*    if ( 0 ne base_Data-ndx_Method and <class_Data> is assigned ).
*      read table <class_Data>-methods
*        index base_Data-ndx_Method
*        assigning <method_Data>.
*    endif.
*
*    " okay all is prepared now go on
*    create object au_Factory.
*    test_Class_Handles = au_Factory->get_Test_Class_Handles(
*      obj_Name = obj_Name
*      obj_Type = obj_Type ).
*
*    if ( test_Class_Handles is initial ).
*      message
*        'Test(s) no longer available'(not)
*        type 'S' display like 'I'.
*      return.
*    endif.
*
*    create object au_Listener exporting show_Success_Also = abap_True.
*    au_Task = au_Factory->create_Task( au_Listener ).
*    if ( <class_Data> is not assigned ).
*      loop at test_Class_Handles into test_Class_Handle.
*        au_Task->add_Test_Class_Handle( test_Class_Handle ).
*      endloop.
*    else.
*      loop at test_Class_Handles into test_Class_Handle.
*        class_Name = test_Class_Handle->get_Class_Name( ).
*        if ( class_Name eq <class_Data>-Info-Name ).
*          if ( <method_Data> is assigned ).
*            " single method only
*            method_Names = test_Class_Handle->get_Test_Methods( ).
*            read table method_Names
*              transporting no fields
*              with key table_Line = <method_Data>-info-name.
*            if ( 0 eq sy-subrc ).
*              create object decorated_Handle
*                exporting
*                  test_instance = test_Class_Handle.
*              append <method_Data>-info-name to methods.
*              decorated_Handle->restrict_Methods(
*                methods = methods ).
*              selected_Handle = decorated_Handle.
*            endif.
*          else.
*            selected_Handle = test_Class_Handle.
*          endif.
*          exit. " loop
*        endif.
*      endloop.
*      if ( selected_Handle is initial ).
*        message
*          'Test(s) no longer available'(not)
*          type 'S' display like 'I'.
*        return.
*      endif.
*      au_Task->add_Test_Class_Handle( selected_Handle ).
*    endif.
*
*    " there we go - in case of a new result another display
*    " instance will appear and turn us invisible - thus
*    " an explicit set visbile is done afterwards.
*    au_Task->set_duration_limit(
*      f_Master->task-info-duration_Settings ).
*    au_Task->restrict_Risk_Level(
*      f_Master->task-info-risk_Level ).
*
*    if ( <method_Data> is assigned and abap_True eq set_Break ).
*      if ( cl_Aunit_Task=>run_Mode_External eq
*           f_Master->task-info-run_Mode ).
*        external_Break = abap_True.
*      endif.
*      success = __Add_Break_Point(
*        external =     external_Break
*        prog_Name =    <prog_Data>-info-name
*        class_Name =   <class_Data>-info-name
*        method_Name =  <method_Data>-info-Name ).
*      if ( abap_False eq success ).
*        f_No_Break = abap_True.
*      endif.
*    endif.
*    au_Task->run(
*      f_Master->task-info-run_Mode ).
*    if ( abap_True eq set_Break ).
*      __Reset_Break_Points(
*        external =     external_Break
*        prog_Name =    <prog_Data>-info-name ).
*    endif.
*    f_Master->set_Visible( abap_True ).
*
*  endmethod.
*
*
*  method __navigate_To_Source.
** ============================
*    data:
*      src_Code             type ref to cl_Saunit_Source_Code_Svc,
*      obj_Type             type tadir-object,
*      obj_Name             type tadir-obj_Name,
*      prog_Name            type progName,
*      wb_Key               type seu_Objkey,
*      wb_Request           type ref to cl_Wb_Request,
*      wb_Requests          like standard table of wb_Request.
*
*    field-symbols:
*      <prog_Data>          type ty_S_Prog_Data,
*      <class_Data>         type ty_S_Clas_Data.
*
*    if ( 0 ne base_Data-ndx_Program ).
*      read table f_Master->task-programs
*        index base_Data-ndx_Program
*        assigning <prog_Data>.
*    endif.
*
*    if ( <prog_Data> is not assigned ).
*      return.
*    endif.
*
*    create object src_Code.
*
*    prog_Name = <prog_Data>-info-name.
*    cl_Aunit_Prog_Info=>progname_To_Tadir(
*      exporting
*        progname =  prog_Name
*      importing
*        obj_Name =  obj_Name
*        obj_Type =  obj_Type ).
*
*    if ( 0 ne base_Data-ndx_Class ).
*      read table <prog_Data>-classes
*        index base_Data-ndx_Class
*        assigning <class_Data>.
*    endif.
*
*    if ( <class_Data> is assigned and
*         ( 'CLAS' ne obj_Type or <class_Data>-info-name ne obj_Name ) ).
*      wb_Request = src_Code->get_Navigation_Request(
*        i_Obj_Type =  obj_Type
*        i_Obj_Name =  obj_Name
*        i_Class_Name = <class_Data>-info-name ).
*    endif.
*
*    if ( wb_Request is initial ).
*      wb_Request = src_Code->get_Navigation_Request(
*        i_Obj_Type =  obj_Type
*        i_Obj_Name =  obj_Name ).
*    endif.
*
*    if ( wb_Request is bound ).
*      insert wb_Request into table wb_Requests.
*      cl_wb_startup=>start(
*        exporting
*          p_Wb_Request_Set =             wb_Requests
*          force_New_Wbmanager_Instance = abap_True
*        exceptions
*          others = 1 ).
*      if ( 0 eq sy-SubRc ).
*        return.
*      endif.
*    endif.
*
*    call function 'RS_TOOL_ACCESS'
*      exporting
*        operation     = 'SHOW'
*        object_Name   = obj_Name
*        object_Type   = obj_Type
*        in_New_window = abap_False
*      exceptions
*        others        = 1.
*    if ( 0 ne sy-subrc ).
*      message
*        'Navigation not possible'                            "#EC NOTEXT
*        type 'S' display like 'I'.
*    endif.
*
*  endmethod.
*
*
*  method _Handle_Expand_Node.
** ==========================
*    " base tree is only filled up to program level
*    " upon the first expansion of a progam entry this method is called
*    " its job is to add the display child nodes of this program
*
*    data:
*      prog_Node_Info       type ty_S_Base_Info.
*
*    prog_Node_Info = __Get_Info_By_Node_Key( node_Key ).
*    if ( prog_Node_Info is initial ).
*      return.
*    endif.
*
*    assert prog_Node_Info-degree eq gc_Info_Degree-program.
*
*    __Expand_Prog_Branch(
*      prog_Key =  node_Key
*      prog_Info = prog_Node_Info ).
*
*  endmethod.
*
*
*  method display_All.
** ==================
*    " the treev expand does not handle lazy nodes (which have not
*    " been sent to the frontend yet). this little helper does
*    types:
*      begin of ty_S_Prog_Node,
*        key             type lvc_Nkey,
*        info            type ty_S_Base_Info,
*      end of ty_S_Prog_Node,
*      ty_T_Prog_Nodes type standard table of ty_S_Prog_Node with default key.
*
*    data:
*      key_Mappings       type LVC_T_ITON,
*      key_Task           type lvc_Nkey   value 1,
*      prog_Nodes         type ty_T_Prog_Nodes,
*      prog_Node          type ty_S_Prog_Node.
*
*    " get programs nodes to expand
*    key_Mappings = f_Tree_Ctrl->get_Index_To_Key_Mappings( ).
*    loop at f_Lines
*      into prog_Node-info
*      where
*        degree = gc_Info_Degree-program.
*
*      read table key_Mappings                         "#EC *
*        with key index = sy-tabix
*        into prog_Node-key.
*
*      if ( 0 ne sy-subrc ).
*        continue.
*      endif.
*
*      read table f_Lines
*        with key
*          degree =      gc_Info_Degree-class
*          ndx_Program = prog_Node-info-ndx_Program
*        transporting no fields.
*
*      if ( 0 ne sy-subrc ).
*        " not expanded yet
*        insert prog_Node into table prog_Nodes[].
*      endif.
*    endloop.
*
*    loop at prog_Nodes into prog_Node.
*      __Expand_Prog_Branch(
*        exporting
*          prog_Key =  prog_Node-key
*          prog_Info = prog_Node-info ).
*    endloop.
*
*    " toggle front end
*    f_Tree_Ctrl->expand_Node(
*      exporting
*        i_Node_Key =       key_Task
*        i_Level_Count =    2
*        i_Expand_Subtree = abap_True
*      exceptions
*        others = 1 ).
*    if ( 0 ne sy-subrc ).
*      clear sy-subrc.
*    endif.
*
*  endmethod.
*
*
*  method _Handle_User_Command.
** ==========================
*    case user_Command.
*      when c_Command-toggle_Counters.
*        f_Master->toggle_Style( ).
*      when others.
*        " okay
*    endcase.
*
*  endmethod.
*
*
*  method update_Style.
** ===================
*    " totals by verdict kind or verdict severity?
*    data:
*      lyt_Fields      type lvc_T_Fcat,
*      flag_Hide_Prio  type abap_Bool,
*      flag_Hide_Kind  type abap_Bool.
*    field-symbols:
*      <lyt_Field>     type lvc_S_Fcat.
*
*    " toggle counter marker
*    if ( abap_True eq f_Master->style_Prio ).
*      flag_Hide_Prio =  abap_False.
*      flag_Hide_Kind =  abap_True.
*    else.
*      flag_Hide_Prio =  abap_True.
*      flag_Hide_Kind =  abap_False.
*    endif.
*
*    " change visbility at frontend
*    f_Tree_Ctrl->get_Frontend_Fieldcatalog(
*      importing
*        et_Fieldcatalog = lyt_Fields[]
*      exceptions
*        others = 1 ).
*    if ( 0 ne sy-subrc ).
*      lyt_Fields = _Get_Field_Catalogue( ).
*    endif.
*
*    loop at lyt_Fields assigning <lyt_Field>
*      where fieldname(3) eq 'CNT'.
*      case <lyt_Field>-fieldname.
*
*        when c_Field_Name-cnt_Fatal       or
*             c_Field_Name-cnt_Critical    or
*             c_Field_Name-cnt_Tolerable   or
*             c_Field_Name-cnt_Info.
*          <lyt_Field>-no_Out = flag_Hide_Prio.
*
*        when c_Field_Name-cnt_Failure     or
*             c_Field_Name-cnt_Error       or
*             c_Field_Name-cnt_Shortdump   or
*             c_Field_Name-cnt_warning     or
*             c_Field_Name-cnt_Extended.
*          <lyt_Field>-no_Out = flag_Hide_Kind.
*
*      endcase.
*    endloop.
*
*    f_Tree_Ctrl->set_Frontend_Fieldcatalog( lyt_Fields ).
*
*    __Init_Buttons( ).
*    refresh_Display( ).
*
*  endmethod.
*
*
*  method __Init_Buttons.
** =====================
*    data:
*      all_Buttons   type ttb_Button,
*      cur_Button    like line of all_Buttons.
*
*    cur_Button-function =  c_Command-toggle_Counters.
*    cur_Button-icon =      icon_Active_Inactive.
*    if ( abap_True eq f_Master->style_Prio ).
*      cur_Button-quickinfo = 'Message Type View             '(TK1).
*      cur_Button-text =      'Message Type  '(TK2).
*    else.
*      cur_Button-quickinfo = 'Priority View'(tp1).
*      cur_Button-text =      'Priority'(tp2).
*    endif.
*
*    insert cur_Button into table all_Buttons[].
*
*    _Set_Custom_Buttons( all_Buttons[] ).
*
*  endmethod.
*
*
*  method __Expand_Prog_Branch.
** ===========================
*    data:
*      txt_Buffer           type lvc_value,
*      is_Child_Node        type abap_Bool,
*      key_Base             type lvc_Nkey,
*      key_Clas             type lvc_Nkey,
*      key_Meth             type lvc_Nkey.
*    field-symbols:
*      <prog_Data>        type ty_S_Prog_Data,
*      <class_Data>          type ty_S_Clas_Data,
*      <cur_Method>         type ty_S_Meth_Data.
*    field-symbols:
*      <info_Alert>         type ty_S_Base_Info,
*      <info_Class>         type ty_S_Base_Info,
*      <info_Method>        type ty_S_Base_Info.
*
*    read table f_Master->task-programs
*      index prog_Info-ndx_Program
*      assigning <prog_Data>.
*    if ( <prog_Data> is not assigned ).
*      return.
*    endif.
*
*    " check errors on program level
*    read table f_Master->data
*      assigning <info_Alert>
*      with key
*        ndx_Program = prog_Info-ndx_Program
*        degree =      gc_Info_Degree-program_Errors.
*
*    if ( 0 eq sy-subrc ).
*      txt_Buffer = <prog_Data>-info-name.
*      key_Clas = __Append_Base_Node(
*        parent_Key = prog_Key
*        is_Child =   abap_True
*        base_Data =  <info_Alert>
*        title =      txt_Buffer
*        icon =       fg_Icon-prog_Error ).
*    else.
*      clear key_Clas.
*    endif.
*
*    " add child nodes to display hierarchy
*    loop at f_Master->data
*      assigning <info_Class>
*      where
*        ndx_Program eq prog_Info-ndx_Program and
*        degree eq      gc_Info_Degree-class.
*
*      read table <prog_Data>-classes
*        index <info_Class>-ndx_Class
*        assigning <class_Data>.
*
*      txt_Buffer = <class_Data>-info-name.
*
*      " adding sibling is faster than adding child !!
*      if ( key_Clas is initial ).
*        key_Base = prog_Key.
*        is_Child_Node = abap_True.
*      else.
*        key_Base = key_Clas.
*        is_Child_Node = abap_False.
*      endif.
*      key_Clas = __Append_Base_Node(
*        parent_Key = key_Base
*        is_Child =   is_Child_Node
*        base_Data =  <info_Class>
*        title =      txt_Buffer
*        icon =       fg_Icon-class ).
*
*      " errors on class level
*      read table f_Master->data
*        assigning <info_Alert>
*        with key
*          ndx_Program = <info_Class>-ndx_Program
*          ndx_Class =   <info_Class>-ndx_Class
*          degree =      gc_Info_Degree-class_Errors.
*
*      if ( 0 eq sy-subrc ).
*        txt_Buffer = <class_Data>-info-name.
*        key_Meth = __Append_Base_Node(
*          parent_Key = key_Clas
*          is_Child =   abap_True
*          base_Data =  <info_Alert>
*          title =      txt_Buffer
*          icon =       fg_Icon-class_Error ).
*      else.
*        clear key_Meth.
*      endif.
*
*      " errors in attached methods
*      loop at f_Master->data
*        assigning <info_Method>
*        where
*          ndx_Program eq <info_Class>-ndx_Program and
*          ndx_Class   eq <info_Class>-ndx_Class   and
*          degree eq      gc_Info_Degree-method.
*
*        read table <class_Data>-methods
*          index <info_Method>-ndx_Method
*          assigning <cur_Method>.
*
*        txt_Buffer = <cur_Method>-info-name.
*
*        " adding sibling is faster than adding child !!
*        if ( key_Meth is initial ).
*          key_Base = key_Clas.
*          is_Child_Node = abap_True.
*        else.
*          key_Base = key_Meth.
*          is_Child_Node = abap_False.
*        endif.
*
*        key_Meth = __Append_Base_Node(
*          parent_Key = key_Base
*          is_Child =   is_Child_Node
*          base_Data =  <info_Method>
*          title =      txt_Buffer
*          icon =       fg_Icon-method ).
*
*      endloop.
*    endloop.
*
*  endmethod.
*
*
*  method set_Selected_Node_By_Detail.
** ==================================
*    data:
*      key_Navg       type lvc_Nkey,
*      node_Keys      type lvc_T_Nkey,
*      num_Index      type lvc_Index.
*    data:
*      key_Mappings       type lvc_T_Iton.
*
*    " required for lazy nodes
*    __Force_Prog_To_Be_Expanded( detail-ndx_Program ).
*
*
*    key_Mappings = f_Tree_Ctrl->get_Index_To_Key_Mappings( ).
*
*    " get the index in the underlying internal table.
*    read table f_Lines
*      with key
*        ndx_Program = detail-ndx_Program
*        degree =      gc_Info_Degree-program
*      transporting no fields.
*
*    if ( 0 eq sy-subrc ).
*      num_Index = sy-tabix.
*      read table f_Lines
*        with key
*          ndx_Program = detail-ndx_Program
*          ndx_Class =   detail-ndx_Class
*          degree =      gc_Info_Degree-class
*        transporting no fields.
*      if ( 0 eq sy-subrc ).
*        num_Index = sy-tabix.
*        read table f_Lines
*          with key
*            ndx_Program = detail-ndx_Program
*            ndx_Class =   detail-ndx_Class
*            ndx_Method =  detail-ndx_Method
*            degree =      gc_Info_Degree-method
*          transporting no fields.
*        if ( 0 eq sy-subrc ).
*          num_Index = sy-tabix.
*        endif.
*      endif.
*    else.
*      return.
*    endif.
*
*    " get the alv tree key - truncation of key is fitting our purpose
*    read table key_Mappings                                       "#EC *
*      with key !index  = num_Index
*      into key_Navg.
*    if ( 0 ne sy-subrc ).
*      return.
*    endif.
*
*    " set selected item
*    insert key_Navg into table node_Keys[].
*    f_Tree_Ctrl->unselect_All( ).
*    f_Tree_Ctrl->set_Selected_Nodes(
*      exporting
*        it_Selected_Nodes = node_Keys
*      exceptions
*        others =            0 ).
*
*  endmethod.
*
*
*  method __Get_Info_By_Node_Key.
** ===========================
*    field-symbols:
*      <cur_Index>   type lvc_S_Indx.
*    data:
*      key_Mappings       type LVC_T_ITON.
*
*    key_Mappings = f_Tree_Ctrl->get_Index_To_Key_Mappings( ).
*
*    " scan line in underlying memory table and query key by its index
*    key_Mappings = f_Tree_Ctrl->get_Index_To_Key_Mappings( ).
*
*    read table key_Mappings
*      with key node_Key = node_Key
*      assigning <cur_Index>.
*
*    if ( 0 eq sy-subrc ).
*      read table f_Lines
*        index <cur_Index>-index
*        into result.
*      if ( 0 eq sy-subrc ).
*        return.
*      endif.
*    endif.
*
*    clear result.
*
*  endmethod.
*
*
*  method __Append_Base_Node.
** =========================
*    data:
*      cur_Data like base_Data.
*
*    cur_Data = base_Data.
*    if ( 0 lt cur_Data-cnt_Alert ).
*      if ( cur_Data-cnt_Alert eq cur_Data-cnt_Tolerable ).
*        cur_Data-icon = fg_Icon-state-reservations.
*      else.
*        cur_Data-icon = fg_Icon-state-bad.
*      endif.
*    else.
*      cur_Data-icon =   fg_Icon-state-good.
*    endif.
*
*    if ( abap_True eq is_Child ).
*      key = f_Tree_Ctrl->append_Child_Node(
*        parent_Key =    parent_Key
*        data =          cur_Data
*        title =         !title
*        icon =          !icon
*        field_Layout =  f_Field_Layout_Infos ).
*    else.
*      key = f_Tree_Ctrl->Append_Sibling_Node(
*        previous_Key =  parent_Key
*        data =          cur_Data
*        title =         !title
*        icon =          !icon
*        field_Layout =  f_Field_Layout_Infos ).
*    endif.
*
*  endmethod.
*
*
*  method __Append_Lazy_Node.
** =========================
*  " nodes that contain child nodes in the beginning. these get added
*  " upon expansion. see handle_Expand_Node()
*    data:
*      cur_Data like base_Data.
*
*    cur_Data = base_Data.
*
*    if ( 0 lt cur_Data-cnt_Alert ).
*      if ( cur_Data-cnt_Alert eq cur_Data-cnt_Tolerable ).
*        cur_Data-icon = icon_Led_Yellow.
*      else.
*        cur_Data-icon = icon_Led_Red.
*      endif.
*    else.
*      cur_Data-icon = icon_Led_Green.
*    endif.
*
*    if ( abap_True eq is_Child ).
*      key = f_Tree_Ctrl->append_Child_Node(
*        parent_Key =  parent_Key
*        data =        cur_Data
*        title =       title
*        is_Folder =   abap_True
*        icon =          icon
*        field_Layout =  f_Field_Layout_Infos ).
*    else.
*      key = f_Tree_Ctrl->append_Sibling_Node(
*        previous_Key =  parent_Key
*        data =          cur_Data
*        title =         !title
*        is_Folder =     abap_True
*        icon =          icon
*        field_Layout =  f_Field_Layout_Infos ).
*    endif.
*
*  endmethod.
*
*  method  __add_Break_Point.
** =========================
*    data:
*      prog_Casted      type syrepid,
*      breakpoints      type breakpoints,
*      new_Breakpoints  type breakpoints,
*      breakpoint       type breakpoint,
*      positions        type cl_Saunit_Source_Info_Svc=>ty_T_Positions,
*      position         type cl_Saunit_Source_Info_Svc=>ty_S_Position.
*
*    positions = cl_Saunit_Source_Info_Svc=>get_Method_Positions(
*      prog_Name = prog_Name
*      class_Name = class_Name
*      options = 'W' ).
*    read table positions
*      into position
*      with key method_Name = method_Name.
*    if ( 0 ne sy-subrc ).
*      return.
*    endif.
*
*    prog_Casted = prog_Name.
*    if ( external is initial ).
*      cl_Abap_Debugger=>read_Breakpoints(
*        exporting
*          main_Program = prog_Casted
*        importing
*          breakpoints = breakpoints
*        exceptions
*          others = 1   ).
*    else.
*      cl_Abap_Debugger=>read_Http_Breakpoints(
*        exporting
*          main_Program = prog_Casted
*        importing
*          breakpoints = breakpoints
*        exceptions
*          others = 1   ).
*    endif.
*    if ( 0 ne sy-subrc or 29 < lines( breakpoints ) ).
*      " error or limit
*      return.
*    endif.
*
*    breakpoint-program = position-include.
*    breakpoint-line =    position-line.
*
*    read table breakpoints
*      with key table_line = breakpoint
*      transporting no fields.
*    if ( 0 eq sy-subrc ).
*      " already there
*      success = abap_True.
*      return.
*    endif.
*
*    insert breakpoint into table breakpoints.
*    if ( external is initial ).
*      " only works for session point active immediatley
*      cl_Abap_Debugger=>save_Breakpoints(
*        exporting
*          main_Program = prog_Casted
*          breakpoints =  breakpoints
*        exceptions
*          others = 1   ).
*    else.
*      " somehow they are effective to late
*      cl_Abap_Debugger=>save_Http_Breakpoints(
*        exporting
*          main_Program = prog_Casted
*          breakpoints =  breakpoints
*        exceptions
*          others = 1   ).
*    endif.
*    if ( 0 ne sy-subrc  ).
*      return.
*    endif.
*
*    " remember break-point to unset later - as the breakpoint line
*    " number can changed ( move to the next executable line )
*    " the delta needs to be analysed
*    if ( external is initial ).
*      cl_Abap_Debugger=>read_Breakpoints(
*        exporting
*          main_Program = prog_Casted
*        importing
*          breakpoints = new_Breakpoints
*        exceptions
*          others = 1   ).
*    else.
*      cl_Abap_Debugger=>read_Http_Breakpoints(
*        exporting
*          main_Program = prog_Casted
*        importing
*          breakpoints = new_Breakpoints
*        exceptions
*          others = 1   ).
*    endif.
*
*    loop at breakpoints into breakpoint.
*      delete new_Breakpoints where table_Line = breakpoint.
*    endloop.
*    insert lines of new_Breakpoints into table f_Breakpoints.
*    success = abap_True.
*
*  endmethod.
*
*
*  method __Reset_Break_Points.
** ============================
*    data:
*      do_Save        type abap_Bool,
*      prog_Casted    type syrepid,
*      breakpoints    type breakpoints,
*      breakpoint     type breakpoint.
*
*    if ( f_Breakpoints is initial ).
*      return.
*    endif.
*
*    prog_Casted = prog_Name.
*    if ( external is initial ).
*      cl_Abap_Debugger=>read_Breakpoints(
*        exporting
*          main_Program = prog_Casted
*        importing
*          breakpoints = breakpoints
*        exceptions
*          others = 1   ).
*    else.
*      cl_Abap_Debugger=>read_Http_Breakpoints(
*        exporting
*          main_Program = prog_Casted
*        importing
*          breakpoints = breakpoints
*        exceptions
*          others = 1   ).
*    endif.
*    if ( 0 ne sy-subrc  ).
*      clear f_Breakpoints.
*      " error or limit
*      return.
*    endif.
*
*    loop at f_Breakpoints into breakpoint.
*      delete breakpoints where
*        table_line = breakpoint.
*      if ( 0 eq sy-subrc ).
*        do_Save = abap_True.
*      endif.
*    endloop.
*
*    clear f_Breakpoints.
*
*    if ( abap_True eq do_Save ).
*      if ( external is initial ).
*        cl_Abap_Debugger=>save_Breakpoints(
*          exporting
*            main_Program = prog_Casted
*            breakpoints =  breakpoints
*          exceptions
*            others = 0  ).
*      else.
*        cl_Abap_Debugger=>save_Http_Breakpoints(
*          exporting
*            main_Program = prog_Casted
*            breakpoints =  breakpoints
*          exceptions
*            others = 0  ).
*      endif.
*    endif.
*
*  endmethod.
*
*
*  method __Force_Prog_To_Be_Expanded.
** ==================================
*  " the tree control offers not reasonable - okay suitable API
*  " for expanding lazy nodes via a single call
*  " so we check if there are child nodes, if there shall be child nodes
*  " and finally create missing child nodes - ARGHHH!
*    data:
*      key_Prog         type lvc_Nkey,
*      num_Index        type lvc_Index.
*    data:
*      key_Mappings     type lvc_T_Iton.
*    field-symbols:
*      <prog_Info>      type ty_S_Base_Info,
*      <prog_Data>      type ty_S_Prog_Data.
*
*    " get program node
*    read table f_Lines
*      with key
*        ndx_Program = prog_Index
*        degree =      gc_Info_Degree-program
*      assigning <prog_Info>.
*    if ( 0 ne sy-subrc ).
*      return.
*    endif.
*    num_Index = sy-tabix.
*
*    " are there child nodes of type class ?
*    read table f_Lines
*      with key
*        ndx_Program = prog_Index
*        degree =      gc_Info_Degree-class
*      transporting no fields.
*    if ( 0 eq sy-subrc ).
*      return.
*    endif.
*
*    " has the program test classes
*    read table f_Master->task-programs
*      index prog_Index
*      assigning <prog_Data>.
*    if ( 0 ne sy-subrc or <prog_Data>-classes is initial ).
*      return.
*    endif.
*
*    " get the alv tree key - truncation of key is fitting our purpose
*    key_Mappings = f_Tree_Ctrl->get_Index_To_Key_Mappings( ).
*    read table key_Mappings                                       "#EC *
*      with key !index  = num_Index
*      into key_Prog.
*    if ( 0 ne sy-subrc or key_Prog is initial ).
*      return.
*    endif.
*
*    __Expand_Prog_Branch(
*      prog_Key = key_Prog
*      prog_Info = <prog_Info> ).
*
*  endmethod.
*
*
*endclass.
