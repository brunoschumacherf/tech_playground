import { DashboardData } from "@/types/dashboard";

const API_BASE_URL = "http://localhost:3000/api/v1";

export const api = {
  async getDashboard(): Promise<DashboardData> {
    const response = await fetch(`${API_BASE_URL}/dashboard`, {
      method: "GET",
      headers: {
        "Content-Type": "application/json",
      },
      cache: 'no-store' 
    });

    if (!response.ok) {
      throw new Error(`Erro na conexão com a API: ${response.statusText}`);
    }

    return response.json();
  }
};