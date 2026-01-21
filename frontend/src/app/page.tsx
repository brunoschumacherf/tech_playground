'use client';

import { useEffect, useState, useCallback } from 'react';
import { apiService } from '@/lib/api';
import { ImportFile } from '@/types';
import { ImportList } from '@/components/imports/ImportList';
import { FileUpload } from '@/components/shared/FileUpload';

export default function Home() {
  const [imports, setImports] = useState<ImportFile[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const [currentPage, setCurrentPage] = useState<number>(1);
  const [totalPages, setTotalPages] = useState<number>(1);
  const [searchQuery, setSearchQuery] = useState<string>('');

  const loadDatasets = useCallback(async (page: number, query: string) => {
    setLoading(true);
    try {
      const response = await apiService.getImports(page, query);

      if (response.data && response.data.data) {
        setImports(response.data.data);
        setTotalPages(response.data.meta.total_pages);
      } else {
        setImports([]);
        setTotalPages(1);
      }
    } catch (error) {
      console.error("Erro ao carregar datasets do Rails:", error);
      setImports([]);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    const timeoutId = setTimeout(() => {
      loadDatasets(currentPage, searchQuery);
    }, 500);
    return () => clearTimeout(timeoutId);
  }, [currentPage, searchQuery, loadDatasets]);

  return (
    <main className="min-h-screen bg-zinc-50 p-6 lg:p-20 font-sans">
      <div className="max-w-5xl mx-auto space-y-16">

        <header className="flex flex-col lg:flex-row lg:items-center justify-between gap-10">
          <div className="max-w-md">
            <h1 className="text-6xl font-black tracking-tighter text-zinc-900 leading-tight">
              Análise<span className="text-indigo-600">.</span>
            </h1>
            <p className="text-lg text-zinc-500 font-medium mt-4">
              Importe seus arquivos CSV de pesquisa de clima e visualize os insights em tempo real.
            </p>
          </div>

          <div className="w-full lg:w-[420px]">
            <FileUpload onUploadSuccess={() => loadDatasets(1, '')} />
          </div>
        </header>

        <section className="space-y-8">
          <div className="flex items-center justify-between border-b border-zinc-200 pb-4 px-2">
            <div className="flex items-center gap-3">
              <span className="w-2 h-2 bg-indigo-500 rounded-full animate-pulse" />
              <h2 className="text-xs font-black uppercase tracking-[0.3em] text-zinc-400">
                Datasets Disponíveis
              </h2>
            </div>
            {!loading && (
              <span className="text-[10px] font-black text-zinc-300 uppercase">
                {imports.length} Arquivo(s)
              </span>
            )}
          </div>

          {loading ? (
            <div className="flex flex-col items-center justify-center py-24 gap-4 bg-white rounded-[3rem] border border-zinc-100 shadow-sm">
              <div className="w-10 h-10 border-4 border-indigo-600 border-t-transparent rounded-full animate-spin" />
              <p className="text-[10px] font-black text-zinc-400 uppercase tracking-widest">
                Sincronizando com Backend...
              </p>
            </div>
          ) : (
            <div className="animate-in fade-in slide-in-from-bottom-4 duration-500">
              <div className="flex flex-col md:flex-row justify-between items-center gap-4 mb-6">
                <input
                  type="text"
                  placeholder="🔍 Buscar dataset por nome..."
                  className="w-full md:w-96 px-6 py-4 rounded-full border border-zinc-200 bg-white text-sm font-medium focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent transition-all shadow-sm"
                  value={searchQuery}
                  onChange={(e) => {
                    setSearchQuery(e.target.value);
                    setCurrentPage(1);
                  }}
                />



                <div className="flex items-center gap-4">
                  <button
                    onClick={() => setCurrentPage(p => Math.max(1, p - 1))}
                    disabled={currentPage === 1}
                    className="px-4 py-2 text-xs font-bold uppercase tracking-widest bg-white border border-zinc-200 rounded-full disabled:opacity-50 hover:bg-zinc-50 transition-colors"
                  >
                    Anterior
                  </button>
                  <span className="text-xs font-black text-zinc-400">
                    Página {currentPage} de {totalPages}
                  </span>
                  <button
                    onClick={() => setCurrentPage(p => Math.min(totalPages, p + 1))}
                    disabled={currentPage === totalPages}
                    className="px-4 py-2 text-xs font-bold uppercase tracking-widest bg-white border border-zinc-200 rounded-full disabled:opacity-50 hover:bg-zinc-50 transition-colors"
                  >
                    Próxima
                  </button>
                </div>
              </div>

              <ImportList items={imports} />
            </div>
          )}
        </section>

        <footer className="pt-10 flex justify-center">
          <p className="text-[10px] font-bold text-zinc-300 uppercase tracking-widest">
            Tech Playground
          </p>
        </footer>
      </div>
    </main>
  );
}