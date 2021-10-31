import VRMarket from 0x03

pub fun main(){

    let acc = getAccount(0x03)
    let listingRef = acc.getCapability<&{VRMarket.MarketInterface}>(/public/VRMarket).borrow() ?? panic("hhhhhhh")
    log(listingRef.getListings())

}