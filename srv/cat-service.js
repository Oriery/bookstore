module.exports = async (srv) => {
    const { Books, Orders } = cds.entities
    const { BusinessPartners } = srv.entities

    const extSrv = await cds.connect.to('API_BUSINESS_PARTNER')

    // Add some discount for overstocked books
    srv.after("READ", "Books", (each) => {
        if (each.stock > 100) {
            each = makeADiscountOnBook(each, 20)            
        }

        return each
    })

    // Reduce stock of books upon incoming orders
    srv.before ('CREATE','Orders', async (req)=>{
        const tx = cds.transaction(req)
        const order = req.data

        if (order.Items) {
            const affectedRows = await tx.run(order.Items.map(item =>
                UPDATE(Books) 
                .where({ID:item.book_ID})
                .and(`stock >=`, item.amount)
                .set(`stock -=`, item.amount)
                )
            )
            if (affectedRows.some(row => !row)) {
                req.error(409, 'Not enough items, sorry')
            }
        }
    })

    // BUG. It worked fine some times but I don't know when it stopped to
    srv.on('READ', BusinessPartners, req => {
        extSrv.tx(req).run(req.query)
    })

    srv.after('READ', BusinessPartners, (each) => {
        if (each.BusinessPartnerIsBlocked) {
            each.LastName += ' IS BLOCKED'
        }

        return each
    })

    extSrv.on('BusinessPartner/Changed', async msg => {
        console.log('Event consumed "BusinessPartner/Changed": ', msg.data)
        
        const businessPartner = msg.data.KEY[0].BUSINESSPARTNER
        let tx = cds.tx(msg)
        const orders = await tx.run(SELECT('ID').from(Orders).where({createdBy: businessPartner, status: 'processing'}))

        if (!orders.length) return

        // BUG This crashes with "[ERROR] Transaction is committed, no subsequent .run allowed, without prior .begin" even when transaction in lines 52-55 is commented
        const businessPartnerFull = await extSrv.run(SELECT.one('BusinessPartnerIsBlocked').from(BusinessPartners).where({ ID: businessPartner }))

        if (!businessPartnerFull || 
            !businessPartnerFull.BusinessPartnerIsBlocked) return
        
        await Promise.all(orders.map(order => tx.run(UPDATE(Orders).where(order).set({status: 'blocked'}))))
        
        console.log('end ')
        srv.emit('TestEvent', 'Some info about event')
    })
}

function makeADiscountOnBook(book, sale) {
    const temp = book.price * (1 - 0.01 * sale)
    const newPrice1 = Math.round(temp * 100) / 100
    const newPrice2 = Math.ceil(newPrice1) - 0.01 // example: 7.4 -> 7.99

    book.price = newPrice2 < book.price ? newPrice2 : newPrice1
    book.title += " -- NOW ON SALE!!!"

    return book
}
