import VRContract from 0x2
import ExampleToken from 0x1
import VRMarket from 0x03

transaction {
    let vrToken: @VRContract.NFT

    prepare(acct: AuthAccount) {
        let collectionRef = acct.borrow<&VRContract.Collection>(from: /storage/NFTCollection)
            ?? panic("Could not borrow a reference to the owner's collection")

        self.vrToken <- collectionRef.withdraw(withdrawID: 3)

    }

    execute {
        let acct = getAccount(0x3)
        let listingRef = acct.getCapability<&{VRMarket.MarketInterface}>(/public/VRMarket)
            .borrow() ?? panic("hhhhhh")

        listingRef.sell(vr:<- self.vrToken, seller: 0x03, price: 6.0)

        log("NFT token is placed in the listing")
    }
}