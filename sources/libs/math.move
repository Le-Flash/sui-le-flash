module sui_le_flash::math{
   use sui::hash::keccak256;
   use std::vector;

     // Function to concatenate two vectors
    public fun concat<T: copy + drop>(v1: vector<T>, v2: vector<T>): vector<T> {
        let  result = v1;
        let  len = vector::length(&v2);
        let  i = 0;

        while (i < len) {
            let elem = vector::borrow(&v2, i);
            vector::push_back(&mut result, *elem);
            i = i + 1;
        };

      result
    }

    public fun equals<T: copy + drop >(v1: vector<T>, v2: vector<T>): bool {
        let len1 = vector::length(&v1);
        let len2 = vector::length(&v2);

        // Check if lengths are different
        if (len1 != len2) {
            return false;
        };

        // Compare elements
        let i = 0;
        while (i < len1) {
            let elem1 = vector::borrow(&v1, i);
            let elem2 = vector::borrow(&v2, i);

            if (elem1 != elem2) {
                return false;
            };
            
            i = i + 1;
        };

        true
    }

    public fun verify(root: vector<u8>, leaf: vector<u8>, proof: vector<vector<u8>>): bool {
        let child = leaf;
        let len = vector::length(&proof);
        let  i = 0;

        while (i < len) {
            let sibling = vector::borrow(&proof, i);
            child = keccak256(&concat(child, *sibling));
            i = i + 1;
        };

       equals(root, child)
    }
   
}