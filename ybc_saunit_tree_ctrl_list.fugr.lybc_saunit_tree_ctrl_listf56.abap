**-----------------------------------------------------------------------
**
**  Include:  LAUNIT_TREE_CTRL_LISTENERF56
**
**-----------------------------------------------------------------------
*
*
*class title_Html_Ctrl implementation.
*
*method constructor.
**==================
*
*  super->constructor( ).
*
*  f_Container = p_Parent_Container.
*  f_Master =    p_Master.
*
*  initialize_Document(
*    background_Color = me->col_Tree_Level1 ).
*
* display_Document(
*   parent =         f_Container ).
*
*endmethod.
*
*
*method my_Rebuild_Content.
**=========================
*
*  data:
*    date_Buffer           type d,
*    time_Buffer           type t,
*    txt_Name              type string,
*    txt_Buffer_1          type c length 30,
*    txt_Buffer_2          type c length 30,
*    txt_Buffer            type sdydo_Text_Element.
*
*  initialize_Document(
*    first_Time = abap_False
*    background_Color = me->col_Tree_Level1 ).
*
*  " create table
*  txt_Buffer = 'Information About test task $TASK$'(tit).
*  txt_Name = f_Master->task-info-name.
*  condense txt_Name.
*  if ( txt_Name is initial ).
*    txt_Name = 'ABAP Unit'.                                  "#EC NOTEXT
*  endif.
*  replace '$TASK$' in txt_Buffer with txt_Name.
*
*  add_Text(
*    text =           txt_Buffer
*    sap_Style = me->heading ).
*
*  new_Line( ).
*
*  case f_Master->task-info-run_Mode.
*    when cl_Aunit_Task=>run_Mode_Catch_Short_Dump or
*         cl_Aunit_Task=>run_Mode_Safe.                            "#EC *
*      txt_Buffer_1 = 'In separate internal mode'(rmi).
*      txt_Buffer_2 = 'Catching of runtime abortions'(rmd).
*    when cl_Aunit_Task=>run_Mode_Common.
*      txt_Buffer_1 = 'In same Internal Mode'(rmc).
*      clear txt_Buffer_2.
*    when cl_Aunit_Task=>run_Mode_External.
*      txt_Buffer_1 = 'In separate external mode'(rme).
*      clear txt_Buffer_2.
*    when cl_Aunit_Task=>run_Mode_Isolated.
*      txt_Buffer_1 = 'In separate internal mode'(rmi).
*      clear txt_Buffer_2.
*    when others.
*      txt_Buffer_1 = 'Unknown'(unk).
*      clear txt_Buffer_2.
*  endcase.
*  concatenate
*    'Execution mode'(rmt) `: ` txt_Buffer_1 ` ` txt_Buffer_2
*    into txt_Buffer.
*  add_Text( text = txt_Buffer ).
*
*  new_Line( ).
*
*  if f_Master->task-info-duration_Settings-category_Long is initial.
*    txt_Buffer = 'No runtime restriction'(dun).
*    add_Text( text = txt_Buffer ).
*  else.
*    case f_Master->task-info-duration_Category.
*      when if_Aunit_Attribute_Enums=>c_Duration-long.
*        txt_Buffer_1 = 'Long'(lon).
*      when if_Aunit_Attribute_Enums=>c_Duration-medium.
*        txt_Buffer_1 = 'Medium'(med).
*      when if_Aunit_Attribute_Enums=>c_Duration-short.
*        txt_Buffer_1 = 'Short'(sho).
*      when others.
*        txt_Buffer_1 = 'Unknown'(unk).
*    endcase.
*    concatenate
*      'Maximum Runtime'(dum) `:` txt_Buffer_1
*      into txt_Buffer separated by space.
*    txt_Buffer_1 =
*      f_Master->task-info-duration_Settings-category_Long.
*    concatenate
*      txt_Buffer
*      ` (` 'Long'(lon) `: `
*      txt_Buffer_1
*    into txt_Buffer.
*    txt_Buffer_1 =
*      f_Master->task-info-duration_Settings-category_Medium.
*    concatenate
*      txt_Buffer
*      ` | ` 'Medium'(med) `: `
*      txt_Buffer_1
*    into txt_Buffer.
*    txt_Buffer_1 =
*      f_Master->task-info-duration_Settings-category_Short.
*    concatenate
*      txt_Buffer
*      ` | ` 'Short'(sho) `: `
*      txt_Buffer_1
*      `)`
*    into txt_Buffer.
*    add_Text( text = txt_Buffer ).
*  endif.
*
*  new_Line( ).
*
*  case f_Master->task-info-risk_Level.
*    when if_Aunit_Attribute_Enums=>c_Risk_Level-critical.
*      txt_Buffer_1 = 'Critical'(rlc).
*    when if_Aunit_Attribute_Enums=>c_Risk_Level-dangerous.
*      txt_Buffer_1 = 'Dangerous'(rld).
*    when if_Aunit_Attribute_Enums=>c_Risk_Level-harmless.
*      txt_Buffer_1 = 'Harmless'(rlh).
*    when others.
*      txt_Buffer_1 = 'Unknown'(unk).
*  endcase.
*  concatenate
*    'Maximum risk level'(rlm) `:` txt_Buffer_1
*    into txt_Buffer separated by space.
*  add_Text( text = txt_Buffer ).
*
*  new_Line( ).
*
*  do 2 times.
*    if ( 1 = sy-index ).
*      convert time stamp f_Master->task-info-start_Stamp
*        time zone sy-zonlo
*        into
*          date date_Buffer
*          time time_Buffer
*        daylight saving time sy-dayst.  "#EC *
*    else.
*      convert time stamp f_Master->task-info-end_Stamp
*        time zone sy-zonlo
*        into
*          date date_Buffer
*          time time_Buffer
*        daylight saving time sy-dayst.  "#EC *
*    endif.
*    write date_Buffer to txt_Buffer_1.
*    write time_Buffer to txt_Buffer_2.
*
*    if ( 1 = sy-index ).
*      concatenate
*        'Start:'(frm) txt_Buffer_1 txt_Buffer_2
*        into txt_Buffer separated by space.
*    else.
*      concatenate
*        'End:'(upt) txt_Buffer_1 txt_Buffer_2
*        into txt_Buffer separated by space.
*    endif.
*    add_Text( text = txt_Buffer ).
*    new_Line( ).
*  enddo.
*
*  concatenate
*    'System:'(sid)
*    f_Master->task-info-system_Id f_Master->task-info-sap_Release
*    into txt_Buffer separated by space.
*  add_Text( text = txt_Buffer ).
*  new_Line( ).
*
*  concatenate
*    'Server:'(srv) f_Master->task-info-host_Name
*    into txt_Buffer separated by space.
*  add_Text( text = txt_Buffer ).
*  new_Line( ).
*
*  case f_Master->task-info-krn_Release.
*    when '000' or '' or '???'.
*      " no data.
*    when others.
*      concatenate
*        'Kernel:'(krn) f_Master->task-info-krn_Release
*        ',' 'Patch'(ptc)  f_Master->task-info-krn_Patch
*        into txt_Buffer separated by space.
*      add_Text( text = txt_Buffer ).
*      new_Line( ).
*  endcase.
*
*  merge_Document( ).
*  display_Document( reuse_Control = abap_True ).
*
*endmethod.
*
*endclass.
