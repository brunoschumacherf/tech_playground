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

  const loadDatasets = useCallback(async (page: number = 1) => {
    setLoading(true);
    try {
      const response = await apiService.getImports(page);
      
      if (response.data && response.data.data) {
        setImports(response.data.data);
    } else {
        setImports([]);
      }
    } catch (error) {
      console.error("Erro ao carregar datasets do Rails:", error);
      setImports([]);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    loadDatasets(currentPage);
  }, [currentPage, loadDatasets]);

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
            <FileUpload onUploadSuccess={() => loadDatasets(1)} />
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