import React from "react";
import { useAuth0 } from "@auth0/auth0-react";

const OrderButton: React.FC = () => {
  const { getAccessTokenSilently, user } = useAuth0();

  async function placeOrder() {
    const token = await getAccessTokenSilently();

    const order = {
      user_id: user?.sub || "anonymous",
      items: [{ sku: "ABC123", quantity: 1 }],
      total: 19.99
    };

    const response = await fetch(`${import.meta.env.VITE_ORDER_API}/order`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${token}`
      },
      body: JSON.stringify(order)
    });

    if (response.ok) {
      alert("Order placed!");
    } else {
      const body = await response.json();
      alert("Order failed: " + JSON.stringify(body));
    }
  }

  return <button onClick={placeOrder}>Place Order</button>;
};

export default OrderButton;
