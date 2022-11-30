import * as fcl from '@onflow/fcl';
import { createContext, useContext, useEffect, useState } from 'react';
import { checkIsInitialized, IS_INITIALIZED } from '../flow/scripts';

export const AuthContext = createContext({});

export const useAuth = () => useContext(AuthContext);
