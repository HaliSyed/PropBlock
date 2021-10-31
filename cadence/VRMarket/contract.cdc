import VRContract from 0x02
import ExampleToken from 0x1

pub contract VRMarket {
  
  // pub event ItemPosted(seller: Address, pixels: String)
  // pub event ItemWithdrawn(seller: Address, pixels: String)
  // pub event ItemSold(seller: Address, pixels: String, buyer: Address)

  pub struct Listing {

    pub let uri: String
    pub let seller: Address
    pub let price: UFix64
    pub let index: Int

    init(uri: String, seller: Address, price: UFix64, index: Int) {
      self.uri = uri
      self.seller = seller
      self.price = price
      self.index = index
    }
  }

  pub resource interface MarketInterface {
    pub fun getListings(): [Listing]
    pub fun sell(vr: @VRContract.NFT, seller: Address, price: UFix64)
    pub fun withdraw(listingIndex: Int, to seller: Address) 
    pub fun buy(listing listingIndex: Int, with tokenVault: @ExampleToken.Vault, buyer: Address)
  }

  pub resource Market: MarketInterface {

    pub let experiences: @{Int: VRContract.NFT}
    pub let listings: [Listing]
    pub var idCount: Int

    init() {
      self.experiences <- {}
      self.listings = []
      self.idCount = 0
    }
    destroy() {
      destroy self.experiences
    }

    pub fun getListings(): [Listing] {
      return self.listings
    }

    pub fun sell(vr: @VRContract.NFT, seller: Address, price: UFix64) {
      let uri:String = vr.metadata["uri"]!
      self.experiences[self.idCount] <-! vr
      let listing = Listing(
        uri: uri,
        seller: seller,
        price: price,
        index: self.idCount
      )
      self.listings.append(listing)
      self.idCount = self.idCount + 1

      // emit ItemPosted(seller: seller, pixels: canvas.pixels)
    }

    pub fun withdraw(listingIndex: Int, to seller: Address) {
      let listing = self.listings[listingIndex]
      if listing.seller == seller {
        self.listings.remove(at: listingIndex)
        let vr <- self.experiences.remove(key: listingIndex)!

        // emit ItemWithdrawn(seller: seller, pixels: listing.canvas.pixels)

        let sellerCollection = getAccount(seller)
          .getCapability(/public/NFTReceiver)
          .borrow<&{VRContract.NFTReceiver}>()
          ?? panic("Couldn't borrow seller vr experiences Collection.")
        
        sellerCollection.deposit(token: <- vr)
        self.idCount = self.idCount - 1
      }
    }

    pub fun buy(listing listingIndex: Int, with tokenVault: @ExampleToken.Vault, buyer: Address) {
      pre {
        self.listings[listingIndex] != nil
        : "Listing no longer exists."
        tokenVault.balance >= self.listings[listingIndex].price
        : "Not enough FLOW to complete purchase."
      }

      let listing = self.listings.remove(at: listingIndex)

      let sellerVault = getAccount(listing.seller)
        .getCapability(/public/MainReceiver)
        .borrow<&ExampleToken.Vault{ExampleToken.Receiver}>()
        ?? panic("Couldn't borrow seller vault.")

      let buyerCollection = getAccount(buyer)
        .getCapability(/public/NFTReceiver)
        .borrow<&{VRContract.NFTReceiver}>()
        ?? panic("Couldn't borrow buyer Picture Collection.")

      // emit ItemSold(seller: listing.seller, pixels: listing.canvas.pixels, buyer: buyer)

      sellerVault.deposit(from: <- tokenVault)
      buyerCollection.deposit(token: <- self.experiences.remove(key: listing.index)!)
    }
  }

  

  init() {
    self.account.save(
      <- create Market(),
      to: /storage/VRMarket
    )
    self.account.link<&{MarketInterface}>(
      /public/VRMarket,
      target: /storage/VRMarket
    )
  }
}