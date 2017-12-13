class YCL_BC_AUNIT_EXAMPLE definition
  public
  inheriting from YCL_BC_AUNIT_ASSERT
  abstract
  create public
  for testing
  duration short
  risk level harmless .

public section.

  methods A01_TESTMETHOD_EXAMPLE
  for testing .

  methods IS_TO_PROCESS
    redefinition .
  protected section.
  private section.
ENDCLASS.



CLASS YCL_BC_AUNIT_EXAMPLE IMPLEMENTATION.


  method a01_testmethod_example.

    if is_to_process( ) = abap_false.
      return.
    endif.

    assert_equals( exp = 1 act = 3 ).

  endmethod.


  method is_to_process.
    rv_is_to_process = abap_true.
  endmethod.
ENDCLASS.
