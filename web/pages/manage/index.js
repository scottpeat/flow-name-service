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
  // Use the AuthContext to track user data
  const { currentUser, isInitialized, checkInit } = useAuth();
  const [domainInfos, setDomainInfos] = useState([]);

  // Function to initialize the user's account if not already initialized
  async function initialize() {
    try {
      const txId = await initializeAccount();
      await fcl.tx(txId).onceSealed();
      await checkInit();
    } catch (error) {
      console.error(error);
    }
  }

  // Function to fetch the domains owned by the currentUser
  async function fetchMyDomains() {
    try {
      const domains = await getMyDomainInfos(currentUser.addr);
      setDomainInfos(domains);
    } catch (error) {
      console.error(error.message);
    }
  }

  // Load user-owned domains if they are initialized
  // Run if value of `isInitialized` changes
  useEffect(() => {
    if (isInitialized) {
      fetchMyDomains();
    }
  }, [isInitialized]);

  return (
    <Container>
      <Head>
        <title>Flow Name Service - Manage</title>
        <meta name="description" content="Flow Name Service" />
        <link rel="icon" href="/favicon.ico" />
      </Head>

      <Navbar />

      <Main>
        <h1>Your Registered Domains</h1>

        {!isInitialized ? (
          <>
            <p>Your account has not been initialized yet</p>
            <button onClick={initialize}>Initialize Account</button>
          </>
        ) : (
          <DomainsContainer>
            {domainInfos.length === 0 ? (
              <p>You have not registered any FNS Domains yet</p>
            ) : (
              domainInfos.map((di, idx) => (
                <Link href={`/manage/${di.nameHash}`}>
                  <DomainInfo key={idx}>
                    <p>
                      {di.id} - {di.name}
                    </p>
                    <p>Owner: {di.owner}</p>
                    <p>Linked Address: {di.address ? di.address : 'None'}</p>
                    <p>Bio: {di.bio ? di.bio : 'None'}</p>
                    <p>
                      Created At:{' '}
                      {new Date(
                        parseInt(di.createdAt) * 1000
                      ).toLocaleDateString()}
                    </p>
                    <p>
                      Expires At:{' '}
                      {new Date(
                        parseInt(di.expiresAt) * 1000
                      ).toLocaleDateString()}
                    </p>
                  </DomainInfo>
                </Link>
              ))
            )}
          </DomainsContainer>
        )}
      </Main>
    </Container>
  );
}

const Container = styled.div`
  background-color: #171923;
  min-height: 100vh;
`;

const Main = styled.main`
  color: white;
  padding: 0 4em;
`;

const DomainsContainer = styled.div`
  display: flex;
  gap: 4em;
  flex-wrap: wrap;
`;

const DomainInfo = styled.div`
  padding: 2em;
  color: antiquewhite;
  background-color: darkslategray;
  border-radius: 2em;
  cursor: pointer;
  max-width: 65ch;
`;
