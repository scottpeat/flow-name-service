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


}