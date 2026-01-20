'use client'
import { useEffect, useState } from 'react'
import { 
  BarChart, Bar, XAxis, YAxis, CartesianGrid, 
  PieChart, Pie, Cell, ResponsiveContainer, 
  Tooltip, Legend 
} from 'recharts'
import { Users, TrendingUp, Activity, AlertTriangle, CheckCircle } from 'lucide-react'

export default function Dashboard() {
  const [data, setData] = useState<any>(null)

  useEffect(() => {
    fetch('http://localhost:3000/api/v1/dashboard')
      .then(res => res.json())
      .then(json => setData(json))
      .catch(err => console.error("Erro ao carregar dados:", err))
  }, [])

  if (!data) return (
    <div className="flex items-center justify-center min-h-screen bg-gray-50">
      <div className="text-center">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto mb-4"></div>
        <p className="text-gray-500 font-medium">Carregando Analytics...</p>
      </div>
    </div>
  )

  const eNPSData = [
    { name: 'Promotores', value: data.summary.promoters_count },
    { name: 'Detratores', value: data.summary.detractors_count },
    { name: 'Passivos', value: data.summary.total_responses - (data.summary.promoters_count + data.summary.detractors_count) }
  ]

  const COLORS = ['#10b981', '#ef4444', '#f59e0b']

  return (
    <div className="p-8 bg-gray-50 min-h-screen font-sans">
      <header className="mb-10">
        <h1 className="text-3xl font-extrabold text-gray-900 tracking-tight">People Analytics Dashboard</h1>
        <p className="text-gray-600 mt-2">Análise de engajamento e clima organizacional</p>
      </header>
      
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-10">
        <StatCard title="Total Respostas" value={data.summary.total_responses} icon={<Users />} color="blue" />
        <StatCard title="eNPS Score" value={data.summary.enps_score} icon={<TrendingUp />} color="purple" />
        <StatCard title="Favorabilidade" value={`${data.summary.favorability}%`} icon={<CheckCircle />} color="green" />
        <StatCard title="Áreas Ativas" value={Object.keys(data.by_area).length} icon={<Activity />} color="orange" />
      </div>

      {Object.keys(data.alerts).length > 0 && (
        <div className="mb-10 p-6 bg-red-50 border-l-4 border-red-500 rounded-r-2xl shadow-sm">
          <div className="flex items-center gap-3 mb-2">
            <AlertTriangle className="text-red-600" />
            <h3 className="text-red-800 font-bold uppercase text-sm tracking-wider">Atenção Necessária</h3>
          </div>
          <p className="text-red-700 text-sm mb-3">As seguintes áreas apresentam eNPS abaixo da média crítica:</p>
          <div className="flex flex-wrap gap-2">
            {Object.entries(data.alerts).map(([area, score]: any) => (
              <span key={area} className="px-3 py-1 bg-white border border-red-200 rounded-full text-xs font-bold text-red-600 shadow-sm">
                {area}: {score.toFixed(1)}
              </span>
            ))}
          </div>
        </div>
      )}

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        <ChartContainer title="Distribuição de Lealdade (eNPS)">
          <ResponsiveContainer width="100%" height="100%">
            <PieChart>
              <Pie data={eNPSData} innerRadius={70} outerRadius={90} paddingAngle={8} dataKey="value">
                {eNPSData.map((_, index) => <Cell key={`cell-${index}`} fill={COLORS[index]} />)}
              </Pie>
              <Tooltip />
              <Legend verticalAlign="bottom" height={36}/>
            </PieChart>
          </ResponsiveContainer>
        </ChartContainer>

        <ChartContainer title="Favorabilidade Média por Área">
          <ResponsiveContainer width="100%" height="100%">
            <BarChart data={Object.entries(data.by_area).map(([name, score]) => ({ name, score: Number(score).toFixed(2) }))}>
              <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f0f0f0" />
              <XAxis dataKey="name" fontSize={10} tick={{fill: '#9ca3af'}} axisLine={false} tickLine={false} />
              <YAxis domain={[0, 5]} fontSize={10} tick={{fill: '#9ca3af'}} axisLine={false} tickLine={false} />
              <Tooltip cursor={{fill: '#f9fafb'}} />
              <Bar dataKey="score" fill="#6366f1" radius={[6, 6, 0, 0]} barSize={40} />
            </BarChart>
          </ResponsiveContainer>
        </ChartContainer>
      </div>
    </div>
  )
}

function StatCard({ title, value, icon, color }: any) {
  const colors: any = {
    blue: "bg-blue-50 text-blue-600",
    purple: "bg-purple-50 text-purple-600",
    green: "bg-green-50 text-green-600",
    orange: "bg-orange-50 text-orange-600"
  }
  return (
    <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-100 flex items-center gap-5 hover:shadow-md transition-shadow">
      <div className={`p-4 rounded-2xl ${colors[color]}`}>{icon}</div>
      <div>
        <p className="text-xs font-bold text-gray-400 uppercase tracking-widest mb-1">{title}</p>
        <p className="text-2xl font-black text-gray-900">{value}</p>
      </div>
    </div>
  )
}

function ChartContainer({ title, children }: any) {
  return (
    <div className="bg-white p-8 rounded-3xl shadow-sm border border-gray-100">
      <h2 className="text-lg font-bold text-gray-800 mb-6 flex items-center gap-2">
        <div className="w-1 h-5 bg-indigo-500 rounded-full"></div>
        {title}
      </h2>
      <div className="h-[300px] w-full">{children}</div>
    </div>
  )
}