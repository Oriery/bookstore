using { panev.bookstore as bs } from '../db/schema';

@path:'/browse'
service CatalogService {
    @readonly entity Books as SELECT from bs.Books {*,
        author.name as author
    } excluding { createdBy, modifiedBy, createdAt, modifiedAt };

    @requires_: 'authenticated-user'
    @insertonly 
    entity Orders as projection on bs.Orders;
}