@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root project view for billing item'
@Metadata.allowExtensions: true
//@Metadata.ignorePropagatedAnnotations: true
define view entity ZBILL_ROOT_PROJ_ITEM as projection on Zbill_r_item
{
    key BillId,
    key ItemNo,
    MaterialId,
    Description,
    Quantity,
    ItemAmount,
    Currency,
    Uom,
    /* Associations */
    _header : redirected to parent ZBILL_ROOT_PROJ_HEADER
}
