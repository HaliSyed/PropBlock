import VRContract from 0x2
import ExampleToken from 0x1
import VRMarket from 0x03

transaction {
    var temporaryVault: @ExampleToken.Vault

  prepare(acct: AuthAccount) {
    // withdraw tokens from your vault by borrowing a reference to it
    // and calling the withdraw function with that reference
    let vaultRef = acct.borrow<&ExampleToken.Vault>(from: /storage/MainVault)
        ?? panic("Could not borrow a reference to the owner's vault")
      
    self.temporaryVault <- vaultRef.withdraw(amount: 7.0)
  }

  execute{
    let acct = getAccount(0x3)
        let listingRef = acct.getCapability<&{VRMarket.MarketInterface}>(/public/VRMarket)
            .borrow() ?? panic("hhhhhh")

    listingRef.buy(listing: 1, with: <- self.temporaryVault, buyer: 0x01)
  }
}