function y_bc_au___create_tree_listener.
*"--------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(SHOW_SUCCESS_ALSO) TYPE  ABAP_BOOL
*"         DEFAULT ABAP_FALSE
*"  EXPORTING
*"     REFERENCE(RESULT) TYPE REF TO IF_AUNIT_LISTENER
*"--------------------------------------------------------------------
*data:
*    custom_listener type syrepid.
*
*  if ( abap_true eq cl_aunit_permission_control=>is_sap_system( ) ).
*    get parameter id 'SAUNIT_SAP_LISTENER' field custom_listener.
*
*    if ( 0 eq sy-subrc ).
*      select single obj_name from tadir
*        into custom_listener
*        where
*          pgmid = 'R3TR'    and
*          object = 'CLAS'   and
*          obj_name = custom_listener.
*      try.
*          if ( 0 eq sy-subrc ).
*            create object result type (custom_listener).
*            if ( show_success_also is not initial ).
*              try.
*                  call method result->('SET_SHOW_SUCCESS_ALSO').
*                catch cx_root.                              "#EC *
*              endtry.
*            endif.
*            return.
*          endif.
*        catch cx_root.                                      "#EC *
*      endtry.
*    endif.
*  endif.
*
  create object result type ycl_bc_aunit_online_listener.
*




endfunction.
