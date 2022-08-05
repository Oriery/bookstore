module.exports = srv => {
    const { A_BusinessPartner } = srv.entities

    srv.after(['CREATE', 'UPDATE', 'DELETE'], A_BusinessPartner, data => {
        const payload = { KEY: [{BUSINESSPARTNER: data.BusinessPartner}]}

        srv.emit('BusinessPartner/Changed', payload)
        console.log('Event emitted "BusinessPartner/Changed": ', payload)
    })
}