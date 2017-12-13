**-----------------------------------------------------------------------
**
**  include:  lAUNIT_TREE_CTRL_LISTENERF51
**
**  created:  03.Aug.2003
**
**-----------------------------------------------------------------------
**
** base class to handle program flow and store global data
** ideally any change to the overall ui presentation should be
** represented by a dedicated public method. Well it is quite easy to
** see that pragmatism rules here as some of the members are exposed to
** the publicity of the other (local) classes.
**
**-----------------------------------------------------------------------
*
*class ui_master_dynp implementation.
*
*
*  method init.
** ============
*    " builds all ui objects and fills em with data
*
*    if ( _fg_display_instance is bound ).
*      _fg_display_instance->ui_master~set_visible( abap_false ).
*    endif.
*    _fg_display_instance = me.
*
*    ui_master~task = task.
*    ui_master~style_prio = abap_true.
*
*    add 1 to _fg_recursion_depth.
*    if ( 3 lt _fg_recursion_depth ).
*      ui_master~permit_navigation = abap_false.
*    else.
*      ui_master~permit_navigation = abap_true.
*    endif.
*
*    " init conversion tool with extended data
*    if ( ui_master~task-extd_infos_by_indicies    is not initial and
*         ui_master~task-extd_mediator is not initial ).
*      try.
*          create object ui_master~mediator
*            type (ui_master~task-extd_mediator).
*          create object ui_master~converter
*            type task_data_converter_ext
*            exporting
*              ext_mediator = ui_master~mediator.
*        catch cx_root.                                      "#EC *
*          clear:
*            ui_master~mediator,
*            ui_master~task-extended_infos,
*            ui_master~task-extended_mediator.
*      endtry.
*    endif.
*
*    if ( ui_master~converter is initial ).
*      create object me->ui_master~converter.
*    endif.
*
*    " convert data for output
*    ui_master~data = ui_master~converter->compute_base_data(
*      task =         ui_master~task
*      do_summarize = abap_true ).
*
*    " build controls and send notification on changed data
*    " the base tree is enough and propagate the notification
*    " accordingly
*    f_ctrl_factory = cl_sat_ui_ctrl_factory_access=>get_factory( ).
*    init_ui_controls( ).
*    ui_master~base_tree->build_content( ).
*
*  endmethod.
*
*
*  method ui_master~set_visible.
** =================================
*    " the visibilty is also the means to support multiple instances
*    " of the ui
*    if ( _fg_display_instance = me ).
*      if ( abap_false eq is_visible ).
*        f_is_visible = is_visible.
*        f_container->set_visible( f_is_visible ).
*        clear _fg_display_instance.
*      else.
*        f_is_visible = abap_true.
*        f_container->set_visible( f_is_visible ).
*      endif.
*    else.
*      if ( abap_false eq is_visible ).
*        f_is_visible = is_visible.
*        f_container->set_visible( f_is_visible ).
*      else.
*        if ( _fg_display_instance is not initial ).
*          _fg_display_instance->ui_master~set_visible( abap_false ).
*        endif.
*        f_is_visible = abap_true.
*        f_container->set_visible( f_is_visible ).
*        _fg_display_instance = me.
*      endif.
*    endif.
*
*  endmethod.
*
*
*  method ui_master~set_new_content.
** ====================================
*
*    ui_master~task =         task.
*
*    " reset data
*    me->ui_master~data = ui_master~converter->compute_base_data(
*      task =         ui_master~task
*      do_summarize = abap_true ).
*
*    " notify controls of changed data ( details and messages are
*    " controlled by the base tree and need no extra notification )
*    ui_master~base_tree->build_content(  ).
*
*    if ( f_header_html is bound ).
*      f_header_html->my_rebuild_content( ).
*    endif.
*
*  endmethod.
*
*
*  method ui_master~toggle_style.
** ==================================
*
*    if ( abap_true eq ui_master~style_prio ).
*      ui_master~style_prio = abap_false.
*    else.
*      ui_master~style_prio = abap_true.
*    endif.
*    ui_master~base_tree->update_style( ).
*    ui_master~detail_list->update_style( ).
*
*  endmethod.
*
*
*  method init_ui_controls.
** ========================
*    " init_Ui_Controls: build the controls
*
*    data:
*       lower_area    type ref to  cl_gui_container.
*
*    f_container = f_ctrl_factory->create_splitter_container(
*      link_dynnr    = '0100'
*      link_repid    = sy-repid
*      parent        = cl_gui_container=>screen0 ).
*
*    f_container->set_grid( rows = 2 columns = 1 ).
*    f_container->set_row_height( id = 1 height = 0 ).
*
*    f_header_area =  f_container->get_container( row = 1 column = 1 ).
*    lower_area =     f_container->get_container( row = 2 column = 1 ).
*
*
*    f_header_area->set_enable( abap_false ).
*
*    init_ui_controls_2( lower_area ).
*
*  endmethod.
*
*
*  method init_ui_controls_2.
** ==========================
*
*    data:
*      splitter   type ref to  cl_gui_splitter_container,
*      left_area  type ref to  cl_gui_container,
*      right_area type ref to  cl_gui_container.
*
*    splitter = f_ctrl_factory->create_splitter_container(
*        parent = parent_container ).
*    splitter->set_grid( rows = 1 columns = 2 ).
*    splitter->set_column_width( id = 1 width = 40 ).
*
*    left_area =  splitter->get_container( row = 1 column = 1 ).
*    right_area = splitter->get_container( row = 1 column = 2 ).
*
*    " create base tree
*    create object ui_master~base_tree
*      exporting
*        master    = me
*        container = left_area.
*
*    " create detail and message area
*    init_ui_controls_3( right_area ).
*
*  endmethod.
*
*
*  method init_ui_controls_3.
** ==========================
*
*    data:
*      splitter   type ref to  cl_gui_splitter_container,
*      lower_area type ref to  cl_gui_container,
*      upper_area type ref to  cl_gui_container.
*
*    splitter = f_ctrl_factory->create_splitter_container(
*        parent = parent_container ).
*
*    splitter->set_grid( rows = 2 columns = 1 ).
*    splitter->set_row_height( id = 1 height = 40 ).
*
*    upper_area = splitter->get_container( row = 1 column = 1 ).
*    lower_area = splitter->get_container( row = 2 column = 1 ).
*
*    create object ui_master~detail_list
*      exporting
*        master    = me
*        container = upper_area.
*
*    create object ui_master~message_tree
*      exporting
*        master    = me
*        container = lower_area.
*
*  endmethod.
*
*
*  method ui_master~show_header.
** =================================
*
*    if ( not f_header_html is bound ).
*      create object f_header_html
*        exporting
*          p_master           = me
*          p_parent_container = f_header_area.
*    endif.
*
*    f_header_area->set_enable( abap_false ).
*    f_header_html->my_rebuild_content( ).
*    f_container->set_row_height( id = 1 height = 20 ).
*
*  endmethod.
*
*
*  method ui_master~do_exit.
** =============================
*    " do_Exit:  called exclusively from dynpro pbo to
*    "           free to server side data of the ui controls !!
*
*    if ( _fg_display_instance is bound ).
*      if ( 0 < _fg_recursion_depth ).
*        subtract 1 from _fg_recursion_depth.
*      endif.
*      if ( _fg_display_instance->f_container is bound ).
*        _fg_display_instance->f_container->free( ).
*        clear _fg_display_instance->f_container.
*      endif.
*      clear _fg_display_instance.
*    endif.
*
*  endmethod.
*
*
*  method ui_master~handle_user_command.
** ========================================
*    " handle_User_Commmand called exclusively form dynpro pbo
*
*    result = abap_false.
*    if ( _fg_display_instance is bound ).
*
*      case user_command.
*
*        when gc_fcode-exit.
*          ui_master~do_exit( ).
*          result = abap_true.
*
*        when gc_fcode-my_save.
*          file_access_svc=>export_intern_format( _fg_display_instance ).
*          result = abap_true.
*
*        when gc_fcode-my_read.
*          file_access_svc=>import_intern_format( _fg_display_instance ).
*          result = abap_true.
*
*        when gc_fcode-my_expand_all.
*          _fg_display_instance->ui_master~base_tree->display_all( ).
*
*        when gc_fcode-my_show_task.
*          _fg_display_instance->ui_master~show_header( ).
*          result = abap_true.
*
*      endcase.
*
*    endif.
*  endmethod.
*
*endclass.
