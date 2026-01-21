'use client';

import React, { useEffect, useState, useCallback } from 'react';
import { useParams, useRouter } from 'next/navigation';
import { apiService } from '@/lib/api';
import { EmployeeFeedback } from '@/types';
import { StatsCards } from '@/components/dashboard/StatsCards';
import { MainChart } from '@/components/dashboard/MainChart';
import { FeedbackTable } from '@/components/feedbacks/FeedbackTable';
import { FeedbackDetailsModal } from '@/components/feedbacks/FeedbackDetailsModal';
import { SentimentChart } from '@/components/dashboard/SentimentChart';

export default function DashboardPage() {
  const params = useParams();
  const router = useRouter();
  const importId = params?.id ? Number(params.id) : null;

  const [data, setData] = useState<any>(null);
  const [selectedFeedback, setSelectedFeedback] = useState<EmployeeFeedback | null>(null);
  const [loading, setLoading] = useState<boolean>(true);

  const [feedbacks, setFeedbacks] = useState<EmployeeFeedback[]>([]);
  const [feedbacksLoading, setFeedbacksLoading] = useState<boolean>(false);
  const [currentPage, setCurrentPage] = useState<number>(1);
  const [totalPages, setTotalPages] = useState<number>(1);
  const [totalFeedbacks, setTotalFeedbacks] = useState<number>(0);

  const loadData = useCallback(async () => {
    if (!importId) return;
    setLoading(true);
    try {
      const response = await apiService.getDashboard(importId);
      setData(response.data);
    } catch (error) {
      console.error(error);
    } finally {
      setLoading(false);
    }
  }, [importId]);

  const loadFeedbacks = useCallback(async (page: number) => {
    if (!importId) return;
    setFeedbacksLoading(true);
    try {
      const response = await apiService.getFeedbacks(importId, page);
      if (response.data && response.data.data) {
        setFeedbacks(response.data.data);
        setTotalPages(response.data.meta.total_pages);
        setTotalFeedbacks(response.data.meta.total_count);
      }
    } catch (error) {
      console.error("Erro ao carregar feedbacks:", error);
    } finally {
      setFeedbacksLoading(false);
    }
  }, [importId]);

  useEffect(() => {
    loadData();
  }, [loadData]);

  useEffect(() => {
    loadFeedbacks(currentPage);
  }, [loadFeedbacks, currentPage]);

  useEffect(() => {
    if (data?.info?.status === 'processing') {
      const interval = setInterval(() => {
        loadData();
        loadFeedbacks(currentPage);
      }, 3000);
      return () => clearInterval(interval);
    }
  }, [data, loadData, loadFeedbacks, currentPage]);

  if (loading || !data) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-zinc-50 font-sans">
        <div className="flex flex-col items-center gap-4">
          <div className="w-12 h-12 border-4 border-indigo-600 border-t-transparent rounded-full animate-spin" />
          <p className="text-[10px] font-black uppercase tracking-[0.3em] text-zinc-400">Sincronizando Insights</p>
        </div>
      </div>
    );
  }

  return (
    <main className="min-h-screen bg-zinc-50 p-6 lg:p-12 font-sans antialiased">
      <div className="max-w-7xl mx-auto space-y-10">

        <header className="flex flex-col md:flex-row md:items-end justify-between gap-6 border-b border-zinc-200 pb-10">
          <div>
            <nav className="flex items-center gap-2 text-zinc-400 mb-4 text-[10px] font-black uppercase tracking-widest no-print">
              <button onClick={() => router.push('/')} className="hover:text-indigo-600 transition-colors">Datasets</button>
              <span>/</span>
              <span className="text-zinc-900 italic">Dashboard #{data.info.id}</span>
            </nav>
            <h1 className="text-6xl font-black text-zinc-900 tracking-tighter leading-none uppercase italic">
              {data.info.name}
            </h1>
            <div className="flex items-center gap-4 mt-4">
              <p className="text-zinc-500 font-bold tracking-tight">
                {new Date(data.info.created_at).toLocaleDateString('pt-BR')} • {data.summary.total_responses} Respostas
              </p>
              <StatusBadge status={data.info.status} />
            </div>
          </div>

          <div className="flex gap-4 no-print">
            <button onClick={() => window.print()} className="px-8 py-4 bg-indigo-600 text-white rounded-full font-black text-[10px] uppercase tracking-[0.2em] hover:bg-zinc-900 transition-all shadow-lg active:scale-95 flex items-center gap-2">
              <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="3" d="M17 17h2a2 2 0 002-2v-4a2 2 0 00-2-2H5a2 2 0 00-2 2v4a2 2 0 00-2 2h2m2 4h10a2 2 0 002-2v-4a2 2 0 012-2H5a2 2 0 01-2 2v4a2 2 0 002 2z" /></svg>
              Exportar PDF
            </button>
            <button onClick={() => router.push('/')} className="px-8 py-4 bg-white border border-zinc-200 rounded-full font-black text-[10px] uppercase tracking-[0.2em] hover:bg-zinc-900 hover:text-white transition-all shadow-sm active:scale-95">
              ← Voltar
            </button>
          </div>
        </header>

        <StatsCards data={data.summary} />

        <section className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <EDACard label="Média Aritmética" value={data.eda.mean} description="Média geral de satisfação" icon="Σ" />
          <EDACard label="Mediana Central" value={data.eda.median} description="Valor que divide a amostra" icon="x͂" />
          <EDACard label="Moda (Frequência)" value={data.eda.mode} description="Nota que mais se repetiu" icon="Mo" />
        </section>

        {data.ai_insights && (
          <section className="bg-gradient-to-br from-zinc-900 via-indigo-950 to-zinc-900 p-12 rounded-[3.5rem] text-white shadow-2xl relative overflow-hidden border border-white/5">
            <div className="relative z-10 space-y-4">
              <p className="text-[10px] font-black uppercase tracking-[0.4em] mb-4 text-indigo-200">Creative Exploration</p>
              <h2 className="text-3xl font-black tracking-tight mb-2">Estratégia: <span className="text-indigo-400 italic">{data.ai_insights.critical_area}</span></h2>
              <p className="text-lg font-medium text-zinc-300 max-w-4xl leading-relaxed">{data.ai_insights.recommendation}</p>
              <div className="pt-4 flex gap-6">
                <div className="bg-white/5 px-6 py-3 rounded-2xl border border-white/10">
                  <p className="text-[10px] font-black text-zinc-500 uppercase">Score</p>
                  <p className="text-xl font-black">{data.ai_insights.score} / 5.0</p>
                </div>
              </div>
            </div>
          </section>
        )}

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          <section className="lg:col-span-2 bg-white p-10 rounded-[3rem] border border-zinc-100 shadow-sm">
            <div className="mb-8">
              <h2 className="text-2xl font-black text-zinc-900 tracking-tight underline decoration-indigo-500 decoration-4">Áreas & Departamentos</h2>
            </div>
            <MainChart data={data.by_area} />
          </section>

          <section className="bg-zinc-900 p-10 rounded-[3rem] text-white shadow-xl flex flex-col items-center">
            <h3 className="text-xs font-black uppercase tracking-[0.2em] text-zinc-500 mb-8">Clima Semântico</h3>
            <SentimentChart data={data.sentiment_analysis} />

            {data.sentiment_details && (
              <div className="mt-8 pt-8 border-t border-zinc-800 w-full space-y-6">
                <div>
                  <p className="text-[10px] font-black text-indigo-400 uppercase tracking-widest mb-4 text-center">Keywords Negativas</p>
                  <div className="flex flex-wrap justify-center gap-2">
                    {Object.entries(data.sentiment_details.top_negative_terms).map(([word, count]: any) => (
                      <span key={word} className="px-3 py-1 bg-rose-500/10 border border-rose-500/20 text-rose-400 rounded-lg text-[10px] font-bold uppercase">
                        {word} ({count}x)
                      </span>
                    ))}
                  </div>
                </div>
                <div className="space-y-3">
                  <p className="text-[10px] font-black text-zinc-500 uppercase tracking-widest text-center">Voz do Colaborador</p>
                  {data.sentiment_details.critical_quotes.map((quote: string, i: number) => (
                    <div key={i} className="bg-white/5 p-4 rounded-2xl italic text-[11px] text-zinc-400 border-l-2 border-rose-500 leading-relaxed">
                      "{quote}"
                    </div>
                  ))}
                </div>
              </div>
            )}
          </section>
        </div>

        <section className="space-y-6 no-print">
          <div className="flex items-center justify-between px-6">
            <h3 className="text-xs font-black uppercase tracking-[0.2em] text-zinc-400 italic">Feedbacks Detalhados</h3>
            <span className="text-[10px] font-black bg-white border border-zinc-200 text-zinc-400 px-4 py-2 rounded-full uppercase">
              {totalFeedbacks} Entradas
            </span>
          </div>

          <FeedbackTable data={feedbacks} isLoading={feedbacksLoading} onSelectFeedback={(fb) => setSelectedFeedback(fb)} />

          {totalPages > 1 && (
            <div className="flex items-center justify-center gap-4 pt-4">
              <button
                onClick={() => setCurrentPage(p => Math.max(1, p - 1))}
                disabled={currentPage === 1 || feedbacksLoading}
                className="px-4 py-2 text-xs font-bold uppercase tracking-widest bg-white border border-zinc-200 rounded-full disabled:opacity-50 hover:bg-zinc-50 transition-colors"
              >
                Anterior
              </button>
              <span className="text-xs font-black text-zinc-400">
                Página {currentPage} de {totalPages}
              </span>
              <button
                onClick={() => setCurrentPage(p => Math.min(totalPages, p + 1))}
                disabled={currentPage === totalPages || feedbacksLoading}
                className="px-4 py-2 text-xs font-bold uppercase tracking-widest bg-white border border-zinc-200 rounded-full disabled:opacity-50 hover:bg-zinc-50 transition-colors"
              >
                Próxima
              </button>
            </div>
          )}
        </section>

        {selectedFeedback && <FeedbackDetailsModal feedback={selectedFeedback} onClose={() => setSelectedFeedback(null)} />}
      </div>

      <style jsx global>{`
        @media print {
          .no-print, button, nav { display: none !important; }
          body { background-color: white !important; }
          main { padding: 0 !important; }
          .max-w-7xl { max-width: 100% !important; }
          section { page-break-inside: avoid; margin-bottom: 2rem; }
          * { -webkit-print-color-adjust: exact !important; print-color-adjust: exact !important; }
        }
      `}</style>
    </main>
  );
}

function EDACard({ label, value, description, icon }: any) {
  return (
    <div className="bg-white border border-zinc-100 p-8 rounded-[2.5rem] shadow-sm flex items-center justify-between group hover:border-indigo-200 transition-colors">
      <div>
        <p className="text-[10px] font-black text-zinc-400 uppercase tracking-widest mb-1">{label}</p>
        <p className="text-4xl font-black text-zinc-900 tracking-tighter">{value || '0'}</p>
        <p className="text-[10px] text-zinc-400 font-medium mt-2 italic">{description}</p>
      </div>
      <div className="text-3xl font-black text-zinc-100 group-hover:text-indigo-50">{icon}</div>
    </div>
  );
}

function StatusBadge({ status }: { status: string }) {
  const config: any = {
    processing: { label: 'Processando', class: 'bg-amber-100 text-amber-700 animate-pulse' },
    completed: { label: 'Concluído', class: 'bg-emerald-100 text-emerald-700' },
    failed: { label: 'Erro', class: 'bg-rose-100 text-rose-700' }
  };
  const current = config[status] || config.processing;
  return (
    <span className={`px-3 py-1 rounded-full text-[10px] font-black uppercase tracking-tighter ${current.class}`}>
      {current.label}
    </span>
  );
}
