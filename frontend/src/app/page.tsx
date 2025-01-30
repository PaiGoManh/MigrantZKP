"use client"

import { useState } from 'react';
import { useAccount, useContractWrite } from 'wagmi';
import { LaborerAttestationABI } from '../abi';
import { ethers } from 'ethers';

export default function Home() {
  const { address } = useAccount();
  const [id, setId] = useState('');
  const [workExp, setWorkExp] = useState('');
  const [proof, setProof] = useState(null);

  declare global {
    interface Window {
      snarkjs: any;
    }
  }

  const { write } = useContractWrite({
    address: process.env.NEXT_PUBLIC_CONTRACT_ADDRESS,
    abi: LaborerAttestationABI,
    functionName: 'verifyAndMint',
  });

  const generateProof = async () => {
    const { proof, publicSignals } = await window.snarkjs.groth16.fullProve(
      { id: id, workExperience: workExp },
      '/circuit.wasm',
      '/circuit_final.zkey'
    );
    
    const calldata = await window.snarkjs.groth16.exportSolidityCallData(proof, publicSignals);
    const [a, b, c, inputs] = JSON.parse(`[${calldata}]`);
    setProof({ a, b, c, inputs });
  };

  const mintNFT = async () => {
    if (!proof) return;
    write({
      args: [proof.a, proof.b, proof.c, proof.inputs],
    });
  };

  return (
    <div>
      <input 
        placeholder="ID Number" 
        value={id}
        onChange={(e) => setId(e.target.value)}
      />
      <input
        placeholder="Work Experience (months)"
        value={workExp}
        onChange={(e) => setWorkExp(e.target.value)}
      />
      <button onClick={generateProof}>Generate Proof</button>
      <button onClick={mintNFT}>Mint Attestation NFT</button>
    </div>
  );
}