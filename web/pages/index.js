import Head from "next/head";
import {useEffect, useState } from "react";
import Navbar from"../components/NavBar;
import { getAllDomainInfos } from "../flow/scripts";
import styled from "styled-components";

export default function Home() {
  // Create a state variable for all the DomainInfo structs
  // Initialize it to an empty array
  const [domainInfos, setDomainInfos] = useState([]);

  // Load all the DomainInfo's by running the Cadence script
  // when the page is loaded
  useEffect(() => {
    async function fetchDomains() {
      const domains = await getAllDomainInfos();
      setDomainInfos(domains);
    }

    fetchDomains();
  }, []);

  return (
    <Container>
      <Head>
        <title>Flow Name Service</title>
        <meta name="description" content="Flow Name Service" />
        <link rel="icon" href="/favicon.ico" />
      </Head>

      <Navbar />

      <Main>
        <h1>All Registered Domains</h1>

        <DomainsContainer>
          {
            // If no domains were found, display a message highlighting that
            domainInfos.length === 0 ? (
            <p>No FNS Domains have been registered yet</p>
          ) : (
            // Otherwise, loop over the array, and render information
            // about each domain
            domainInfos.map((di, idx) => (
              <DomainInfo>
                <p>
                  {di.id} - {di.name}
                </p>
                <p>Owner: {di.owner}</p>
                <p>Linked Address: {di.address ? di.address : "None"}</p>
                <p>Bio: {di.bio ? di.bio : "None"}</p>
                <!-- Parse the timestamps as human-readable dates -->
                <p>
                  Created At:{" "}
                  {new Date(parseInt(di.createdAt) * 1000).toLocaleDateString()}
                </p>
                <p>
                  Expires At:{" "}
                  {new Date(parseInt(di.expiresAt) * 1000).toLocaleDateString()}
                </p>
              </DomainInfo>
            ))
          )}
        </DomainsContainer>
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
  max-width: 65ch;
`;
