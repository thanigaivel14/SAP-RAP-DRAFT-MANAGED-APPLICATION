@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'consumption for supplement'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity zcd_supplement_child
  as projection on zr_bookingSuppl_d
{
  key BooksupplUuid,
      RootUuid,
      ParentUuid,
      BookingSupplementId,
      @Consumption.valueHelpDefinition: [{
          entity: {
              name: '/DMO/I_Supplement_StdVH',
              element: 'SupplementID'
          },useForValidation: true,
          additionalBinding: [{ localElement: 'Price', element: 'Price'  } ]
      }]
      SupplementId,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      Price,
      CurrencyCode,
      LocalLastChangedAt,
      /* Associations */
      _booking : redirected to parent zcd_booking_child,
      _currency,
      _travel  : redirected to zcd_travel_root
}
