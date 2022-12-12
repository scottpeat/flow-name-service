import * as fcl from '@onflow/fcl';
import { useEffect, useState } from 'react';
import Head from 'next/head';
import Navbar from '../components/Navbar';
import { useAuth } from '../contexts/AuthContext';
import { checkIsAvailable, getRentCost } from '../flow/scripts';
import { initializeAccount, registerDomain } from '../flow/transactions';
import styled from 'styled-components';

// Maintain a constant for seconds per year
const SECONDS_PER_YEAR = 365 * 24 * 60 * 60;

export default function Purchase() {
  // Use the AuthContext to check whether the connected user is initialized or not
  const { isInitialized, checkInit } = useAuth();
  // State Variable to keep track of the domain name the user wants
  const [name, setName] = useState('');
  // State variable to keep track of how many years
  // the user wants to rent the domain for
  const [years, setYears] = useState(1);
  // State variable to keep track of the cost of this purchase
  const [cost, setCost] = useState(0.0);
  // Loading state
  const [loading, setLoading] = useState(false);

  // Function to initialize a user's account if not already initialized
  async function initialize() {
    try {
      const txId = await initializeAccount();

      // This method waits for the transaction to be mined (sealed)
      await fcl.tx(txId).onceSealed();
      // Recheck account initialization after transaction goes through
      await checkInit();
    } catch (error) {
      console.error(error);
    }
  }

  // Function which calls `registerDomain`
  async function purchase() {
    try {
      setLoading(true);
      const isAvailable = await checkIsAvailable(name);
      if (!isAvailable) throw new Error('Domain is not available');

      if (years <= 0) throw new Error('You must rent for at least 1 year');
      const duration = (years * SECONDS_PER_YEAR).toFixed(1).toString();
      const txId = await registerDomain(name, duration);
      await fcl.tx(txId).onceSealed();
    } catch (error) {
      console.error(error);
    } finally {
      setLoading(false);
    }
  }

  // Function which calculates cost of purchase as user
  // updates the name and duration
  async function getCost() {
    if (name.length > 0 && years > 0) {
      const duration = (years * SECONDS_PER_YEAR).toFixed(1).toString();
      const c = await getRentCost(name, duration);
      setCost(c);
    }
  }

  // Call getCost() every time `name` and `years` changes
  useEffect(() => {
    getCost();
  }, [name, years]);

  return (
    <Container>
      <Head>
        <title>Flow Name Service = Purchase</title>
        <meta name="description" content="Flow Name Service" />
        <link rel="icon" href="/favicon.ico" />
      </Head>
      <Navbar />
      {!isInitialized ? (
        <>
          <p>Your account has not been initialized yet</p>
          <button onClick={initialize}>Initialize Account</button>
        </>
      ) : (
        <Main>
          <InputGroup>
            <span>Name: </span>
            <input
              type="text"
              value={name}
              placeholder="learnweb3"
              onChange={(e) => setName(e.target.value)}
            />
            <span>.fns</span>
          </InputGroup>
        </Main>
      )}
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
  display: flex;
  gap: 2em;
  flex-direction: column;
  width: 30%;
  margin: auto;
  align-items: center;

  & button {
    width: fit-content;
  }
`;

const InputGroup = styled.div`
  display: flex;
  flex-direction: row;
  gap: 12px;

  & input {
    padding: 0.2em;
    border-radius: 0.5em;
    border-width: 0;
  }
`;
