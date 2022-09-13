// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev This abstract contract provides a fallback function that passes all calls to another contract using the EVM
 * instruction `staticcall`.
 *
 * https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/proxy/Proxy.sol
 */
abstract contract Modifier {
    /**
     * @dev Passes the current call to `implementation`.
     */
    function _call(address implementation) internal virtual {
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := staticcall(
                gas(),
                implementation,
                0,
                calldatasize(),
                0,
                0
            )
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    /**
     * @dev This is a virtual function that should be overridden so it returns the address to which the fallback function
     * and {_fallback} should call.
     */
    function _underlying() internal view virtual returns (address);

    /**
     * @dev Delegates the current call to the address returned by `_implementation()`.
     *
     * This function does not return to its internal call site, it will return directly to the external caller.
     */
    function _fallback() internal virtual {
        _beforeFallback();
        _call(_underlying());
    }

    /**
     * @dev Fallback function that calls to the address returned by `_implementation()`. Will run if no other
     * function in the contract matches the call data.
     */
    fallback() external payable virtual {
        _fallback();
    }

    /**
     * @dev Fallback function that calls to the address returned by `_implementation()`. Will run if call data
     * is empty.
     */
    receive() external payable virtual {
        _fallback();
    }

    /**
     * @dev Hook that is called before falling back to the implementation. Can happen as part of a manual `_fallback`
     * call, or as part of the Solidity `fallback` or `receive` functions.
     *
     * If overridden should call `super._beforeFallback()`.
     */
    function _beforeFallback() internal virtual {}
}

contract AdminModifier is Modifier {
    address public admin;
    address public underlying;

    function _underlying() internal view override returns (address) {
        return underlying;
    }

    /**
     * @dev Checks current call is from this contract or from admin.
     */
    function checkAdmin() public view {
        require(msg.sender == address(this) || msg.sender == admin);
    }

    /**
     * @dev Only calls from this contract or from admin can fallback to underlying contract.
     */
    function _beforeFallback() internal view override {
        checkAdmin();
    }
}
