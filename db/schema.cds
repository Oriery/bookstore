namespace panev.bookstore;

using { Currency, managed, cuid } from '@sap/cds/common';
using { panev.products.Products } from '../products';

entity Books : Products {
    author   : Association to Authors;
}

entity Magazines : Products {
    publisher   : String;
}

entity Authors : managed {
    key ID   : Integer;
    name     : String(64);
    books    : Association to many Books on books.author = $self;
}

entity Orders : managed, cuid {
    OrderNo  : String @title:'Order Number'; //> readable key
    Items    : Composition of many OrderItems on Items.parent = $self;
}

entity OrderItems : cuid {
    parent   : Association to Orders;
    book     : Association to Books;
    amount   : Integer;
}

annotate Books with {
    ID @(Common: {Label: 'ID'});
    title @(Common: {Label: '{i18n>PropertyTitle}'});
    stock @(Common: {Label: '{i18n>PropertyStock}'}, Measures.Unit: '{i18n>WordPCS}');
    price @(Common: {Label: '{i18n>PropertyPrice}'}, Measures.ISOCurrency: currency_code);
};

annotate Authors with {
    name @(Common: {Label : '{i18n>PropertyAuthor}'})
};
