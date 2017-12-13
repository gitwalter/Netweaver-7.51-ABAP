class YCL_BC_AUNIT_ASSERT definition
  public
  inheriting from CL_AUNIT_ASSERT
  abstract
  create public .

public section.

  class-methods ASSERT_MESSAGE_IN_RETURNTABLE
    importing
      !IS_RETURN type BAPIRET2
      !IT_RETURN type BAPIRET2_T .
  methods IS_TO_PROCESS
  abstract
    returning
      value(RV_IS_TO_PROCESS) type ABAP_BOOL .
  class-methods ASSERT_EQUALS_MSG
    importing
      value(IV_EXP) type ANY
      value(IV_ACT) type ANY
      value(IV_MSG) type CSEQUENCE .
protected section.
private section.

  class-methods APPEND_AND_TO_WHERE_CLAUSE
    changing
      !CV_WHERE_CLAUSE type STRING .
ENDCLASS.



CLASS YCL_BC_AUNIT_ASSERT IMPLEMENTATION.


method append_and_to_where_clause.
*-----------------------------------------------------------------------
* Description:
* Add an "AND" to the where clause
*-----------------------------------------------------------------------

  if cv_where_clause is not initial.
    concatenate cv_where_clause
                'AND'
                into cv_where_clause separated by space.
  endif.
endmethod.


method assert_equals_msg.
*-----------------------------------------------------------------------
* Description:
*   cases call of assertion class
*-----------------------------------------------------------------------
  data:
    lv_string     type string,
    lv_string_exp type string,
    lv_string_act type string.

  lv_string_exp  = iv_exp.
  lv_string_act  = iv_act.

  concatenate iv_msg 'Erwartet:'(003) lv_string_exp 'Ist:'(004) lv_string_act into lv_string separated by space.
  cl_abap_unit_assert=>assert_equals( exp = iv_exp act = iv_act msg = lv_string ).
endmethod.


method assert_message_in_returntable.
*-----------------------------------------------------------------------
* Description:
* Assert that a specified message is in the returntable
*-----------------------------------------------------------------------
  data: lv_where_clause type string.

* message type
  if is_return-type is not initial.
    concatenate lv_where_clause
                'TYPE = IS_RETURN-TYPE'
                into lv_where_clause separated by space.
  endif.

* message class
  if is_return-id is not initial.
    append_and_to_where_clause( changing cv_where_clause = lv_where_clause ).
    concatenate lv_where_clause
                'ID = IS_RETURN-ID'
                into lv_where_clause separated by space.
  endif.

* message number
  if is_return-number is not initial.
    append_and_to_where_clause( changing cv_where_clause = lv_where_clause ).
    concatenate lv_where_clause
                'NUMBER = IS_RETURN-NUMBER'
                into lv_where_clause separated by space.
  endif.

* message text
  if is_return-message is not initial.
    append_and_to_where_clause( changing cv_where_clause = lv_where_clause ).
    concatenate lv_where_clause
                'MESSAGE = IS_RETURN-MESSAGE'
                into lv_where_clause separated by space.
  endif.

* log number
  if is_return-log_no is not initial.
    append_and_to_where_clause( changing cv_where_clause = lv_where_clause ).
    concatenate lv_where_clause
                'LOG_NO = IS_RETURN-LOG_NO'
                into lv_where_clause separated by space.
  endif.

* log message number
  if is_return-log_msg_no is not initial.
    append_and_to_where_clause( changing cv_where_clause = lv_where_clause ).
    concatenate lv_where_clause
                'LOG_MSG_NO = IS_RETURN-LOG_MSG_NO'
                into lv_where_clause separated by space.
  endif.

* message variable 1
  if is_return-message_v1 is not initial.
    append_and_to_where_clause( changing cv_where_clause = lv_where_clause ).
    concatenate lv_where_clause
                'MESSAGE_V1 = IS_RETURN-MESSAGE_V1'
                into lv_where_clause separated by space.
  endif.

* message variable 2
  if is_return-message_v2 is not initial.
    append_and_to_where_clause( changing cv_where_clause = lv_where_clause ).
    concatenate lv_where_clause
                'MESSAGE_V2 = IS_RETURN-MESSAGE_V2'
                into lv_where_clause separated by space.
  endif.

* message variable 3
  if is_return-message_v3 is not initial.
    append_and_to_where_clause( changing cv_where_clause = lv_where_clause ).
    concatenate lv_where_clause
                'MESSAGE_V3 = IS_RETURN-MESSAGE_V3'
                into lv_where_clause separated by space.
  endif.

* message variable 4
  if is_return-message_v4 is not initial.
    append_and_to_where_clause( changing cv_where_clause = lv_where_clause ).
    concatenate lv_where_clause
                'MESSAGE_V4 = IS_RETURN-MESSAGE_V4'
                into lv_where_clause separated by space.
  endif.

* parameter
  if is_return-parameter is not initial.
    append_and_to_where_clause( changing cv_where_clause = lv_where_clause ).
    concatenate lv_where_clause
                'PARAMETER = IS_RETURN-PARAMETER'
                into lv_where_clause separated by space.
  endif.

* row
  if is_return-row is not initial.
    append_and_to_where_clause( changing cv_where_clause = lv_where_clause ).
    concatenate lv_where_clause
                'RETURN_ROW = IS_RETURN-RETURN_ROW'
                into lv_where_clause separated by space.
  endif.

* field
  if is_return-field is not initial.
    append_and_to_where_clause( changing cv_where_clause = lv_where_clause ).
    concatenate lv_where_clause
                'FIELD = IS_RETURN-FIELD'
                into lv_where_clause separated by space.
  endif.

* system
  if is_return-system is not initial.
    append_and_to_where_clause( changing cv_where_clause = lv_where_clause ).
    concatenate lv_where_clause
                'SYSTEM = IS_RETURN-SYSTEM'
                into lv_where_clause separated by space.
  endif.

* read the line according to the specified where clause
  loop at it_return
       transporting no fields
       where (lv_where_clause).
    exit.
  endloop.

  assert_subrc( sy-subrc ).
endmethod.
ENDCLASS.
