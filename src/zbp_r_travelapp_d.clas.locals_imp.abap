CLASS lhc_ZR_TRAVELapp_D DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations FOR ZR_TRAVELapp_D RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      REQUEST requested_authorizations FOR ZR_TRAVELapp_D RESULT result.

    METHODS get_instance_features FOR INSTANCE FEATURES
      keys REQUEST requested_features FOR ZR_TRAVELapp_D RESULT result.

    METHODS AcceptTravel FOR MODIFY
       keys FOR ACTION ZR_TRAVELapp_D~AcceptTravel RESULT result.

    METHODS DeductDiscount FOR MODIFY
       keys FOR ACTION ZR_TRAVELapp_D~DeductDiscount RESULT result.

    METHODS RecalTotal FOR MODIFY
       keys FOR ACTION ZR_TRAVELapp_D~RecalTotal.

    METHODS RejectTravel FOR MODIFY
       keys FOR ACTION ZR_TRAVELapp_D~RejectTravel RESULT result.
    METHODS SetStatus FOR DETERMINE ON MODIFY
       keys FOR ZR_TRAVELapp_D~SetStatus.

    METHODS TotalPrice FOR DETERMINE ON MODIFY
       keys FOR ZR_TRAVELapp_D~TotalPrice.

    METHODS SetTravel FOR DETERMINE ON SAVE
       keys FOR ZR_TRAVELapp_D~SetTravel.
    METHODS CustomerIdValidation FOR VALIDATE ON SAVE
       keys FOR ZR_TRAVELapp_D~CustomerIdValidation.

ENDCLASS.

CLASS lhc_ZR_TRAVELapp_D IMPLEMENTATION.

  METHOD get_instance_authorizations.

*    DATA vupdate TYPE abp_behv_auth.
*    DATA vdelete TYPE abp_behv_auth.
*
*    READ ENTITY IN LOCAL MODE ZR_TRAVELapp_d
*    FIELDS ( AgencyId )
*    WITH CORRESPONDING #( keys )
*    RESULT DATA(lt_travel)
*    FAILED failed
*    .
*
*    CHECK lt_travel IS NOT INITIAL.
*
*    SELECT FROM
*    /dmo/a_travel_d AS travel
*    INNER JOIN
*    /dmo/agency AS agency
*    ON
*    travel~agency_id = agency~agency_id
*    FIELDS travel~travel_uuid, agency~agency_id,agency~country_code
*    FOR ALL ENTRIES IN @lt_travel
*    WHERE travel~travel_uuid = @lt_travel-TravelUuid
*    INTO TABLE @DATA(ls_agency_ctry).
*
*
*    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<fs_travel>).
*      READ TABLE ls_agency_ctry ASSIGNING FIELD-SYMBOL(<fs_agency>) WITH KEY travel_uuid = <fs_travel>-TravelUuid.
*      IF requested_authorizations-%update = if_abap_behv=>mk-on.
*        AUTHORITY-CHECK OBJECT '/DMO/TRVL'
*        ID '/dmo/cntry' FIELD <fs_agency>-country_code
*        ID 'actvt' FIELD '02'.
*
*        vupdate =   COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed ELSE if_abap_behv=>auth-unauthorized ).
*
*      ENDIF.
*
*      IF requested_authorizations-%delete = if_abap_behv=>mk-on.
*        AUTHORITY-CHECK OBJECT '/DMO/TRVL'
*          ID '/dmo/cntry' FIELD <fs_agency>-country_code
*          ID 'actvt' FIELD '06'.
*
*        vdelete =   COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed ELSE if_abap_behv=>auth-unauthorized ).
*
*      ENDIF.
*      APPEND VALUE #(  TravelUuid = <fs_travel>-TravelUuid
*       %delete = vdelete
*       %update = vupdate
*        ) TO result.
*
*
*    ENDLOOP.


  ENDMETHOD.

  METHOD get_global_authorizations.
