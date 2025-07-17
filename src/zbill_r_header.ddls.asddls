@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root View for billing document header'
//@Metadata.ignorePropagatedAnnotations: true
define root view entity ZBILL_R_HEADER as select from 
zbilling_header composition  [0..*] of Zbill_r_item as _item

{
    key bill_id as BillId,
    bill_type as BillType,
    bill_date as BillDate,
    customer_id as CustomerId,    
    net_amount as NetAmount,
    currency as Currency,
    sales_org as SalesOrg,
    _item
//    _association_name // Make association public
}
