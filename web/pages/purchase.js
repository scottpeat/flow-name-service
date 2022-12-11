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
