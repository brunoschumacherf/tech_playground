'use client';

import { EmployeeFeedback } from '@/types';

interface FeedbackDetailsModalProps {
  feedback: EmployeeFeedback;
  onClose: () => void;
}

export function FeedbackDetailsModal({ feedback, onClose }: FeedbackDetailsModalProps) {
  if (!feedback) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-zinc-900/80 backdrop-blur-md animate-in fade-in duration-300">
      <div className="bg-white w-full max-w-4xl max-h-[90vh] overflow-y-auto rounded-[3.5rem] shadow-2xl border border-zinc-100">
        
        <div className="sticky top-0 bg-white/90 backdrop-blur-md px-12 py-10 border-b border-zinc-100 flex justify-between items-center z-10">
          <div>
            <div className="flex items-center gap-3 mb-2">
              <span className="bg-indigo-600 text-white px-4 py-1.5 rounded-full text-[10px] font-black uppercase tracking-widest">
                {feedback.area}
              </span>
              <span className="bg-zinc-100 text-zinc-500 px-3 py-1.5 rounded-full text-[10px] font-black uppercase tracking-widest">
                {feedback.funcao}
              </span>
              <span className="text-zinc-300 text-xs font-medium">#{feedback.id}</span>
            </div>
            <h2 className="text-4xl font-black text-zinc-900 leading-none tracking-tighter uppercase italic">{feedback.nome}</h2>
            <p className="text-zinc-500 font-bold mt-1 uppercase text-xs tracking-tight">{feedback.email} • {feedback.cargo}</p>
          </div>
          <button onClick={onClose} className="p-5 hover:bg-zinc-100 rounded-full transition-all active:scale-90 bg-zinc-50 shadow-inner">
            <svg className="w-6 h-6 text-zinc-900" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="3" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>

        <div className="p-12 space-y-12">
          <div className="grid grid-cols-2 md:grid-cols-2 gap-4">
            <MetricCard label="eNPS (Lealdade)" value={feedback.enps} color={feedback.enps >= 9 ? "text-emerald-500" : feedback.enps <= 6 ? "text-rose-500" : "text-amber-500"} />
            <MetricCard label="Satisfação Geral" value={`${feedback.feedback}/5`} color="text-indigo-600" />
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-12">
            <section className="space-y-6">
              <h3 className="text-[10px] font-black uppercase tracking-[0.3em] text-zinc-400 border-l-4 border-indigo-500 pl-4">Perfil do Colaborador</h3>
              <div className="space-y-2 bg-zinc-50 p-6 rounded-[2rem]">
                <InfoRow label="Tempo de Casa" value={feedback.tempo_de_empresa} />
                <InfoRow label="Geração" value={feedback.geracao} />
                <InfoRow label="Gênero" value={feedback.genero} />
                <InfoRow label="Data Resposta" value={feedback.data_da_resposta} />
              </div>
            </section>

            <section className="space-y-6">
              <h3 className="text-[10px] font-black uppercase tracking-[0.3em] text-zinc-400 border-l-4 border-emerald-500 pl-4">Percepções Abertas</h3>
              <div className="space-y-6">
                <CommentBlock label="Justificativa eNPS" content={feedback.enps_aberta} />
                <CommentBlock label="Feedback Geral" content={feedback.comentarios_feedback} />
              </div>
            </section>
          </div>
        </div>

        <div className="p-10 bg-zinc-50 border-t border-zinc-100 flex justify-center">
          <div className="text-[10px] text-zinc-300 font-black tracking-[0.5em] uppercase">
            Data Analytics Tech Playground System
          </div>
        </div>
      </div>
    </div>
  );
}

function MetricCard({ label, value, color }: any) {
  return (
    <div className="bg-zinc-50 border border-zinc-100 p-8 rounded-[2.5rem] text-center shadow-sm">
      <p className="text-[10px] font-black text-zinc-400 uppercase tracking-widest mb-3 italic">{label}</p>
      <p className={`text-6xl font-black tracking-tighter ${color}`}>{value || '0'}</p>
    </div>
  );
}

function InfoRow({ label, value }: { label: string, value: string }) {
  return (
    <div className="flex justify-between items-center py-3 border-b border-zinc-200/50 last:border-0">
      <span className="text-xs font-bold text-zinc-400 uppercase tracking-tight">{label}</span>
      <span className="text-xs font-black text-zinc-800 uppercase">{value || 'N/A'}</span>
    </div>
  );
}

function CommentBlock({ label, content }: { label: string, content: string }) {
  return (
    <div className="bg-white border border-zinc-100 p-8 rounded-[2.5rem] shadow-sm relative overflow-hidden group">
      <div className="absolute top-0 left-0 w-1 h-full bg-indigo-100 group-hover:bg-indigo-500 transition-colors" />
      <p className="text-[10px] font-black text-indigo-500 uppercase mb-4 tracking-widest">{label}</p>
      <p className="text-sm text-zinc-600 font-bold italic leading-relaxed">
        {content && content !== '-' ? `"${content}"` : "O colaborador não registrou comentário para esta pergunta."}
      </p>
    </div>
  );
}