'use client';

import { useState, useRef } from 'react';
import { apiService } from '@/lib/api';

interface FileUploadProps {
  onUploadSuccess: () => void;
}

export function FileUpload({ onUploadSuccess }: FileUploadProps) {
  const [isUploading, setIsUploading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const handleFileChange = async (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (!file) return;

    if (!file.name.endsWith('.csv')) {
      setError('Por favor, selecione um arquivo CSV.');
      return;
    }

    setIsUploading(true);
    setError(null);

    try {
      await apiService.createImport(file);
      onUploadSuccess();
      if (fileInputRef.current) fileInputRef.current.value = '';
      alert('Arquivo importado com sucesso!');
    } catch (err: any) {
      console.error(err);
      setError(err.response?.data?.error || 'Erro ao enviar o arquivo para o servidor.');
    } finally {
      setIsUploading(false);
    }
  };

  return (
    <div className="w-full">
      <label 
        className={`
          relative flex flex-col items-center justify-center w-full h-32 
          border-2 border-dashed rounded-[2rem] cursor-pointer
          transition-all duration-300
          ${isUploading ? 'bg-zinc-50 border-indigo-300' : 'bg-white border-zinc-200 hover:border-indigo-400 hover:bg-zinc-50'}
        `}
      >
        <div className="flex flex-col items-center justify-center pt-5 pb-6">
          {isUploading ? (
            <div className="flex flex-col items-center gap-2">
              <div className="w-6 h-6 border-4 border-indigo-600 border-t-transparent rounded-full animate-spin" />
              <p className="text-sm font-bold text-indigo-600 uppercase tracking-tighter">Processando</p>
            </div>
          ) : (
            <>
              <p className="mb-1 text-sm text-zinc-900 font-black uppercase tracking-tighter">
                Clique para importar CSV
              </p>
            </>
          )}
        </div>
        
        <input 
          ref={fileInputRef}
          type="file" 
          className="hidden" 
          accept=".csv"
          onChange={handleFileChange}
          disabled={isUploading}
        />
      </label>
      
      {error && (
        <p className="mt-2 text-xs font-bold text-rose-500 text-center">{error}</p>
      )}
    </div>
  );
}