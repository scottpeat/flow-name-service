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
