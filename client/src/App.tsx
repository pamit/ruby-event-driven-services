import { useAuth0 } from "@auth0/auth0-react";
import LoginLogoutButton from "./components/LoginLogoutButton";
import OrderButton from "./components/OrderButton";

const App = () => {
  const { isAuthenticated } = useAuth0();

  return (
    <div className="app-container">
      <h2 className="title">Ruby Shop!</h2>
      <hr/>
      <p className="title-description">This demo app shows how to use Auth0 with a React frontend and a Ruby backend using EventBridge and SQS queues, following an event-driven approach.</p>

      <div className="button-group">
        <LoginLogoutButton />
        { isAuthenticated && <OrderButton />}
      </div>
    </div>
  );
};

export default App;
