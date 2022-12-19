import Link from 'next/link';
import { useAuth } from '../contexts/AuthContext';
import '../flow/config';
import styled from 'styled-components';

export default function Navbar() {
  const { currentUser, logOut, logIn } = useAuth();

  return (
    <NavbarStyle>
      <Link href="/">Home</Link>
      <Link href="/purchase">Purchase</Link>
      <Link href="/manage">Manage</Link>
      <button onClick={currentUser.addr ? logOut : logIn}>
        {currentUser.addr ? 'Log Out' : 'Login'}
      </button>
    </NavbarStyle>
  );
}

const NavbarStyle = styled.nav`
  display: flex;
  justify-content: center;
  column-gap: 2em;
  align-items: center;
  background-color: #171923;
  padding: 1em 0 1em 0;
  font-size: 16px;
  border-bottom: 2px solid darkslategray;
  margin-bottom: 2em;

  & a {
    border: 2px solid transparent;
    border-radius: 10px;
    padding: 8px;
    color: white;
  }

  & button {
    padding: 8px;
    background-color: transparent;
    border: 2px solid transparent;
    border-radius: 10px;
    color: white;
    font: inherit;
  }

  & a:hover,
  & button:hover {
    border: 2px solid darkslategray;
    border-radius: 10px;
    padding: 8px;
    cursor: pointer;
  }
`;
