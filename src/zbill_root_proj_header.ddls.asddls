@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root project view for billing header'
@Metadata.allowExtensions: true
//@Metadata.ignorePropagatedAnnotations: true
define root view entity ZBILL_ROOT_PROJ_HEADER provider contract
transactional_query as projection on ZBILL_R_HEADER

{
    key BillId,
    BillType,
    BillDate,
    CustomerId,
    NetAmount,
    Currency,
    SalesOrg,
    _item : redirected to composition child ZBILL_ROOT_PROJ_ITEM
}
