**-----------------------------------------------------------------------
**
**  include:  LAUNIT_TREE_CTRL_LISTENERF55
**
**  created:  21.Aug.2003
**
**-----------------------------------------------------------------------
**
**  purpose: display details as list tree, there a two rootlike nodes
**           - analysis
**           - call stack
**           when building the tree both kinds share a unique format
**           including the nesting level, leaving those dull GUI API
**           as the only obstacle to manage here.
**           the list tree has been chosen over alv because it offers
**           to define a equi distance font which is required for a
**           human readable diff output
**-----------------------------------------------------------------------
*
*
*class message_Tree_Ctrl implementation.
*
*  method constructor.
**  =================
*    super->constructor( ).
*    _Init_Instance( container = container ).
*    f_Master = master.
*
*  endmethod.
*
*
*  method build_Tree_Data.
**  =====================
*  " set the content of the tree
*
*    types:
*      begin of _Ty_S_Indent_Key,
*        indent  type i,
*        key     type lvc_Nkey,
*      end of _Ty_S_Indent_Key,
*      _Ty_T_Indent_Keys   type sorted table of _Ty_S_Indent_Key
*                                            with unique key indent.
*
*    data:
*      inf_Initial_Alert   type     ty_S_Alert_Data.
*    data:
*      txt_Key_Line        type     lvc_Nkey,
*      indent_Keys         type     _Ty_T_Indent_Keys,
*      indent_Key          type     _Ty_S_Indent_Key.
*    data:
*      cur_Message         type     ty_S_Message_Info.
*    data:
*      all_Nodes           type     treev_Ntab,
*      all_Items           type     table of saunit_S_Tree_Item_Message,
*      inf_Node            type     treev_Node,
*      inf_Item            type     saunit_S_Tree_Item_Message,
*      l_Str               type     string,
*      node_Key            like     inf_Item-node_Key.
*    field-symbols:
*      <ext_Info>          type     ty_S_Ext_Info,
*      <cur_Message>       type     ty_S_Message_Info,
*      <cur_Alert>         type     ty_S_Alert_Data,
*      <cur_Program>       type     ty_S_Prog_Data,
*      <cur_Class>         type     ty_S_Clas_Data,
*      <cur_Method>        type     ty_S_Meth_Data.
*
*    constants:
*      c_Infos             type     tv_Nodekey   value 'Infos',    "#EC *
*      c_Stack             type     tv_Nodekey   value 'Stack'.    "#EC *
*
*    _Clear_Content( ).
*
*    clear:
*      f_Info_Messages[],
*      f_Stack_Messages[].
*
*    " get messages ( no error handling, but there should be none )
*    if ( p_Detail-kind eq gc_Alert_Kind-extended_Info ).
*      read table f_Master->task-extended_Infos index p_Detail-ndx_Alert
*        assigning <ext_Info>.
*      f_Info_Messages =
*        f_Master->converter->get_Messages_For_Extended_Info(
*          ndx_Info = p_Detail-ndx_Alert
*          ext_Info = <ext_Info> ).
*    else.
*      case p_Detail-degree.
*
*        when gc_Info_Degree-initial.
*          assign inf_Initial_Alert to <cur_Alert>.
*
*        when gc_Info_Degree-task or gc_Info_Degree-task_Errors.
*          read table f_Master->task-alerts[]
*            index p_Detail-ndx_Alert assigning <cur_Alert>.
*          if ( 0 ne sy-subrc ).
*            assign inf_Initial_Alert to <cur_Alert>.
*          endif.
*
*        when gc_Info_Degree-program or gc_Info_Degree-program_Errors.
*          read table f_Master->task-programs[]
*            index p_Detail-ndx_Program assigning <cur_Program>.
*          read table <cur_Program>-alerts[]
*            index p_Detail-ndx_Alert   assigning <cur_Alert>.
*
*        when gc_Info_Degree-class or gc_Info_Degree-class_Errors.
*          read table f_Master->task-programs[]
*            index p_Detail-ndx_Program assigning <cur_Program>.
*          read table <cur_Program>-classes[]
*            index p_Detail-ndx_Class   assigning <cur_Class>.
*          read table <cur_Class>-alerts[]
*            index p_Detail-ndx_Alert   assigning <cur_Alert>.
*
*        when gc_Info_Degree-method.
*          read table f_Master->task-programs[]
*            index p_Detail-ndx_Program assigning <cur_Program>.
*          read table <cur_Program>-classes[]
*            index p_Detail-ndx_Class   assigning <cur_Class>.
*          read table <cur_Class>-methods[]
*            index p_Detail-ndx_Method  assigning <cur_Method>.
*          read table <cur_Method>-alerts[]
*            index p_Detail-ndx_Alert   assigning <cur_Alert>.
*
*        when others.
*          " bad Detail Level
*          assert 1 = 2.
*
*      endcase.
*
*      " there are 2 basic entry kinds analysis and stack,
*      " the later is optional
*      f_Master->converter->get_Messages_For_Alert(
*        exporting
*          alert =        <cur_Alert>
*        importing
*          text_Infos =   f_Info_Messages[]
*          stack_Lines =  f_Stack_Messages[] ).
*    endif.
*
*    " (root) node with key 'Infos'
*    clear inf_Node.
*    inf_Node-node_Key = c_Infos.
*    clear inf_Node-relatkey.
*    clear inf_Node-relatship.
*    inf_Node-isfolder = 'X'.
*    inf_Node-n_Image = icon_Detail.
*    inf_Node-exp_Image = icon_Detail.
*    insert inf_Node into table all_Nodes.
*    " item of info node
*    clear inf_Item.
*    inf_Item-node_Key =  c_Infos.
*    inf_Item-item_Name = '1'.
*    inf_Item-class = cl_Gui_List_Tree=>item_Class_Text.
*    inf_Item-alignment = cl_Gui_List_Tree=>align_Auto.
*    inf_Item-font = cl_Gui_List_Tree=>item_Font_Prop.
*    inf_Item-text = 'Info                '(mif).
*    insert inf_Item into table all_Items.
*
*    " no messages? display special info...
*    if ( 1 > lines( f_Info_Messages[] ) ).
*        cur_Message-text =
*          'There are no detailed informations for this item'(nda).
*        clear inf_Node.
*        inf_Node-node_Key = 'Info_1'.                        "#EC NOTEXT
*        inf_Node-relatkey = c_Infos.
*        inf_Node-relatship = cl_Gui_List_Tree=>relat_Last_Child.
*        inf_Node-n_Image = icon_Information.
*        clear inf_Node-isfolder.
*        insert inf_Node into table all_Nodes.
*        "   item of info message
*        clear inf_Item.
*        inf_Item-node_Key = 'Info_1'.                        "#EC NOTEXT
*        inf_Item-item_Name = 1.
*        inf_Item-class = cl_Gui_List_Tree=>item_Class_Text.
*        inf_Item-length = 256.
*        inf_Item-alignment = cl_Gui_List_Tree=>align_Auto.
*        inf_Item-font = cl_Gui_List_Tree=>item_Font_Fixed.
*        inf_Item-text = cur_Message-text.
*        insert inf_Item into table all_Items.
*    endif.
*
*    " subnodes of info root node
*    loop at f_Info_Messages[] assigning <cur_Message>.
*      l_Str = sy-tabix.
*      if ( <cur_Message>-indent eq 0 ).
*        clear: indent_Keys[].
*        txt_Key_Line =     c_Infos.
*        indent_Key-indent = 1.
*      else.
*        delete indent_Keys[] where indent > <cur_Message>-indent.
*        read table indent_Keys[]
*          with table key indent = <cur_Message>-indent
*          into indent_Key.
*        assert 0 eq sy-subrc.   " bad indention - tool error
*        txt_Key_Line = indent_Key-key.
*        add 1 to indent_Key-indent.
*      endif.
*
*      " node key contains message index (need this for double click)
*      concatenate 'Info_' l_Str into node_Key.               "#EC NOTEXT
*      indent_Key-key = node_Key.
*      insert indent_Key into table indent_Keys[].
*     "subnode no. l_Str of info node; father is txt_Key_Line
*      clear inf_Node.
*      inf_Node-node_Key = node_Key.                          "#EC NOTEXT
*      inf_Node-relatkey = txt_Key_Line.
*      inf_Node-isfolder = abap_True.
*     "inf_Node-relatship = cl_Saunit_Ui_List_Tree=>relat_Last_Child.
*      inf_Node-n_Image =   'BNONE'.
*      inf_Node-exp_Image = 'BNONE'.
*      insert inf_Node into table all_Nodes.
*     "item of this subnode (fixed font)
*      clear inf_Item.
*      inf_Item-node_Key = node_Key.
*      inf_Item-item_Name = 1.
*      inf_Item-length = 256.
*      inf_Item-alignment = cl_Gui_List_Tree=>align_Auto.
*      inf_Item-font = cl_Gui_List_Tree=>item_Font_Fixed.
*      inf_Item-text = <cur_Message>-text.
*      if <cur_Message>-is_Link is not initial.
*        inf_Item-style = cl_Gui_List_Tree=>style_Intensified.
*        inf_Item-class = cl_Gui_List_Tree=>item_Class_Link.
*      else.
*        inf_Item-style = cl_Gui_List_Tree=>style_Default.
*        inf_Item-class = cl_Gui_List_Tree=>item_Class_Text.
*      endif.
*      insert inf_Item into table all_Items.
*    endloop.
*
*    " node with key 'Stack' (only needed if there are stack messages)
*    if ( 0 < lines( f_Stack_Messages[] ) ).
*      "   stack (root) node
*      clear inf_Node.
*      inf_Node-node_Key = c_Stack.
*      clear inf_Node-relatkey.
*      clear inf_Node-relatship.
*      inf_Node-isfolder =  abap_True.
*      inf_Node-n_Image =   icon_Stack.
*      inf_Node-exp_Image = icon_Stack.
*      insert inf_Node into table all_Nodes.
*      "  stack item
*      clear inf_Item.
*      inf_Item-node_Key =  c_Stack.
*      inf_Item-item_Name = '1'.
*      inf_Item-class =     cl_Gui_List_Tree=>item_Class_Text.
*      inf_Item-alignment = cl_Gui_List_Tree=>align_Auto.
*      inf_Item-font =      cl_Gui_List_Tree=>item_Font_Prop.
*      inf_Item-text =      'Stack'(mst).
*      insert inf_Item into table all_Items.
*    endif.
*
*    " subnodes of stack root node
*    loop at f_Stack_Messages[] assigning <cur_Message>.
*      l_Str = sy-tabix.
*      concatenate 'Stack_' l_Str into node_Key.              "#EC NOTEXT
*      " subnode of stack node
*      clear inf_Node.
*      inf_Node-node_Key = node_Key.
*      inf_Node-relatkey =   c_Stack.
*      inf_Node-relatship =  cl_Gui_List_Tree=>relat_Last_Child.
*      inf_Node-n_Image =    'BNONE'.
*      inf_Node-exp_Image =  'BNONE'.
*      insert inf_Node into table all_Nodes.
*      " item of this subnode
*      clear inf_Item.
*      inf_Item-node_Key = node_Key.
*      inf_Item-item_Name = 1.
*      inf_Item-length =    256.
*      inf_Item-alignment = cl_Gui_List_Tree=>align_Auto.
*      inf_Item-font =      cl_Gui_List_Tree=>item_Font_Fixed.
*      inf_Item-text =      <cur_Message>-text.
*      if <cur_Message>-is_Link is not initial.
*        inf_Item-style = cl_Gui_List_Tree=>style_Intensified.
*        inf_Item-class = cl_Gui_List_Tree=>item_Class_Link.
*      else.
*        inf_Item-style = cl_Gui_List_Tree=>style_Default.
*        inf_Item-class = cl_Gui_List_Tree=>item_Class_Text.
*      endif.
*      insert inf_Item into table all_Items.
*    endloop.
*
*    " ...and go...
*    f_Tree_Ctrl->add_Nodes_And_Items(
*      exporting
*        node_Table                     = all_Nodes
*        item_Table                     = all_Items
*        item_Table_Structure_Name      = 'SAUNIT_S_TREE_ITEM_MESSAGE'
*      exceptions
*        failed                         = 1
*        cntl_System_Error              = 2
*        error_In_Tables                = 3
*        dp_Error                       = 4
*        table_Structure_Name_Not_Found = 5
*        others                         = 6 ).
*    assert 0 eq sy-subrc.
*
*    f_Tree_Ctrl->expand_Root_Nodes( ).
*
*  endmethod.
*
*
*  method _Handle_Double_Click.
** ===========================
*  " double click on stack entry      => display include
*  " double click on extend info link => dispatch to extension
*
*    data:
*      xpt_Caught         type ref to cx_Root,
*      txt_Include_Casted type trdir-name,
*      position           type i,
*      idx                type int4,
*      ext_Info           type ty_S_Ext_Info.
*
*    field-symbols:
*      <message>    type ty_S_Message_Info.
*
*    if node_Key(4) = 'Info'.                                 "#EC NOTEXT
*      if strlen( node_Key ) gt 5.
*        idx = node_Key+5.
*        read table f_Info_Messages index idx assigning <message>.
*      else.
*        exit.
*      endif.
*    elseif node_Key(5) = 'Stack'.                            "#EC NOTEXT
*      if strlen( node_Key ) gt 6.
*        idx = node_Key+6.
*      read table f_Stack_Messages index idx assigning <message>.
*      else.
*        exit.
*      endif.
*    else.
*      exit.
*    endif.
*
*    if <message> is not assigned.
*      exit.
*    endif.
*
*    if ( <message>-line < 1 ).
*      position = 1.
*    else.
*      position = <message>-line.
*    endif.
*
*    if ( <message>-include is not initial ).
*      txt_Include_Casted = <message>-include.
*      call function 'RS_TOOL_ACCESS'
*        exporting
*          operation =     'SHOW'
*          object_Type =   'PROG'
*          include =       txt_Include_Casted
*          position =      position
*          in_New_Window = abap_False
*        exceptions
*          others =         1.
*      if ( 0 ne sy-subrc and sy-msgid is not initial ).
*        message
*          id     sy-msgid
*          type   'S'
*          number sy-msgno
*          display like sy-msgty
*          with sy-msgv1 sy-msgv1 sy-msgv3 sy-msgv4.
*      endif.
*    elseif ( <message>-document is not initial ).
*      __Display_Document( <message>-document ).
*
*    elseif ( <message>-ndx_Info is not initial and
*            f_Master->mediator is bound ).
*      read table
*        f_Master->task-extended_Infos
*        index <message>-ndx_Info
*        into ext_Info.
*      if ( 0 eq sy-subrc ).
*        " extensions handle (e.g. coverage results) handle navigation
*        " on their own.
*        try.
*          f_Master->mediator->do_Navigation( ext_Info ).
*        catch cx_Root into xpt_Caught.                            "#EC *
*          do 3 times.
*            message xpt_Caught type 'I' display like 'E'.
*            xpt_Caught = xpt_Caught->previous.
*            if ( xpt_Caught is not bound ).
*              exit. "do.
*            endif.
*          enddo.
*        endtry.
*      endif.
*    endif.
*
*  endmethod.
*
*
*  method __Display_Document.
** =========================
*    data:
*      type  type doku_Class,
*      name  type doku_Oname,
*      !text type string.
*
*    split document at '.' into type name.
*    call function 'DSYS_SHOW'
*      exporting
*        dokclass = type
*        doklangu = sy-langu
*        dokname  = name
*        doktitle = ' '
*      exceptions
*        others = 1.
*    if ( 0 eq sy-subrc ).
*      return.
*    endif.
*
*    if ( 'E' ne sy-langu ).
*      call function 'DSYS_SHOW'
*        exporting
*          dokclass = type
*          doklangu = 'E'
*          dokname  = name
*          doktitle = ' '
*        exceptions
*          others = 1.
*      if ( 0 eq sy-subrc ).
*        return.
*      endif.
*    endif.
*
*    if ( 'D' ne sy-langu ).
*      call function 'DSYS_SHOW'
*        exporting
*          dokclass = type
*          doklangu = 'D'
*          dokname  = name
*          doktitle = ' '
*        exceptions
*          others = 1.
*      if ( 0 eq sy-subrc ).
*        return.
*      endif.
*    endif.
*
*    text = 'Document [&|&] is not available'(ndc).
*    replace '&' in text with type.
*    replace '&' in text with name.
*    message text type 'S' display like 'I'.
*
*  endmethod.
*
*endclass.
