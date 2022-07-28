module.exports = (srv) => {
    const { Books } = cds.entities

    // Add some discount for overstocked books
    srv.after("READ", "Books", (books) => {
        if (Array.isArray(books)) {
            return books.map((book) => {
                if (book.stock > 100) {
                    book = makeADiscountOnBook(book, 20)            
                }
            })
        }
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
}

function makeADiscountOnBook(book, sale) {
    const temp = book.price * (1 - 0.01 * sale)
    const newPrice1 = Math.round(temp * 100) / 100
    const newPrice2 = Math.ceil(newPrice1) - 0.01 // example: 7.4 -> 7.99

    book.price = newPrice2 < book.price ? newPrice2 : newPrice1
    book.title += " -- NOW ON SALE!!!"

    return book
}
