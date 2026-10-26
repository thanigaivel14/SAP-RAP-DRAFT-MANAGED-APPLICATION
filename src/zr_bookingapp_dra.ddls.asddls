@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'booking cds'
@Metadata.ignorePropagatedAnnotations: true
define view entity zr_bookingapp_dra
  as select from /dmo/a_booking_d
  association        to parent ZR_TRAVELapp_D    as _travel   on $projection.ParentUuid = _travel.TravelUuid
  association [0..1] to /DMO/I_Customer          as _customer on $projection.CustomerId = _customer.CustomerID
  association [1..1] to I_Currency               as _currency on $projection.CurrencyCode = _currency.Currency
  association [0..*] to /DMO/I_Flight            as _flight   on $projection.CarrierId = _flight.AirlineID
  association [1..1] to /DMO/I_Overall_Status_VH as _Status   on $projection.BookingStatus = _Status.OverallStatus
  composition [0..*] of zr_bookingSuppl_d as _supply 
{
  key booking_uuid          as BookingUuid,
      parent_uuid           as ParentUuid,
      booking_id            as BookingId,
      booking_date          as BookingDate,
      customer_id           as CustomerId,
      carrier_id            as CarrierId,
      connection_id         as ConnectionId,
      flight_date           as FlightDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      flight_price          as FlightPrice,
      currency_code         as CurrencyCode,
      booking_status        as BookingStatus,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      _travel,
      _customer,
      _currency,
      _flight,
      _Status,
      _supply
}
