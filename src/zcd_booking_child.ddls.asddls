@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'consumption for booking'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@Search.searchable: true
define view entity zcd_booking_child as projection on zr_bookingapp_dra
{
    key BookingUuid,
    ParentUuid,
    BookingId,
    BookingDate,
    @Search.defaultSearchElement: true
    CustomerId,
    CarrierId,
    ConnectionId,
    FlightDate,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    FlightPrice,
    CurrencyCode,
    BookingStatus,
    LocalLastChangedAt,
    /* Associations */
    _currency,
    _customer,
    _flight,
    _Status,
    _supply: redirected to composition child zcd_supplement_child,
    _travel: redirected to parent zcd_travel_root
}
