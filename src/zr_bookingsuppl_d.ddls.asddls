@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'booking supplement csd'
@Metadata.ignorePropagatedAnnotations: true
define view entity zr_bookingSuppl_d
  as select from /dmo/a_bksuppl_d
  association        to parent zr_bookingapp_dra as _booking  on $projection.ParentUuid = _booking.BookingUuid
  association [1..1] to ZR_TRAVELapp_D as _travel on $projection.RootUuid = _travel.TravelUuid 
  association [1..1] to I_Currency               as _currency on $projection.CurrencyCode = _currency.Currency
{
  key booksuppl_uuid        as BooksupplUuid,
      root_uuid             as RootUuid,
      parent_uuid           as ParentUuid,
      booking_supplement_id as BookingSupplementId,
      supplement_id         as SupplementId,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      price                 as Price,
      currency_code         as CurrencyCode,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      _booking,
      _currency,
      _travel
}
