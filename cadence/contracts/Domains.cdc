import NonFungibleToken from "./interfaces/NonFungibleToken.cdc"
import FungibleToken from "./interfaces/FungibleToken.cdc"
import FlowToken from "./tokens/FlowToken.cdc"

// The Domains contract defines the Domains NFT Collection
// to be used by flow-name-service
pub contract Domains: NonFungibleToken {
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
        pub let owners: {String: Address}
        pub let expirationTimes: {String: UFix64}

        pub event DomainBioChanged(nameHash: String, bio: String)
        pub event DomainAddressChanged(nameHash: String, address: Address)

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


            }}

            
 