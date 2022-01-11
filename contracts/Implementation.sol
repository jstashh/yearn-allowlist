// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;
import "./Utilities/Owner.sol";

/*******************************************************
 *                      Interfaces
 *******************************************************/
interface IRegistry {
  function isRegistered(address) external view returns (bool);

  function numVaults(address) external view returns (uint256);

  function vaults(address, uint256) external view returns (address);
}

interface IVault {
  function token() external view returns (address);
}

/*******************************************************
 *                      Implementation
 *******************************************************/
contract YearnAllowlistImplementation is Ownable {
  address public registryAddress;
  mapping(address => bool) public isZapperContract;

  constructor(address _registryAddress) {
    registryAddress = _registryAddress;
  }

  function setIsZapperContract(address contractAddress, bool _isZapperContract) external onlyOwner {
    isZapperContract[contractAddress] = _isZapperContract;
  }

  /**
   * @notice Determine whether or not a vault address is a valid vault
   * @param tokenAddress The vault token address to test
   * @return Returns true if the valid address is valid and false if not
   */
  function isVaultToken(address tokenAddress) public view returns (bool) {
    return registry().isRegistered(tokenAddress);
  }

  /**
   * @notice Determine whether or not a vault address is a valid vault
   * @param vaultAddress The vault address to test
   * @return Returns true if the valid address is valid and false if not
   */
  function isVault(address vaultAddress) public view returns (bool) {
    IVault vault = IVault(vaultAddress);
    address tokenAddress;
    try vault.token() returns (address _tokenAddress) {
      tokenAddress = _tokenAddress;
    } catch {
      return false;
    }
    uint256 numVaults = registry().numVaults(tokenAddress);
    for (uint256 vaultIdx; vaultIdx < numVaults; vaultIdx++) {
      address currentVaultAddress = registry().vaults(tokenAddress, vaultIdx);
      if (currentVaultAddress == vaultAddress) {
        return true;
      }
    }
    return false;
  }

  /**
   * @dev Internal convienence method used to fetch registry interface
   */
  function registry() internal view returns (IRegistry) {
    return IRegistry(registryAddress);
  }
}
