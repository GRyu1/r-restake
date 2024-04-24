import {
  time,
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import hre from "hardhat";

describe("aUSDC", function () {
  async function deployaUSDCFixture() {
    const [owner, otherAccount] = await hre.ethers.getSigners();

    const aUSDCToken = await hre.ethers.getContractFactory("aUSDC");
    const aUSDC = await aUSDCToken.deploy();

    return { aUSDC, owner, otherAccount };
  }

  async function deployaVaultFixture() {
    const { aUSDC, owner } = await loadFixture(deployaUSDCFixture);
    
    const Vault = await hre.ethers.getContractFactory("Vault");
    const vault = await Vault.deploy(aUSDC.getAddress());

    return { aUSDC, vault, owner };
  }

  describe("aUSDC Test", function () {
    it("Should deploy with the correct name and symbol", async function () {
      const { aUSDC, owner } = await loadFixture(deployaUSDCFixture);

      expect(await aUSDC.name()).to.equal("Test aUSDC");
      expect(await aUSDC.symbol()).to.equal("aUSDC");

      const totalSupply = await aUSDC.totalSupply();
      expect(totalSupply).to.equal(1000000n * 10n ** 18n);

      const ownerBalance = await aUSDC.balanceOf(owner.address);
      expect(ownerBalance).to.equal(1000000n * 10n ** 18n);
    });
  });

  describe("Vault deposit Test", function () {
    it("Should deposit aUSDC to the vault", async function () {
      const { aUSDC, vault, owner } = await loadFixture(deployaVaultFixture);

      await aUSDC.approve(vault.getAddress(), 10n * 10n ** 18n);
      expect(await aUSDC.allowance(owner.getAddress(), vault.getAddress())).to.equal(10n * 10n ** 18n);
    });
  });
});
