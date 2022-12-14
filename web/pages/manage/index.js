import * as fcl from '@onflow/fcl';
import Head from 'next/head';
import Link from 'next/link';
import { useEffect, useState } from 'react';
import Navbar from '../../components/Navbar';
import { useAuth } from '../../contexts/AuthContext';
import { getMyDomainInfos } from '../../flow/scripts';
import { initializeAccount } from '../../flow/transactions';
import styled from 'styled-components';
