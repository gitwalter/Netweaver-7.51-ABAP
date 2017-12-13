**-----------------------------------------------------------------------
**
**  include:  LAUNIT_TREE_CTRL_LISTENERF57
**
**  Created:  22.Aug.2003
**
**-----------------------------------------------------------------------
**
**  purpose:  result download to workstation. as this functionality
**            is using plain serialization of internal data types this
**            approach will not stand the test of time. never ever use
**            it for persisting data at customer suite.
**
**-----------------------------------------------------------------------
*
*
*class file_Access_Svc implementation.
*
*
*  method export_Intern_Format.
** ===========================
*  " export program format to buffer
*    data:
*      chosen_Action    type   i,
*      temp_Counter     type   i,
*      byte_Length      type   i,
*      txt_Buffer       type   sychar32,
*      one_Char         type   sychar01,
*      file_Extension   type   sychar04,
*      dialog_Title     type   string,
*      default_Name     type   string,
*      file_Name        type   string,
*      path_Name        type   string,
*      full_Name        type   string,
*      serialized_Info  type   saunit_D_Serialized_Data,
*      serialized_Line  type   ty_D_Xline,
*      serialized_Lines type   ty_T_Xlines.
*
*    " precheck and init
*    describe field serialized_Line length temp_Counter in byte mode.
*    if ( temp_Counter ne c_S_Xline_Len ).
*      " internal error
*      assert 1 = 2.
*    endif.
*
*    " build file name
*    txt_Buffer = p_Master->task-info-name.
*    translate txt_Buffer to upper case.                           "#EC *
*    temp_Counter = 0.
*    do 32 times.
*      one_Char = txt_Buffer+temp_Counter(1).
*      if ( '_01234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ' cs one_Char and
*           '' ne one_Char ).
*        concatenate
*          default_Name p_Master->task-info-name+temp_Counter(1)
*          into default_Name.
*      endif.
*      add 1 to temp_Counter.
*    enddo.
*    if ( 0 = strlen( default_Name ) ).
*      default_Name = 'ABAP_UNIT'.                            "#EC NOTEXT
*    endif.
*
*    " query user
*    dialog_Title = 'Save Results in Local file'(sav).
*    while
*      c_Extension_Serialized ne file_Extension   and
*      c_Extension_Xml        ne file_Extension.
*
*      cl_Gui_Frontend_Services=>file_Save_Dialog(
*        exporting
*          window_Title      = dialog_Title
*          default_File_Name = default_Name
*          default_Extension = c_Extension_Serialized
*          file_Filter       = c_File_Filter
*          initial_Directory = 'C:\'                          "#EC NOTEXT
*        changing
*          path =              path_Name
*          filename          = file_Name
*          fullpath          = full_Name
*          user_Action       = chosen_Action ).
*      if ( cl_Gui_Frontend_Services=>action_Cancel eq chosen_Action or
*           file_Name is initial ).
*        return.
*      endif.
*      temp_Counter = strlen( file_Name  ).
*      if ( 4 < temp_Counter ).
*        temp_Counter = temp_Counter - 4.
*        file_Extension = file_Name+temp_Counter(4).
*        translate file_Extension to upper case.            "#EC SYNTCHAR
*      endif.
*    endwhile.
*
*    " upon file extension either choose:
*    " - binary format
*    " - xml    format
*    if ( file_Extension eq c_Extension_Serialized ).
*      serialized_Info =
*        cl_Saunit_Result_Serialize_Svc=>convert_Data_To_Stream(
*          p_Master->task ).
*    else.
*      serialized_Info =
*        cl_Saunit_Result_Serialize_Svc=>convert_Data_To_Xml(
*          p_Master->task ).
*    endif.
*
*    " convert XString to XTable due file-Download format restrictions
*    byte_Length = temp_Counter = xstrlen( serialized_Info ).
*    while temp_Counter > 0.
*      if ( c_S_Xline_Len < temp_Counter ).
*        serialized_Line = serialized_Info(c_S_Xline_Len).
*        insert serialized_Line into table serialized_Lines.
*
*        shift serialized_Info left by c_S_Xline_Len places in byte mode.
*        temp_Counter = xstrlen( serialized_Info ).
*      else.
*        serialized_Line = serialized_Info(temp_Counter).
*        insert serialized_Line into table serialized_Lines.
*
*        clear serialized_Info.
*        temp_Counter = 0.
*      endif.
*    endwhile.
*
*    " and there we go
*    call function 'GUI_DOWNLOAD'
*      exporting
*        filename =                    full_Name
*        filetype =                    'BIN'
*        bin_Filesize =                byte_Length
*      tables
*        data_Tab =                    serialized_Lines[]
*      exceptions
*        others =                      1.
*
*    if ( 0 ne sy-subrc and sy-msgid is not initial ).
*       message
*         id     sy-msgid
*         type   'I'
*         number sy-msgno
*         with   sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*    endif.
*
*  endmethod.
*
*
*  method import_Intern_Format.
** ===========================
*  " import buffer back into internal format
*    data:
*      chosen_Action        type   i,
*      temp_Counter         type   i,
*      file_Counter         type   i,
*      dialog_Title         type   string,
*      full_Name            type   string,
*      serialized_Info      type   saunit_D_Serialized_Data,
*      serialized_Lines     type   ty_T_Xlines,
*      file_Names           type   filetable.
*
*    field-symbols:
*      <serialized_Line>    like line of serialized_Lines,
*      <file_Name>          like line of file_Names.
*
*    data:
*      file_Extension       type   sychar04,
*      au_Task              type   ty_S_Task_Data.
*
*    " get file name
*    dialog_Title = 'Read Local Result file'(lod).
*    while
*      c_Extension_Serialized   ne file_Extension   and
*      c_Extension_Xml          ne file_Extension.
*
*      cl_Gui_Frontend_Services=>file_Open_Dialog(
*        exporting
*          window_Title      = dialog_Title
*          default_Extension = c_Extension_Serialized
*          file_Filter       = c_File_Filter
*          initial_Directory = 'C:\'                               "#EC *
*        changing
*          file_Table =        file_Names
*          rc =                file_Counter
*          user_Action =       chosen_Action ).
*
*      if ( cl_Gui_Frontend_Services=>action_Cancel eq chosen_Action ).
*        return.
*      endif.
*      read table file_Names index 1 assigning <file_Name>.
*      if ( 0 ne sy-subrc or 1 ne file_Counter ).
*        return.
*      endif.
*
*      temp_Counter = strlen( <file_Name> ).
*      if ( 4 < temp_Counter ).
*        temp_Counter = temp_Counter - 4.
*        full_Name = <file_Name>.
*        file_Extension = <file_Name>+temp_Counter(4).
*        translate file_Extension to upper case.            "#EC SYNTCHAR
*      endif.
*    endwhile.
*
*    " load file and convert XTable to XString
*    call function 'GUI_UPLOAD'
*      exporting
*        filename                      = full_Name
*        filetype                      = 'BIN'
*      tables
*        data_Tab                      = serialized_Lines[]
*      exceptions
*        others                        = 1.
*
*    if ( 0 ne sy-subrc and sy-msgid is not initial ).
*       message
*         id     sy-msgid
*         type   'I'
*         number sy-msgno
*         with   sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*      return.
*    endif.
*
*    loop at serialized_Lines assigning <serialized_Line>.
*      concatenate
*        serialized_Info <serialized_Line>
*        into serialized_Info in byte mode.
*    endloop.
*    clear serialized_Lines[].
*
*    " restore data and pass it to our master for further processing
*    if ( file_Extension eq c_Extension_Serialized ).
*      au_Task = cl_Saunit_Result_Serialize_Svc=>convert_Stream_To_Data(
*        serialized_Info ).
*    else.
*      au_Task = cl_Saunit_Result_Serialize_Svc=>convert_Xml_To_Data(
*        serialized_Info ).
*    endif.
*
*    " change display
*    p_Master->set_New_Content( au_Task ).
*
*  endmethod.
*
*
*endclass.
