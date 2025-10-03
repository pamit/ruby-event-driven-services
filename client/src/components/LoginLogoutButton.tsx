import React from "react";
import { useAuth0 } from "@auth0/auth0-react";

const LoginLogoutButton: React.FC = () => {
  const { loginWithRedirect, logout, isAuthenticated } = useAuth0();
  return (
    <div>
      {!isAuthenticated ? (
        <button onClick={() => loginWithRedirect()}>Log in</button>
      ) : (
        <button
          onClick={() =>
            logout({ logoutParams: { returnTo: window.location.origin } })
          }
        >
          Log out
        </button>
      )}
    </div>
  );
};

export default LoginLogoutButton;
