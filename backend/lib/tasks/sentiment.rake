namespace :analysis do
  desc "Analisa o sentimento dos comentários dos colaboradores"
  task process_comments: :environment do
    analyzer = Sentimental.new
    analyzer.load_defaults
    EmployeeFeedback.find_each do |feedback|
      text = feedback.enps_aberta
      next if text.blank?

      score = analyzer.sentiment text 
      
      puts "ID: #{feedback.id} | Sentimento: #{score} | Texto: #{text[0..50]}..."
    end
  end
end