namespace panev.bookstore;

using { Currency, managed } from '@sap/cds/common';

entity Books : managed {
    key ID : Integer;
    title : localized String(64);
    descr    : localized String(1024);
    author   : Association to Authors;
    stock    : Integer;
    price    : Decimal(9,2);
    currency : Currency;
}

entity Authors : managed {
    key ID   : Integer;
    name     : String(64);
    books    : Association to many Books on books.author = $self;
}

entity Orders : managed {
    key ID   : UUID;
    OrderNo  : String @title:'Order Number'; //> readable key
    Items    : Composition of many OrderItems on Items.parent = $self;
}
entity OrderItems {
    key ID   : UUID;
    parent   : Association to Orders;
    book     : Association to Books;
    amount   : Integer;
}