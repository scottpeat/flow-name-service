import FungibleToken from "./interfaces/FungibleToken.cdc"
import NonFungibleToken from "./interfaces/NonFungibleToken.cdc"
import FlowToken from "./tokens/FlowToken.cdc"

// The Domains contract defines the Domains NFT Collection
// to be used by flow-name-service
pub contract Domains: NonFungibleToken {
    pub let owners: {String: Address}
    pub let expirationTimes: {String: UFix64}

    // A mapping for domain nameHash -> domain ID
    pub let nameHashToIDs: {String: UInt64}
    // Defines forbidden characters within domain names - such as .
    pub let forbiddenChars: String
    // Defines the minimum duration a domain must be rented for
    pub let minRentDuration: UFix64
    // Defines the maximum length of the domain name (not including .fns)
    pub let maxDomainLength: Int

    // A counter to keep track of how many domains have been minted
    pub var totalSupply: UInt64

    pub event DomainBioChanged(nameHash: String, bio: String)
    pub event DomainAddressChanged(nameHash: String, address: Address)
    pub event Withdraw(id: UInt64, from: Address?)
    pub event Deposit(id: UInt64, to: Address?)
    pub event DomainMinted(id: UInt64, name: String, nameHash: String, expiresAt: UFix64, receiver: Address)
    // Events to emit when a domain is renewed and rented for longer
    pub event DomainRenewed(id: UInt64, name: String, nameHash: String, expiresAt: UFix64, receiver: Address)

    init() {
        self.owners = {}
        self.expirationTimes = {}
    }
    
    // Struct that represents information about an FNS domain
    pub struct DomainInfo {
    // Public Variables of the Struct
        pub let id: UInt64
        pub let owner: Address
        pub let name: String
        pub let nameHash: String
        pub let expiresAt: UFix64
        pub let address: Address?
        pub let bio: String
        pub let createdAt: UFix64

        // Struct initializer
        init(
            id: UInt64,
            owner: Address,
            name: String,
            nameHash: String,
            expiresAt: UFix64,
            address: Address?,
            bio: String,
            createdAt: UFix64
            ) {
            self.id = id
            self.owner = owner
            self.name = name
            self.nameHash = nameHash
            self.expiresAt = expiresAt
            self.address = address
            self.bio = bio
            self.createdAt = createdAt
            }
        }

        // Checks if a domain is available for sale
        pub fun isAvaliable(nameHash: String): Bool {
            if self.owners[nameHash] == nil {
                return true
            }
            return self.isExpired(nameHash: nameHash)
        }

        // Returns the expiry time for a domain
        pub fun getExpirationTime(nameHash: String): UFix64? {
            return self.expirationTimes[nameHash]
        }

        //  Checks if a domain is expired
        pub fun isExpired(nameHash: String): Bool {
            let currTime = getCurrentBlock().timestamp
            let expTime = self.expirationTimes[nameHash]
            if expTime != nil {
                return currTime >= expTime!
            }
            return false
        }

        // Returns the entire `owners` dictionary
        pub fun getAllOwners(): {String: Address} {
            return self.owners
        }

        // Returns the entire `expirationTimes` dictionary
        pub fun getAllExpirationTimes(): {String: UFix64} {
            return self.expirationTimes
        }

        // Update the owner of a domain
        access(account) fun updateOwner(nameHash: String, address: Address) {
            self.owners[nameHash] = address
        }

        // Update the expiration time of a domain
        access(account) fun updateExpirationTime(nameHash: String, expTime: UFix64) {
            self.expirationTimes[nameHash] = expTime
        }

         pub fun getAllNameHashToIDs(): {String: UInt64} {
            return self.nameHashToIDs
        }

        access(account) fun updateNameHashToID(nameHash: String, id: UInt64) {
            self.nameHashToIDs[nameHash] = id
        }

        
        pub resource interface DomainPublic {
            pub let id: UInt64
            pub let name: String
            pub let nameHash: String
            pub let createdAt: UFix64

            pub fun getBio(): String
            pub fun getAddress(): Address?
            pub fun getDomainName(): String
            pub fun getInfo(): DomainInfo
        }

        pub resource interface DomainPrivate {
            pub fun setBio(bio: String)
            pub fun setAddress(addr: Address)
        }

        pub resource NFT: DomainPublic, DomainPrivate, NonFungibleToken.INFT {
            pub let id: UInt64
            pub let name: String
            pub let nameHash: String
            pub let createdAt: UFix64
            
            access(self) var address: Address?
            access(self) var bio: String

            init(id: UInt64, name: String, nameHash: String) {
            self.id = id
            self.name = name
            self.nameHash = nameHash
            self.createdAt = getCurrentBlock().timestamp
            self.address = nil
            self.bio = ""
            }

            pub fun getBio(): String {
                return self.bio
            }

            pub fun getAddress(): Address? {
                return self.address
            }

            pub fun getDomainName(): String {
                return self.name.concat(".fns")
            }

            pub fun setBio(bio: String) {
                // This is like a `require` statement in Solidity
                // A 'pre'-check to running this function
                // If the condition is not valid, it will throw the given error
                pre {
                    Domains.isExpired(nameHash: self.nameHash) == false : "Domain is expired"
                }
                self.bio = bio
                emit DomainBioChanged(nameHash: self.nameHash, bio: bio)
            }
        
            pub fun setAddress(addr: Address) {
                pre {
                    Domains.isExpired(nameHash: self.nameHash) == false : "Domain is expired"
                }

                self.address = addr
                emit DomainAddressChanged(nameHash: self.nameHash, address: addr)
            }

            pub fun getInfo(): DomainInfo {
                let owner = Domains.owners[self.nameHash]!

                return DomainInfo(
                    id: self.id,
                    owner: owner,
                    name: self.getDomainName(),
                    nameHash: self.nameHash,
                    expiresAt: Domains.expirationTimes[self.nameHash]!,
                    address: self.address,
                    bio: self.bio,
                    createdAt: self.createdAt
                    )
            }
        }

        pub resource interface CollectionPublic {
            pub fun borrowDomain(id: UInt64): &{Domains.DomainPublic}
        }

        pub resource interface CollectionPrivate {
            access(account) fun mintDomain(name: String, nameHash: String, expiresAt: UFix64, receiver: Capablity<&{NonFungibleToken}>)
            pub fun borrowDomainPrivate(id: UInt64): &Domains.NFT
        }

        pub resource Collection: CollectionPublic, CollectionPrivate, NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic {
            // Dictionary (mapping) of Token ID -> NFT Resource 
            pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

        init() {
            // Initialize as an empty resource
            self.ownedNFTs <- {}
        }

        pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
            let domain <- self.ownedNFTs.remove(key: withdrawID)
                ?? panic("NFT not found in collection")
            emit Withdraw(id: domain.id, from: self.owner?.address)
            return <- domain
        }

        // NonFungibleToken.Receiver
        pub fun deposit(token: @NonFungibleToken.NFT) { 
            // Typecast the generic NFT resource as a Domains.NFT resource
            let domain <- token as! @Domains.NFT
            let id = domain.id
            let nameHash = domain.nameHash

            if Domains.isExpired(nameHash: nameHash) {
                panic("Domain is expired")
            }

            Domains.updateOwner(nameHash: nameHash, address: self.owner?.address) 

            let oldToken <- self.ownedNFTs[id] <- domain
            emit Deposit(id: id, to: self.owner?.address)

            destroy oldToken
        }

        // NonFungibleToken.CollectionPublic
        pub fun getIDs(): [UInt64] {
            // Ah, the joy of being able to return keys which are set
             // in a mapping. Solidity made me forget this was doable.
            return self.ownedNFTs.keys
        }

        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
            return (&self.ownedNFTs[id] as &NonFungibleToken.NFT?)!
        }

        // Domains.CollectionPublic
        pub fun borrowDomain(id: UInt64): &{Domains.DomainPublic} {
            pre {
                self.ownedNFTs[id] != nil : "Domain does not exist"
            }

            let token = (&self.ownedNFTs[id] as auth &NonFungibleToken.NFT?)!
            return token as! &Domains.NFT
        }

        // Domains.CollectionPrivate
        access(account) fun mintDomain(name: String, nameHash: String, expiresAt: UFix64, receiver: Capablity<&{NonFungibleToken.Receiver}>) {
            pre {
                Domains.isAvaliable(nameHash: nameHash) : "Domain not available"
            }

            let domain <- create Domains.NFT(
                id: Domains.totalSupply,
                name: name,
                nameHash: nameHash
            )

            Domains.updateOwner(nameHash: nameHash, address: receiver.address)
            Domains.updateExpirationTime(nameHash: nameHash, expTime: expiresAt)

            // We haven't defined the next two lines yet
            Domains.updateNameHashToID(nameHash: nameHash, id: domain.id)
            Domains.totalSupply = Domains.totalSupply + 1

            emit DomainMinted(id: domain.id, name: name, nameHash: nameHash, expiresAt: expiresAt, receiver: receiver.address)

            receiver.borrow()!.deposit(token: <- domain)
        }

       pub fun borrowDomainPrivate(id: UInt64): &Domains.NFT {
         pre {
            self.ownedNFTs[id] != nil: "Domain does not exist"
        }
            let ref = (&self.ownedNFTs[id] as auth &NonFungibleToken.NFT?)!
            return ref as! &Domains.NFT
        }

        destroy() {
            destroy self.ownedNFTs
        }
    }

    pub resource interface RegistrarPublic {
        pub let minRentDuration: UFix64
        pub let maxDomainLength: Int
        pub let prices:  {Int: UFix64}

        pub fun renewDomain(domain: &Domains.NFT, duration: UFix64, feeTokens: @FungibleToken.Vault)
        pub fun registerDomain(name: String, duration: UFix64, feeTokens: @FungibleToken.Vault, receiver: Capablity<&{NonFungibleToken.Receiver}>)
        pub fun getPrices(): {Int: UFix64}
        pub fun getVaultBalance(): UFix64
    }

    pub resource interface RegistrarPrivate {
        pub fun updateRentVault(vault: @FungibleToken.Vault)
        pub fun withdrawVault(receiver: Capablity<&{FungibleToken.Receiver}>, amount: UFix64)
        pub fun setPrices(key: Int, val: UFix64)
    }

    pub resource Registrar: RegistrarPublic, RegistrarPrivate {
        // Variables defined in the interfaces
        pub let minRentDuration: UFix64
        pub let maxDomainLength: Int
        pub let prices: {Int: UFix64}

        // A reference to the Vault used for depositing Flow tokens we receive
        // `priv` variables cannot be defined in interfaces
        // `priv` = `private`. It is a shorthand for access(self)
        pub var rentVault: @FungibleToken.Vault

        // A capability for the Domains.Collection resource owned by the account
        // Only the account has access to it
        // We will use this to access the account-only `mintDomain` function
        // Within the Collection owned by our smart contract account
        access(account) var domainsCollection: Capablity<&Domains.Collection>

        init(vault: @FungibleToken.Vault, collection: Capability<&Domains.Collection>) {
            // This represents 1 year in seconds
            self.minRentDuration = UFix64(365 * 24 * 60 * 60)
            self.maxDomainLength = 30
            self.prices = {}

            self.rentVault <- vault
            self.domainsCollection = collection
        }

        pub fun renewDomain(domain: &Domains.NFT, duration: UFix64, feeTokens: @FungibleToken.Vault) {
            // We don't need to check if the user owns this domain
            // because they are providing us a full reference to Domains.NFT
            // through the first argument.
            // They could not have done this if they did not own the domain
            var len = domain.name.length
            // If the length of the domain name is >10,
            // Make the arbitrary decision to price it the same way
            // as if it was 10 characters long
            if len > 10 {   
                len = 10
            }

            // Get the price per second of rental for this length of domain
            let price = self.getPrices()[len]

            // Ensure that the duration to rent for isn't less than the minimum
            if duration < self.minRentDuration {
                panic("Domain must be registered for at least the minimum duration: ".concat(self.minRentDuration.toString()))
            }

             // Ensure that the admin has set a price for this domain length
             if price == 0.0 || price == nil {
                panic("Price has not been set for this length of domain")
            }

            // Calculate total rental cost (price * duration)
            let rentCost = price! * duration
            // Check the balance of the Vault given to us by the user
            // This is their way of sending us tokens through the transaction
            let feeSent = feeTokens.balance

            // Ensure they've sent >= tokens as required
            if feeSent < rentCost {
                panic("You did not send enough FLOW tokens.  Expected: ".concat(rentCost.toString()))
            }

            // If yes, deposit those tokens into our own rentVault
            self.rentVault.deposit(from: <- feeTokens)

            // Calculate the new expiration date for this domain
            // Add duration of rental to current expiry date
            // and update the expiration time
            let newExpTime = Domains.getExpirationTime(nameHash: domain.nameHash)! + duration
            Domains.updateExpirationTime(nameHash: domain.nameHash, expTime: newExpTime)

            // emit the DomainRenewed event
            emit DomainRenewed(id: domain.id, name: domain.name, nameHash: nameHash, expiresAt: newExpTime, receiver: domain.owner!.address)
        }

        






}
    
 