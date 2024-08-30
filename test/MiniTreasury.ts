import { expect } from "chai";
import { ethers } from "hardhat";
import { ERC20Mock, ERC721Mock, MiniTreasury } from "../typechain-types";

describe("MiniTreasury", function () {
  let owner: any, addr1: any, addr2: any;
  let miniTreasury: MiniTreasury, erc20Mock: ERC20Mock, erc721Mock: ERC721Mock;

  beforeEach(async function () {
    [owner, addr1, addr2] = await ethers.getSigners();

    const ERC20MockFactory = await ethers.getContractFactory("ERC20Mock");
    erc20Mock = (await ERC20MockFactory.connect(owner).deploy("MockERC20", "M20", 18, ethers.parseEther("100000"))) as ERC20Mock;
    await erc20Mock.waitForDeployment();

    const ERC721MockFactory = await ethers.getContractFactory("ERC721Mock");
    erc721Mock = (await ERC721MockFactory.deploy("MockERC721", "M721")) as ERC721Mock;
    await erc721Mock.waitForDeployment();

    const MiniTreasuryFactory = await ethers.getContractFactory("MiniTreasury");
    miniTreasury = (await MiniTreasuryFactory.deploy()) as MiniTreasury;
    await miniTreasury.waitForDeployment();
  });

  it("should set the right owner", async function () {
    expect(await miniTreasury.owner()).to.equal(owner.address);
  });

  describe("Enable and Disable Tokens", function () {
    it("only owner can enable token", async function () {
      await expect(miniTreasury.connect(addr1).enableAToken(erc20Mock.target)).to.be.revertedWithCustomError(miniTreasury, "OnlyOwner")
        .withArgs(addr1.address, owner.address);
    });

    it("only owner can disable token", async function () {
      await miniTreasury.connect(owner).enableAToken(erc20Mock.target);
      await expect(miniTreasury.connect(addr1).disableAToken(erc20Mock.target)).to.be.revertedWithCustomError(miniTreasury, "OnlyOwner")
        .withArgs(addr1.address, owner.address);
    });

    it("should enable ERC20 token", async function () {
      await miniTreasury.connect(owner).enableAToken(erc20Mock.target);
      const isEnabled = await miniTreasury.enabledTokens(erc20Mock.target);
      expect(isEnabled).to.be.true;
    });

    it("should enable ERC721 token", async function () {
      await miniTreasury.connect(owner).enableAToken(erc721Mock.target);
      const isEnabled = await miniTreasury.enabledTokens(erc721Mock.target);
      expect(isEnabled).to.be.true;
    });

    it("should disable ERC20 token", async function () {
      await miniTreasury.connect(owner).enableAToken(erc20Mock.target);
      await miniTreasury.connect(owner).disableAToken(erc20Mock.target);
      const isEnabled = await miniTreasury.enabledTokens(erc20Mock.target);
      expect(isEnabled).to.be.false;
    });

    it("should disable ERC721 token", async function () {
      await miniTreasury.connect(owner).enableAToken(erc721Mock.target);
      await miniTreasury.connect(owner).disableAToken(erc721Mock.target);
      const isEnabled = await miniTreasury.enabledTokens(erc721Mock.target);
      expect(isEnabled).to.be.false;
    });
  });

  describe("Deposit and Withdwaw ERC20 Tokens", async function () {
    it("should deposit ERC20 tokens", async function () {
      await miniTreasury.connect(owner).enableAToken(erc20Mock.target);
      await erc20Mock.connect(addr1).mint(addr1.address, ethers.parseEther("100"));
      await erc20Mock.connect(addr1).approve(miniTreasury.target, ethers.parseEther("100"));
      await miniTreasury.connect(addr1).depositERC20(erc20Mock.target, ethers.parseEther("100"));
      const balance = await miniTreasury.erc20TokenBalances(addr1.address, erc20Mock.target);
      expect(balance).to.equal(ethers.parseEther("100"));
    });

    it("should withdraw ERC20 tokens", async function () {
      await miniTreasury.connect(owner).enableAToken(erc20Mock.target);
      await erc20Mock.connect(addr1).mint(addr1.address, ethers.parseEther("100"));
      await erc20Mock.connect(addr1).approve(miniTreasury.target, ethers.parseEther("100"));
      await miniTreasury.connect(addr1).depositERC20(erc20Mock.target, ethers.parseEther("100"));
      await miniTreasury.connect(addr1).withdrawERC20(erc20Mock.target, ethers.parseEther("100"));
      const balance = await miniTreasury.erc20TokenBalances(addr1.address, erc20Mock.target);
      expect(balance).to.equal(0);
    });
  })

  describe("Deposit and Withdwaw ERC721 Tokens", async function () {
    it("should deposit ERC721 tokens", async function () {
      await miniTreasury.connect(owner).enableAToken(erc721Mock.target);
      await erc721Mock.connect(addr1).mint(addr1.address, 1);
      await erc721Mock.connect(addr1).approve(miniTreasury.target, 1);
      await miniTreasury.connect(addr1).depositERC721(erc721Mock.target, 1);
      const status = await miniTreasury.erc721TokenDeposits(addr1.address, erc721Mock.target, 1);
      expect(status).to.be.true;
    });

    it("should withdraw ERC721 tokens", async function () {
      await miniTreasury.connect(owner).enableAToken(erc721Mock.target);
      await erc721Mock.connect(addr1).mint(addr1.address, 1);
      await erc721Mock.connect(addr1).approve(miniTreasury.target, 1);
      await miniTreasury.connect(addr1).depositERC721(erc721Mock.target, 1);
      await miniTreasury.connect(addr1).withdrawERC721(erc721Mock.target, 1);
    });
  })
  
});
