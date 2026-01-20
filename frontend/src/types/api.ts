export interface DashboardData {
  summary: {
    total_responses: number;
    enps_score: number;
    promoters_count: number;
    detractors_count: number;
    sentiment_score: number; 
  };
  by_area: Record<string, number>;
  alerts: Record<string, number>;
  sentiment_analysis: {
    positive: number;
    neutral: number;
    negative: number;
  };
}