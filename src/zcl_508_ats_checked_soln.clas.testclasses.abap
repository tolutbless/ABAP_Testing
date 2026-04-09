*"* use this source file for your ABAP unit test classes
class ltcl_find_flights definition final for testing
  duration short
  risk level harmless.

  private section.
    methods:
      test_find_cargo_flight for testing raising cx_static_check.
endclass.

CLASS ltcl_find_flights IMPLEMENTATION.

  METHOD test_find_cargo_flight.

"Read an arbitrary cargo flight from the DB
  SELECT SINGLE
    FROM /lrn/cargoflight
   FIELDS carrier_id, connection_id, flight_date,
          airport_from_id, airport_to_id
     INTO @DATA(some_flight_data).

"If no data found → fail test
    IF sy-subrc <> 0.
      cl_abap_unit_assert=>fail( `No data in table /LRN/CARGOFLIGHT` ).
    ENDIF.

"Instantiate carrier object
    TRY.
        data(the_carrier) = new lcl_carrier( i_carrier_id = some_flight_data-carrier_id ).


        CATCH cx_abap_invalid_value.
         cl_abap_unit_assert=>fail( `Unable to instantiate lcl_carrier` ).
    ENDTRY.

 "Call method under test

    the_carrier->find_cargo_flight(
      EXPORTING
        i_airport_from_id = some_flight_data-airport_from_id
        i_airport_to_id   = some_flight_data-airport_to_id
        i_from_date       = some_flight_data-flight_date
        i_cargo           = 1
      IMPORTING
        e_flight          = data(flight)
        e_days_later      = data(days_later)
    ).

 "Assert: returned flight reference must be valid
   cl_abap_unit_assert=>assert_bound(
        act = flight
        msg = `Method find_cargo_flight does not return a result`
    ).
"Assert: days_later must be zero
    cl_abap_unit_assert=>assert_equals(
        act = days_later
        exp = 0
        msg = `Method find_cargo_flight returns wrong result` ).

  ENDMETHOD.

ENDCLASS.
