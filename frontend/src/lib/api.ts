import axios from 'axios';
import {
  ImportFile,
  DashboardData,
  EmployeeFeedback,
  PaginatedResponse
} from '@/types';

export const api = axios.create({
  baseURL: 'http://localhost:3000/api/v1',
  headers: {
    'Content-Type': 'application/json',
  },
});

export const apiService = {
  getImports: (page: number = 1, query: string = '') =>
    api.get<PaginatedResponse<ImportFile>>(`/imports`, { params: { page, query } }),

  getDashboard: (id: number) =>
    api.get<DashboardData>(`/imports/${id}`),

  getFeedbacks: (id: number, page: number = 1) =>
    api.get<PaginatedResponse<EmployeeFeedback>>(`/feedbacks`, {
      params: { import_id: id, page }
    }),

  createImport: (file: File) => {
    const formData = new FormData();
    formData.append('file', file);
    return api.post('/imports', formData, {
      headers: { 'Content-Type': 'multipart/form-data' }
    });
  }
};