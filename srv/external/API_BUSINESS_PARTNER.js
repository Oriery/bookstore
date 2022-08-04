module.exports = srv => {
    const { A_BusinessPartner } = srv.entities

    srv.on(['CREATE', 'UPDATE', 'DELETE'], A_BusinessPartner, req => {
        const payload = { KEY: [{BUSINESSPARTNER: req.data.BusinessPartner}]}

        cds.run(req.query)

        srv.emit('BusinessPartner/Changed', payload)
        console.log('Event emitted "BusinessPartner/Changed": ', payload, req.event)
    })
}