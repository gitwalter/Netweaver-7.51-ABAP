*module mod_Pbo_0100 output.
**=========================
*  perform sub_Pbo_0100.
*
*endmodule.
*
*
*form sub_Pbo_0100.
**================
*  data:
*    Excluded_FCodes   type ty_T_Fcodes.
*
*  " exclude functions which will be changed from customer usage !!
*  if ( Abap_True eq Cl_Aunit_Permission_Control=>is_Sap_System( ) ).
*    set pf-status 'MAIN100'.
*    set titlebar  'MAIN100'.
*  else.
*    insert gc_FCode-My_Read into table excluded_Fcodes[].
*    insert gc_FCode-My_Save into table excluded_Fcodes[].
*    set pf-status 'MAIN100' excluding excluded_Fcodes[].
*    set titlebar 'MAIN100'.
*  endif.
*
*endform.
