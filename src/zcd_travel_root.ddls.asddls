@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'co'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@Search.searchable: true
define root view entity zcd_travel_root
  provider contract transactional_query
  as projection on ZR_TRAVELapp_D
{
  key TravelUuid,

      TravelId,
      @Consumption.valueHelpDefinition: [{ entity : {name: '/DMO/I_Agency_StdVH', element: 'AgencyID'  } }]
      @ObjectModel.text.element: ['AgencyName']
      @Search.defaultSearchElement: true
      AgencyId,
      _agency.Name as AgencyName,
      @Consumption.valueHelpDefinition: [{ entity: {
          name: '/DMO/I_Customer_StdVH',
          element: 'CustomerID'
      } }]
      @ObjectModel.text.element: [ 'CustomerName' ]
      @Search.defaultSearchElement: true
      CustomerId,

      _customer.FirstName as CustomerName,
      BeginDate,
      EndDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      BookingFee,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      TotalPrice,
      CurrencyCode,
      Description,
      OverallStatus,
      _Status._Text.Text as overallStatusText : localized,
      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      LastChangedAt,
      /* Associations */
      _agency,
      _book : redirected  to  composition child zcd_booking_child,
      _currency,
      _customer,
      _Status
}
