export interface ImportFile {
  id: number;
  name: string;
  status: string;
  created_at: string;
  feedbacks_count?: number;
}

export interface EmployeeFeedback {
  id: number;
  nome: string;
  email: string;
  area: string;
  cargo: string;
  enps: number;
  feedback: number;
  enps_aberta: string;
  comentarios_feedback: string;
  interacao_gestor: number;
  expectativa_permanencia: number;
  interesse_no_cargo: number;
  clareza_carreira: number;
  comentarios_clareza: string;
  localidade: string;
  data_da_resposta: string;
  import_file_id: number;
}

export interface DashboardSummary {
  total_responses: number;
  enps_score: number;
  favorability: number;
}

export interface DashboardData {
  info: ImportFile;
  summary: DashboardSummary;
  by_area: Record<string, number>;
  sentiment_analysis: {
    positive: number;
    neutral: number;
    negative: number;
  };
  alerts: Record<string, number>;
}

export interface PaginationMeta {
  current_page: number;
  next_page: number | null;
  prev_page: number | null;
  total_pages: number;
  total_count: number;
}

export interface PaginatedResponse<T> {
  data: T[];
  meta: PaginationMeta;
}