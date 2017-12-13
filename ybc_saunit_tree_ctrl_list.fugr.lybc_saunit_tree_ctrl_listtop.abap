function-pool ybc_saunit_tree_ctrl_list message-id sabp_unit.
*
** ---------------------------------------------------------------------
** inclusion of type pools
** ---------------------------------------------------------------------
*
*type-pools:
*  abap,                                                     "#EC *
*  cntl,                                                     "#EC *
*  icon,                                                     "#EC *
*  swbm.
*
** ---------------------------------------------------------------------
** simple type definitions
** ---------------------------------------------------------------------
*
*interface if_saunit_internal_result_type load.
*
*interface ui_master      deferred.
*
*class listener_with_ui_trigger           definition deferred.
*class title_html_ctrl         definition deferred.
*class base_tree_ctrl          definition deferred.
*class detail_grid_ctrl        definition deferred.
*class message_tree_ctrl       definition deferred.
*class file_access_svc       definition deferred.
*class task_data_converter     definition deferred.
*class task_data_converter_ext definition deferred.
*
**----------------------------------------------------------------------*
**       INTERFACE local_Unit_Test
**----------------------------------------------------------------------*
**
**----------------------------------------------------------------------*
*interface local_unit_test.
*endinterface.                    "local_Unit_Test
*
*
** ---------------------------------------------------------------------
** simple type definitions
** ---------------------------------------------------------------------
*
*types:
*  begin of ty_ui_state,
*    " for data exchange with dynpro 0100
*    begin of dyn_0100,
*      ok type       syst-ucomm,
*    end of dyn_0100,
*  end of ty_ui_state.
*
*types:
*  ty_d_fcode  type syucomm,
*  ty_t_fcodes type standard table of ty_d_fcode with default key.
*
** ---------------------------------------------------------------------
** type definitions linked with controls !!!!!!
** ---------------------------------------------------------------------
*
*types:
*  ty_icon_short  type sychar04,
*  ty_icon_long   type string,
*  ty_info_degree type i.
*
** important keep this structure in sync with the field catalogue
** of the base tree / search #BASE_INFO# to find related source
*types:
*  begin of ty_s_base_info,
*    " display issue
*    icon          type      ty_icon_long,
*    " counters for severity
*    cnt_fatal     type      i,         " total of fatal     alerts
*    cnt_critical  type      i,         " total of critical  alerts
*    cnt_tolerable type      i,         " total of tolerable alerts
*    cnt_info      type      i,         " total of info      items
*    " counters per kind
*    cnt_alert     type      i,         " total of any problem
*    cnt_failure   type      i,         " total of failed assertions
*    cnt_warning   type      i,         " total of warnings
*    cnt_error     type      i,         " total of runtime errors
*    cnt_shortdump type      i,         " total of short dumps
*    cnt_extended  type      i,         " extended data
*    " position information
*    degree        type      ty_info_degree,
*    ndx_program   type      i,         " index of prog info in task
*    ndx_class     type      i,         " index of clas info in prog
*    ndx_method    type      i,         " index of meth info in clas
*
*  end of ty_s_base_info,
*  ty_t_base_infos type      standard table of ty_s_base_info
*                                with non-unique key
*                                ndx_program ndx_class ndx_method.
*
** important keep this structure in sync with the field catalogue
** of the detail ist / search #DETAIL_INFO# to find related source
*types:
*  begin of ty_s_detail_info,
*    degree       type      ty_info_degree,
*    ndx_task     type      i,       " index in task itself
*    ndx_program  type      i,       " index of prog info in task
*    ndx_class    type      i,       " index of clas info in prog
*    ndx_method   type      i,       " index of meth info in clas
*    ndx_alert    type      i,       " index of alert within method
*    ndx_extended type      i,       " index in extended data
*    kind         type      saunit_d_alert_kind,
*    level        type      saunit_d_alert_level,
*    header       type      string,
*    icon_level   type      ty_icon_long,
*    icon_kind    type      ty_icon_long,
*  end of ty_s_detail_info,
*  ty_t_detail_infos type     standard table of ty_s_detail_info
*                                            with non-unique key
*                                            kind header.
*
** important keep this structure in sync with the field catalogue
** of the message tree / search #MESSAGE_INFO# to find related source
*
*types:
*  ty_msg_kind    type c length 1.
*
*types:
*  begin of ty_s_message_info,
*    indent   type      i,
*    text     type      string,
*    include  type      string,
*    document type      string,
*    is_link  type      abap_bool,
*    ndx_info type      i,
*    line     type      i,
*  end of ty_s_message_info,
*  ty_t_message_infos type standard table of ty_s_message_info
*                                        with non-unique key
*                                        indent text.
*
** ---------------------------------------------------------------------
** type definitions for convience
** ---------------------------------------------------------------------
*
*types:
*  ty_s_task_data  type if_saunit_internal_result_type=>ty_s_task,
*  ty_s_prog_data  type if_saunit_internal_result_type=>ty_s_program,
*  ty_s_clas_data  type if_saunit_internal_result_type=>ty_s_class,
*  ty_s_meth_data  type if_saunit_internal_result_type=>ty_s_method,
*  ty_t_prog_data  type if_saunit_internal_result_type=>ty_t_programs,
*  ty_t_clas_data  type if_saunit_internal_result_type=>ty_t_classes,
*  ty_t_meth_data  type if_saunit_internal_result_type=>ty_t_methods,
*  ty_s_alert_data type if_saunit_internal_result_type=>ty_s_alert,
*  ty_t_alert_data type if_saunit_internal_result_type=>ty_t_alerts.
**  ty_s_ext_info     type if_saunit_internal_result_type=>ty_s_ext_info.
*types:
*  begin of ty_s_ext_info,
*    program type string,
*    class   type string,
*    method  type string,
*    data    type xstring,
*  end of ty_s_ext_info .
*
** ---------------------------------------------------------------------
** constants
** ---------------------------------------------------------------------
*
*constants:
*  "
*  begin of gc_info_degree,
*    initial        type ty_info_degree value 0,
*    task           type ty_info_degree value 1,
*    task_errors    type ty_info_degree value 11,
*    program        type ty_info_degree value 2,
*    program_errors type ty_info_degree value 21,
*    class          type ty_info_degree value 4,
*    class_errors   type ty_info_degree value 41,
*    method         type ty_info_degree value 6,
*    other          type ty_info_degree value 8,
*  end of gc_info_degree,
*  " shorten typing the constant for the alert type
*  begin of gc_alert_kind,
*    error
*      type   saunit_d_alert_kind
*      value  if_saunit_internal_result_type=>c_alert_kind-error,
*    failure
*      type   saunit_d_alert_kind
*      value  if_saunit_internal_result_type=>c_alert_kind-failure,
*    warning
*      type   saunit_d_alert_kind
*      value  if_saunit_internal_result_type=>c_alert_kind-warning,
*    shortdump
*      type   saunit_d_alert_kind
*      value  if_saunit_internal_result_type=>c_alert_kind-shortdump,
*    execution_event
*      type   saunit_d_alert_kind
*      value  if_saunit_internal_result_type=>c_alert_kind-execution_event,
*    extended_info
*      type   saunit_d_alert_kind
*      value  if_saunit_internal_result_type=>c_alert_kind-extended_info,
*  end of gc_alert_kind,
*  " shorten typing the constant for the alert type
*  begin of gc_alert_level,
*    critical
*      type   saunit_d_alert_level
*      value  if_saunit_internal_result_type=>c_alert_level-critical,
*    fatal
*      type   saunit_d_alert_level
*      value  if_saunit_internal_result_type=>c_alert_level-fatal,
*    tolerable
*      type   saunit_d_alert_level
*      value  if_saunit_internal_result_type=>c_alert_level-tolerable,
*    information
*      type   saunit_d_alert_level
*      value  if_saunit_internal_result_type=>c_alert_level-information,
*
*  end of gc_alert_level.
*
*constants:
*  begin of gc_fcode,
*    back          type ty_d_fcode   value 'BACK',
*    exit          type ty_d_fcode   value 'EXIT',
*    cancel        type ty_d_fcode   value 'CANC',
*    my_save       type ty_d_fcode   value 'MY_SAVE',
*    my_read       type ty_d_fcode   value 'MY_READ',
*    my_show_task  type ty_d_fcode   value 'MY_SH_TASK',
*    my_expand_all type ty_d_fcode   value 'MY_EXP_ALL',
*  end of gc_fcode.
*
*
** ---------------------------------------------------------------------
** global data - enforced by UI programming model (Dynps)
** ---------------------------------------------------------------------
*
*data:
*  gor_ui      type   ty_ui_state.               " ui state data
*
** ---------------------------------------------------------------------
** class definitions
** ---------------------------------------------------------------------
*
*" please note that copying the fUBA will not copy includes in the top
*" include - therefore first move these include statements into the
*" main include before copying.
*" on the other hand the syntax check has some weakness if they would
*" stay in the main include. so after the fuGr copy move them back
*
*include lybc_au_tree_ctrl_listenerf01.         " Ui master
*include lybc_au_tree_ctrl_listenerf02.         " base tree
*include lybc_au_tree_ctrl_listenerf03.         " detail list
*include lybc_au_tree_ctrl_listenerf04.         " listener
*include lybc_au_tree_ctrl_listenerf05.         " message tree
*include lybc_au_tree_ctrl_listenerf06.         " html title
*include lybc_au_tree_ctrl_listenerf07.         " file manager
*include lybc_au_tree_ctrl_listenerf08.         " converter tool
