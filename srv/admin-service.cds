using { panev.bookstore as my } from '../db/schema';

service AdminService @(_requires:'admin') {
    entity Books as projection on my.Books;
    entity Authors as projection on my.Authors;
    entity Orders as select from my.Orders;
}

annotate AdminService.Books with @(
    UI: {
        HeaderInfo : {
            $Type : 'UI.HeaderInfoType',
            TypeName : '{i18n>TypeNameSingularBooks}',
            TypeNamePlural : '{i18n>TypeNamePluralBooks}',
            Title: {$Type: 'UI.DataField', Value: title}
        },
        SelectionFields : [ID, title, stock, price, author.name],
        LineItem : [
            {$Type: 'UI.DataField', Value: ID},
            {$Type: 'UI.DataField', Value: title},
            {$Type: 'UI.DataField', Value: category.name},
            {$Type: 'UI.DataField', Value: stock},
            {$Type: 'UI.DataField', Value: price},
            {$Type: 'UI.DataField', Value: author.name}
        ],
        HeaderFacets : [
            {$Type: 'UI.ReferenceFacet', Target: '@UI.FieldGroup#BookDetail', Label: '{i18n>HeaderFacetDetails}'},
            {$Type: 'UI.ReferenceFacet', Target: '@UI.DataPoint#Price'}
        ],
        Facets : [
            {
                $Type: 'UI.CollectionFacet',
                Label: '{i18n>FacetProductInformation}',
                Facets: [
                    {$Type: 'UI.ReferenceFacet', Target: '@UI.FieldGroup#Description', Label: '{i18n>FacetSectionDescription}'}
                ]
            }
        ],
        DataPoint#Price : {
            $Type : 'UI.DataPointType',
            Value : price,
            Title : '{i18n>HeaderPrice}'
        },
        FieldGroup#Description : {
            $Type : 'UI.FieldGroupType',
            Data: [
                {$Type: 'UI.DataField', Value: descr}
            ]
        },
        FieldGroup#BookDetail : {
            $Type : 'UI.FieldGroupType',
            Data: [
                {$Type: 'UI.DataField', Value: ID},
                {$Type: 'UI.DataField', Value: stock},
                {$Type: 'UI.DataField', Value: author.name}
            ]
        },
    }
);
