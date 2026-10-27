CLASS lhc_zr_bookingapp_dra DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS CalculateTotalPrice FOR DETERMINE ON MODIFY
       keys FOR zr_bookingapp_dra~CalculateTotalPrice.

    METHODS SetBookingId FOR DETERMINE ON SAVE
       keys FOR zr_bookingapp_dra~SetBookingId.
    METHODS SetBookingDate FOR DETERMINE ON SAVE
       keys FOR zr_bookingapp_dra~SetBookingDate.
    METHODS valcustomerId FOR VALIDATE ON SAVE
       keys FOR zr_bookingapp_dra~valcustomerId.

ENDCLASS.

CLASS lhc_zr_bookingapp_dra IMPLEMENTATION.

  METHOD CalculateTotalPrice.
    READ ENTITIES OF zr_travelapp_d IN LOCAL MODE
    ENTITY zr_bookingapp_dra BY \_travel
    FIELDS ( TravelUuid )
    WITH CORRESPONDING #( keys )
    RESULT DATA(ls_travel).

    MODIFY ENTITIES OF zr_travelapp_d IN LOCAL MODE
    ENTITY ZR_TRAVELapp_D EXECUTE RecalTotal FROM CORRESPONDING #( ls_travel ).
  ENDMETHOD.

  METHOD SetBookingId.

    READ ENTITIES OF ZR_TRAVELapp_D
      IN LOCAL MODE
      ENTITY zr_bookingapp_dra
      BY \_travel
      FIELDS ( TravelUuid )
      WITH CORRESPONDING #( keys )
      RESULT DATA(ls_travel).


    LOOP AT ls_travel INTO DATA(lt_travel).

      READ ENTITIES OF zr_travelapp_d
        IN LOCAL MODE
        ENTITY ZR_TRAVELapp_D BY \_book
        FIELDS ( BookingId )
        WITH VALUE #( ( %tky = lt_travel-%tky ) )
        RESULT DATA(ls_booking).


      DATA(v_recent_bookingID) = '00000000'.

      "Find highest existing BookingId
      LOOP AT ls_booking INTO DATA(lt_booking).

        IF lt_booking-BookingId > v_recent_bookingID.
          v_recent_bookingID = lt_booking-BookingId.
        ENDIF.

      ENDLOOP.


      "Keep only new bookings without BookingId
      DELETE ls_booking
        WHERE BookingId IS NOT INITIAL.


      "Prepare all updates first
      DATA lt_update TYPE TABLE FOR UPDATE
                              zr_travelapp_d\\zr_bookingapp_dra.

      LOOP AT ls_booking ASSIGNING FIELD-SYMBOL(<ls_book>).

        v_recent_bookingID += 1.
        DATA(lv_booking_date) = VALUE /dmo/booking_date( ).

        " 2. Assign the current system date using the modern system class or system field
        lv_booking_date = cl_abap_context_info=>get_system_date( ).

        APPEND VALUE #(
          %tky      = <ls_book>-%tky
          BookingId = v_recent_bookingID
          BookingDate = lv_booking_date

        ) TO lt_update.

      ENDLOOP.


      "One EML update
      IF lt_update IS NOT INITIAL.

        MODIFY ENTITIES OF zr_travelapp_d
          IN LOCAL MODE
          ENTITY zr_bookingapp_dra
          UPDATE
          FIELDS ( BookingId BookingDate )
          WITH lt_update.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.
  METHOD SetBookingDate.
  ENDMETHOD.

  METHOD valcustomerId.

    READ ENTITIES OF zr_travelapp_d IN LOCAL MODE
    ENTITY  zr_bookingapp_dra
    FIELDS ( CustomerId )
    WITH CORRESPONDING #( keys )
    RESULT DATA(ls_book).

    READ ENTITIES OF zr_travelapp_d IN LOCAL MODE
    ENTITY zr_bookingapp_dra BY \_travel
    FROM CORRESPONDING #( ls_book )
    LINK DATA(travel_booking_link).

    DATA customer TYPE SORTED TABLE OF /dmo/customer WITH UNIQUE KEY customer_id.

    customer = CORRESPONDING #( ls_book DISCARDING DUPLICATES MAPPING customer_id = CustomerId EXCEPT *  ).

    SELECT FROM /dmo/customer
    FIELDS ( customer_id )
    FOR ALL ENTRIES IN @customer
    WHERE customer_id = @customer-customer_id
    INTO TABLE @DATA(ls_customer).

    LOOP AT ls_book ASSIGNING FIELD-SYMBOL(<fs_book>).
      APPEND VALUE #(  %tky = <fs_book>-%tky %state_area = 'CustomerId'  ) TO reported-zr_bookingapp_dra .

      IF <fs_book>-CustomerId IS INITIAL.
        failed-zr_bookingapp_dra = VALUE #( ( %tky = <fs_book>-%tky ) ).
        APPEND VALUE #(  %tky = <fs_book>-%tky
                         %state_area = 'CustomerId'
                         %msg = NEW /dmo/cm_flight_messages( textid = /dmo/cm_flight_messages=>enter_customer_id
                                                            severity = if_abap_behv_message=>severity-error )
                         %path = VALUE #( zr_travelapp_d-%tky = travel_booking_link[ KEY id source-%tky = <fs_book>-%tky  ]-target-%tky )
                         %element-CustomerID = if_abap_behv=>mk-on
        ) TO reported-zr_bookingapp_dra.


      ENDIF.
      IF <fs_book>-CustomerId IS NOT INITIAL AND NOT line_exists( ls_customer[ customer_id = <fs_book>-CustomerId  ] ).
        failed-zr_bookingapp_dra = VALUE #( ( %tky = <fs_book>-%tky ) ).
        APPEND VALUE #(  %tky = <fs_book>-%tky
                         %state_area = 'CustomerId'
                         %msg = NEW /dmo/cm_flight_messages( textid = /dmo/cm_flight_messages=>customer_unkown
                                                            severity = if_abap_behv_message=>severity-error )
                         %path = VALUE #( zr_travelapp_d-%tky = travel_booking_link[ KEY id source-%tky = <fs_book>-%tky  ]-target-%tky )
                         %element-CustomerID = if_abap_behv=>mk-on
        ) TO reported-zr_bookingapp_dra.


      ENDIF.

    ENDLOOP.
  ENDMETHOD.





ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations

