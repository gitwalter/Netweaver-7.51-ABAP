class YCL_BC_AUNIT_BATCH_LISTENER definition
  public
  inheriting from CL_AUNIT_LISTENER_LIST
  final
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !LANGUAGE type SYLANGU default SY-LANGU
      !IO_AUNIT_EXEC_UNIT_TESTS type ref to YCL_BC_AUNIT_EXEC_UNIT_TESTS .

  methods IF_AUNIT_LISTENER~METHOD_END
    redefinition .
  methods IF_AUNIT_LISTENER~METHOD_START
    redefinition .
  methods IF_AUNIT_LISTENER~PROGRAM_END
    redefinition .
  methods IF_AUNIT_LISTENER~PROGRAM_START
    redefinition .
  methods IF_AUNIT_LISTENER~TASK_END
    redefinition .
protected section.
private section.

  data MT_IF_AUNIT_INFO_FAILED type YBC_T_IF_AUNIT_INFO_STEP_END .
  data MO_AUNIT_PROTOCOL type ref to YCL_BC_AUNIT_PROTOCOL .
  data MO_AUNIT_EXEC_UNIT_TESTS type ref to YCL_BC_AUNIT_EXEC_UNIT_TESTS .
  data MT_CLASSES_WITHOUT_LOCAL_CLASS type YBC_T_EXECUTE_UNIT_TESTS .
  data MT_RESPONSIBLE_DEVELOPERS type SPERS_ULST .

  methods ADD_RECIPIENTS
    importing
      !IO_SEND_REQUEST type ref to CL_BCS .
  methods SEND_EMAIL .
  methods GET_CLASS_INFORMATION
    importing
      !IV_CLASSNAME type CLIKE
    returning
      value(RV_SO_TEXT255) type SO_TEXT255 .
ENDCLASS.



CLASS YCL_BC_AUNIT_BATCH_LISTENER IMPLEMENTATION.


method add_recipients.
    data: lv_email         type                   adr6-smtp_addr,
          lv_string        type string,
          lo_recipient     type ref to            if_recipient_bcs,
          lx_bcs_exception type ref to            cx_bcs,
          ls_sousradri1    type                   sousradri1,
          lt_sousradri1    type standard table of sousradri1.

    field-symbols: <lv_uname>      type uname,
                   <ls_sousradri1> type sousradri1.

    sort mt_responsible_developers.
    delete adjacent duplicates from mt_responsible_developers comparing table_line.

    try.
        "Email TO...
        loop at mt_responsible_developers assigning <lv_uname>.
          clear lv_email.
          ls_sousradri1-sapname = <lv_uname>.
          insert ls_sousradri1 into table lt_sousradri1.
          call function 'SO_USER_ADDRESS_READ_API1'
            tables
              user_address    = lt_sousradri1
            exceptions
              enqueue_errror  = 1
              parameter_error = 2
              x_error         = 3.
          if sy-subrc <> 0.
            lv_email     = 'hf-it-entwicklung@hermes-europe.de'(006).
          endif.

          read table lt_sousradri1 index 1 assigning <ls_sousradri1>.
          if <ls_sousradri1> is assigned.
            lv_email = <ls_sousradri1>-address.
          endif.

          if lv_email is initial or lv_email co space.
            lv_email     = 'hf-it-entwicklung@hermes-europe.de'(006).
          endif.


          lo_recipient = cl_cam_address_bcs=>create_internet_address( lv_email ).
          "Add recipient to send request
          io_send_request->add_recipient(
              i_recipient = lo_recipient
              i_express   = abap_true ).
        endloop.

        "Email copy...
        lv_email     = 'hf-it-entwicklung@hermes-europe.de'(006).
        lo_recipient = cl_cam_address_bcs=>create_internet_address( lv_email ).
        "Add recipient to send request
        io_send_request->add_recipient(
            i_recipient = lo_recipient
            i_express   = abap_true
            i_copy      = abap_true ).

      catch cx_bcs into lx_bcs_exception.
