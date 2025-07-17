@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface view for Billing Doc Item'
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity Zbill_r_item as select from zbilling_item
association to parent ZBILL_R_HEADER as _header on $projection.BillId = _header.BillId
{
    key bill_id as BillId,
    key item_no as ItemNo,
    material_id as MaterialId,
    description as Description,
    quantity as Quantity,
    item_amount as ItemAmount,
    currency as Currency,
    uom as Uom,
    _header
//    _association_name // Make association public
}
