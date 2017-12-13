**-----------------------------------------------------------------------
**
**  include:  LSAUNIT_TREE_CTRL_LISTENERF53
**
**-----------------------------------------------------------------------
*
*class detail_Grid_Ctrl implementation.
*
*  method constructor.
** ==================
*    data:
*      mediator_Setting  type if_Saunit_Extended_Ui_Mediator=>ty_S_Ui_Setting,
*      lines_ref         type ref to ty_T_Detail_Infos,
*      handler_Options   type string,
*      alv_Layout        type lVC_S_Layo.
*
*    super->Constructor( ).
*
*    " lazy class data initialization - necessary due translation
*    if ( abap_False eq fg_Icon-init_Done ).
*      concatenate
*        fg_Icon-fatal(3)    `\Q `   'Fatal'(TFT) ' @'             "#EC *
*        into fg_Icon-fatal.
*      concatenate
*        fg_Icon-critical(3) `\Q `    'Critical'(TCR) ' @'         "#EC *
*        into fg_Icon-critical.
*      concatenate
*        fg_Icon-tolerable(3)   `\Q ` 'Tolerable'(TTL) ' @'        "#EC *
*        into fg_Icon-tolerable.
*      concatenate
*        fg_Icon-execution_Event(3)   `\Q ` 'Message'(MSG) ' @'    "#EC *
*        into fg_Icon-execution_Event.
*      concatenate
*        fg_Icon-warning(3)     `\Q ` 'Warning'(TWN) ' @'          "#EC *
*        into fg_Icon-warning.
*      concatenate
*        fg_Icon-shortDump(3)   `\Q ` 'Runtime abortion'(TSD) ' @' "#EC *
*        into fg_Icon-shortdump.
*      concatenate
*        fg_Icon-error(3)   `\Q `     'Exception Error'(TPE) ' @'  "#EC *
*        into fg_Icon-error.
*      concatenate
*        fg_Icon-failure(3)   `\Q `   'Check assumption'(TCA) ' @' "#EC *
*        into fg_Icon-failure.
*      concatenate
*        fg_Icon-information(3) `\Q ` 'Information'(INF) ' @'      "#EC *
*        into fg_Icon-information.
*      fg_Icon-init_Done = abap_True.
*    endif.
*
*    " copy params to attributes
*    f_Master = Master.
*    handler_Options = if_Sat_Ui_Tree=>c_Handle_Double_click.
*
*    alv_Layout-smallTitle =    abap_True.
*    " alv_Layout-Zebra =         abap_True.
*    " alv_Layout-cWidth_Opt =    abap_True.
*
*    " icons for instance only
*    if ( f_Master->mediator is bound ).
*      mediator_Setting = f_Master->mediator->get_Display_Setting( ).
*
*      if ( mediator_Setting-icon_Severity is not initial ).
*        f_Icon-extended_Info = mediator_Setting-icon_Severity.
*      endif.
*
*      if ( strlen( f_Icon-extended_Info ) < 5 ).
*        if ( mediator_Setting-column_Title is not initial ).
*          concatenate
*            f_Icon-extended_Info(3) `\Q `
*            mediator_Setting-column_Title ' @'
*            into f_Icon-extended_Info.
*        else.
*          concatenate
*           f_Icon-extended_Info(3) `\Q ` 'Extended info'(INX) ' @'
*           into f_Icon-extended_Info.
*        endif.
*      endif.
*    endif.
*
*    get reference of f_Lines into lines_Ref.
*    _init_Instance(
*      container =               container
*      handler_Options =         handler_Options
*      layout =                  alv_Layout
*      header_Title =            'Alerts and Messages'(Exc)
*      content_Table_Reference = lines_Ref ).
*
*  endmethod.
*
*
*  method update_Style.
** ===================
*    data:
*      layout_Of_Fields      type lvc_T_Fcat,
*      flag_Hide_Prio  type abap_Bool,
*      flag_Hide_Kind  type abap_Bool.
*
*    field-symbols:
*      <layout_Field>    type lvc_S_Fcat.
*
*    " toggle counter marker - reverse base style !!
*    if ( abap_True eq f_Master->style_Prio ).
*      flag_Hide_Prio =  abap_True.
*      flag_Hide_Kind =  abap_False.
*    else.
*      flag_Hide_Prio =  abap_False.
*      flag_Hide_Kind =  abap_True.
*    endif.
*
*    " modify definiton at frontend
*    if ( abap_True eq at_Front_End ).
*      f_Grid_Ctrl->get_Frontend_FieldCatalog(
*        importing
*          et_FieldCatalog = layout_Of_Fields[]
*        exceptions
*          others          = 1 ).
*      if ( 0 ne sy-subrc ).
*        layout_Of_Fields = _Get_Field_Catalogue( ).
*      endif.
*
*      loop at layout_Of_Fields assigning <layout_Field>
*        where fieldName(4) eq 'ICON'.                        "#EC NOTEXT
*        case <layout_Field>-fieldName.
*          when c_Field_Name-icon_Level.
*            <layout_Field>-No_Out = flag_Hide_Prio.
*
*          when c_Field_Name-icon_Kind.
*            <layout_Field>-No_Out = flag_Hide_Kind.
*
*        endcase.
*      endloop.
*      f_Grid_Ctrl->set_Frontend_FieldCatalog( layout_Of_Fields ).
*    endif.
*
*    " modify definiton at frontend
*    if ( abap_True eq at_Back_End ).
*      layout_Of_Fields = _Get_Field_Catalogue( ).
*      loop at layout_Of_Fields assigning <layout_Field>
*        where fieldName(4) eq 'ICON'.                        "#EC NOTEXT
*        case <layout_Field>-fieldName.
*          when c_Field_Name-icon_Level.
*            <layout_Field>-no_Out = flag_Hide_Prio.
*
*          when c_Field_Name-icon_Kind.
*            <layout_Field>-no_Out = flag_Hide_Kind.
*
*        endcase.
*      endloop.
*      f_Grid_Ctrl->change_Field_Catalogue( layout_Of_Fields ).
*
*    endif.
*
*    refresh_Display( ).
*
*  endmethod.
*
*
*  method _Get_Field_Catalogue.
** ===========================
*  " build the initial field catalogue
*    data:
*      layout_Field like line of result.
*    data:
*      keep_In_Sync    type ty_S_Detail_Info.                 "#EC NEEDED
*
*    if ( _Fg_Field_Catalogue is initial ).
*      "   keep in sync with the type definition of ty_S_Detail_Info.
*      "  scan for #DETAIL_INFO# to find related source code
*      clear layout_Field.
*      layout_Field-col_Pos =       1.
*      layout_Field-fieldName =     c_Field_Name-icon_Level.
*      layout_Field-intType =       'C'.
*      layout_Field-selText =
*        layout_Field-colText =     'Prio'(LVL).
*      layout_Field-OutputLen =     6.
*
*      layout_Field-icon =          abap_True.
*      " reversed style !!
*      if ( abap_True eq f_Master->style_Prio ).
*        layout_Field-No_Out = abap_True.
*      else.
*        layout_Field-No_Out = abap_False.
*      endif.
*      layout_Field-style =            cl_Gui_Alv_Grid=>mc_Style_Hotspot.
*      insert layout_Field into table _Fg_Field_Catalogue[].
*
*      clear layout_Field.
*      layout_Field-col_Pos =       2.
*      layout_Field-fieldName =     c_Field_Name-icon_Kind.
*      layout_Field-intType =       'C'.
*      layout_Field-selText =
*        layout_Field-colText =     'Type'(Knd).
*      layout_Field-OutputLen =     6.
*      layout_Field-icon =          abap_True.
*      " reversed style !!
*      if ( abap_True eq f_Master->style_Prio ).
*        layout_Field-No_Out = abap_False.
*      else.
*        layout_Field-No_Out = abap_True.
*      endif.
*      layout_Field-style =         cl_Gui_Alv_Grid=>mc_Style_Hotspot.
*      insert layout_Field into table _Fg_Field_Catalogue[].
*
*      clear layout_Field.
*      layout_Field-col_Pos =       3.
*      layout_Field-fieldName =     c_Field_Name-Header.
*      layout_Field-intType =       'g'.
*      layout_Field-selText =
*        layout_Field-colText =     'Message'(MSG).
*      layout_Field-OutputLen =     80.
*      layout_Field-style =         cl_Gui_Alv_Grid=>mc_Style_Hotspot.
*      insert layout_Field into table _Fg_Field_Catalogue[].
*
*    endif.
*
*    result = _Fg_Field_Catalogue.
*
*  endmethod.
*
*
*  method set_List_Data.
** ====================
*  " set the content
*    data:
*      dat_Line_Temp like line of content_Lines,
*      dat_Lines     like content_Lines.
*    field-symbols:
*      <dat_Line> like line of content_Lines.
*
*    " change the icons
*    dat_Lines = content_Lines[].
*
*    loop at dat_Lines assigning <dat_Line>.
*      case <dat_Line>-Level.
*
*        when gc_Alert_Level-fatal.
*          <dat_Line>-icon_Level = fg_Icon-fatal.
*
*        when gc_Alert_Level-critical.
*          <dat_Line>-icon_Level = fg_Icon-critical.
*
*        when gc_Alert_Level-tolerable.
*          <dat_Line>-icon_Level = fg_Icon-tolerable.
*
*        when others.
*          <dat_Line>-icon_Level = fg_Icon-information.
*      endcase.
*
*      case <dat_Line>-kind.
*
*        when gc_Alert_Kind-error.
*          <dat_Line>-icon_Kind = fg_Icon-error.
*
*        when gc_Alert_Kind-failure.
*          <dat_Line>-icon_Kind = fg_Icon-failure.
*
*        when gc_Alert_Kind-shortDump.
*          <dat_Line>-icon_Kind = fg_Icon-shortdump.
*
*        when gc_Alert_Kind-warning.
*          <dat_Line>-icon_Kind = fg_Icon-warning.
*
*        when gc_Alert_Kind-extended_Info.
*          <dat_Line>-icon_Kind = f_Icon-extended_Info.
*
*        when others.
*          <dat_Line>-icon_Kind = fg_Icon-execution_Event.
*
*      endcase.
*
*    endloop.
*
*    " and there we go to the screen
*    f_Lines = dat_Lines.
*    refresh_Display( ).
*
*    " update messages pane and create a info line if no alert is selected
*    read table dat_Lines[] index 1 assigning <dat_Line>.
*    if ( <dat_Line> is assigned ).
*      f_Master->message_Tree->build_Tree_Data( <dat_Line> ).
*    else.
*      dat_Line_Temp-icon_Level =   icon_Information.
*      dat_Line_Temp-Header =
*        'There are no detailed informations for this test'(NMG).
*      insert dat_Line_Temp into table dat_Lines[].
*      f_Master->message_Tree->build_Tree_Data( ).
*    endif.
*
*  endmethod.
*
*
*  method _Handle_Double_Click.
** ===========================
*    data:
*      one_Detail   type ty_S_Detail_Info,
*      index        type i.
*
*    index = row-index.
*
*    read table f_Lines index !index into one_Detail.
*    if ( one_Detail is initial ).
*      f_Master->message_Tree->build_Tree_Data(  ).
*    else.
*      f_Master->message_Tree->build_Tree_Data( one_Detail ).
*      f_Master->base_Tree->set_Selected_Node_By_Detail( one_Detail ).
*    endif.
*
*  endmethod.
*
*endclass.
