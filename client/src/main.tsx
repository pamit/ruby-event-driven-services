import React from "react";
import { createRoot } from "react-dom/client";
import { Auth0Provider } from "@auth0/auth0-react";
import App from "./App";
import "./index.css";

/**
 * We pull the Auth0 settings from Vite env vars.
 * These must be set (prefixed with VITE_) in .env or your runtime environment.
 */
const auth0Domain = import.meta.env.VITE_AUTH0_DOMAIN;
const auth0ClientId = import.meta.env.VITE_AUTH0_CLIENT_ID;

if (auth0Domain === undefined || auth0Domain === '' || auth0ClientId === undefined || auth0ClientId === '' ) {
  console.error("Missing VITE_AUTH0_DOMAIN or VITE_AUTH0_CLIENT_ID. Auth0 will not function correctly.");
}

const rootEl = document.getElementById("root");
if (!rootEl) {
  throw new Error("Root element not found. Make sure index.html has <div id='root'></div>");
}

createRoot(rootEl).render(
  <React.StrictMode>
    <Auth0Provider
      domain={auth0Domain}
      clientId={auth0ClientId}
      authorizationParams={{
        redirect_uri: window.location.origin,
      }}
    >
      <App />
    </Auth0Provider>
  </React.StrictMode>
);
