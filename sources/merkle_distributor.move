module sui_le_flash::merkle_distributor{
   use sui::object::{Self, ID, UID};
   use sui::tx_context::{TxContext};
   use sui::transfer;
   
    struct Distributor has key {
        id: UID,
        token: vector<u8>,
        merkle_root: vector<u8>,
        total: u64,
        claimed: u64,
        ended_at: u64,
        metadata: vector<u8>
    }

    struct AdminCap has key, store {
        id: UID,
        distributor_id: ID,
    }

     public fun initialize_distributor(
        ctx: &mut TxContext,
        _token:vector<u8>,
        _merkle_root: vector<u8>,
        _total: u64,
        _ended_at: u64,
        _metadata: vector<u8>
      ): AdminCap{
        let id = object::new(ctx);
        let distributor_id = object::uid_to_inner(&id);
        let distributor = Distributor {
          id,
          token: _token,
          merkle_root:_merkle_root,
          claimed: 0,
          total: _total,
          ended_at: _ended_at,
          metadata: _metadata
        };

        transfer::share_object(distributor);
        AdminCap { id: object::new(ctx), distributor_id }
    }

}