*      lv_string = lx_bcs_exception->get_text( ).
*      message x398(00) with lv_string.
    endtry.
  endmethod.                    "add_recipients


method constructor.
*-----------------------------------------------------------------------
* Description:
*    Constructor
*-----------------------------------------------------------------------
* Change-Log
*-----------------------------------------------------------------------
* Date      Name        Description
*-----------------------------------------------------------------------
*
*-----------------------------------------------------------------------

    super->constructor( language = language ).
    create object mo_aunit_protocol.
*{   INSERT         ED1K907875                                        1
    mo_aunit_exec_unit_tests = io_aunit_exec_unit_tests.
*}   INSERT
  endmethod.                    "constructor


method get_class_information.
    data: lv_author        type responsibl,
          lv_changing_user type uname,
          lv_changed_on    type rdir_udate.

    select single author from  tadir
          into lv_author
          where  pgmid     = 'R3TR'
          and    object    = 'CLAS'
          and    obj_name  = iv_classname.
    if lv_author is not initial.
      insert lv_author into table mt_responsible_developers.
    endif.

    select changedby changedon
           into (lv_changing_user, lv_changed_on)
           up to 1 rows
           from  seocompodf
           where  clsname   = iv_classname
             and  changedon = ( select max( changedon )
                                   from seocompodf
                                   where clsname = iv_classname ).
    endselect.

    if lv_changing_user is initial or
       lv_changing_user = lv_author.
      concatenate iv_classname
                  'erstellt von'(009)
                  lv_author
                  into rv_so_text255 separated by space.
    else.
      insert lv_changing_user into table mt_responsible_developers.
      concatenate iv_classname
                  'erstellt von'(009)
                  lv_author
                  'geändert von'(011)
                  lv_changing_user
                  'am'(012)
                  lv_changed_on
                  into rv_so_text255 separated by space.
    endif.
  endmethod.                    "get_class_information


method if_aunit_listener~method_end.
    mo_aunit_protocol->write_protocol_method_end(
          iv_methodname          = info->name
          io_aunit_info_step_end = info ).

    super->if_aunit_listener~method_end( info ).
  endmethod.                    "IF_AUNIT_LISTENER~METHOD_END


method if_aunit_listener~method_start.
*-----------------------------------------------------------------------
* Description:
*    Handle method start
*-----------------------------------------------------------------------
* Change-Log
*-----------------------------------------------------------------------
* Date      Name        Description
*-----------------------------------------------------------------------
*
*-----------------------------------------------------------------------
    mo_aunit_protocol->write_protocol_method_start(
           iv_methodname = info->name ).

    super->if_aunit_listener~method_start( info ).
  endmethod.                    "if_aunit_listener~method_start


method if_aunit_listener~program_end.
*-----------------------------------------------------------------------
* Description:
*    Check if the test failed
*-----------------------------------------------------------------------
* Change-Log
*-----------------------------------------------------------------------
* Date      Name        Description
*-----------------------------------------------------------------------
*
*-----------------------------------------------------------------------
    super->if_aunit_listener~program_end( info ).

    if info->get_alert_summary( )-is_okay = abap_false.
      insert info into table mt_if_aunit_info_failed.
    endif.
  endmethod.                    "if_aunit_listener~program_end


method if_aunit_listener~program_start.
*-----------------------------------------------------------------------
* Description:
*    Handle program start
*-----------------------------------------------------------------------
* Change-Log
*-----------------------------------------------------------------------
* Date      Name        Description
*-----------------------------------------------------------------------
*
*-----------------------------------------------------------------------
    mo_aunit_protocol->set_classname( info->name ).
    super->if_aunit_listener~program_start( info ).
  endmethod.                    "if_aunit_listener~program_start


