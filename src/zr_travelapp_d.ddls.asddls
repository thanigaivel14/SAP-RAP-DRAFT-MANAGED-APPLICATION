@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'travel'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZR_TRAVELapp_D
  as select from /dmo/a_travel_d
  composition [0..*] of zr_bookingapp_dra        as _book
  association [0..1] to /DMO/I_Customer          as _customer on $projection.CustomerId = _customer.CustomerID
  association [0..1] to /DMO/I_Agency            as _agency   on $projection.AgencyId = _agency.AgencyID
  association [1..1] to I_Currency               as _currency on $projection.CurrencyCode = _currency.Currency
  association [1..1] to /DMO/I_Overall_Status_VH as _Status   on $projection.OverallStatus = _Status.OverallStatus




{
  key travel_uuid           as TravelUuid,
      travel_id             as TravelId,
      agency_id             as AgencyId,
      customer_id           as CustomerId,
      begin_date            as BeginDate,
      end_date              as EndDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      booking_fee           as BookingFee,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      total_price           as TotalPrice,
      currency_code         as CurrencyCode,
      description           as Description,
      overall_status        as OverallStatus,
      local_created_by      as LocalCreatedBy,
      local_created_at      as LocalCreatedAt,
      local_last_changed_by as LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      _book,
      _customer,
      _agency,
      _currency,
      _Status
}
