CLASS lhc_zr_bookingsuppl_d DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS SupplementId FOR VALIDATE ON SAVE
       keys FOR zr_bookingSuppl_d~SupplementId.

ENDCLASS.

CLASS lhc_zr_bookingsuppl_d IMPLEMENTATION.

  METHOD SupplementId.

    READ ENTITIES OF zr_travelapp_d IN LOCAL MODE
    ENTITY zr_bookingSuppl_d
    FIELDS ( SupplementId )
    WITH CORRESPONDING #( keys )
    RESULT DATA(ls_supply).

    DATA supplement TYPE SORTED TABLE OF /dmo/supplement WITH UNIQUE KEY supplement_id .
    supplement = CORRESPONDING #( ls_supply DISCARDING DUPLICATES MAPPING supplement_id = SupplementId EXCEPT * ).

    SELECT FROM /dmo/supplement FIELDS ( supplement_id )
    FOR ALL ENTRIES IN @supplement
    WHERE supplement_id = @supplement-supplement_id
    INTO TABLE @DATA(supplyid).


    READ ENTITIES OF zr_travelapp_d IN LOCAL MODE
     ENTITY zr_bookingSuppl_d BY \_booking
     FROM CORRESPONDING #( keys )
     RESULT DATA(ls_read_book)
     LINK DATA(supply_book_link).


    READ ENTITIES OF zr_travelapp_d IN LOCAL MODE
    ENTITY zr_bookingSuppl_d BY \_travel
    FROM CORRESPONDING #( keys )
    RESULT DATA(ls_read_travel)
    LINK DATA(supply_travel_link).

    LOOP AT ls_supply ASSIGNING FIELD-SYMBOL(<fs_supply>).

*  APPEND  VALUE #(  %tky = <fs_supply>-%tky
*                    %state_area = 'validate_supplyId'
*                    ) TO reported-zr_bookingsuppl_d.

      IF <fs_supply>-SupplementId IS INITIAL.

        APPEND VALUE #(  %tky = <fs_supply>-%tky ) TO failed-zr_bookingsuppl_d.
        APPEND  VALUE #(  %tky = <fs_supply>-%tky
                                                %msg = NEW /dmo/cm_flight_messages( textid = /dmo/cm_flight_messages=>enter_supplement_id
                                                                                     severity = if_abap_behv_message=>severity-error
                                                                                      )
                                                 %path = VALUE #( zr_travelapp_d-%tky = supply_travel_link[ KEY id source-%tky = <fs_supply>-%tky ]-target-%tky
                                                                  zr_bookingapp_dra-%tky = supply_book_link[ KEY id source-%tky = <fs_supply>-%tky ]-target-%tky
                                                                    )
                                                  %state_area = 'validate_supplyId'
                                                  %element-supplementid = if_abap_behv=>mk-on


                                                    ) TO reported-zr_bookingsuppl_d.
      ENDIF.
      IF <fs_supply>-SupplementId IS NOT INITIAL AND NOT line_exists( supplyid[ supplement_id = <fs_supply>-SupplementId ] ).

        APPEND  VALUE #(  %tky = <fs_supply>-%tky ) TO failed-zr_bookingsuppl_d.
        APPEND  VALUE #(  %tky = <fs_supply>-%tky
                                                %msg = NEW /dmo/cm_flight_messages( textid = /dmo/cm_flight_messages=>supplement_unknown
                                                                                     severity = if_abap_behv_message=>severity-error
                                                                                      )
                                                 %path = VALUE #( zr_travelapp_d-%tky = supply_travel_link[ KEY id source-%tky = <fs_supply>-%tky ]-target-%tky
                                                                  zr_bookingapp_dra-%tky = supply_book_link[ KEY id source-%tky = <fs_supply>-%tky ]-target-%tky
                                                                    )
                                                 %state_area = 'validate_supplyId'
                                                 %element-supplementid = if_abap_behv=>mk-on

                                                    ) TO reported-zr_bookingsuppl_d.
      ENDIF.

    ENDLOOP.


  ENDMETHOD.

ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations

