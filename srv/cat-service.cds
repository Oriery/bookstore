using { panev.bookstore as bs } from '../db/schema';
using { API_BUSINESS_PARTNER as external } from './external/API_BUSINESS_PARTNER.csn';


@path:'/browse'
service CatalogService {
    @readonly entity Books as SELECT from bs.Books {*,
        author.name as author
    } excluding { createdBy, modifiedBy, createdAt, modifiedAt };

    @requires_: 'authenticated-user'
    @insertonly
    entity Orders as projection on bs.Orders;

    @readonly
    entity BusinessPartners as projection on external.A_BusinessPartner {
        key BusinessPartner as ID,
        FirstName,
        LastName,
        BusinessPartnerIsBlocked
    };

    event TestEvent {
        SomeInfo: String;
    }
}

annotate CatalogService.Books with @(
    UI: {
        HeaderInfo : {
            $Type : 'UI.HeaderInfoType',
            TypeName : '{i18n>TypeNameSingularBooks}',
            TypeNamePlural : '{i18n>TypeNamePluralBooks}',
            Title: {$Type: 'UI.DataField', Value: title}
        },
        SelectionFields : [ID, title, stock, price, author],
        LineItem : [
            {$Type: 'UI.DataField', Value: ID},
            {$Type: 'UI.DataField', Value: title},
            {$Type: 'UI.DataField', Value: category.name},
            {$Type: 'UI.DataField', Value: stock},
            {$Type: 'UI.DataField', Value: price},
            {$Type: 'UI.DataField', Value: author}
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
                {$Type: 'UI.DataField', Value: author}
            ]
        },
    }
);
