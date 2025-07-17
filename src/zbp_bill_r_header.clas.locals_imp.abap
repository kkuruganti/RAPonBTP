CLASS lhc_ZBILL_R_HEADER DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zbill_r_header RESULT result.
    METHODS validatecurrency FOR VALIDATE ON SAVE
      IMPORTING keys FOR zbill_r_header~validatecurrency.
    METHODS setsystemdate FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zbill_r_header~setsystemdate.
    METHODS updatecustomername FOR MODIFY
      IMPORTING keys FOR ACTION zbill_r_header~updatecustomername RESULT result.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zbill_r_header RESULT result.

*    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
*      IMPORTING REQUEST requested_authorizations FOR zbill_r_header RESULT result.

ENDCLASS.

CLASS lhc_ZBILL_R_HEADER IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

*  METHOD get_global_authorizations.
*  ENDMETHOD.

  METHOD validateCurrency.

*  // Read the data

    READ ENTITIES OF zbill_r_header IN LOCAL MODE
    ENTITY zbill_r_header
    FIELDS ( BillId  Currency )
    WITH CORRESPONDING #( keys )
    RESULT DATA(billings).

*data(ls_billing) = billing[ 1 ].
    IF billings IS NOT INITIAL.
      SELECT  FROM i_currency FIELDS currency
      FOR ALL ENTRIES IN @billings
      WHERE Currency = @billings-currency INTO TABLE @DATA(lt_currency) .
    ENDIF.

    LOOP AT billings INTO DATA(ls_billing).


      APPEND VALUE #(  %tky                 = ls_billing-%tky
                       %state_area          = 'VALIDATE_CURRENCY'
                     ) TO reported-zbill_r_header.

      IF ls_billing-currency IS INITIAL.

        APPEND VALUE #(  %tky                 = ls_billing-%tky
                         %state_area          = 'VALIDATE_CUSTOMER'
                       ) TO reported-zbill_r_header.

      ELSEIF ls_billing-currency IS NOT INITIAL AND NOT line_exists( lt_currency[ currency = ls_billing-Currency  ] ).
        APPEND VALUE #(  %tky = ls_billing-%tky ) TO failed-zbill_r_header.
        APPEND VALUE #(  %tky                = ls_billing-%tky
                               %state_area         = 'VALIDATE_CURRENCY'
                         %msg                = new_message_with_text(

                                   severity = if_abap_behv_message=>severity-error
                                  text       = |Validation failed for currency: { ls_billing-currency }|
                               )


                            ) TO reported-zbill_r_header.

      ENDIF.
    ENDLOOP.


  ENDMETHOD.

  METHOD setSystemDate.

    READ ENTITIES OF zbill_r_header IN LOCAL MODE
   ENTITY zbill_r_header
   FIELDS ( billid BillDate SalesOrg )
   WITH CORRESPONDING #( keys )
   RESULT DATA(lt_data).

    IF lt_data[ 1 ]-SalesOrg = '1000'.

      MODIFY ENTITIES OF zbill_r_header IN LOCAL MODE
      ENTITY zbill_r_header
      UPDATE FIELDS ( BillDate )
      WITH VALUE #(  FOR ls_data IN lt_data
                                      ( %tky = ls_data-%tky
                                      BillDate = cl_abap_context_info=>get_system_date( ) ) ).


    ENDIF.



  ENDMETHOD.

  METHOD updateCustomerName.

   READ ENTITIES OF zbill_r_header IN LOCAL MODE
   ENTITY zbill_r_header
   ALL FIELDS
   WITH CORRESPONDING #( keys )
   RESULT DATA(lt_billdata).

  ENDMETHOD.

  METHOD get_instance_features.
  ENDMETHOD.

ENDCLASS.
