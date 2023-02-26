const connectButton = document.getElementById("connectButton");
const mintButton = document.getElementById("mintButton");
const depositButton = document.getElementById("depositButton");
const rewardButton = document.getElementById("rewardButton");
const withdrawButton = document.getElementById("withdrawButton");

connectButton.onclick = connect;
mintButton.onclick = mintAssetToken;
depositButton.onclick = depositAsset;
approveButton.onclick = approveContract;
rewardButton.onclick = getRewards;
withdrawButton.onclick = withdrawAssets;

import { ethers } from "./ethers-5.1.esm.min.js";
import {
  assetAbi,
  assetAddress,
  stakingAssetAddress,
  rewardAbi,
  rewardAddress,
  stakingAssetAbi,
} from "./constants.js";

async function connect() {
  if (typeof window.ethereum != "undefined") {
    const chainId = await window.ethereum.request({ method: "eth_chainId" });

    if (chainId != "0xa869") {
      alert("Connect to Avalanche FUJI Testnet");
    } else {
      try {
        await window.ethereum.request({ method: "eth_requestAccounts" });
      } catch (error) {
        console.log(error);
      }
      const accounts = await ethereum.request({ method: "eth_accounts" });
      connectButton.innerHTML = `${accounts[0]}`;

      console.log(accounts);
    }
  } else {
    connectButton.innerHTML.innerHTML = "Install Metamask";
  }
}

async function mintAssetToken() {
  //const amount = ethers.utils.parseEther("20");
  if (typeof window.ethereum != "undefined") {
    const provider = new ethers.providers.Web3Provider(window.ethereum);

    const signer = provider.getSigner();
    const assetcontract = new ethers.Contract(assetAddress, assetAbi, signer);
    const mntAmount = document.getElementById("mintAmount").value;

    const res = await assetcontract.mintAsset(
      ethers.utils.parseEther(`${mntAmount}`)
    );
    await listenForTransaction(res, provider);
    const balance = await assetcontract.balanceOf(signer.getAddress());

    document.getElementById("assetTokenBalance").innerHTML = balance;
  }
}

async function approveContract() {
  if (typeof window.ethereum != "undefined") {
    const provider = new ethers.providers.Web3Provider(window.ethereum);

    const signer = provider.getSigner();
    const assetcontract = new ethers.Contract(assetAddress, assetAbi, signer);
    const appAmount = document.getElementById("approveAmount").value;

    const rep = await assetcontract.approve(
      stakingAssetAddress,
      ethers.utils.parseEther(`${appAmount}`)
    );
    await listenForTransaction(rep, provider);
    const allow = await assetcontract.allowance(
      signer.getAddress(),
      stakingAssetAddress
    );
    alert(`${allow} tokens Approved`);
  }
}

async function depositAsset() {
  const amount = ethers.utils.parseEther("20");
  if (typeof window.ethereum != "undefined") {
    const provider = new ethers.providers.Web3Provider(window.ethereum);

    const signer = provider.getSigner();
    const stakingCon = new ethers.Contract(
      stakingAssetAddress,
      stakingAssetAbi,
      signer
    );
    const tokenAmount = document.getElementById("tokenAmount").value;

    const rep = await stakingCon.deposit(
      ethers.utils.parseEther(`${tokenAmount}`)
    );
    await listenForTransaction(rep, provider);
    const num = await stakingCon.getNumberOfAssets();

    document.getElementById("numAssets").innerHTML = num;
  }
}

async function withdrawAssets() {
  if (typeof window.ethereum != "undefined") {
    const provider = new ethers.providers.Web3Provider(window.ethereum);

    const signer = provider.getSigner();
    const stakingCon = new ethers.Contract(
      stakingAssetAddress,
      stakingAssetAbi,
      signer
    );

    const numAssets = document.getElementById("withAssets").value;
    const transRep = await stakingCon.withdrawAssets(numAssets);
    await listenForTransaction(transRep, provider);
    const num = await stakingCon.getNumberOfAssets();

    document.getElementById("assets").innerHTML = num;
  }
}

async function getRewards() {
  const provider = new ethers.providers.Web3Provider(window.ethereum);

  const signer = provider.getSigner();
  const stakingCon = new ethers.Contract(
    stakingAssetAddress,
    stakingAssetAbi,
    signer
  );
  const rewardCon = new ethers.Contract(rewardAddress, rewardAbi, signer);

  const rew = await stakingCon.claimRewards();

  await listenForTransaction(rew, provider);
  const bal = await rewardCon.balanceOf(signer.getAddress());

  document.getElementById("rewards").innerHTML = bal;
}

function listenForTransaction(assets, provider) {
  return new Promise((resolve, reject) => {
    provider.once(assets.hash, (transactionRep) => {
      resolve();
    });
  });
}
