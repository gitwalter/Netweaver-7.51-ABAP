*module mod_pai_0100 input.
**========================
*  perform sub_Pai_0100.
*
*endmodule.
*
*
*form sub_Pai_0100.
**================
*  data:
*    command_Consumed type abap_Bool.
*
*  case gor_Ui-Dyn_0100-Ok.
*    when gc_FCode-Back or gc_FCode-Cancel or gc_FCode-Exit.
*      ui_Master_Dynp=>ui_Master~do_Exit( ).
*      leave to screen 0.
*
*    when others.
*      " handle our self ?
*      command_Consumed =
*        ui_Master_Dynp=>ui_Master~handle_User_Command(
*          gor_Ui-dyn_0100-ok ).
*      if ( abap_False eq command_Consumed  ).
*        " or leave to ctrl fcode dispatcher
*        cl_Gui_CFW=>dispatch( ).
*        cl_Gui_CFW=>flush( ).
*      endif.
*
*  endcase.
*  clear: gor_Ui-Dyn_0100-Ok.
*
*endform.
