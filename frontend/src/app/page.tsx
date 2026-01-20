'use client'
import { useEffect, useState } from 'react'
import { Users, TrendingUp, Activity, MessageSquare } from 'lucide-react'
import { api } from '@/services/api'
import { DashboardData } from '@/types/dashboard'
import StatCard from '@/components/StatCard'
import EnpsChart from '@/components/EnpsChart'
import SentimentChart from '@/components/SentimentChart'

export default function Dashboard() {
  const [data, setData] = useState<DashboardData | null>(null)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    api.getDashboard()
      .then(setData)
      .catch(err => setError(err.message))
  }, [])

  if (error) return <div className="p-20 text-center text-red-500 font-bold font-sans">Erro: {error}</div>
  if (!data) return <div className="p-20 text-center font-sans text-gray-400 animate-pulse">Carregando métricas...</div>

  return (
    <div className="p-8 bg-gray-50 min-h-screen font-sans">
      <div className="max-w-7xl mx-auto">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-10">
          <StatCard 
            title="Total Respostas" 
            value={data.summary.total_responses} 
            icon={<Users size={20}/>} 
            color="blue" 
          />
          <StatCard 
            title="eNPS Score" 
            value={data.summary.enps_score} 
            icon={<TrendingUp size={20}/>} 
            color="purple" 
          />
          <StatCard 
            title="Áreas Ativas" 
            value={Object.keys(data.by_area).length} 
            icon={<Activity size={20}/>} 
            color="green" 
          />
          <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-100 flex items-center gap-4">
            <div className="p-4 rounded-xl bg-orange-50 text-orange-600">
              <MessageSquare size={20} />
            </div>
            <div>
              <p className="text-sm font-medium text-gray-500 uppercase tracking-wider">Humor Geral</p>
              <p className="text-2xl font-bold text-gray-900">
                {data.sentiment_analysis?.positive > data.sentiment_analysis?.negative ? 'Positivo' : 'Alerta'}
              </p>
            </div>
          </div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
          <EnpsChart data={{
            promoters_count: data.summary.promoters_count,
            detractors_count: data.summary.detractors_count,
            total_responses: data.summary.total_responses
          }} />

          {data.sentiment_analysis && (
            <SentimentChart data={data.sentiment_analysis} />
          )}
        </div>
      </div>
    </div>
  )
}