*    IF requested_authorizations-%create = if_abap_behv=>mk-on.
*      AUTHORITY-CHECK OBJECT '/dmo/trvl'
*      ID '/DMO/CNTRY' DUMMY
*      ID 'ACTVT' FIELD '01'.
*      result-%create = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed
*                                ELSE  if_abap_behv=>auth-unauthorized   ).
*    ENDIF.
*
*    IF requested_authorizations-%update = if_abap_behv=>mk-on.
*      AUTHORITY-CHECK OBJECT '/dmo/trvl'
*      ID '/DMO/CNTRY' DUMMY
*      ID 'ACTVT' FIELD '02'.
*      result-%update = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed
*                                ELSE  if_abap_behv=>auth-unauthorized   ).
*    ENDIF.
*
*    IF requested_authorizations-%delete = if_abap_behv=>mk-on.
*      AUTHORITY-CHECK OBJECT '/dmo/trvl'
*      ID '/DMO/CNTRY' DUMMY
*      ID 'ACTVT' FIELD '06'.
*      result-%delete = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed
*                                ELSE  if_abap_behv=>auth-unauthorized   ).
*    ENDIF.
  ENDMETHOD.

  METHOD get_instance_features.

    READ ENTITIES OF zr_travelapp_d
    IN LOCAL MODE
    ENTITY ZR_TRAVELapp_D
    FIELDS ( OverallStatus )
    WITH CORRESPONDING #( keys )
    RESULT DATA(ls_travel)
    FAILED DATA(ls_fail_travel)
    .
    IF ls_fail_travel IS NOT INITIAL.
      failed = ls_fail_travel.
    ENDIF.
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<fs_key>).
      DATA(status) = ls_travel[ KEY id %tky = <fs_key>-%tky ]-OverallStatus.

      APPEND VALUE #(  %tky = <fs_key>-%tky
                          %action-AcceptTravel = COND #( WHEN status = 'A' THEN if_abap_behv=>fc-o-disabled
                                                              ELSE if_abap_behv=>fc-o-enabled )
                          %action-RejectTravel = COND #( WHEN status = 'X' THEN if_abap_behv=>fc-o-disabled
                                                               ELSE if_abap_behv=>fc-o-enabled )
                          %action-DeductDiscount = COND #( WHEN status = 'O' OR status = 'A' THEN if_abap_behv=>fc-o-enabled
                                                                ELSE if_abap_behv=>fc-o-disabled )
       ) TO result.

    ENDLOOP.

  ENDMETHOD.






  METHOD AcceptTravel.
    DATA lt_new_travel TYPE TABLE FOR UPDATE ZR_TRAVELapp_D.
    READ ENTITIES OF ZR_TRAVELapp_D IN LOCAL MODE
    ENTITY ZR_TRAVELapp_D
    FIELDS ( OverallStatus )
    WITH CORRESPONDING #( keys )
    RESULT DATA(ls_travel).
    LOOP AT ls_travel ASSIGNING FIELD-SYMBOL(<fs_travel>).
      .
      APPEND VALUE #(  %tky = <fs_travel>-%tky
                                  OverallStatus = 'A' ) TO lt_new_travel.
    ENDLOOP.

    MODIFY ENTITIES OF ZR_TRAVELapp_D
    IN LOCAL MODE
    ENTITY ZR_TRAVELapp_D
    UPDATE
    FIELDS ( OverallStatus )
    WITH lt_new_travel.

    READ ENTITIES OF ZR_TRAVELapp_D IN LOCAL MODE
      ENTITY ZR_TRAVELapp_D
     ALL FIELDS WITH
     CORRESPONDING #( keys )
     RESULT DATA(travel).

    LOOP AT travel ASSIGNING FIELD-SYMBOL(<f_travel>).

      result = VALUE #( ( %tky = <f_travel>-%tky %param = <f_travel> ) ).
    ENDLOOP.

  ENDMETHOD.

  METHOD DeductDiscount.

    DATA(ls_keys) = keys.

    LOOP AT ls_keys ASSIGNING FIELD-SYMBOL(<fs_keys>) WHERE %param-discount IS INITIAL OR %param-discount LE 0 OR %param-discount GT 100 .

      APPEND VALUE #(   %tky = <fs_keys>-%tky  ) TO failed-zr_travelapp_d.
      APPEND VALUE #(  %tky = <fs_keys>-%tky
                                           %msg = NEW  /dmo/cm_flight_messages(
        textid                = /dmo/cm_flight_messages=>discount_invalid
        severity              = if_abap_behv_message=>severity-error
      )
      %element-bookingfee = if_abap_behv=>mk-on
      %action-deductdiscount = if_abap_behv=>mk-on
                                            ) TO reported-zr_travelapp_d .

      DELETE ls_keys.
    ENDLOOP.

    CHECK ls_keys IS NOT INITIAL.

    READ ENTITIES OF ZR_TRAVELapp_D IN LOCAL MODE
    ENTITY ZR_TRAVELapp_D
    ALL FIELDS WITH
    CORRESPONDING #( ls_keys )
    RESULT DATA(ls_travel).

    DATA lt_new_travel TYPE TABLE FOR UPDATE ZR_TRAVELapp_D.
    DATA : lv_dic TYPE decfloat16.
    LOOP AT ls_travel ASSIGNING FIELD-SYMBOL(<fs_travel>).


      DATA(lv_discount) = ls_keys[ KEY id %tky = <fs_travel>-%tky ]-%param-discount.
      lv_dic = lv_discount / 100.
      DATA(ls_new_bkfee) = <fs_travel>-BookingFee - ( <fs_travel>-BookingFee * lv_dic ).

      APPEND VALUE #(   %tky = <fs_travel>-%tky BookingFee = ls_new_bkfee  ) TO lt_new_travel  .

    ENDLOOP.

    MODIFY ENTITIES OF ZR_TRAVELapp_D
    IN LOCAL MODE
    ENTITY ZR_TRAVELapp_D
    UPDATE FIELDS ( BookingFee )
    WITH lt_new_travel.

    READ ENTITIES OF zr_travelapp_d IN LOCAL MODE
    ENTITY ZR_TRAVELapp_D
    ALL FIELDS WITH
    CORRESPONDING #( ls_keys )
    RESULT DATA(ls_new_travel).

    LOOP AT ls_new_travel ASSIGNING FIELD-SYMBOL(<fs_new_travel>).
      APPEND VALUE #(    %tky = <fs_new_travel>-%tky %param = <fs_new_travel>  ) TO result.
    ENDLOOP.

  ENDMETHOD.

  METHOD RecalTotal.

    TYPES:
      BEGIN OF ty_amt_per_ccode,
        amount        TYPE /dmo/total_price,
        currency_code TYPE /dmo/currency_code,
      END OF ty_amt_per_ccode.

    DATA:
      lt_amt_per_ccode TYPE STANDARD TABLE OF ty_amt_per_ccode,
      lt_update        TYPE TABLE FOR UPDATE zr_travelapp_d,
      lv_updated_total TYPE /dmo/total_price.

    "Read Travel including current TotalPrice
    READ ENTITIES OF zr_travelapp_d IN LOCAL MODE
      ENTITY ZR_TRAVELapp_D
        FIELDS ( TravelUuid BookingFee CurrencyCode TotalPrice )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_travel).

    "Currency code is required for conversion
    DELETE lt_travel WHERE CurrencyCode IS INITIAL.

    "Read related bookings
    READ ENTITIES OF zr_travelapp_d IN LOCAL MODE
      ENTITY ZR_TRAVELapp_D
        BY \_book
        FIELDS ( BookingUuid ParentUuid FlightPrice CurrencyCode )
        WITH CORRESPONDING #( lt_travel )
      RESULT DATA(lt_booking).

    "Corrected: remove rows having empty currency
    DELETE lt_booking WHERE CurrencyCode IS INITIAL.

    "Read related supplements
    READ ENTITIES OF zr_travelapp_d IN LOCAL MODE
      ENTITY zr_bookingapp_dra
        BY \_supply
        FIELDS ( RootUuid ParentUuid Price CurrencyCode )
        WITH CORRESPONDING #( lt_booking )
      RESULT DATA(lt_supply).

    "Corrected: remove rows having empty currency
    DELETE lt_supply WHERE CurrencyCode IS INITIAL.

    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<fs_travel>).

      CLEAR:
        lt_amt_per_ccode,
        lv_updated_total.

      "Add Travel booking fee
      APPEND VALUE #(
        amount        = <fs_travel>-BookingFee
        currency_code = <fs_travel>-CurrencyCode
      ) TO lt_amt_per_ccode.

      "Add booking prices
      LOOP AT lt_booking ASSIGNING FIELD-SYMBOL(<fs_booking>)
           WHERE ParentUuid = <fs_travel>-TravelUuid.

        APPEND VALUE #(
          amount        = <fs_booking>-FlightPrice
          currency_code = <fs_booking>-CurrencyCode
        ) TO lt_amt_per_ccode.

        "Add supplement prices for the booking
        LOOP AT lt_supply ASSIGNING FIELD-SYMBOL(<fs_supply>)
             WHERE ParentUuid = <fs_booking>-BookingUuid
               AND RootUuid   = <fs_travel>-TravelUuid.

          APPEND VALUE #(
            amount        = <fs_supply>-Price
            currency_code = <fs_supply>-CurrencyCode
          ) TO lt_amt_per_ccode.

        ENDLOOP.

      ENDLOOP.

      LOOP AT lt_amt_per_ccode ASSIGNING FIELD-SYMBOL(<fs_amount>).

        DATA(lv_amount) = <fs_amount>-amount.

        IF <fs_amount>-currency_code <> <fs_travel>-CurrencyCode.

          TRY.

              /dmo/cl_flight_amdp=>convert_currency(
                EXPORTING
                  iv_amount               = lv_amount
                  iv_currency_code_source = <fs_amount>-currency_code
                  iv_currency_code_target = <fs_travel>-CurrencyCode
                  iv_exchange_rate_date   = cl_abap_context_info=>get_system_date( )
                IMPORTING
                  ev_amount               = lv_amount
              ).

            CATCH cx_root INTO DATA(lx_error).

              "Handle the error here
              DATA(lv_error_text) = lx_error->get_text( ).

          ENDTRY.

        ENDIF.

        lv_updated_total += lv_amount.

      ENDLOOP.

      "Important: update only if the value actually changed
      IF <fs_travel>-TotalPrice <> lv_updated_total.

        APPEND VALUE #(
          %tky       = <fs_travel>-%tky
          TotalPrice = lv_updated_total
          %control-TotalPrice = if_abap_behv=>mk-on
        ) TO lt_update.

      ENDIF.

    ENDLOOP.

    IF lt_update IS NOT INITIAL.

      MODIFY ENTITIES OF zr_travelapp_d IN LOCAL MODE
        ENTITY ZR_TRAVELapp_D
          UPDATE FIELDS ( TotalPrice )
          WITH lt_update
        REPORTED DATA(lt_reported)
        FAILED   DATA(lt_failed).

    ENDIF.

  ENDMETHOD.
  METHOD RejectTravel.
    DATA lt_new_travel TYPE TABLE FOR UPDATE ZR_TRAVELapp_D.
    READ ENTITIES OF ZR_TRAVELapp_D IN LOCAL MODE
    ENTITY ZR_TRAVELapp_D
    FIELDS ( OverallStatus )
    WITH CORRESPONDING #( keys )
    RESULT DATA(ls_travel).
    LOOP AT ls_travel ASSIGNING FIELD-SYMBOL(<fs_travel>).
      .
      APPEND VALUE #(  %tky = <fs_travel>-%tky
                                  OverallStatus = 'X' ) TO lt_new_travel.
    ENDLOOP.

    MODIFY ENTITIES OF ZR_TRAVELapp_D
    IN LOCAL MODE
    ENTITY ZR_TRAVELapp_D
    UPDATE
    FIELDS ( OverallStatus )
    WITH lt_new_travel.

    READ ENTITIES OF ZR_TRAVELapp_D IN LOCAL MODE
      ENTITY ZR_TRAVELapp_D
     ALL FIELDS WITH
     CORRESPONDING #( keys )
     RESULT DATA(travel).

    LOOP AT travel ASSIGNING FIELD-SYMBOL(<f_travel>).

      result = VALUE #( ( %tky = <f_travel>-%tky %param = <f_travel> ) ).
    ENDLOOP.
  ENDMETHOD.

  METHOD SetStatus.
    READ ENTITIES OF zr_travelapp_d
  IN LOCAL MODE
  ENTITY ZR_TRAVELapp_D
  FIELDS ( OverallStatus )
  WITH CORRESPONDING #( keys )
  RESULT DATA(ls_travel).

    DELETE ls_travel WHERE OverallStatus IS NOT INITIAL.
    CHECK ls_travel IS NOT INITIAL.

    LOOP AT ls_travel ASSIGNING FIELD-SYMBOL(<fs_travel>).

      MODIFY ENTITIES OF zr_travelapp_d
      IN LOCAL MODE
      ENTITY ZR_TRAVELapp_D
      UPDATE FIELDS ( OverallStatus )
      WITH VALUE #( (  %tky = <fs_travel>-%tky OverallStatus = 'O' ) ).
    ENDLOOP.

  ENDMETHOD.

  METHOD TotalPrice.
    MODIFY ENTITIES OF zr_travelapp_d IN LOCAL MODE
    ENTITY ZR_TRAVELapp_D
    EXECUTE RecalTotal
    FROM CORRESPONDING #( keys ).

  ENDMETHOD.

  METHOD SetTravel.

    READ ENTITIES OF zr_travelapp_d
    IN LOCAL MODE
    ENTITY ZR_TRAVELapp_D
    FIELDS ( TravelId )
    WITH CORRESPONDING #( keys )
    RESULT DATA(ls_travel).

    DELETE ls_travel WHERE TravelId IS NOT INITIAL.
    CHECK ls_travel IS NOT INITIAL.

    SELECT FROM
    /dmo/a_travel_d
    FIELDS MAX( travel_id )
    INTO @DATA(last_travelId).

    LOOP AT ls_travel ASSIGNING FIELD-SYMBOL(<fs_travel>).
      last_travelid += 1.
      MODIFY ENTITIES OF zr_travelapp_d
      IN LOCAL MODE
      ENTITY ZR_TRAVELapp_D
      UPDATE FIELDS ( TravelId )
      WITH VALUE #( (  %tky = <fs_travel>-%tky TravelId = last_travelId ) ).
    ENDLOOP.


  ENDMETHOD.

  METHOD CustomerIdValidation.

    READ ENTITIES OF zr_travelapp_d IN LOCAL MODE
    ENTITY zr_travelapp_d
    FIELDS ( CustomerId )
    WITH CORRESPONDING #( keys )
    RESULT DATA(ls_travel).

    DATA ls_customer TYPE SORTED TABLE OF /dmo/customer WITH UNIQUE KEY customer_id.


    ls_customer = CORRESPONDING #( ls_travel DISCARDING DUPLICATES MAPPING customer_id = CustomerId EXCEPT * ).

    IF ls_customer IS NOT INITIAL.
      SELECT FROM /dmo/customer
      FIELDS customer_id
      FOR ALL ENTRIES IN @ls_customer
      WHERE customer_id = @ls_customer-customer_id
      INTO TABLE @DATA(ls_fetched_customerId).

    ENDIF.


    LOOP AT ls_travel ASSIGNING FIELD-SYMBOL(<fs_travel>).

      reported-zr_travelapp_d = VALUE #( ( %tky = <fs_travel>-%tky %state_area = 'Validate_CustomerID' ) ).

      IF <fs_travel>-CustomerId IS INITIAL.
        APPEND VALUE #(  %tky = <fs_travel>-%tky
                                             %state_area = 'Validate_CustomerID'
                                             %msg = NEW /dmo/cm_flight_messages(
          textid                = /dmo/cm_flight_messages=>enter_customer_id
          severity              = if_abap_behv_message=>severity-error
        )
          ) TO reported-zr_travelapp_d.
      ENDIF.

      IF <fs_travel>-CustomerId IS NOT INITIAL AND NOT line_exists( ls_fetched_customerid[ customer_id = <fs_travel>-CustomerId ] ) .
        APPEND VALUE #(  %tky = <fs_travel>-%tky
                                             %state_area = 'Validate_CustomerID'
                                             %msg = NEW /dmo/cm_flight_messages(
          textid                = /dmo/cm_flight_messages=>customer_unkown
          severity              = if_abap_behv_message=>severity-error
        )
          ) TO reported-zr_travelapp_d.
      ENDIF.


    ENDLOOP.


  ENDMETHOD.

ENDCLASS.
