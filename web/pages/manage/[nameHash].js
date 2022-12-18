import { useRouter } from 'next/router';
import { useEffect, useState } from 'react';
import { useAuth } from '../../contexts/AuthContext';
import * as fcl from '@onflow/fcl';
import Head from 'next/head';
import NavBar from '../../components/NavBar';
import { getDomainInfoByNameHash, getRentCost } from '../../flow/scripts';
import styled from 'styled-components';
import {
  renewDomain,
  updateAddressForDomain,
  updateBioForDomain,
} from '../../flow/transactions';

// constant representing seconds per year
const SECONDS_PER_YEAR = 365 * 24 * 60 * 60;
