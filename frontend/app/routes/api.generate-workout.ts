import { json } from "@remix-run/node";
import type { ActionFunction } from "@remix-run/node";

const BACKEND_URL = process.env.NODE_ENV === "production" 
  ? "https://workout-generator-0oa9.onrender.com"
  : "http://127.0.0.1:4567";

export const action: ActionFunction = async ({ request }) => {
  if (request.method !== "POST") {
    return json({ error: "Method not allowed" }, { status: 405 });
  }

  try {
    const { duration, targetArea, equipment } = await request.json();

    // Call the Ruby backend
    const response = await fetch(`${BACKEND_URL}/generate-workout`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ duration, targetArea, equipment }),
    });

    if (!response.ok) {
      const errorText = await response.text();
      console.error("Backend error:", errorText);
      throw new Error(`Failed to generate workout: ${errorText}`);
    }

    const data = await response.json();
    return json(data);
  } catch (error) {
    console.error("Error:", error);
    return json({ 
      error: "Failed to generate workout. Please try again later.",
      details: error instanceof Error ? error.message : String(error)
    }, { status: 500 });
  }
}; 