method if_aunit_listener~task_end.
*-----------------------------------------------------------------------
* Description:
*    Constructor
*-----------------------------------------------------------------------
* Send email on end of task if errors occured.
*-----------------------------------------------------------------------
* Date      Name        Description
*-----------------------------------------------------------------------
*
*-----------------------------------------------------------------------
    super->if_aunit_listener~task_end( info ).

    mt_classes_without_local_class = mo_aunit_exec_unit_tests->determine_classes_no_loc_class( ).
    if mt_if_aunit_info_failed is not initial or
       mt_classes_without_local_class is not initial.
      send_email( ).
    endif.
  endmethod.                    "if_aunit_listener~task_end


method send_email.
*-----------------------------------------------------------------------
* Description:
*    Send email
*-----------------------------------------------------------------------
* Change-Log
*-----------------------------------------------------------------------
* Date      Name        Description
*-----------------------------------------------------------------------
*
*-----------------------------------------------------------------------
    constants:
      lc_raw               type char03 value 'RAW'.

    data:
      lv_sent_to_all   type os_boolean,
      lv_subject       type so_obj_des,
      lt_text          type bcsy_text,
      ls_soli          type soli,
      lv_length        type i,
      lo_send_request  type ref to cl_bcs,
      lx_bcs_exception type ref to cx_bcs,
      lo_sender        type ref to cl_sapuser_bcs,
      lo_document      type ref to cl_document_bcs.

    data: lv_string type string,
          lv_clsname type seoclsname.

    field-symbols: <ls_execute_unit_tests>  type ybc_s_execute_unit_tests,
                   <lo_aunit_info_step_end> type ref to if_aunit_info_step_end.

    if mt_classes_without_local_class is not initial.
      ls_soli-line =  'Bei folgenden Klassen fehlt die lokale Testklasse:'(010).
      insert ls_soli into table lt_text.

      loop at mt_classes_without_local_class assigning <ls_execute_unit_tests>.
        clear ls_soli-line.
        ls_soli-line = get_class_information( <ls_execute_unit_tests>-classname ).
        insert ls_soli into table lt_text.
      endloop.

    endif.

    if mt_if_aunit_info_failed is not initial.
      clear ls_soli-line.
      insert ls_soli into table lt_text.
      ls_soli-line =  'Bei der Ausführung der folgenden Testklassen sind Fehler aufgetreten:'(004).
      insert ls_soli into table lt_text.
    endif.

    loop at mt_if_aunit_info_failed assigning <lo_aunit_info_step_end>.
      clear: lv_length.
      find regex '=' in <lo_aunit_info_step_end>->name match offset lv_length.
      if lv_length is initial.
        lv_string = <lo_aunit_info_step_end>->name.
        lv_length = strlen( lv_string ) - 2.
      endif.
      clear ls_soli-line.
      lv_clsname = <lo_aunit_info_step_end>->name(lv_length).
      ls_soli-line = get_class_information( lv_clsname ).
      insert ls_soli into table lt_text.
    endloop.

    try.
        "Create send request
        lo_send_request = cl_bcs=>create_persistent( ).

        "Email FROM...
        lo_sender = cl_sapuser_bcs=>create( sy-uname ).
        "Add sender to send request
        lo_send_request->set_sender( lo_sender ).

        add_recipients( lo_send_request ).

        concatenate 'Unittestfehler'(005)
                    'System:'(007)
                    sy-sysid
                    'Mdt:'(008)
                    sy-mandt
                    'User:'(013)
                    sy-uname into lv_subject separated by space.

        "Email BODY
        lo_document = cl_document_bcs=>create_document(
                        i_type    = lc_raw
                        i_text    = lt_text
                        i_length  = '12'
                        i_subject = lv_subject ).
        "Add document to send request
        lo_send_request->set_document( lo_document ).


        "Send email
        lv_sent_to_all = lo_send_request->send( abap_true ).

        if lv_sent_to_all = abap_true.
          write 'Email wurde versendet!'(001).
        endif.

        "Commit to send email
        commit work.


        "Exception handling
      catch cx_bcs into lx_bcs_exception.
        lv_string = lx_bcs_exception->get_text( ).
        message x398(00) with lv_string.
    endtry.
  endmethod.                    "send_email
ENDCLASS.
