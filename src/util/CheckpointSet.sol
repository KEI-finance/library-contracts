// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.8.0;

import "@openzeppelin/contracts/utils/math/SafeCast.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

library CheckpointSet {
    struct Set {
        Checkpoint[] _checkpoints;
    }

    struct Checkpoint {
        uint32 timestamp;
        uint224 value;
    }

    /**
     * @dev Lookup a value in a list of (sorted) checkpoints.
     */
    function lookup(Set storage set, uint256 timestamp) internal view returns (uint256) {
        // We run a binary search to look for the earliest checkpoint taken after `timestamp`.
        //
        // During the loop, the index of the wanted checkpoint remains in the range [low-1, high).
        // With each iteration, either `low` or `high` is moved towards the middle of the range to maintain the invariant.
        // - If the middle checkpoint is after `timestamp`, we look in [low, mid)
        // - If the middle checkpoint is before or equal to `timestamp`, we look in [mid+1, high)
        // Once we reach a single value (when low == high), we've found the right checkpoint at the index high-1, if not
        // out of bounds (in which case we're looking too far in the past and the result is 0).
        // Note that if the latest checkpoint available is exactly for `timestamp`, we end up with an index that is
        // past the end of the array, so we technically don't find a checkpoint after `timestamp`, but it works out
        // the same.
        uint256 high = set._checkpoints.length;
        uint256 low = 0;
        while (low < high) {
            uint256 mid = Math.average(low, high);
            if (set._checkpoints[mid].timestamp > timestamp) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }

        return high == 0 ? 0 : set._checkpoints[high - 1].value;
    }

    function value(Set storage set) internal view returns (uint256) {
        uint256 pos = set._checkpoints.length;
        return pos == 0 ? 0 : set._checkpoints[pos - 1].value;
    }

    function add(Set storage set, uint256 delta) internal returns (uint256 prevValue, uint256 newValue) {
        return _writeCheckpoint(set._checkpoints, _add, delta);
    }

    function subtract(Set storage set, uint256 delta) internal returns (uint256 prevValue, uint256 newValue) {
        return _writeCheckpoint(set._checkpoints, _subtract, delta);
    }

    function _writeCheckpoint(
        Checkpoint[] storage ckpts,
        function(uint256, uint256) view returns (uint256) op,
        uint256 delta
    ) private returns (uint256 oldWeight, uint256 newWeight) {
        uint256 pos = ckpts.length;
        oldWeight = pos == 0 ? 0 : ckpts[pos - 1].value;
        newWeight = op(oldWeight, delta);

        if (pos > 0 && ckpts[pos - 1].timestamp == block.timestamp) {
            ckpts[pos - 1].value = SafeCast.toUint208(newWeight);
        } else {
            ckpts.push(
                Checkpoint({timestamp: SafeCast.toUint32(block.timestamp), value: SafeCast.toUint208(newWeight)})
            );
        }
    }

    function _add(uint256 a, uint256 b) private pure returns (uint256) {
        return a + b;
    }

    function _subtract(uint256 a, uint256 b) private pure returns (uint256) {
        return a - b;
    }
}
