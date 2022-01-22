import { ethers } from 'ethers'
import { useState, useEffect } from 'react'
import axios from 'axios'
import Web3Modal from 'web3modal'

import {
    DAOaddress
} from '../config'

import Head from 'next/head'
import Link from 'next/link'

const ConnectButton = () => {

    const [address, setAddress] = useState()
    const [connected, setConnected] = useState(false)

    useEffect(() => {
        connect()
    }, [])

    async function connect() {
        const web3Modal = new Web3Modal({
            network: "mainnet",
            cacheProvider: true,
        })
        //const connection = await 
        web3Modal.connect().then(async (connection) => {
            const provider = new ethers.providers.Web3Provider(connection)
            const signer = provider.getSigner()

            const { chainId } = await provider.getNetwork()
            console.log('Chain ID:', chainId)

            if (chainId != 42161) {
                await window.ethereum.request({ method: 'wallet_switchEthereumChain', params: [{ chainId: '0x66eeb' }] })
            }

            let signerAddress = await signer.getAddress()
            signerAddress = signerAddress.slice(0, 5) + '...' + signerAddress.slice(-4)
            setAddress(signerAddress)
            setConnected(true)
        }, (reason) => { })
    }

    if (!connected) {
        return (
            <button className="bg-transparent hover:bg-pink-500 text-pink-500
             font-semibold hover:text-white py-2 px-4 border border-pink-500 
             hover:border-transparent rounded" onClick={connect}>
                Connect
            </button>
        )
    }

    return (
        <button className="bg-transparent hover:bg-pink-500 text-pink-500
         font-semibold hover:text-white py-2 px-4 border border-pink-500 
         hover:border-transparent rounded">
            Connected as {address}
        </button>
    )
}

export default ConnectButton;