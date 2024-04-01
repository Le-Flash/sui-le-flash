module sui_le_flash::merkle_distributor{
   use sui::object::{Self, ID, UID};
   use sui::tx_context::{TxContext, sender};
   use sui::coin::{Coin};
   use sui::coin;
   use sui::transfer;
   use sui::table;

    struct Distributor <phantom D>  has key, store {
        id: UID,
        coin: Coin<D>,
        merkle_root: vector<u8>,
        total: u64,
        claimed: u64,
        ended_at: u64,
        metadata: vector<u8>,
        receipts: table::Table<address, UserClaim>,
    }

     struct UserClaim has store {
        amount: u64,
        claim_time: u64,
    }

    struct AdminCap has key, store {
        id: UID,
        distributor_id: ID,
    }

     public fun initialize_distributor<D>(
        _coin: Coin<D>,
        _merkle_root: vector<u8>,
        _total: u64,
        _ended_at: u64,
        _metadata: vector<u8>,
        ctx: &mut TxContext,
      ): AdminCap{
        let id = object::new(ctx);
        let distributor_id = object::uid_to_inner(&id);
        let distributor = Distributor<D> {
          id,
          coin: _coin,
          merkle_root:_merkle_root,
          claimed: 0,
          total: _total,
          ended_at: _ended_at,
          metadata: _metadata,
          receipts: table::new(ctx),
        };

        transfer::share_object(distributor);
        AdminCap { id: object::new(ctx), distributor_id }
    }

    public fun claim<D>(
      distributor: &mut Distributor<D>,
      proof: vector<u8>,
      amount: u64,
      timestamp_ms: u64,
      ctx: &mut TxContext
    ): Coin<D>{
      let user_address = sender(ctx);
      let user_staked = table::borrow_mut(&mut distributor.receipts, user_address);
      assert!(table::contains(&distributor.receipts, user_address), 1);

      let current_time = timestamp_ms / 1000;
      let new_user_claim = UserClaim { amount, claim_time: current_time / 1000 };
      table::add(&mut distributor.receipts, user_address, new_user_claim);

      let coin = coin::split(&mut distributor.coin, amount, ctx);
      coin

    }


}