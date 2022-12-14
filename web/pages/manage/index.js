import * as fcl from '@onflow/fcl';
import Head from 'next/head';
import Link from 'next/link';
import { useEffect, useState } from 'react';
import Navbar from '../../components/Navbar';
import { useAuth } from '../../contexts/AuthContext';
import { getMyDomainInfos } from '../../flow/scripts';
import { initializeAccount } from '../../flow/transactions';
import styled from 'styled-components';

export default function Home() {
  const { currentUser, isInitialized, checkInit } = useAuth();
  const [domainInfos, setDomainInfos] = useState([]);

  async function initialize() {
    try {
      const txId = await initializeAccount();
      await fcl.tx(txId).onceSealed();
      await checkInit();
    } catch (error) {
      console.error(error);
    }
  }
}
