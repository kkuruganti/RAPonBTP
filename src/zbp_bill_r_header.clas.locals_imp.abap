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
    METHODS copyheader FOR MODIFY
      IMPORTING keys FOR ACTION zbill_r_header~copyheader.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zbill_r_header RESULT result.

ENDCLASS.

CLASS lhc_ZBILL_R_HEADER IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

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

  METHOD copyHeader.
    DATA: headers      TYPE TABLE FOR CREATE zbill_r_header.
    READ TABLE keys WITH KEY  %cid = ' ' INTO DATA(key_with_initial_cid).
    ASSERT key_with_initial_cid IS INITIAL.

    READ ENTITIES OF zbill_r_header IN LOCAL MODE
    ENTITY zbill_r_header
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_header) FAILED failed.

*
    LOOP AT lt_header ASSIGNING FIELD-SYMBOL(<ls_header>).

      APPEND VALUE #( %cid      = keys[ KEY entity %key = <ls_header>-%key ]-%cid
                       %is_draft = keys[ KEY entity %key = <ls_header>-%key ]-%param-%is_draft
                       %data     = CORRESPONDING #( <ls_header> EXCEPT BILLID )
                    )
         TO headers  ASSIGNING FIELD-SYMBOL(<new_header>).

    ENDLOOP.

    MODIFY ENTITIES OF zbill_r_header IN LOCAL MODE
    ENTITY zbill_r_header
    CREATE FIELDS ( BILLID   BillType BillDate  CustomerId NetAmount Currency SalesOrg )
    WITH headers
    MAPPED DATA(mapped_create).

*    mapped_create-zbill_r_header[ 1 ]-%cid = headers[ 1 ]-%cid .
*    mapped_create-zbill_r_header[ 1 ]-%is_draft = headers[ 1 ]-%is_draft.
*    mapped_create-zbill_r_header[ 1 ]-BILLID = headers[ 1 ]-BILLID.

*    MOVE-CORRESPONDING headers TO mapped_create-zbill_r_header.
    mapped-zbill_r_header = mapped_create-zbill_r_header.



  ENDMETHOD.

ENDCLASS.
